import 'package:flutter/widgets.dart';

import 'app_back_button_dispatcher.dart';
import 'custom_route_information_parser.dart';
import 'custom_route_information_provider.dart';
import 'navigation_observer.dart';
import 'navigation_stack.dart';
import 'route_path.dart';
import 'tab_routes_delegate.dart';

/// Two-level navigation config for tabs.
///
/// Accepts pre-defined stack of [routes]
///
/// The[routeNotFoundPath] route will be displayed,
/// when routepath not found.
///
/// The [builder] is using for building tab page.
/// The [observer] is using to observe route updates.
///
class TabRoutesConfig extends RouterConfig<NavigationStack> {
  factory TabRoutesConfig.create(
      {required List<RoutePath> routes,
      RouteNotFoundPath? routeNotFoundPath,
      required TabPageBuilder builder,
      NavigationObserver? observer}) {
    final routeNotFound = routeNotFoundPath ?? RouteNotFoundPath();
    final delegate =
        TabRoutesDelegate(routes, builder, observer, routeNotFound);
    return TabRoutesConfig(
        routes: routes, delegate: delegate, routeNotFoundPath: routeNotFound);
  }

  TabRoutesConfig({
    required List<RoutePath> routes,
    required TabRoutesDelegate delegate,
    required RouteNotFoundPath routeNotFoundPath,
  }) : super(
            backButtonDispatcher:
                AppBackButtonDispatcher(routerDelegate: delegate),
            routeInformationParser: CustomRouteInformationParser(
                NavigationStack(routes), routeNotFoundPath),
            routerDelegate: delegate,
            routeInformationProvider: CustomRouteInformationProvider());  
}
