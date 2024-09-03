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

Define route configuration:

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
 In order to create single (not a tab) pages, use RoutePath constructor. In order to create tab route with nested pages, use RoutePath.branch constructor. You can set the second parameter, or use RoutePath.builder to provide widget which will be displayed on the page. Each first child page of a branch route from configuration, becomes a tab root route in navigation stack. In this case, it will be pages with paths: '/', '/page1', '/page2'.

### Create config:

```dart
final config = TabRouterConfig.create(
        routes: tabRoutes,     
        tabPageBuider: (context, tabRoutes, view, controller) => PlatformMultiStackWrapper(
            tabRoutes: tabRoutes, view: view, controller: controller));
```

You can create your own widget to customize tabbarview page. To give an example, consider PlatformMultiStackWrapper widget, which is showing tabs for small screen devices and navigation rail for wide screen devices.  

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

Use AppRouter inherited widget for navigation between pages:

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

The difference is that you omit '/' prefix for path. If current page is a nested page of some tab, for example /tab1 tab, router will try to search /tab1/page1 in routes. In case of success, nested page will be pushed, otherwise it will try to search route in the root stack or push "route not found" page.

if you want to replace current route use:

```dart
AppRouter.of(context).replaceWith('/page6?test=2');
```

If previous route had the same route path, but query parameters are different, the page won't rebuilded.
if you want to get updated parameters at the build function of the page6, you can call router with listen parameter setted up to true:

```dart
AppRouter.of(context, true).routePath.queryParams;
```

AppRouter is inherited widget, which is not add widget to dependants by default. It allows to use it's methods without subscribe to changes. If you get AppRouter with "listen: true" parameter, dependonInheritedWidget function will be called, and widget will subscribe to route changes (in this case, query parameters updating).   

## Route not found functionality

You can pass route, which is used, when router can't find route path:

```dart
final routeNotFoundPath =
      RouteNotFoundPath(path: '/not_found', child: const RouteNotFoundPage());
final config = TabRouterConfig.create(
          ...
          routeNotFoundPath: routeNotFoundPath,
          tabPageBuider: ...);
```

You can set uri and widget/builder for this page.


## Guards and Redirects

The package doesn't have any special guards, but you can create your own by using Routepath.builder and Redirect widget:

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
final config = TabRouterConfig.create(
          ...
          observer: LocationObserver(),
          tabPageBuider: ...);
```

The current page will not perform unneccessary rebuilds, when you push or pop other route, or switching to another tab. But if you want to rebuild something or run some callback on current page, when navigation events occurs, you can use LocationObserver stream.

## Hardware back button behavior

When you tap android back button, default back handler will be called. Router will try to pop nested page 
or root page, otherwise, if tab root page is opened, it will try to switch to previuos tab. When you tap on the root page of the first tab, it will pop entire application.

You can override this behavior by using HardwareBackHandler widget from any widget and any page: 

```dart
HardwareBackHandler(
      onBackButtonPressed: () {
        // returning false will close the application
        return Future.value(true);
      },
      child: ...
...      
```

If you want to change default behavior for entire application, you can pass your own BackButtonDispatcher to router config:

```dart
class MyCustomBackButtonDispatcher extends RootBackButtonDispatcher {
  ...
}
...
final config = TabRouterConfig.create(
          ...
          backButtonDispatcher: MyCustomBackButtonDispatcher,
          tabPageBuider: ...);
```

## Custom page transitions

You can define default page transitions by providing custom page builder to configuration: 

```dart
final config = TabRouterConfig.create(
          ...
          defaultPageBuilder: (child) => MyCustomPageBuilder(child),
          tabPageBuider: ...);
```

and you can override default page builder from configaration for specific routepath: 

```dart
RoutePath('/page6', const Page6(),
      pageBuilder: (child) => MaterialPage(child)),
 ```           