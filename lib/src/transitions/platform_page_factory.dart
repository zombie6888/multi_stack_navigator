import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'slide_down_transition.dart';
import 'slide_left_transition.dart';
import 'slide_up_transition.dart';
import 'transition_builders.dart';

class TransitionPage<T> extends TransitionBuilderPage<T> {
  /// Initialize a transition page.
  ///
  /// If [pushTransition] or [popAnimation] are null, 
  /// the SlideLeftTransition transition is used.
  const TransitionPage({
    required Widget child,
    this.pushTransition,
    this.popTransition,
    bool maintainState = true,
    bool fullscreenDialog = false,
    this.location = '',
    this.routePath = '',
    bool opaque = true,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) : super(
          child: child,
          arguments: arguments,
          restorationId: restorationId,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
          opaque: opaque,
          key: key,
          name: name,
        );

  final PageTransition? pushTransition;
  final PageTransition? popTransition;
  final String location;
  final String routePath;

  @override
  PageTransition buildPushTransition(BuildContext context) {
    if (pushTransition == null) {
      return SlideLeftTransition();
    }

    return pushTransition!;
  }

  @override
  PageTransition buildPopTransition(BuildContext context) {
    if (popTransition == null) {
      return SlideLeftTransition();
    }

    return popTransition!;
  }
}

enum PageInitialPosition { right, down, up }

class PlatformPageFactory {
  static Page<dynamic> getPage(
      {PageInitialPosition initialPosition = PageInitialPosition.right,
      LocalKey? key,
      String location = '',
      String routePath = '',
      String? restorationId,
      required Widget child}) {
    if (!kIsWeb && Platform.isIOS) {
      return CupertinoPage(child: child);
    } else {
      PageTransition transition = SlideLeftTransition();
      if (initialPosition == PageInitialPosition.right) {
        transition = SlideLeftTransition();
      }
      if (initialPosition == PageInitialPosition.up) {
        transition = SlideUpTransition();
      }
      if (initialPosition == PageInitialPosition.down) {
        transition = SlideDownTransition();
      }
      return TransitionPage(
          key: key,
          restorationId: restorationId,
          pushTransition: transition,
          popTransition: transition,
          child: child);
    }
  }
}
