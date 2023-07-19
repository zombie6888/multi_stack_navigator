import 'package:flutter/material.dart';
import 'navigation_stack.dart';
import 'route_path.dart';
import 'route_utils.dart';

/// Custom route infromation parser.
///
/// This class is using to convert [RouteInformation] to [NavigationStack], and
/// get back [NavigationStack] from [RouteInformation].
///
/// - See [RouteInformationParser]
///
class CustomRouteInformationParser
    extends RouteInformationParser<NavigationStack> {
  final List<RoutePath> _routes;
  final RouteNotFoundPath _routeNotFoundPath;
  CustomRouteInformationParser(
      NavigationStack stack, RouteNotFoundPath routeNotFoundPath)
      : _routes = stack.routes,
        _routeNotFoundPath = routeNotFoundPath;

  /// Inform router about platfrom updates.
  ///
  /// Takes [RouteInformation] from platform and returns
  /// updated [NavigationStack].
  ///
  @override
  Future<NavigationStack> parseRouteInformation(
      RouteInformation routeInformation) async {
    return RouteParseUtils(routeInformation.location, _routeNotFoundPath)
        .restoreRouteStack(_routes);
  }

  /// Inform platform about route configuration updates.
  ///
  /// Takes [NavigationStack] from router and pass updated [RouteInformation]
  /// to platform.
  ///
  @override
  RouteInformation? restoreRouteInformation(NavigationStack configuration) {
    final RoutePath? activeRoute =
        configuration.routes.isNotEmpty ? configuration.routes.last : null;
    final isBranchRoute = activeRoute?.children.isNotEmpty ?? true;
    if (!isBranchRoute && activeRoute != null) {
      return RouteInformation(
          location: '${activeRoute.path}${activeRoute.queryString}');
    }
    final route = configuration.getCurrentTabRoute();
    final children = route?.children ?? [];
    final path = route?.path ?? '';
    final nestedRoute = children.isNotEmpty ? children.last : null;
    final nestedPath = nestedRoute?.path ?? '';
    final query = nestedRoute?.queryString ?? '';
    if (nestedPath == '/') {
      return RouteInformation(location: '$path$query');
    } else {
      return RouteInformation(location: '$path$nestedPath$query');
    }
  }
}
