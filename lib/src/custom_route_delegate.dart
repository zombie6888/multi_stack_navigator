import 'navigation_observer.dart';

abstract interface class CustomRouteDelegate {
  final NavigationObserver? observer;
  CustomRouteDelegate(this.observer);

  navigate(String path, [bool isRedirect = false]);
  replaceCurrentRoute(String path);
}
