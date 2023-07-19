import 'package:flutter/material.dart';

import 'transition_builders.dart';

class SlideDownTransition extends PageTransition {
  @override
  final Duration duration = const Duration(milliseconds: 300);

  @override
  final PageTransitionsBuilder transitionsBuilder =
      const SlideDownTransitionsBuilder();
}

class SlideDownTransitionsBuilder extends PageTransitionsBuilder {
  const SlideDownTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _SlideDownTransitionsBuilder(
        routeAnimation: animation, child: child);
  }
}

class _SlideDownTransitionsBuilder extends StatelessWidget {
  _SlideDownTransitionsBuilder({
    Key? key,
    required Animation<double> routeAnimation,
    required this.child,
  })  : _slideAnimation = CurvedAnimation(
          parent: routeAnimation,
          curve: Curves.linear,
        ).drive(_kBottomUpTween),
        super(key: key);

  final Animation<Offset> _slideAnimation;

  static final Animatable<Offset> _kBottomUpTween = Tween<Offset>(
    begin: const Offset(0.0, -1.0),
    end: const Offset(0.0, 0.0),
  );

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _slideAnimation, child: child);
  }
}