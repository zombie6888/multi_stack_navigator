import 'navigation_observer.dart';

abstract interface class CustomRouteDelegate {
  final NavigationObserver? observer;
  CustomRouteDelegate(this.observer);

  pushNamed(String path, [bool isRedirect = false]);
}
