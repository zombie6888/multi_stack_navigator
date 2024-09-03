import 'package:flutter/material.dart';

import 'transition_builders.dart';

class SlideLeftTransition extends PageTransition {
  @override
  final Duration duration = const Duration(milliseconds: 300);

  @override
  final PageTransitionsBuilder transitionsBuilder =
      const SlideLeftTransitionsBuilder();
}

class SlideLeftTransitionsBuilder extends PageTransitionsBuilder {
  const SlideLeftTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _SlideLeftTransitionsBuilder(
        routeAnimation: animation, child: child);
  }
}

class _SlideLeftTransitionsBuilder extends StatelessWidget {
  _SlideLeftTransitionsBuilder({
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
    begin: const Offset(1.0, 0.0),
    end: const Offset(0.0, 0.0),
  );

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _slideAnimation, child: child);
  }
}
