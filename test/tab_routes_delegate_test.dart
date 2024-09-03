import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_stack_navigator/common/pages.dart';
import 'package:multi_stack_navigator/common/platform_multi_stack_wrapper.dart';
import 'package:multi_stack_navigator/common/routes.dart';
import 'package:multi_stack_navigator/multi_stack_navigator.dart';
import 'package:multi_stack_navigator/src/custom_route_information_parser.dart';
import 'package:multi_stack_navigator/src/tab_router_delegate.dart';

void main() {
  late TabRouterConfig config;
  TestWidgetsFlutterBinding.ensureInitialized();
  late TabRouterDelegate delegate;
  late CustomRouteInformationParser parser;
  final routeNotFoundPath =
      RouteNotFoundPath(path: '/not_found', child: const RouteNotFoundPage());

  group('TabRoutesDelegate', () {
    setUp(() {
      config = TabRouterConfig.create(
          routes: tabRoutes,
          routeNotFoundPath: routeNotFoundPath,
          observer: LocationObserver(),
          tabPageBuider: (context, tabRoutes, view, controller) =>
              PlatformMultiStackWrapper(
                  tabRoutes: tabRoutes, view: view, controller: controller));

      delegate = config.routerDelegate as TabRouterDelegate;
      parser = config.routeInformationParser as CustomRouteInformationParser;
    });
    group('Push route', () {
      test('Push single (not a tab) route', () {
        delegate.navigate('/page6');
        expect(delegate.currentConfiguration?.routes.last,
            RoutePath('/page6', null));
        expect(delegate.currentConfiguration?.currentLocation, '/page6');
      });
      test('Push with query parameters', () {
        delegate.navigate('/page6');
        expect(delegate.currentConfiguration?.routes.last,
            RoutePath('/page6', null));
        delegate.navigate('/page6?test=1');
        expect(delegate.currentConfiguration?.routes[0],
            RoutePath('/page6', null));
        expect(delegate.currentConfiguration?.routes[1],
            RoutePath('/page6', null, queryParams: {'test': '1'}));
        expect(delegate.currentConfiguration?.routes[1].queryString, '?test=1');
      });
      test('Push same route with query parameters', () async {
        delegate.navigate('/page6?test=1');
        expect(delegate.currentConfiguration?.routes.last,
            RoutePath('/page6', null, queryParams: {'test': '1'}));
        delegate.navigate('/page6?test=1');
        // prevent duplicate routes
        expect(delegate.currentConfiguration?.routes.length, 1);
        expect(delegate.currentConfiguration?.routes[0],
            RoutePath('/page6', null, queryParams: {'test': '1'}));
      });
      test('Push nested route', () async {
        final stack = await parser
            .parseRouteInformation(RouteInformation(uri: Uri.parse('/')));
        await delegate.setNewRoutePath(stack);
        expect(delegate.currentConfiguration?.currentIndex, 0);
        delegate.navigate('/tab2/page5');
        expect(delegate.currentConfiguration?.routes[1].children.last,
            RoutePath('/page5', null));
        expect(delegate.currentConfiguration?.currentIndex, 1);
        expect(delegate.currentConfiguration?.currentLocation, '/tab2/page5');
      });
      test('Push nested routes with different query parameters', () async {
        final stack = await parser
            .parseRouteInformation(RouteInformation(uri: Uri.parse('/')));
        await delegate.setNewRoutePath(stack);
        expect(delegate.currentConfiguration?.currentIndex, 0);
        delegate.navigate('/tab2/page1?test=1');
        expect(delegate.currentConfiguration?.routes[1].children.last,
            RoutePath('/page1', null, queryParams: {'test': '1'}));
        expect(delegate.currentConfiguration?.currentIndex, 1);
        expect(delegate.currentConfiguration?.currentLocation, '/tab2/page1');
        delegate.navigate('/tab2/page1?test=2');
        expect(delegate.currentConfiguration?.routes[1].children[1],
            RoutePath('/page1', null, queryParams: {'test': '1'}));
        expect(delegate.currentConfiguration?.routes[1].children[2],
            RoutePath('/page1', null, queryParams: {'test': '2'}));
        delegate.navigate('/tab2/page1?test=2');
        expect(delegate.currentConfiguration?.routes[1].children.length, 3);
        expect(delegate.currentConfiguration?.routes[1].children[2],
            RoutePath('/page1', null, queryParams: {'test': '2'}));
      });
      test('Push nested replace route', () async {
        final stack = await parser
            .parseRouteInformation(RouteInformation(uri: Uri.parse('/')));
        await delegate.setNewRoutePath(stack);
        delegate.navigate('/tab2/page1');
        delegate.navigate('/tab2/page5');
        delegate.navigate('/tab2/page9');
        expect(delegate.currentConfiguration?.currentIndex, 1);
        expect(delegate.currentConfiguration?.routes[1].children.last,
            RoutePath('/page9', null));
        expect(delegate.currentConfiguration?.routes[1].children.length, 3);
        delegate.navigate('/tab2/page5');
        expect(delegate.currentConfiguration?.routes[1].children.last,
            RoutePath('/page5', null));
        expect(delegate.currentConfiguration?.routes[1].children.length, 2);
        expect(delegate.currentConfiguration?.routes.map((r) => r.path),
            isNot(contains('/page9')));
      });
      test('Push between tabs', () async {
        final stack = await parser
            .parseRouteInformation(RouteInformation(uri: Uri.parse('/')));
        delegate.setNewRoutePath(stack);
        delegate.navigate('/tab2/page1');
        delegate.navigate('/tab2/page5');
        delegate.navigate('/tab2/page9');
        delegate.navigate('/tab1/page4');
        delegate.navigate('/tab1/page5');
        expect(delegate.currentConfiguration?.currentIndex, 0);
        expect(delegate.currentConfiguration?.routes[1].children.last,
            RoutePath('/page9', null));
        expect(delegate.currentConfiguration?.routes[1].children.length, 3);
        expect(delegate.currentConfiguration?.routes[0].children.last,
            RoutePath('/page5', null));
        expect(delegate.currentConfiguration?.routes[0].children.length, 3);
        delegate.navigate('/tab2/page5');
        expect(delegate.currentConfiguration?.currentIndex, 1);
        expect(delegate.currentConfiguration?.routes[1].children.last,
            RoutePath('/page5', null));
        expect(delegate.currentConfiguration?.routes[1].children.length, 2);
        expect(delegate.currentConfiguration?.routes.map((r) => r.path),
            isNot(contains('/page9')));
      });
      test('Push between tabs with query parameters', () async {
        final stack = await parser
            .parseRouteInformation(RouteInformation(uri: Uri.parse('/')));
        await delegate.setNewRoutePath(stack);
        delegate.navigate('/tab2/page1');
        delegate.navigate('/tab2/page5?test=1');
        delegate.navigate('/tab2/page9');
        delegate.navigate('/tab1/page4');
        delegate.navigate('/tab1/page5');
        expect(delegate.currentConfiguration?.currentIndex, 0);
        expect(delegate.currentConfiguration?.routes[1].children.last,
            RoutePath('/page9', null));
        expect(delegate.currentConfiguration?.routes[1].children.length, 3);
        expect(delegate.currentConfiguration?.routes[0].children.last,
            RoutePath('/page5', null));
        expect(delegate.currentConfiguration?.routes[0].children.length, 3);
        delegate.navigate('/tab2/page5?test=2');
        expect(delegate.currentConfiguration?.currentIndex, 1);
        expect(delegate.currentConfiguration?.routes[1].children.length, 4);
        expect(
          delegate.currentConfiguration?.routes[1].children.last,
          RoutePath('/page5', null, queryParams: {'test': '2'}),
        );
      });
      test('Push tab root route', () async {
        final stack = await parser
            .parseRouteInformation(RouteInformation(uri: Uri.parse('/')));
        await delegate.setNewRoutePath(stack);
        expect(delegate.currentConfiguration?.currentIndex, 0);
        delegate.navigate('/tab2/page1');
        expect(delegate.currentConfiguration?.routes[1].children.last,
            RoutePath('/page1', null));
        expect(delegate.currentConfiguration?.currentIndex, 1);
        expect(delegate.currentConfiguration?.currentLocation, '/tab2/page1');
      });
      test('Push redirect from single route', () async {
        final stack = await parser
            .parseRouteInformation(RouteInformation(uri: Uri.parse('/')));
        await delegate.setNewRoutePath(stack);
        expect(delegate.currentConfiguration?.currentIndex, 0);
        delegate.navigate('/page6');
        expect(
          delegate.currentConfiguration?.routes.last,
          RoutePath('/page6', null),
        );
        delegate.navigate('/page7', true);
        // ensure previous route was removed from stack
        expect(delegate.currentConfiguration?.routes.map((r) => r.path),
            isNot(contains('/page6')));
      });
      test('Push redirect from nested route', () async {
        final stack = await parser
            .parseRouteInformation(RouteInformation(uri: Uri.parse('/')));
        await delegate.setNewRoutePath(stack);
        expect(delegate.currentConfiguration?.currentIndex, 0);
        delegate.navigate('/tab2/page5');
        expect(delegate.currentConfiguration?.currentIndex, 1);
        expect(delegate.currentConfiguration?.routes[1].children.last,
            RoutePath('/page5', null));
        delegate.navigate('/tab1/page4', true);
        // ensure tab is changed
        expect(delegate.currentConfiguration?.currentIndex, 0);
        expect(delegate.currentConfiguration?.routes[0].children.last,
            RoutePath('/page4', null));
        // ensure previous route was removed from stack
        expect(
            delegate.currentConfiguration?.routes[1].children
                .map((r) => r.path),
            isNot(contains('/page5')));
      });
      test('Push redirect between tabs from nested route', () async {
        final stack = await parser
            .parseRouteInformation(RouteInformation(uri: Uri.parse('/')));
        await delegate.setNewRoutePath(stack);
        expect(delegate.currentConfiguration?.currentIndex, 0);
        delegate.navigate('/tab2/page5');
        expect(delegate.currentConfiguration?.currentIndex, 1);
        expect(delegate.currentConfiguration?.routes[1].children.last,
            RoutePath('/page5', null));
        delegate.navigate('/tab2/page9', true);
        // ensure tab is changed
        expect(delegate.currentConfiguration?.currentIndex, 1);
        expect(delegate.currentConfiguration?.routes[1].children.last,
            RoutePath('/page9', null));
        // ensure previous route was removed from stack
        expect(
            delegate.currentConfiguration?.routes[1].children
                .map((r) => r.path),
            isNot(contains('/page5')));
      });
      test('Push related route', () async {
        final stack = await parser
            .parseRouteInformation(RouteInformation(uri: Uri.parse('/')));
        await delegate.setNewRoutePath(stack);
        expect(delegate.currentConfiguration?.currentIndex, 0);
        delegate.navigate('/tab2/page5');
        expect(delegate.currentConfiguration?.currentIndex, 1);
        expect(delegate.currentConfiguration?.routes[1].children.last,
            RoutePath('/page5', null));
        delegate.navigate('page9');
        // ensure tab is changed
        expect(delegate.currentConfiguration?.currentIndex, 1);
        expect(delegate.currentConfiguration?.currentLocation, '/tab2/page9');
        expect(delegate.currentConfiguration?.routes[1].children.last,
            RoutePath('/page9', null));
        delegate.navigate('page6');
        //expect(delegate.currentConfiguration?.routes.length, 4);
        expect(delegate.currentConfiguration?.routes.last,
            RoutePath('/page6', null));
        expect(delegate.currentConfiguration?.currentLocation, '/page6');
      });
      test('Push root branch route', () async {
        final stack = await parser
            .parseRouteInformation(RouteInformation(uri: Uri.parse('/')));
        await delegate.setNewRoutePath(stack);
        expect(delegate.currentConfiguration?.currentIndex, 0);
        delegate.navigate('/tab2/page5');
        expect(delegate.currentConfiguration?.currentIndex, 1);
        expect(delegate.currentConfiguration?.routes[1].children.last,
            RoutePath('/page5', null));
        delegate.navigate('page6');       
        expect(delegate.currentConfiguration?.routes.last,
            RoutePath('/page6', null));
        delegate.navigate('/tab1');    
        // ensure tab is changed
        expect(delegate.currentConfiguration?.currentIndex, 0);
        expect(delegate.currentConfiguration?.currentLocation, '/tab1');
        expect(delegate.currentConfiguration?.routes.last,
            RoutePath('/tab3', null));        
      });
      test('Replace nested route', () async {
        final stack = await parser
            .parseRouteInformation(RouteInformation(uri: Uri.parse('/')));
        await delegate.setNewRoutePath(stack);
        expect(delegate.currentConfiguration?.currentIndex, 0);
        delegate.navigate('/tab1/page4');
        expect(delegate.currentConfiguration?.routes[0].children.length, 2);
        expect(delegate.currentConfiguration?.routes[0].children.last,
            RoutePath('/page4', null));
        delegate.navigate('/tab1/nestedtest/page7');
        expect(delegate.currentConfiguration?.currentLocation,
            '/tab1/nestedtest/page7');
        expect(delegate.currentConfiguration?.routes[0].children.last,
            RoutePath('/nestedtest/page7', null));
        expect(delegate.currentConfiguration?.routes[0].children.length, 3);
        await delegate.replaceCurrentRoute('/tab1/page5');
        expect(delegate.currentConfiguration?.routes[0].children.last,
            RoutePath('/page5', null));
        expect(delegate.currentConfiguration?.currentLocation, '/tab1/page5');
        expect(delegate.currentConfiguration?.routes[0].children.length, 3);
      });
      test('Replace single route', () async {
        final stack = await parser
            .parseRouteInformation(RouteInformation(uri: Uri.parse('/')));
        await delegate.setNewRoutePath(stack);
        expect(delegate.currentConfiguration?.currentIndex, 0);
        delegate.navigate('/page6');
        expect(delegate.currentConfiguration?.routes.length, 4);
        expect(delegate.currentConfiguration?.routes.last,
            RoutePath('/page6', null));
        await delegate.replaceCurrentRoute('/page8');
        expect(delegate.currentConfiguration?.currentLocation, '/page8');
        expect(delegate.currentConfiguration?.routes.last,
            RoutePath('/page8', null));
        expect(delegate.currentConfiguration?.routes.length, 4);
      });
      test('Replace single route with different params', () async {
        final stack = await parser
            .parseRouteInformation(RouteInformation(uri: Uri.parse('/')));
        delegate.setNewRoutePath(stack);
        expect(delegate.currentConfiguration?.currentIndex, 0);
        delegate.navigate('/page6?test=1');
        expect(delegate.currentConfiguration?.routes.length, 4);
        expect(delegate.currentConfiguration?.routes.last,
            RoutePath('/page6', null, queryParams: {'test': '1'}));
        delegate.replaceCurrentRoute('/page6?test=2');
        expect(delegate.currentConfiguration?.currentLocation, '/page6');
        expect(delegate.currentConfiguration?.routes.last,
            RoutePath('/page6', null, queryParams: {'test': '2'}));
        expect(delegate.currentConfiguration?.routes.length, 4);
      });
      test('Push route not found route', () {
        delegate.navigate('/fakeroute');
        expect(delegate.currentConfiguration?.routes.last, routeNotFoundPath);
        expect(delegate.currentConfiguration?.currentLocation, '/not_found');
      });
    });
    group('Set route from platform', () {
      test('Deep link to root route', () async {
        final stack = await parser
            .parseRouteInformation(RouteInformation(uri: Uri.parse('/page6')));
        await delegate.setNewRoutePath(stack);
        expect(delegate.currentConfiguration?.routes.last,
            RoutePath('/page6', null));
      });
      test('Deep link to tab root route', () async {
        final stack = await parser
            .parseRouteInformation(RouteInformation(uri: Uri.parse('/tab1')));
        await delegate.setNewRoutePath(stack);
        expect(delegate.currentConfiguration?.routes[0].children.last,
            RoutePath('/', null));
        expect(delegate.currentConfiguration?.routes.length, 3);
        expect(delegate.currentConfiguration?.routes.last,
            isNot(routeNotFoundPath));
      });
      test('Deep link with query params', () async {
        final stack = await parser.parseRouteInformation(
           RouteInformation(uri: Uri.parse('/page6?test=1')));
        await delegate.setNewRoutePath(stack);
        expect(delegate.currentConfiguration?.routes.last,
            RoutePath('/page6', null, queryParams: {'test': '1'}));
      });
      test('Deep link to tab route', () async {
        final stack = await parser.parseRouteInformation(
           RouteInformation(uri: Uri.parse('/tab2/page1')));
        await delegate.setNewRoutePath(stack);
        expect(delegate.currentConfiguration?.routes[1].children.last,
            RoutePath('/page1', null));
        expect(delegate.currentConfiguration?.currentIndex, 1);
        expect(delegate.currentConfiguration?.currentLocation, '/tab2/page1');
      });
      test('Deep link to tab nested route', () async {
        final stack = await parser.parseRouteInformation(
            RouteInformation(uri: Uri.parse('/tab3/nestedtest/page7')));
        await delegate.setNewRoutePath(stack);
        expect(delegate.currentConfiguration?.routes[2].children.last,
            RoutePath('/nestedtest/page7', null));
        expect(delegate.currentConfiguration?.currentIndex, 2);
        expect(delegate.currentConfiguration?.currentLocation,
            '/tab3/nestedtest/page7');
      });
      test('Deep link with unknown route', () async {
        final stack = await parser.parseRouteInformation(
            RouteInformation(uri: Uri.parse('/fakeroute')));
        await delegate.setNewRoutePath(stack);
        expect(delegate.currentConfiguration?.routes.last, routeNotFoundPath);
        expect(delegate.currentConfiguration?.currentLocation, '/not_found');
      });
    });
  });
}
