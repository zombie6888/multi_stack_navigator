import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_stack_navigator/common/pages.dart';
import 'package:multi_stack_navigator/common/platform_tabs_page.dart';
import 'package:multi_stack_navigator/common/routes.dart';
import 'package:multi_stack_navigator/multi_stack_navigator.dart';
import 'package:multi_stack_navigator/src/custom_route_information_parser.dart';
import 'package:multi_stack_navigator/src/navigation_stack.dart';

void main() {
  late TabRoutesConfig config;
  TestWidgetsFlutterBinding.ensureInitialized();
  late CustomRouteInformationParser parser;
  RouteInformation? routeInformation;
  final routeNotFoundPath =
      RouteNotFoundPath(path: '/not_found', child: const RouteNotFoundPage());

  group('CustomRouteInformationParser', () {
    setUp(() {
      config = TabRoutesConfig(
          routes: tabRoutes,
          routeNotFoundPath: routeNotFoundPath,
          observer: LocationObserver(),
          builder: (context, tabRoutes, view, controller) => PlatformTabsPage(
              tabRoutes: tabRoutes, view: view, controller: controller));

      parser = config.routeInformationParser as CustomRouteInformationParser;
    });
    group('Convert route infromation to configarion', () {
      test('Deep link to root route', () async {
        final stack = await parser
            .parseRouteInformation(const RouteInformation(location: '/page6'));
        expect(stack.routes.length, 4);
        expect(stack.routes[0].children.length, 1);
        expect(stack.routes[1].children.length, 1);
        expect(stack.routes[2].children.length, 1);
        expect(
          stack.routes.last,
          RoutePath('/page6', null),
        );
      });
      test('Deep link to tab route', () async {
        final stack = await parser.parseRouteInformation(
            const RouteInformation(location: '/tab2/page1'));
        expect(stack.routes.length, 3);
        expect(stack.routes[0].children.length, 1);
        expect(stack.routes[1].children.length, 1);
        expect(stack.routes[2].children.length, 1);
        expect(
          stack.routes[1].children.last,
          RoutePath('/page1', null),
        );
      });
      test('Deep link to tab nested route', () async {
        final stack = await parser.parseRouteInformation(
            const RouteInformation(location: '/tab3/nestedtest/page7'));
        expect(stack.routes.length, 3);
        expect(stack.routes[0].children.length, 1);
        expect(stack.routes[1].children.length, 1);
        expect(stack.routes[2].children.length, 2);
        expect(
          stack.routes[2].children.last,
          RoutePath('/nestedtest/page7', null),
        );
      });
      test('Deep link with query parameters', () async {
        final stack = await parser.parseRouteInformation(
            const RouteInformation(location: '/tab3/nestedtest/page7?test=1'));
        expect(
          stack.routes[2].children.last,
          RoutePath('/nestedtest/page7', null, queryParams: {"test": "1"}),
        );
      });
    });
    group('Convert configarion to route infromation', () {
      test('Single (not a tab) route', () async {
        final configuration = NavigationStack([RoutePath('/page6', null)]);
        final routeInformation = parser.restoreRouteInformation(configuration);
        expect(routeInformation?.location, '/page6');
      });
      test('Tab route', () async {
        final configuration = NavigationStack([
          RoutePath.branch('/tab1', [
            RoutePath('/', null),
          ]),
          RoutePath.branch('/tab2', [
            RoutePath('/page1', null),
          ]),
          RoutePath.branch('/tab3', [
            RoutePath('/page2', null),
          ])
        ]);
        routeInformation = parser.restoreRouteInformation(configuration);
        expect(routeInformation?.location, '/tab1');
        routeInformation = parser
            .restoreRouteInformation(configuration.copyWith(currentIndex: 1));
        expect(routeInformation?.location, '/tab2/page1');
      });
      test('Tab nested route', () async {
        final configuration = NavigationStack([
          RoutePath.branch('/tab1', [
            RoutePath('/', null),
          ]),
          RoutePath.branch('/tab2', [
            RoutePath('/page1', null),
            RoutePath('/page5', null),
          ]),
          RoutePath.branch('/tab3', [
            RoutePath('/page2', null),
            RoutePath('/nestedtest/page7', null),
          ])
        ], currentIndex: 2);
        routeInformation = parser.restoreRouteInformation(configuration);
        expect(routeInformation?.location, '/tab3/nestedtest/page7');
        routeInformation = parser
            .restoreRouteInformation(configuration.copyWith(currentIndex: 1));
        expect(routeInformation?.location, '/tab2/page5');
      });
      test('Tab single route above tab routes', () async {
        final configuration = NavigationStack([
          RoutePath.branch('/tab1', [
            RoutePath('/', null),
          ]),
          RoutePath.branch('/tab2', [
            RoutePath('/page1', null),
          ]),
          RoutePath.branch('/tab3', [
            RoutePath('/page2', null),
          ]),
          RoutePath('/page6', null),
        ]);
        routeInformation = parser.restoreRouteInformation(configuration);
        expect(routeInformation?.location, '/page6');
      });
      test('Tab route with query parameters', () async {
        final configuration = NavigationStack([
          RoutePath.branch('/tab1', [
            RoutePath('/', null, queryParams: {"test": "1"}),
          ]),
          RoutePath.branch('/tab2', [
            RoutePath('/page1', null),
          ]),
          RoutePath.branch('/tab3', [
            RoutePath('/page2', null),
          ])
        ]);
        routeInformation = parser.restoreRouteInformation(configuration);
        expect(routeInformation?.location, '/tab1?test=1');
      });
      test('Single route with query parameters', () async {
        final configuration = NavigationStack([
          RoutePath('/page6', null, queryParams: {"test": "1"})
        ]);
        final routeInformation = parser.restoreRouteInformation(configuration);
        expect(routeInformation?.location, '/page6?test=1');
      });
      test('Tab route with query parameters', () async {
        final configuration = NavigationStack([
          RoutePath.branch('/tab1', [
            RoutePath('/', null, queryParams: {"test": "1"}),
          ]),
          RoutePath.branch('/tab2', [
            RoutePath('/page1', null),
          ]),
          RoutePath.branch('/tab3', [
            RoutePath('/page2', null),
          ])
        ]);
        routeInformation = parser.restoreRouteInformation(configuration);
        expect(routeInformation?.location, '/tab1?test=1');
      });
      test('Route not found', () async {
        final configuration = NavigationStack([routeNotFoundPath]);
        routeInformation = parser.restoreRouteInformation(configuration);
        expect(routeInformation?.location, '/not_found');
      });
    });
  });
}
