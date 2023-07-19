import 'package:flutter/material.dart';
import 'transition_builders.dart';

class OpacityTransition extends PageTransition {
  @override
  final Duration duration = const Duration(milliseconds: 300);

  @override
  final PageTransitionsBuilder transitionsBuilder =
       const OpacityPageRouteBuilder();  
}

class OpacityPageRouteBuilder extends PageTransitionsBuilder {
  const OpacityPageRouteBuilder();

   @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _OpacityTransitionsBuilder(
        routeAnimation: animation, child: child);
  }
}

class _OpacityTransitionsBuilder extends StatelessWidget {
  _OpacityTransitionsBuilder({
    Key? key,
    required Animation<double> routeAnimation,
    required this.child,
    }) : _opacityAnimation = routeAnimation.drive(_easeInTween),
        super(key: key);

  final Animation<double> _opacityAnimation;
  static final Animatable<double> _easeInTween = CurveTween(curve: Curves.easeIn);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacityAnimation, child: child);
  }
}