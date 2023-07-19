import 'package:flutter/material.dart';

/// This widget prevents [TabBarView] from rebuilding.
/// https://github.com/flutter/flutter/issues/19116#issuecomment-403315432
/// 
class KeepAliveWidget extends StatefulWidget {
  final Widget child;
  const KeepAliveWidget({super.key, required this.child});

  @override
  State<KeepAliveWidget> createState() => _KeepAliveWidgetState();
}

class _KeepAliveWidgetState extends State<KeepAliveWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
