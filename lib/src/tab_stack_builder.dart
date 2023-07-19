import 'package:flutter/material.dart';
/// Builder for tabs. Provides a way to customize tabbar page
/// 
/// Takes current active tab [index] and listen to index updates.
/// Takes [tabsLenght] as count of tabs.
/// 
class TabStackBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, TabController controller) builder;
  final int index;
  final int tabsLenght;
  final Function(int index) tabIndexUpdateHandler;
  const TabStackBuilder(
      {super.key,
      required this.builder,
      required this.tabIndexUpdateHandler,
      required this.index,
      required this.tabsLenght});

  @override
  State<TabStackBuilder> createState() => _TabStackBuilderState();
}

class _TabStackBuilderState extends State<TabStackBuilder>
    with TickerProviderStateMixin {
  late CustomTabController controller;

  @override
  void didUpdateWidget(covariant TabStackBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (controller.index != widget.index) {
      controller.animateTo(widget.index);
    }
  }

  @override
  void initState() {
    super.initState();
    controller = CustomTabController(
      initialIndex: widget.index,
      length: widget.tabsLenght,
      vsync: this,
    );
    controller.addListener(_onChangeTab);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// Update navigation stack when tab index was changed
  /// 
  /// PostFrameCallback prevents stack update while widgets rebuild process, 
  /// caused by tab switching.
  ///  
  /// - See [TabRoutesDelegate._tabIndexUpdateHandler]
  /// 
  _onChangeTab() {
    if (controller.index != controller.previousIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.tabIndexUpdateHandler(controller.index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, controller);
  }
}


/// Custom tab controller
///
/// It's a little bit hacky, but there is a bug that [TabBarView]
/// doesn't respect [TabController.animateTo] duration
/// 
/// This will update [animationDuration] property when
/// [TabController.animateTo] function is called, which is the only way
/// to control tab animation. 
/// 
/// The purpose of this workaround, is to disable animation,
/// when index was changed by router (push route, which is nested 
/// route of another tab), and keep animation remaining,
/// when index was changed by user (tapping on tab).
/// 
class CustomTabController extends TabController {
  CustomTabController(
      {required super.length, required super.vsync, super.initialIndex});

  Duration? _currentDuration = const Duration(milliseconds: 300);

  @override
  Duration get animationDuration => _currentDuration ?? super.animationDuration;

  @override
  void animateTo(int value,
      {Duration? duration = Duration.zero, Curve curve = Curves.ease}) {
    _currentDuration = duration;
    super.animateTo(value, duration: duration, curve: curve);
  }
}
