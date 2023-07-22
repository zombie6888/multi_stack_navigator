import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_router.dart';
import 'custom_route_delegate.dart';
import 'keep_alive_widget.dart';
import 'navigation_observer.dart';
import 'navigation_stack.dart';
import 'route_path.dart';
import 'route_utils.dart';
import 'tab_stack_builder.dart';

// Builder for tabs. Provide way to
typedef TabPageBuilder = Widget Function(BuildContext context,
    Iterable<RoutePath> tabRoutes, TabBarView view, TabController controller);

typedef PageBuilder = Page<dynamic> Function(Widget child)?;    

/// Router delagate for tabs navigation.
///
/// This class handle [NavigationStack] updates
/// from predefined route configuration [routes] and uses [tabPageBuider]
/// for showing tab navigation pages.
///
/// It contains root [Navigator] and nested [Navigator] list.
///
/// When nested route requested it will push/pop pages
/// to nested navigator. When root route requested,
/// it will updates pages in root navigator.
///
/// It supports only two-level navigation,
/// - see [RoutePath]
///
class TabRouterDelegate extends RouterDelegate<NavigationStack>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin
    implements CustomRouteDelegate {
  TabRouterDelegate(
      {required List<RoutePath> routes,
      required this.tabPageBuider,
      this.observer,
      PageBuilder defaultpageBuilder,
      required RouteNotFoundPath routeNotFoundPath})
      : _routes = List.unmodifiable(routes),
        _routeNotFoundPath = routeNotFoundPath,
        _defaultPageBuilder = defaultpageBuilder,
        _rootNavigatorKey = GlobalKey<NavigatorState>();

  /// Route for page, which will be desplayed when route not found
  ///
  final RouteNotFoundPath _routeNotFoundPath;

  /// Page builder for routepath
  ///
  final PageBuilder _defaultPageBuilder;

  /// Observes navigation events
  ///
  @override
  final NavigationObserver? observer;

  /// Widget builder for tabs page. Mostly scaffold with bootomTabBar.
  ///
  final TabPageBuilder tabPageBuider;

  /// Uses for root navigator access
  ///
  final GlobalKey<NavigatorState> _rootNavigatorKey;

  /// [NavigationStack] keeps all data which is neccessary for [currentConfiguration].
  ///
  /// As opposite to [_routes], we can modify [_stack.routes] list.
  ///
  NavigationStack _stack = NavigationStack([]);

  /// Route configaration which could be passed to [TabRoutesConfig]
  ///
  /// This contains predefined routes, that shouldn't be changed.
  ///
  /// Route parse utilities will pick routes from [_routes] list and update
  /// [NavigationStack] accordingly.
  ///
  /// As opposite to [_stack.routes], this list is unmodifiable.
  ///
  final List<RoutePath> _routes;

  /// Whether page was opened from deep link
  bool _fromDeepLink = true;

  /// Whether page was opened by redirect function from another page
  bool _pageWasRedirected = true;

  /// Index of previous opened tab
  int _previousIndex = 0;

  /// Returns pages wrapped with nested [Navigator]
  Widget getNestedNavigator(int index, BuildContext context) {
    final rootRoute = _stack.routes[index];
    final nestedPages = rootRoute.children
        .map((route) => _createPage(route, rootRoute.navigatorKey))
        .toList();

    if (nestedPages.isEmpty) {
      return _routeNotFoundPath.builder?.call(context) ??
          _routeNotFoundPath.widget ??
          Container();
    }

    return Navigator(
        key: _stack.routes[index].navigatorKey,
        pages: nestedPages,
        onGenerateRoute: (settings) =>
            MaterialPageRoute(builder: (_) => Container()),
        onUnknownRoute: (settings) =>
            MaterialPageRoute(builder: (_) => Container()),
        onPopPage: _onPopNestedPage);
  }

  /// See [RouterDelegate.navigatorKey]
  @override
  GlobalKey<NavigatorState>? get navigatorKey => GlobalKey();

  /// Current navigation config.
  @override
  NavigationStack? get currentConfiguration => _stack;

  /// This will update navigation configration.
  ///
  /// [_stack] could be updated either, by [navigate] function
  /// or by platform. For example if you come from deep link.
  ///
  /// - See [RouterDelegate.setNewRoutePath]
  ///
  @override
  SynchronousFuture<void> setNewRoutePath(NavigationStack configuration) {
    _previousIndex = _fromDeepLink || _pageWasRedirected
        ? configuration.currentIndex
        : _stack.currentIndex;
    _stack = configuration;
    notifyListeners();
    return SynchronousFuture<void>(null);
  }

  /// Push page to navigation stack [_stack]
  ///
  /// It will be called when you run
  ///   AppRouter.of(context).navigate('page');
  /// or
  ///   AppRouter.of(context).redirect('page');
  ///
  @override
  void navigate(String path, [bool isRedirect = false]) {
    _fromDeepLink = false;
    _pageWasRedirected = isRedirect;
    final fullPath = path.startsWith('/') ? path : _getAbsolutePath(path);
    final utils = RouteParseUtils(fullPath, _routeNotFoundPath);

    final newStack = utils.updateNavigationStack(_routes, _stack);
    observer?.didPushRoute(newStack.currentLocation);

    if (isRedirect) {
      final redirectStack =
          utils.getRedirectStack(currentStack: _stack, targetStack: newStack);
      setNewRoutePath(redirectStack);
      return;
    }

    setNewRoutePath(newStack);
  }

  /// Hardware back button default handler
  ///
  /// It will pop single or tab nested page. If current active route
  /// is a tab nested page, nested navigator pop method will be called,
  /// for a single page it calls [_rootNavigatorKey.currentState.pop].
  ///
  /// If current route is a tab root page route it will switch to previous tab,
  /// until initial tab will be reached. From root page of initial tab it will
  /// close the entire application.
  ///
  /// If return value is false, it will pass control to system and app will be
  /// closed in most of cases.
  /// - see [RouterDelegate.popRoute]
  ///
  /// This behaviour can be overrided by [BackButtonListener]
  /// or [HardwareBackHandler].
  ///
  /// When [BackButtonListener] state disposed, this callback will continue
  /// to handle back behavior. The state of any nested page will only be
  /// disposed, when navigator pop event occurs. It will cause listener
  /// to continue handle back behavior, even if page is not active (active tab
  /// index was changed or another nested page was pushed). In order to prevent
  /// this case, consider to use [HardwareBackHandler], which is listening for
  /// navigation events and will pass controll back to this handler,
  /// if any of navigation event occurs.
  ///
  @override
  Future<bool> popRoute() {
    final branchRoutes =
        _stack.routes.where((r) => r.children.isNotEmpty).toList();

    if (branchRoutes.length == _stack.routes.length) {
      final nestedNavigator = branchRoutes[_stack.currentIndex].navigatorKey;
      if (nestedNavigator?.currentState?.canPop() ?? false) {
        // nested route pop
        nestedNavigator?.currentState?.pop();
      } else if (_stack.currentIndex > 0) {
        // switch tab
        _tabIndexUpdateHandler(_stack.currentIndex - 1);
      } else {
        // close app
        return SynchronousFuture(false);
      }
    } else {
      if (_rootNavigatorKey.currentState?.canPop() ?? false) {
        // root route pop
        _rootNavigatorKey.currentState?.pop();
      }
    }
    // do not close
    return SynchronousFuture(true);
  }

  /// Replace current active route with route of [targetLocation].
  ///
  @override
  Future<void> replaceCurrentRoute(String targetLocation) async {
    final utils = RouteParseUtils(targetLocation);
    final path = utils.path ?? '';
    final queryParams = utils.queryParams;
    final routes = [..._stack.routes];

    /// current page is nested
    if (routes.last.children.isNotEmpty) {
      final parentRoute = routes[_stack.currentIndex];
      final branchRoutes = _routes.where((r) => r.children.isNotEmpty).toList();
      final parentPath = utils.parentPath;
      final targetPath =
          parentPath != null ? path.replaceFirst(parentPath, '') : path;
      final targetRoute = RouteParseUtils.searchRoute(
          branchRoutes[_stack.currentIndex].children, targetPath, true);
      if (targetRoute != null) {
        final targetRoutes = [...parentRoute.children]..removeLast();
        routes[_stack.currentIndex] = parentRoute.copyWith(children: [
          ...targetRoutes,
          targetRoute.copyWith(queryParams: queryParams)
        ]);
        final parentLocation = _getParentLocation();
        final location = parentLocation != null
            ? '$parentLocation${targetRoute.path}'
            : targetRoute.path;
        await setNewRoutePath(
            _stack.copyWith(routes: routes, currentLocation: location));
      }
    } else {
      final targetRoute = RouteParseUtils.searchRoute(_routes, path, true);
      if (targetRoute != null) {
        await setNewRoutePath(_stack.copyWith(routes: [
          ...routes..removeLast(),
          targetRoute.copyWith(queryParams: queryParams)
        ], currentLocation: targetRoute.path));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: First build occurs before setNewRoutePath called.
    // Fix this behavior (if posssible) or replace  _routeNotFoundPath.
    // with splash screen. Ensure that deep links are working.
    final routes = _stack.routes.isEmpty ? [_routeNotFoundPath] : _stack.routes;
    final pages = routes
        .where((e) => e.children.isEmpty)
        .map((route) => _createPage(route));

    final tabRoutes = routes.where((e) => e.children.isNotEmpty);

    return Navigator(
        key: _rootNavigatorKey,
        pages: [
          if (tabRoutes.isNotEmpty)
            MaterialPage(
              child: TabStackBuilder(
                  index: _stack.currentIndex,
                  tabIndexUpdateHandler: _tabIndexUpdateHandler,
                  tabsLenght: tabRoutes.length,
                  builder: (context, controller) {
                    final view = TabBarView(
                      controller: controller,
                      children: [
                        for (var i = 0; i < tabRoutes.length; i++)
                          KeepAliveWidget(
                              key: ValueKey('tab_stack_${i.toString()}'),
                              child: getNestedNavigator(i, context)),
                      ],
                    );
                    return tabPageBuider(context, tabRoutes, view, controller);
                  }),
            ),
          ...pages
        ],
        onGenerateRoute: (settings) =>
            MaterialPageRoute(builder: (_) => Container()),
        onUnknownRoute: (settings) =>
            MaterialPageRoute(builder: (_) => Container()),
        onPopPage: (route, result) => _onPopRootPage(route, result, pages));
  }

  /// Update route configuration when active tab [index] is changing.
  ///
  /// This will update [currentLocation] and [index] of active tab route.
  ///
  void _tabIndexUpdateHandler(int index) {
    final location = _getRouteLocation(_stack.routes[index]);
    if (location != _stack.currentLocation) {
      observer?.didPushRoute(location);
    }
    _stack = _stack.copyWith(currentIndex: index, currentLocation: location);
    notifyListeners();
  }

  /// Wrap page with [AppRouter] inhertied witdget.
  ///
  /// [AppRouter.navigatorKey] field is using for nested Navigator access.
  /// [AppRouter.routerDelegate] field is using for [TabRoutesDelegate] access.
  /// [AppRouter.routePath] contains current route path.
  ///
  Page<dynamic> _createPage(RoutePath route,
      [GlobalKey<NavigatorState>? navigatorKey]) {
    final page = AppRouter(
        navigatorKey: navigatorKey ?? _rootNavigatorKey,
        routePath: route,
        routerDelegate: this,
        child: Builder(builder: (context) {
          return route.widget ?? route.builder?.call(context) ?? Container();
        }));
    if (route.pageBuilder != null) {
      return route.pageBuilder!(page);
    } else if (_defaultPageBuilder != null) {
      return _defaultPageBuilder!(page);
    } else {
      return MaterialPage(child: page);
    }
  }

  /// Calling when get back from nested page.
  ///
  /// It will remove a nested route from [_stack].
  ///
  bool _onPopNestedPage(Route<dynamic> route, dynamic result) {
    if (!route.didPop(result)) {
      return false;
    }

    final currentindex = _stack.currentIndex;

    // Remove last route from navigation stack.
    final rootPaths = [..._stack.routes];
    var currentStack = rootPaths[currentindex];
    final children = [...currentStack.children]..removeLast();
    rootPaths[currentindex] = currentStack.copyWith(children: children);
    _stack = _stack.copyWith(routes: rootPaths);

    // When pop route, which will pushed from another tab,
    // it will change active tab index to go back to previous tab.
    //
    // TODO: make it optional?
    if (!_fromDeepLink &&
        !_pageWasRedirected &&
        _previousIndex != currentindex) {
      _stack = _stack.copyWith(currentIndex: _previousIndex);
      //notifyListeners();
      //return true;
    }

    final location = _getRouteLocation(_stack.routes[_stack.currentIndex]);
    _stack.copyWith(currentLocation: location);
    observer?.didPopRoute(location);

    notifyListeners();
    return true;
  }

  /// Calling when get back from root page.
  ///
  /// It will remove a root route from navigation stack [_stack].
  ///
  bool _onPopRootPage(
      Route<dynamic> route, dynamic result, Iterable<Page<dynamic>> pages) {
    if (!route.didPop(result)) {
      return false;
    }

    final routes = _stack.routes;

    if (pages.isNotEmpty && routes.length > 1) {
      _stack = _stack.copyWith(routes: [...routes]..removeLast());

      final location = _getRouteLocation(_stack.routes[_stack.currentIndex]);
      _stack.copyWith(currentLocation: location);
      observer?.didPopRoute(location);

      notifyListeners();
      return true;
    }
    return true;
  }

  /// Returns location of active root or nested route
  String _getRouteLocation(RoutePath route) {
    final children = route.children;
    if (children.isNotEmpty) {
      return children.last.path != '/'
          ? '${route.path}${children.last.path}'
          : route.path;
    }
    return route.path;
  }

  /// Returns location of parent route
  ///
  /// if current location is:
  ///    /tab1
  ///      --/
  ///      --...
  /// result will be: /tab1.
  ///
  /// if current location is:
  ///    /tab1
  ///      --/page1
  ///      ...
  /// result will be the same: /tab1.
  ///
  /// if current location is:
  ///   /page1 (not a nested page opened)
  /// result will be null;
  ///
  String? _getParentLocation() {
    final location = _stack.currentLocation;
    final utils = RouteParseUtils(location);
    final route = RouteParseUtils.searchRoute(_routes, location, true);
    if ((route?.children ?? []).isNotEmpty) {
      return location;
    } else {
      return utils.parentPath;
    }
  }

  /// Convert route related path to absoulte path
  String? _getAbsolutePath(String path) {
    final parentPath = _getParentLocation();
    if (parentPath != null) {
      final branchRoutes = _routes.where((r) => r.children.isNotEmpty).toList();
      final targetRoute = RouteParseUtils.searchRoute(
          branchRoutes[_stack.currentIndex].children, '/$path', true);
      if (targetRoute != null) {
        return '$parentPath/$path';
      }
    }
    return '/$path';
  }
}
