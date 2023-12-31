import 'package:flutter/material.dart';
import 'package:multi_stack_navigator/common/pages.dart';
import 'package:multi_stack_navigator/common/platform_multi_stack_wrapper.dart';
import 'package:multi_stack_navigator/common/routes.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:multi_stack_navigator/multi_stack_navigator.dart';

void main() {
  setPathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = TabRouterConfig.create(
        defaultPageBuilder: (child) =>
            PlatformPageFactory.getPage(child: child),
        routes: tabRoutes,
        routeNotFoundPath: RouteNotFoundPath(
            path: '/not_found', child: const RouteNotFoundPage()),
        observer: LocationObserver(),
        tabPageBuider: (context, tabRoutes, view, controller) =>
            PlatformMultiStackWrapper(
                tabRoutes: tabRoutes, view: view, controller: controller));

    return MaterialApp.router(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: config,
    );
  }
}
