import 'dart:async';

import 'package:flutter/material.dart';
import 'package:multi_stack_navigator/multi_stack_navigator.dart';

class HardwareBackHandler extends StatefulWidget {
  const HardwareBackHandler({
    super.key,
    required this.child,
    required this.onBackButtonPressed,
  });

  final Widget child;
  final ValueGetter<Future<bool>> onBackButtonPressed;

  @override
  State<HardwareBackHandler> createState() => _BackButtonHandlerState();
}

class _BackButtonHandlerState extends State<HardwareBackHandler> {
  BackButtonDispatcher? dispatcher;
  StreamSubscription<LocationUpdateData>? _loacationSubscription;

  @override
  void initState() {
    if (AppRouter.maybeOf(context) != null) {
      _loacationSubscription =
          AppRouter.of(context).locationUpdates?.listen((event) {
        dispatcher?.removeCallback(widget.onBackButtonPressed);
      });
    } 
    super.initState();
  }

  @override
  void didChangeDependencies() {
    dispatcher?.removeCallback(widget.onBackButtonPressed);

    final BackButtonDispatcher? rootBackDispatcher =
        Router.of(context).backButtonDispatcher;
    assert(rootBackDispatcher != null,
        'The parent router must have a backButtonDispatcher to use this widget');

    dispatcher = rootBackDispatcher!.createChildBackButtonDispatcher()
      ..addCallback(widget.onBackButtonPressed)
      ..takePriority();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant HardwareBackHandler oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onBackButtonPressed != widget.onBackButtonPressed) {
      dispatcher?.removeCallback(oldWidget.onBackButtonPressed);
      dispatcher?.addCallback(widget.onBackButtonPressed);
      dispatcher?.takePriority();
    }
  }

  @override
  void dispose() {
    _loacationSubscription?.cancel();
    dispatcher?.removeCallback(widget.onBackButtonPressed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
