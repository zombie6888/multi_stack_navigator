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
  /// If [pushTransition] or [popAnimation] are null, the platform default
  /// transition is used. This is the Cupertino animation on iOS and macOS, and
  /// the fade upwards animation on all other platforms.
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


enum AnimationDirection { left, down, up, right }

// TODO: Change left to right and rename classes
class PlatformPageFactory {
  static Page<dynamic> getPage(
      {AnimationDirection direction = AnimationDirection.left,
      LocalKey? key,
      String location = '',
      String routePath = '',
      String? restorationId,
      required Widget child}) {
      if (!kIsWeb && Platform.isIOS) {
      return CupertinoPage(child: child);
    } else {
      PageTransition transition = SlideLeftTransition();
      if (direction == AnimationDirection.left) {
        transition = SlideLeftTransition();
      }
      if (direction == AnimationDirection.up) {
        transition = SlideUpTransition();
      }
      if (direction == AnimationDirection.down) {
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
