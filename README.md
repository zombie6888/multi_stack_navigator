# Multi stack navigator

A flutter navigator with deep links and nested navigation support. 
Based on navigator 2.0.

## Features

Deep links
Nested Navigation
Redirect
RouteNotFound

This is two-level navigation, but route uri path can contains as many as you want segments. This was designed to reduce complexity. The common case of using this package is a tab navigation for mobile devices and navigation rail for web. It prevents nested pages from unneccessary rebuilds, when you push new route or changing tab.

## Getting started

### Create routes: 

```dart
final tabRoutes = [
  RoutePath.branch('/tab1', [
    RoutePath('/', const HomePage()),
    RoutePath('/page4', const Page4()),
    RoutePath('/page5', const Page5()),
    RoutePath('/nestedtest/page7', const Page7()),
  ]),
  RoutePath.branch('/tab2', [
    RoutePath('/page1', const Page1()),
    RoutePath('/page5', const Page5()),
    RoutePath('/page9', const Page9()),
    RoutePath.builder(
        '/page8', (context) => const RedirectWidget(path: '/tab1/page5'))
  ]),
  RoutePath('/page1', const Page8()),
  RoutePath.branch('/tab3', [
    RoutePath('/page2', const Page2()),
    RoutePath('/nestedtest/page7', const Page7()),
  ]),
  RoutePath('/page6', const Page6()),
  RoutePath('/page7', const RedirectWidget(path: '/tab3/nestedtest/page7')),
];
```
Use RoutePath.branch constructor for nested route/tab pages.
You can pass page widget or use RoutePath.builder as page builder.  
Each first child route in branch will be used as a tab root route. 
For this route configuration it will be '/', '/page1', '/page2' routes.

### Create config:
```dart
final config = TabRoutesConfig(
        routes: tabRoutes,     
        builder: (context, tabRoutes, view, controller) => PlatformTabsPage(
            tabRoutes: tabRoutes, view: view, controller: controller));
```

You can create your own widget to customize tabbarview page or can try 
PlatformTabsPage widget, which is showing tabs for small screen devices and navigation rail for wide sreen devices.  

### Pass config to App router
```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

```