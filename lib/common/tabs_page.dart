import 'package:flutter/material.dart';
import 'package:multi_stack_navigator/multi_stack_navigator.dart';

class TabsPage extends StatelessWidget {
  final Iterable<RoutePath> tabRoutes;
  final TabBarView view;
  final TabController controller;
  const TabsPage(
      {super.key,
      required this.tabRoutes,
      required this.view,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: view,
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.index,
            type: BottomNavigationBarType.fixed,
            items: <BottomNavigationBarItem>[
              for (var route in tabRoutes)
                BottomNavigationBarItem(                
                  icon: const Icon(Icons.home),
                  label: route.path,
                )
            ],
            selectedItemColor: Colors.amber[800],
            onTap: (index) => controller.animateTo(index,
                duration: const Duration(milliseconds: 300))));
  }
}
