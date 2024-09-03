import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';

import 'package:multi_stack_navigator/common/pages.dart';
import 'package:multi_stack_navigator/common/platform_multi_stack_wrapper.dart';
import 'package:multi_stack_navigator/common/routes.dart';
import 'package:multi_stack_navigator/multi_stack_navigator.dart';

void main() {
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  final routeConfig = TabRouterConfig.create(
      defaultPageBuilder: (child) => PlatformPageFactory.getPage(child: child),
      routes: tabRoutes,
      routeNotFoundPath: RouteNotFoundPath(
          path: '/not_found', child: const RouteNotFoundPage()),
      observer: LocationObserver(),
      tabPageBuider: (context, tabRoutes, view, controller) =>
          PlatformMultiStackWrapper(
              tabRoutes: tabRoutes, view: view, controller: controller));
  runApp(MyApp(config: routeConfig));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.config});

  final TabRouterConfig config;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: config,
    );
  }
}
