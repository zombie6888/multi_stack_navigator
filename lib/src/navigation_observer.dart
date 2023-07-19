import 'dart:async';

abstract interface class NavigationObserver {
  void didPushRoute(String location);
  void didPopRoute(String location);
}

/// LocationObserver keeps current and previous route location.
///
/// The [_currentLocation] and [_previousLocation]
/// is a current and previous route [Uri] path.
/// 
/// Location updates [stream] can be accessable from any widget by using
/// AppRouter.of(context).locationUpdates
/// 
class LocationObserver extends NavigationObserver
    with LocationStreamController {
  String? _currentLocation;
  String? _previousLocation;

  @override
  void didPopRoute(String location) {
    _previousLocation = _currentLocation;
    _currentLocation = location;
    _controller.add(LocationUpdateData(
        type: LocationUpdateType.pop,
        currentLocation: _currentLocation,
        previousLocation: _previousLocation));
  }

  @override
  void didPushRoute(String location) {
    _previousLocation = _currentLocation;
    _currentLocation = location;
    _controller.add(LocationUpdateData(
        type: LocationUpdateType.push,
        currentLocation: _currentLocation,
        previousLocation: _previousLocation));
  }
}

class LocationUpdateData {
  final String? currentLocation;
  final String? previousLocation;
  final LocationUpdateType type;
  LocationUpdateData(
      {required this.currentLocation,
      required this.previousLocation,
      required this.type});
}

enum LocationUpdateType { pop, push }

/// This allows to listen to location updates
///
/// It can be useful, if you want to rebuild page on navigation updates
/// (for example when you push another route).
/// 
/// Because router is designed to prevent unnecessary rebuilds.
/// 
mixin LocationStreamController on NavigationObserver {
  final _controller = StreamController<LocationUpdateData>.broadcast();

  Stream<LocationUpdateData> get stream => _controller.stream;
}
