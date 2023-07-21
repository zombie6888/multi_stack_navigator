# Multi stack navigator

A flutter navigator with deep links and nested navigation support. 
Based on navigator 2.0. 

See [Web example](https://zombie6888.github.io/multi_stack_navigator/)

## Features

* Deep links
* Nested Navigation
* Redirect
* RouteNotFound

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
Use RoutePath.branch constructor for nested route/tab pages. You can pass page widget or use RoutePath.builder as page builder. Each first child route in branch will be used as a tab root route. For this route configuration it will be '/', '/page1', '/page2' routes.

### Create config:

```dart
final config = TabRoutesConfig.create(
        routes: tabRoutes,     
        builder: (context, tabRoutes, view, controller) => PlatformTabsPage(
            tabRoutes: tabRoutes, view: view, controller: controller));
```

You can create your own widget to customize tabbarview page or can try PlatformTabsPage widget, which is showing tabs for small screen devices and navigation rail for wide sreen devices.  

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

## Navigate between pages

User AppRouter inherited widget for navigation between pages:

```dart
AppRouter.of(context).navigate('/page1?param=test');
```

On the /page1 you can get query parameters by using: 

```dart
AppRouter.of(context).routePath.queryParams; //{"param": "test"}
```

You can also push related path like:

```dart
AppRouter.of(context).navigate('page1?param=test');
```

The difference is that you omit '/' prefix for path. If current page is a nested page of some tab, for example /tab1 tab, router will try to search /tab1/page1 in routes. In case of success, nested page will be pushed, otherwise it will try to search route in root stack or push "route not found" page.

if you want to replace current route use:

```dart
AppRouter.of(context).replaceWith('/page6?test=2');
```

If previous route had the same route path, but query parameters are different, the page won't rebuilded.
if you want to get updated parameters at the build function of the page6 you can call router with listen parameter setted up to true:

```dart
AppRouter.of(context, true).routePath.queryParams;
```

Approuter is inherited widget, which is not add widget to dependants by default. It allows to use it's methods without subscribe to changes. If you get it with "listen: true" parameter, dependonInheritedWidget function will be called, and widget will subscribe to route changes (in this case query parameters updating).   

## Route not found functionality

You can pass route, which will be used, if router can't find route path:

```dart
final routeNotFoundPath =
      RouteNotFoundPath(path: '/not_found', child: const RouteNotFoundPage());
final config = TabRoutesConfig.create(
          ...
          routeNotFoundPath: routeNotFoundPath,
          builder: ...);
```

You can set uri and widget/builder for this page.


## Guards and Redirects

There is no any special guards, but you can create your own by using Routepath.builder and Redirect widget:

```dart
RoutePath.builder('/page1', (context) {
    final isLogged = ... // your custom logic
    if(isLogged) {
      return Page1();
    } else {
      return const RedirectWidget(path: '/login'));
    }
});
```

## Observe navigation

You can create your own navigation observer by extending NavigationObserver or use LocationObserver class: 

```dart
final config = TabRoutesConfig.create(
          ...
          observer: LocationObserver(),
          builder: ...);
```

There is no unneccessary rebuilds on current page when you push or pop other route, or switching to another tab. But if you want to rebuild something or run some callback on current page, when navigation events occurs, you can use LocationObserver stream.

## Deep linking

Deep links is supported by this package. You can directly access to any path of your routes configuration. 


