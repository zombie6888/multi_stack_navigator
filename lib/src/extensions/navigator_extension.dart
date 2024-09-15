import 'package:flutter/material.dart';

extension NavigatorStateExtension on NavigatorState {
  NavigatorState? get parent =>
      context.findAncestorStateOfType<NavigatorState>();
}
