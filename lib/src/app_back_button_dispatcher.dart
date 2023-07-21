
import 'package:flutter/widgets.dart';

import 'custom_route_delegate.dart';

class AppBackButtonDispatcher extends RootBackButtonDispatcher {
  final CustomRouteDelegate routerDelegate;

  AppBackButtonDispatcher({
    required this.routerDelegate,
  }) : super();

  @override
  Future<bool> didPopRoute() {
    return invokeCallback(routerDelegate.popRoute());
  }
}