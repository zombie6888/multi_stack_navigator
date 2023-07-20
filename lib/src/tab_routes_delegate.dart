import 'package:flutter/material.dart';

import 'app_router.dart';
import 'custom_route_delegate.dart';
import 'keep_alive_widget.dart';
import 'navigation_observer.dart';
import 'navigation_stack.dart';
import 'route_path.dart';
import 'route_utils.dart';
import 'tab_stack_builder.dart';
import 'transitions/platform_page_factory.dart';

// Builder for tabs. Provide way to
typedef TabPageBuilder = Widget Function(BuildContext context,
    Iterable<RoutePath> tabRoutes, TabBarView view, TabController controller);

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
class TabRoutesDelegate extends RouterDelegate<NavigationStack>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin
    implements CustomRouteDelegate {
  TabRoutesDelegate(List<RoutePath> routes, this.tabPageBuider, this.observer,
      RouteNotFoundPath routeNotFoundPath)
      : _routes = List.unmodifiable(routes),
        _routeNotFoundPath = routeNotFoundPath,
        _rootNavigatorKey = GlobalKey<NavigatorState>();

  /// Route for page, which will be desplayed when route not found
  ///
  final RouteNotFoundPath _routeNotFoundPath;

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
        .map(
          (route) => PlatformPageFactory.getPage(
              child: _createPage(route, rootRoute.navigatorKey)),
        )
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
  /// [_stack] could be updated either, by [pushNamed] function
  /// or by platform. For example if you come from deep link.
  ///
  /// - See [RouterDelegate.setNewRoutePath]
  ///
  @override
  Future<void> setNewRoutePath(NavigationStack configuration) async {
    _previousIndex = _fromDeepLink || _pageWasRedirected
        ? configuration.currentIndex
        : _stack.currentIndex;
    _stack = configuration;
    notifyListeners();
  }

  /// Push page to navigation stack [_stack]
  ///
  /// It will be called when you run
  ///   AppRouter.of(context).pushNamed('page');
  /// or
  ///   AppRouter.of(context).redirect('page');
  ///
  @override
  Future<void> pushNamed(String path, [bool isRedirect = false]) async {
    _fromDeepLink = false;
    _pageWasRedirected = isRedirect;
    final fullPath = path.startsWith('/') ? path : _getAbsolutePath(path);
    final utils = RouteParseUtils(fullPath, _routeNotFoundPath);

    final newStack = utils.pushRouteToStack(_routes, _stack);
    observer?.didPushRoute(newStack.currentLocation);

    if (isRedirect) {
      final redirectStack =
          utils.getRedirectStack(currentStack: _stack, targetStack: newStack);
      await setNewRoutePath(redirectStack);
      return;
    }

    await setNewRoutePath(newStack);
  }

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
        await setNewRoutePath(
            _stack.copyWith(routes: routes, currentLocation: targetRoute.path));
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
    final pages = routes.where((e) => e.children.isEmpty).map(
          (route) => PlatformPageFactory.getPage(child: _createPage(route)),
        );

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
  AppRouter _createPage(RoutePath route,
      [GlobalKey<NavigatorState>? navigatorKey]) {
    return AppRouter(
        navigatorKey: navigatorKey ?? _rootNavigatorKey,
        routePath: route,
        routerDelegate: this,
        child: Builder(builder: (context) {
          return route.widget ?? route.builder?.call(context) ?? Container();
        }));
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
    //final utils = RouteParseUtils(path);
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
