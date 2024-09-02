import 'dart:async';

import 'package:flutter/material.dart';
import 'package:multi_stack_navigator/multi_stack_navigator.dart';

class RedirectWidget extends StatefulWidget {
  final String path;
  final Map<String, dynamic>? queryParameters;
  const RedirectWidget({super.key, required this.path, this.queryParameters});

  @override
  State<RedirectWidget> createState() => _RedirectWidgetState();
}

class _RedirectWidgetState extends State<RedirectWidget> {
  late final String _currentPath;
  late final StreamSubscription<LocationUpdateData>?
      _locationUpdateSubscription;

  @override
  void initState() {
    final router = AppRouter.of(context);
    _currentPath = router.path;
    _locationUpdateSubscription = router.locationUpdates?.listen((data) {
      if (data.currentLocation == _currentPath &&
          data.previousLocation != widget.path) {
        router.redirect(widget.path);
      }
    });
    router.redirect(widget.path);
    super.initState();
  }

  @override
  void dispose() {
    _locationUpdateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
