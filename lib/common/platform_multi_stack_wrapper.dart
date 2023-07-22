import 'package:flutter/material.dart';
import 'package:multi_stack_navigator/multi_stack_navigator.dart';

class PlatformMultiStackWrapper extends StatelessWidget {
  final Iterable<RoutePath> tabRoutes;
  final TabBarView view;
  final TabController controller;
  const PlatformMultiStackWrapper(
      {super.key,
      required this.tabRoutes,
      required this.view,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Row(
          children: [
            if (screenWidth >= 600)
              Material(
                child: NavigationRail(
                    backgroundColor: Colors.white,
                    elevation: 5,
                    minWidth: 50,
                    selectedIndex: controller.index,
                    labelType: NavigationRailLabelType.all,
                    destinations: [
                      for (var route in tabRoutes)
                        NavigationRailDestination(
                          indicatorColor: Colors.black,
                          icon: const Icon(Icons.home),
                          label: Text(
                            route.path.replaceAll('/', ''),
                          ),
                        ),
                    ],
                    onDestinationSelected: (index) {
                      controller.animateTo(index);
                    }),
              ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: view),
          ],
        ),
        bottomNavigationBar: screenWidth < 600
            ? BottomNavigationBar(
                currentIndex: controller.index,
                type: BottomNavigationBarType.fixed,
                items: <BottomNavigationBarItem>[
                  for (var route in tabRoutes)
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.home),
                      label: route.path.replaceAll('/', ''),
                    )
                ],
                selectedItemColor: Colors.amber[800],
                onTap: (index) => controller.animateTo(index,
                    duration: const Duration(milliseconds: 300)))
            : null);
  }
}
