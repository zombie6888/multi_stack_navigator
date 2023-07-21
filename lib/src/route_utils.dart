import 'dart:math';

import 'package:collection/collection.dart';
import 'navigation_stack.dart';
import 'route_path.dart';

/// Utility class, which is using to parse route path to navigation stack
///
class RouteParseUtils {
  /// Target uri
  ///
  late Uri _uri;

  /// Default route, when target route not found
  ///
  late RouteNotFoundPath _routeNotFoundPath;
  RouteParseUtils(String? path, [RouteNotFoundPath? routeNotFoundPath]) {
    assert(path != null, 'not a valid path!');
    _uri = Uri.tryParse(path!) ?? Uri();
    _routeNotFoundPath = routeNotFoundPath ?? RouteNotFoundPath();
  }

  String? get path => _uri.path;

  Map<String, String> get queryParams => _uri.queryParameters;

  String? get parentPath =>
      _uri.pathSegments.length > 1 ? '/${_uri.pathSegments[0]}' : null;

  /// Creates configuration [NavigationStack]
  ///
  /// Takes [routes], passed by [RouteInformationParser],
  /// and return updated navigation stack according to the target [_uri.path].
  ///
  /// Called by platform, Deep links will be parsed here.
  ///
  NavigationStack restoreNavigationStack(List<RoutePath> routes) {
    assert(routes.isNotEmpty, 'route config should be not empty');

    final branchRoutes = routes.where((c) => c.children.isNotEmpty).toList();
    final rootRoutes = routes.where((c) => c.children.isEmpty).toList();

    List<RoutePath> rootStack = [];
    int currentIndex = 0;

    final rootRoute = rootRoutes
        .firstWhereOrNull((c) => c.path == _uri.path)
        ?.copyWith(queryParams: _uri.queryParameters);

    // stack from nested uri
    if (parentPath != null) {
      for (var i = 0; i < branchRoutes.length; i++) {
        var route = branchRoutes[i];
        final children = _createChildStack(route.children);
        if (route.path.startsWith(parentPath ?? '')) {
          final nestedPath = getNestedPath(_uri.path);
          final childRoute =
              route.children.firstWhereOrNull((c) => c.path == nestedPath);
          if (childRoute != null) {
            final childRouteIndex = route.children.indexOf(childRoute);
            if (childRouteIndex > 0) {
              children
                  .add(childRoute.copyWith(queryParams: _uri.queryParameters));
            }
          }
          currentIndex = i;
        }
        route = route.copyWith(children: children);
        rootStack.add(route);
      }

      final stack = rootRoute == null ? rootStack : [...rootStack, rootRoute];
      // nested route
      return NavigationStack(stack,
          currentIndex: currentIndex, currentLocation: _uri.path);
    }

    // root stack
    if (branchRoutes.isNotEmpty) {
      final branchStack = _createParentStack(branchRoutes);

      final currentBranch = branchStack[currentIndex];
      final children = [...currentBranch.children];
      if (children.isNotEmpty) {
        children.first =
            children.first.copyWith(queryParams: _uri.queryParameters);
      }
      branchStack[currentIndex] = currentBranch.copyWith(children: children);

      if (rootRoute == null) {
        if (_uri.path == '/' || _uri.path == branchStack[currentIndex].path) {
          // default route
          final location =
              _uri.path == '/' ? '/' : branchStack[currentIndex].path;
          return NavigationStack(branchStack,
              currentIndex: currentIndex, currentLocation: location);
        } else {
          // route not found
          return NavigationStack([...branchStack, _routeNotFoundPath],
              currentIndex: currentIndex,
              currentLocation: _routeNotFoundPath.path);
        }
      } else {
        // single page route(not a tab)
        return NavigationStack([...branchStack, rootRoute],
            currentIndex: currentIndex, currentLocation: _uri.path);
      }
    }

    // route not found
    return NavigationStack([_routeNotFoundPath],
        currentLocation: _routeNotFoundPath.path);
  }

  /// Returns updated configaration [NavigationStack]
  ///
  /// Takes [routeList] and current [stack] from [RouterDelegate]
  /// and return updated navigation stack according to the target [_uri.path].
  ///
  /// Called by [CustomRouteDelegate.navigate].
  ///
  NavigationStack updateNavigationStack(
      List<RoutePath> routeList, NavigationStack stack) {
    final rootRoute = routeList.firstWhereOrNull((e) => e.path == _uri.path);
    final routes = stack.routes;

    // add route to root stack
    if (rootRoute != null && rootRoute.children.isEmpty) {
      final rootStack =
          _updateStack(routeList: routeList, stack: routes, isRootStack: true);

      return stack.copyWith(
          routes: rootStack, currentLocation: rootStack.last.path);
    }

    // add route to nested stack
    if (parentPath != null) {
      final targetRoute = routes.firstWhereOrNull((e) => e.path == parentPath);
      if (targetRoute != null) {
        final index = routes.indexOf(targetRoute);
        final updatedNestedStack =
            _updateStack(routeList: routeList, stack: targetRoute.children);

        final targetStack = [...routes.where((r) => r.children.isNotEmpty)];
        targetStack[index] =
            targetStack[index].copyWith(children: updatedNestedStack);
        return NavigationStack(targetStack,
            currentIndex: index, currentLocation: _uri.path);
      }
    }

    return NavigationStack([...routes, _routeNotFoundPath],
        currentLocation: _routeNotFoundPath.path);
  }

  /// Returns routes with only first route in nested stack
  ///
  /// Fro example for routes:
  /// tab1
  ///   --page1
  ///   --page2
  ///   ...
  /// tab2
  ///   --page3
  ///   --page4
  ///   --page5
  ///   ...
  /// result is:
  /// tab1
  ///   --page1
  /// tab2
  ///   --page3
  List<RoutePath> _createParentStack(List<RoutePath> routes) {
    return [
      ...routes.map((route) =>
          route.copyWith(children: _createChildStack(route.children)))
    ];
  }

  /// Return routes with only first route in stack
  ///
  List<RoutePath> _createChildStack(List<RoutePath> routes) =>
      routes.isNotEmpty ? [routes.first] : [];

  /// Search route in [routeList] configuration
  ///
  static RoutePath? searchRoute(List<RoutePath> routeList, String path,
      [bool searchInRootRoutes = false]) {
    if (searchInRootRoutes) {
      return routeList.lastWhereOrNull((e) => e.path == path);
    }
    RoutePath? routePath;
    for (var route in routeList) {
      final result = route.children.lastWhereOrNull((e) => e.path == path);
      if (result != null) {
        routePath = result;
        break;
      }
    }
    return routePath;
  }

  /// Returns updated route list for nested routes depending on [_uri.path]
  /// and [_uri.queryParameters].
  ///
  /// If route was found in [stack] and it has the same query parameters,
  /// then crop stack (return stack, where route is last).
  ///
  /// If route was found but query parameters are different,
  /// then adds route to stack as a new route.
  ///
  /// If route wasn't found in [stack], it will try to search
  /// route in [routeList] and adds it to stack as a new route
  /// in case of success.
  ///
  /// For example for stack:
  ///   [page1, page2?q=1, page3]
  /// if you push: "page2?q=2",
  /// updated stack will be: [page1, page2?q=1, page3, page2?q=2],
  /// or if you push: "page2?q=1",
  /// updated stack will be: [page1, page2?q=1]
  ///
  List<RoutePath> _updateStack({
    required List<RoutePath> routeList,
    required List<RoutePath> stack,
    bool isRootStack = false,
  }) {
    final fullPath = _uri.path;
    final path = isRootStack ? fullPath : getNestedPath(fullPath);
    final currentRoute = stack.lastWhereOrNull((c) => c.path == path);
    if (currentRoute != null) {
      final targetRoute =
          currentRoute.copyWith(queryParams: _uri.queryParameters);
      if (currentRoute != targetRoute) {
        return [...stack, targetRoute];
      }
      return _cropStack(
        stack: stack,
        targetRoute: targetRoute,
      );
    } else {
      final route = searchRoute(routeList, path, isRootStack);
      return route != null
          ? [...stack, route.copyWith(queryParams: _uri.queryParameters)]
          : [...stack];
    }
  }

  /// Returns nested path for subroutes
  ///
  String getNestedPath(String path) {
    final nestedSegments = path.split('/').sublist(2);
    return nestedSegments.isNotEmpty ? '/${nestedSegments.join('/')}' : '';
  }

  /// Returns stack, where route is last
  ///
  List<RoutePath> _cropStack({
    required List<RoutePath> stack,
    required RoutePath targetRoute,
  }) {
    final index = stack.indexOf(targetRoute);
    final subRoutes = stack.sublist(0, min(index + 1, stack.length));
    subRoutes[index] =
        subRoutes[index].copyWith(queryParams: _uri.queryParameters);
    return subRoutes;
  }

  /// When pushed redirect route, we need to remove it from [targetStack]
  ///
  NavigationStack getRedirectStack({
    required NavigationStack currentStack,
    required NavigationStack targetStack,
  }) {
    final lastRoute = currentStack.routes.last;
    // redirect to root page
    if (lastRoute.children.isEmpty) {
      targetStack = targetStack.copyWith(
          routes: targetStack.routes
              .where((e) => e.path != currentStack.currentLocation)
              .toList());
    } else {
      // redirect to nested page of another parent route
      if (targetStack.currentIndex != currentStack.currentIndex) {
        final route = targetStack.routes[currentStack.currentIndex];
        final children = [...route.children];
        targetStack.routes[currentStack.currentIndex] =
            route.copyWith(children: children..removeLast());
      } else {
        // redirect to nested page of the same parent route
        final nestedPath = getNestedPath(currentStack.currentLocation);
        final parentRoute = targetStack.routes[targetStack.currentIndex];
        targetStack.routes[targetStack.currentIndex] = parentRoute.copyWith(
            children: parentRoute.children
                .where((e) => e.path != nestedPath)
                .toList());
      }
    }
    return targetStack;
  }
}
