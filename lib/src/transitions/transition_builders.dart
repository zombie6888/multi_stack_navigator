import 'package:flutter/material.dart';

abstract class PageTransition {
  /// Initialize a transition for a page pop or push animation.
  const PageTransition();

  /// How long this transition animation lasts.
  Duration get duration;

  /// A builder that configures the animation.
  PageTransitionsBuilder get transitionsBuilder;
}

abstract class TransitionBuilderPage<T> extends Page<T> {
  /// Initialize a page that provides separate push and pop animations.
  const TransitionBuilderPage({
    required this.child,
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.opaque = true,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) : super(
          key: key,
          name: name,
          arguments: arguments,
          restorationId: restorationId,
        );

  /// Called when this page is pushed, returns a [PageTransition] to configure
  /// the push animation.
  ///
  /// Return `PageTransition.none` for an immediate push with no animation.
  PageTransition buildPushTransition(BuildContext context);

  /// Called when this page is popped, returns a [PageTransition] to configure
  /// the pop animation.
  ///
  /// Return `PageTransition.none` for an immediate pop with no animation.
  PageTransition buildPopTransition(BuildContext context);

  /// The content to be shown in the [Route] created by this page.
  final Widget child;

  /// {@macro flutter.widgets.ModalRoute.maintainState}
  final bool maintainState;

  /// {@macro flutter.widgets.PageRoute.fullscreenDialog}
  final bool fullscreenDialog;

  /// {@macro flutter.widgets.TransitionRoute.opaque}
  final bool opaque;

  @override
  Route<T> createRoute(BuildContext context) {
    return TransitionBuilderPageRoute<T>(page: this);
  }
}

/// The route created by by [TransitionBuilderPage], which delegates push and
/// pop transition animations to that page.
class TransitionBuilderPageRoute<T> extends PageRoute<T> {
  /// Initialize a route which delegates push and pop transition animations to
  /// the provided [page].
  TransitionBuilderPageRoute({
    required TransitionBuilderPage<T> page,
  }) : super(settings: page);

  TransitionBuilderPage<T> get _page => settings as TransitionBuilderPage<T>;

  /// This value is not used.
  ///
  /// The actual durations are provides by the [PageTransition] objects.
  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: _page.child,
    );
  }

  @override
  bool didPop(T? result) {
    final transition = _page.buildPopTransition(navigator!.context);
    controller!.reverseDuration = transition.duration;
    return super.didPop(result);
  }

  @override
  TickerFuture didPush() {
    final transition = _page.buildPushTransition(navigator!.context);
    controller!.duration = transition.duration;
    return super.didPush();
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final isPopping = controller!.status == AnimationStatus.reverse;

    // If the push is complete we build the pop transition.
    // This is so cupertino back user gesture will work, even if a cupertino
    // transition wasn't used to show this page.
    final pushIsComplete = controller!.status == AnimationStatus.completed;

    final transition =
        (isPopping || pushIsComplete || navigator!.userGestureInProgress)
            ? _page.buildPopTransition(navigator!.context)
            : _page.buildPushTransition(navigator!.context);

    return transition.transitionsBuilder
        .buildTransitions(this, context, animation, secondaryAnimation, child);
  }

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  bool get opaque => _page.opaque;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';
}