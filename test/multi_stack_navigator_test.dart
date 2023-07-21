import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_stack_navigator/common/pages.dart';
import 'package:multi_stack_navigator/common/platform_tabs_page.dart';
import 'package:multi_stack_navigator/common/routes.dart';
import 'package:multi_stack_navigator/multi_stack_navigator.dart';

import 'package:multi_stack_navigator/src/custom_route_information_parser.dart';
import 'package:multi_stack_navigator/src/tab_routes_delegate.dart';

void main() {
  late TabRoutesConfig config;
  TestWidgetsFlutterBinding.ensureInitialized();
  late CustomRouteInformationParser parser;
  late TabRoutesDelegate delegate;

  group('Navigate forward tests', () {
    loadApp(WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp.router(
        routerConfig: config,
      ));
      await tester.pumpAndSettle();
    }

    setUp(() {
      config = TabRoutesConfig(
          routes: tabRoutes,
          routeNotFoundPath: RouteNotFoundPath(
              path: '/not_found', child: const RouteNotFoundPage()),
          observer: LocationObserver(),
          builder: (context, tabRoutes, view, controller) => PlatformTabsPage(
              tabRoutes: tabRoutes, view: view, controller: controller));
    });
    testWidgets('HomeScreen loaded', (WidgetTester tester) async {
      await loadApp(tester);
      expect(find.text('home'), findsWidgets);
    });
    testWidgets('Navigate to page not found', (WidgetTester tester) async {
      await loadApp(tester);
      await tester.tap(find.byKey(const Key('btn_route_not_found')));
      await tester.pumpAndSettle();
      expect(find.text('404'), findsWidgets);
    });
    testWidgets('Push a single page', (WidgetTester tester) async {
      await loadApp(tester);
      await tester.tap(find.byKey(const Key('btn_page6')));
      await tester.pumpAndSettle();
      expect(find.text('page6'), findsWidgets);
    });
    testWidgets('Push a tab page', (WidgetTester tester) async {
      await loadApp(tester);
      await tester.tap(find.byKey(const Key('btn_tab2_page1')));
      await tester.pump();
      expect(find.text('page1'), findsWidgets);
    });
    testWidgets('Push a tab nested page', (WidgetTester tester) async {
      await loadApp(tester);
      await tester.tap(find.byKey(const Key('btn_tab2_page5')));
      await tester.pump();
      expect(find.text('page5'), findsWidgets);
    });
    testWidgets('Push a tab page, then nested page',
        (WidgetTester tester) async {
      await loadApp(tester);
      await tester.tap(find.byKey(const Key('btn_tab2_page1')));
      await tester.pump();
      expect(find.text('page1'), findsWidgets);
      await tester.tap(find.byKey(const Key('btn_tab2_page5')));
      await tester.pump();
      expect(find.text('page5'), findsWidgets);
    });
    testWidgets('Navigate between tabs', (WidgetTester tester) async {
      await loadApp(tester);
      await tester.tap(find.byKey(const Key('btn_tab2_page1')));
      await tester.pump();
      expect(find.text('page1'), findsWidgets);
      await tester.tap(find.byKey(const Key('btn_tab1_page4')));
      await tester.pump();
      expect(find.text('page4'), findsWidgets);
    });
    testWidgets('Push redirect page', (WidgetTester tester) async {
      await loadApp(tester);
      await tester.tap(find.byKey(const Key('btn_tab2_page1')));
      await tester.pump();
      expect(find.text('page1'), findsWidgets);
      await tester.tap(find.byKey(const Key('btn_tab2_page8')));
      await tester.pumpAndSettle();
      expect(find.text('page5'), findsWidgets);
    });
    testWidgets('Naviagate replacement nested', (WidgetTester tester) async {
      await loadApp(tester);
      await tester.tap(find.byKey(const Key('btn_tab1_page4')));
      await tester.pumpAndSettle();
      expect(find.text('page4'), findsWidgets);
      await tester.tap(find.byKey(const Key('btn_tab1_nestedtest_page7')));
      await tester.pumpAndSettle();
      expect(find.text('page7'), findsWidgets);
      await tester.tap(find.byKey(const Key('btn_tab1_page5')));
      await tester.pumpAndSettle();
      expect(find.text('page5'), findsWidgets);
    });
    testWidgets('Naviagate replacement single route',
        (WidgetTester tester) async {
      await loadApp(tester);
      await tester.tap(find.byKey(const Key('btn_page6')));
      await tester.pumpAndSettle();
      expect(find.text('page6'), findsWidgets);
      await tester.tap(find.byKey(const Key('btn_replace_page8')));
      await tester.pumpAndSettle();
      expect(find.text('page8'), findsWidgets);
    });
    testWidgets('Naviagate replacement single route with parameters',
        (WidgetTester tester) async {
      await loadApp(tester);
      await tester.tap(find.byKey(const Key('btn_page6')));
      await tester.pumpAndSettle();
      expect(find.text('page6'), findsWidgets);
      await tester.tap(find.byKey(const Key('btn_replace_page6')));
      await tester.pumpAndSettle();
      expect(find.text('page6'), findsWidgets);
    });
  });
  group('Navigate forward and backward tests', () {
    loadApp(WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp.router(
        routerConfig: config,
      ));
      await tester.pumpAndSettle();
    }

    setUp(() {
      config = TabRoutesConfig(
          routes: tabRoutes,
          routeNotFoundPath: RouteNotFoundPath(
              path: '/not_found', child: const RouteNotFoundPage()),
          observer: LocationObserver(),
          builder: (context, tabRoutes, view, controller) => PlatformTabsPage(
              tabRoutes: tabRoutes, view: view, controller: controller));
      parser = config.routeInformationParser as CustomRouteInformationParser;
      delegate = config.routerDelegate as TabRoutesDelegate;
    });
    testWidgets('Pop test', (WidgetTester tester) async {
      await loadApp(tester);
      await tester.tap(find.byKey(const Key('btn_page6')));
      await tester.pumpAndSettle();
      expect(find.text('page6'), findsWidgets);
      await tester.tap(find.byKey(const Key('back_btn')));
      await tester.pump();
      expect(find.text('home'), findsWidgets);
    });
    testWidgets('Pop from nested page test', (WidgetTester tester) async {
      await loadApp(tester);
      await tester.tap(find.byKey(const Key('btn_tab1_page5')));
      await tester.pumpAndSettle();
      expect(find.text('page5'), findsWidgets);
      await tester.tap(find.byKey(const Key('back_btn')));
      await tester.pumpAndSettle();
      expect(find.text('home'), findsWidgets);
    });
    testWidgets('Navigate between tabs and back', (WidgetTester tester) async {
      await loadApp(tester);
      await tester.tap(find.byKey(const Key('btn_tab2_page1')));
      await tester.pump();
      expect(find.text('page1'), findsWidgets);
      await tester.tap(find.byKey(const Key('btn_tab1_page4')));
      await tester.pumpAndSettle();
      expect(find.text('tab1/page4'), findsWidgets);
      await tester.tap(find.byKey(const Key('back_btn')));
      await tester.pump();
      expect(find.text('page1'), findsWidgets);
    });
    testWidgets('Navigate to redirect and back', (WidgetTester tester) async {
      await loadApp(tester);
      await tester.tap(find.byKey(const Key('btn_tab2_page1')));
      await tester.pump();
      expect(find.text('page1'), findsWidgets);
      await tester.tap(find.byKey(const Key('btn_tab2_page8')));
      await tester.pumpAndSettle();
      expect(find.text('page5'), findsWidgets);
      await tester.tap(find.byKey(const Key('back_btn')));
      await tester.pump();
      expect(find.text('home'), findsWidgets);
    });
    testWidgets('Pop from from deep link', (WidgetTester tester) async {
      await loadApp(tester);
      final stack = await parser.parseRouteInformation(
          const RouteInformation(location: '/tab2/page9'));
      await delegate.setNewRoutePath(stack);
      await tester.pumpAndSettle();
      expect(find.text('page9'), findsWidgets);
      await tester.tap(find.byKey(const Key('back_btn')));
      await tester.pumpAndSettle();
      expect(find.text('page1'), findsWidgets);
    });
    testWidgets('Pop from page not found', (WidgetTester tester) async {
      await loadApp(tester);
      await tester.tap(find.byKey(const Key('btn_route_not_found')));
      await tester.pumpAndSettle();
      expect(find.text('404'), findsWidgets);
      await tester.tap(find.byKey(const Key('back_btn')));
      await tester.pumpAndSettle();
      expect(find.text('home'), findsWidgets);
    });
    testWidgets('Naviagate replacement and back', (WidgetTester tester) async {
      await loadApp(tester);
      await tester.tap(find.byKey(const Key('btn_tab1_page4')));
      await tester.pumpAndSettle();
      expect(find.text('page4'), findsWidgets);
      await tester.tap(find.byKey(const Key('btn_tab1_nestedtest_page7')));
      await tester.pumpAndSettle();
      expect(find.text('page7'), findsWidgets);
      await tester.tap(find.byKey(const Key('btn_tab1_page5')));
      await tester.pumpAndSettle();
      expect(find.text('page5'), findsWidgets);
      await tester.tap(find.byKey(const Key('back_btn')));
      await tester.pumpAndSettle();
      expect(find.text('page4'), findsWidgets);
    });
    testWidgets('Navigate replacement single route and back',
        (WidgetTester tester) async {
      await loadApp(tester);
      await tester.tap(find.byKey(const Key('btn_page6')));
      await tester.pumpAndSettle();
      expect(find.text('page6'), findsWidgets);
      await tester.tap(find.byKey(const Key('btn_replace_page8')));
      await tester.pumpAndSettle();
      expect(find.text('page8'), findsWidgets);
      await tester.tap(find.byKey(const Key('back_btn')));
      await tester.pumpAndSettle();
      expect(find.text('home'), findsWidgets);
    });
    testWidgets('Navigate replacement single route with parameters and back',
        (WidgetTester tester) async {
      await loadApp(tester);
      await tester.tap(find.byKey(const Key('btn_page6')));
      await tester.pumpAndSettle();
      expect(find.text('page6'), findsWidgets);
      await tester.tap(find.byKey(const Key('btn_replace_page6')));
      await tester.pumpAndSettle();
      expect(find.text('page6'), findsWidgets);
      await tester.tap(find.byKey(const Key('back_btn')));
      await tester.pumpAndSettle();
      expect(find.text('home'), findsWidgets);
    });
  });
}
