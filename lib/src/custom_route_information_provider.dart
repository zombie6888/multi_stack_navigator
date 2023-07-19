import 'dart:ui';

import 'package:flutter/material.dart';

/// See [RouteInformationProvider]
///
/// Pass [PlatformDispatcher.instance.defaultRouteName]
/// to [RouteInformationProvider], which is providing [RouteInformation] from platform.
/// Useful for deep link support. 
/// Provides [RouteInformation] to Platform
/// 
/// Constructor gets location from [PlatformDispatcher.instance.defaultRouteName]
/// and pass it to [RouteInfromationParser]. 
/// 
/// This adds deep linking support.
/// 
class CustomRouteInformationProvider extends PlatformRouteInformationProvider {
  CustomRouteInformationProvider()
      : super(
            initialRouteInformation: RouteInformation(
                location: PlatformDispatcher.instance.defaultRouteName));
}
