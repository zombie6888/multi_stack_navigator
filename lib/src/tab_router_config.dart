import 'package:flutter/widgets.dart';

import 'custom_route_information_parser.dart';
import 'custom_route_information_provider.dart';
import 'navigation_observer.dart';
import 'navigation_stack.dart';
import 'route_path.dart';
import 'tab_router_delegate.dart';

/// Two-level navigation config for tabs.
///
/// Accepts pre-defined stack of [routes]
///
/// The[routeNotFoundPath] route will be displayed,
/// when routepath not found.
///
/// [backButtonDispatcher] handles hardware back button behavior
/// (mostly android hardware back button). By default it's a [RootBackButtonDispatcher],
///  which will call [TabRoutesDelegate.popRoute] callback, but can be replaced
///  with [BackButtonListener] callback.
/// - see [RootBackButtonDispatcher], [ChildBackButtonDispatcher],
/// [BackButtonListener]
///
/// The [builder] is using for building tab page.
/// The [observer] is using to observe route updates.
///
class TabRouterConfig extends RouterConfig<NavigationStack> {
  factory TabRouterConfig.create(
      {required List<RoutePath> routes,
      RouteNotFoundPath? routeNotFoundPath,
      BackButtonDispatcher? backButtonDispatcher,
      PageBuilder? defaultPageBuilder,
      required TabPageBuilder tabPageBuider,
      NavigationObserver? observer}) {
    final routeNotFound = routeNotFoundPath ?? RouteNotFoundPath();
    final delegate = TabRouterDelegate(
        routes: routes,
        defaultpageBuilder: defaultPageBuilder,
        tabPageBuider: tabPageBuider,
        observer: observer,
        routeNotFoundPath: routeNotFound);
    return TabRouterConfig(
        backButtonDispatcher:
            backButtonDispatcher ?? RootBackButtonDispatcher(),
        routes: routes,
        delegate: delegate,
        routeNotFoundPath: routeNotFound);
  }

  TabRouterConfig({
    required List<RoutePath> routes,
    required TabRouterDelegate delegate,
    required BackButtonDispatcher backButtonDispatcher,
    required RouteNotFoundPath routeNotFoundPath,
  }) : super(
            backButtonDispatcher: backButtonDispatcher,
            routeInformationParser: CustomRouteInformationParser(
                NavigationStack(routes), routeNotFoundPath),
            routerDelegate: delegate,
            routeInformationProvider: CustomRouteInformationProvider());
}
