import 'route_path.dart';

/// Router configuration.
///
/// It contains stack of [routes]
/// - see [RoutePath].
/// 
/// The [currentIndex] can be used for nested route access. 
/// 
/// For tab navigation, currentIndex is using to provide access 
/// to routes from the current active tab.
/// 
/// The [currentLocation] value is the uri path of active route.
/// 
class NavigationStack {
  final List<RoutePath> routes;
  final int currentIndex;
  final String currentLocation;

  NavigationStack(this.routes,
      {this.currentIndex = 0, this.currentLocation = ''});

  NavigationStack copyWith(
          {List<RoutePath>? routes,
          int? currentIndex,
          String? currentLocation}) =>
      NavigationStack(
        routes ?? this.routes,
        currentIndex: currentIndex ?? this.currentIndex,
        currentLocation: currentLocation ?? this.currentLocation,
      );

  RoutePath? getCurrentTabRoute() {
    if (routes.length - 1 >= currentIndex) {
      return routes[currentIndex];
    }
    return null;
  }
}