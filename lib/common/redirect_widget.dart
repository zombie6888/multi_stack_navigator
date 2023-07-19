import 'package:flutter/material.dart';
import 'package:multi_stack_navigator/multi_stack_navigator.dart';

class RedirectWidget extends StatefulWidget {
  final String path;
  const RedirectWidget({super.key, required this.path});

  @override
  State<RedirectWidget> createState() => _RedirectWidgetState();
}

class _RedirectWidgetState extends State<RedirectWidget> {
  @override
  void initState() {
    final router = AppRouter.of(context);
    router.redirect(widget.path);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
