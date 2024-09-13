import 'package:flutter/widgets.dart';

import 'custom_route_delegate.dart';
import 'navigation_observer.dart';
import 'route_path.dart';

class AppRouter extends InheritedWidget {
  const AppRouter({
    super.key,
    required RoutePath routePath,
    required this.routerDelegate,
    this.navigatorKey,
    this.rootNavigatorKey,   
    RoutePath? parentPath,
    required super.child,
  })  : _routePath = routePath,
        _parentPath = parentPath;

  final RoutePath _routePath;
  final RoutePath? _parentPath;

  String get path => _routePath.path == '/' && _parentPath != null
      ? _parentPath!.path
      : _routePath.path;

  final GlobalKey<NavigatorState>? navigatorKey;
  final GlobalKey<NavigatorState>? rootNavigatorKey;
  final CustomRouteDelegate routerDelegate;

  Stream<LocationUpdateData>? get locationUpdates {
    if (routerDelegate.observer is LocationStreamController) {
      return (routerDelegate.observer as LocationStreamController).stream;
    }
    return null;
  }

  NavigationObserver? get observer => routerDelegate.observer;

  void navigate(String path, {Map<String, dynamic>? queryParameters}) {
    final routePath = _addQueryParameters(path, queryParameters);
    routerDelegate.navigate(routePath);
  }

  void replaceWith(String path, {Map<String, dynamic>? queryParameters}) {
    final routePath = _addQueryParameters(path, queryParameters);
    routerDelegate.replaceCurrentRoute(routePath);
  }

  void redirect(String path, {Map<String, dynamic>? queryParameters}) {
    final routePath = _addQueryParameters(path, queryParameters);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      routerDelegate.navigate(routePath, true);
    });
  }

  void pop() {
    final navigator = navigatorKey?.currentState;
    assert(navigator != null, 'No navigator found');
    navigator?.pop();
  }

  static AppRouter? maybeOf(BuildContext context, [bool listen = false]) {
    if (listen == true) {
      return context.dependOnInheritedWidgetOfExactType<AppRouter>();
    } else {
      return context.getInheritedWidgetOfExactType<AppRouter>();
    }
  }

  static AppRouter of(BuildContext context, [bool listen = false]) {
    final AppRouter? result = maybeOf(context, listen);
    assert(result != null, 'No router found in context');
    return result!;
  }

  T? queryParameter<T>(String key) {
    final params = _routePath.queryParams;
    if (params == null) {
      return null;
    }
    final value = params[key];
    switch (T) {
      case int:
        return value != null ? int.tryParse(value) as T : null;
      case String:
      default:
        return value is T ? value as T : null;
    }
  }

  String _addQueryParameters(
      String path, Map<String, dynamic>? queryParameters) {
    if (queryParameters != null) {
      final uri = Uri.parse(path);
      Map<String, String> stringQueryParameters =
          queryParameters.map((key, value) => MapEntry(key, value!.toString()));
      final fullUri = uri.replace(
          queryParameters: {...uri.queryParameters, ...stringQueryParameters});
      return fullUri.toString();
    }
    return path;
  }

  @override
  bool updateShouldNotify(AppRouter oldWidget) =>
      oldWidget._routePath != _routePath;
}
