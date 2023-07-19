import 'package:flutter/material.dart';
import 'package:multi_stack_navigator/multi_stack_navigator.dart';

class Page6 extends StatelessWidget {
  const Page6({super.key});

  @override
  Widget build(BuildContext context) {
    print('build page6');
    final router = AppRouter.of(context);
    print('query params: ${router.routePath.queryParams}');
    return Scaffold(
        appBar: AppBar(
            leading: const BackButton(key: ValueKey('back_btn')),
            title: const Text("page6")),
        body: Center(
          child: Column(
            children: [
              const Text(
                "page6",
                style: TextStyle(fontSize: 22),
              ),
              TextButton(
                  onPressed: () {
                    //Navigator.of(context).pushNamed('/page1');
                    router.pushNamed('/tab2/page5');
                  },
                  child: const Text("/tab2/page5",
                      style: TextStyle(fontSize: 22))),
              TextButton(
                  onPressed: () {
                    //Navigator.of(context).pushNamed('/page1');
                    router.pushNamed('page1');
                  },
                  child:
                      const Text("to page1", style: TextStyle(fontSize: 22))),
              TextButton(
                  onPressed: () {
                    //Navigator.of(context).pushNamed('/page1');
                    router.pushNamed('page6?test=2&tre=3');
                  },
                  child: const Text("page6?test=2",
                      style: TextStyle(fontSize: 22))),
              TextButton(
                  onPressed: () {
                    //Navigator.of(context).pushNamed('/page1');
                    router.pushNamed('/tab1/page7');
                  },
                  child: const Text("to page7 redirect",
                      style: TextStyle(fontSize: 22))),
              TextButton(
                  onPressed: () {
                    //Navigator.of(context).pushNamed('/page1');
                    router.pop();
                  },
                  child: const Text("test pop", style: TextStyle(fontSize: 22)))
            ],
          ),
        ));
  }
}

class Page8 extends StatelessWidget {
  const Page8({super.key});

  @override
  Widget build(BuildContext context) {
    print('build page8');
    final router = AppRouter.of(context);
    print('qery params: ${router.routePath.queryParams}');
    return Scaffold(
        appBar: AppBar(title: const Text("page8")),
        body: Center(
          child: Column(
            children: [
              const Text(
                "page8",
                style: TextStyle(fontSize: 22),
              ),
              TextButton(
                  onPressed: () {
                    //Navigator.of(context).pushNamed('/page1');
                    router.pop();
                  },
                  child: const Text("test pop", style: TextStyle(fontSize: 22)))
            ],
          ),
        ));
  }
}

class Page7 extends StatelessWidget {
  const Page7({super.key});

  @override
  Widget build(BuildContext context) {
    print('build page7');
    return Scaffold(
        appBar: AppBar(title: const Text("page7")),
        body: const Center(
          child: Column(
            children: [
              Text(
                "page7",
                style: TextStyle(fontSize: 22),
              ),
            ],
          ),
        ));
  }
}

class Page1 extends StatelessWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    print('build /tab2/page1');
    final router = AppRouter.of(context);
    return Scaffold(
        appBar: AppBar(title: const Text("page1")),
        body: Center(
          child: Column(
            children: [
              const Text(
                "/tab2/page1",
                style: TextStyle(fontSize: 22),
              ),
              TextButton(
                  onPressed: () {
                    router.pushNamed('/tab3/page2');
                  },
                  child:
                      const Text("to page2", style: TextStyle(fontSize: 22))),
              TextButton(
                  key: const ValueKey('btn_tab2_page5'),
                  onPressed: () {
                    router.pushNamed('/tab2/page5');
                  },
                  child: const Text("to tab2 page5",
                      style: TextStyle(fontSize: 22))),
              TextButton(
                  key: const ValueKey('btn_tab2_page8'),
                  onPressed: () {
                    router.pushNamed('/tab2/page8');
                  },
                  child:
                      const Text("to page8", style: TextStyle(fontSize: 22))),
              TextButton(
                  key: const ValueKey('btn_tab1_page4'),
                  onPressed: () {
                    //Navigator.of(context).pushNamed('/page1');
                    router.pushNamed('/tab1/page4?test=1');
                  },
                  child: const Text("to page4", style: TextStyle(fontSize: 22)))
            ],
          ),
        ));
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('build home');
    final router = AppRouter.of(context);
    return StreamBuilder(
        stream: router.locationUpdates,
        builder: (context, snapshot) {
          print('home page navigation event');
          print(
              'type: ${snapshot.data?.type}, current location: ${snapshot.data?.currentLocation}, previous location: ${snapshot.data?.previousLocation}');
          return Scaffold(
              appBar: AppBar(title: const Text("home")),
              body: Center(
                child: Builder(builder: (context) {
                  return Column(
                    children: [
                      const Text("home", style: TextStyle(fontSize: 22)),
                      TextButton(
                          key: const ValueKey('btn_tab2_page1'),
                          onPressed: () {
                            //Navigator.of(context).pushNamed('/page1');
                            router.pushNamed('/tab2/page1');
                          },
                          child: const Text("to page1",
                              style: TextStyle(fontSize: 22))),
                      TextButton(
                          onPressed: () {
                            //Navigator.of(context).pushNamed('/page1');
                            router.pushNamed('/tab1/page4?test=1');
                          },
                          child: const Text("to page4",
                              style: TextStyle(fontSize: 22))),
                      TextButton(
                          key: const ValueKey('btn_page6'),
                          onPressed: () {
                            //Navigator.of(context).pushNamed('/page1');
                            router.pushNamed('/page6?test=1');
                          },
                          child: const Text("to page6",
                              style: TextStyle(fontSize: 22))),
                      TextButton(
                          key: const ValueKey('btn_tab1_page5'),
                          onPressed: () {
                            router.pushNamed('/tab1/page5');
                          },
                          child: const Text("/tab1/page5",
                              style: TextStyle(fontSize: 22))),        
                      TextButton(
                          key: const ValueKey('btn_tab2_page5'),
                          onPressed: () {
                            router.pushNamed('/tab2/page5');
                          },
                          child: const Text("/tab2/page5",
                              style: TextStyle(fontSize: 22))),
                      TextButton(
                          key: const ValueKey('btn_route_not_found'),
                          onPressed: () {
                            router.pushNamed('/abrakadabra');
                          },
                          child: const Text("Push to non existing route",
                              style: TextStyle(fontSize: 22))),        
                    ],
                  );
                }),
              ));
        });
  }
}

class RouteNotFoundPage extends StatelessWidget {
  const RouteNotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    print('build route not found page');
    return Scaffold(
        appBar: AppBar(
          leading: const BackButton(key: ValueKey('back_btn')),
          title: const Text("404")),
        body: const Center(
          child: Column(
            children: [
              Text(
                "404",
                style: TextStyle(fontSize: 22),
              ),
            ],
          ),
        ));
  }
}

class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    print('build page2');
    return Scaffold(
        appBar: AppBar(title: const Text("page2")),
        body: const Center(
          child: Column(
            children: [
              Text(
                "page2",
                style: TextStyle(fontSize: 22),
              ),
            ],
          ),
        ));
  }
}

class Page4 extends StatelessWidget {
  const Page4({super.key});

  @override
  Widget build(BuildContext context) {
    print('build tab1/page4');
    final router = AppRouter.of(context);
    return Scaffold(
        appBar: AppBar(
            leading: const BackButton(key: ValueKey('back_btn')),
            title: const Text("tab1/page4")),
        body: Center(
          child: Column(
            children: [
              const Text(
                "page4",
                style: TextStyle(fontSize: 22),
              ),
              TextButton(
                  onPressed: () {
                    router.pushNamed('/tab1/page5');
                  },
                  child:
                      const Text("to page5", style: TextStyle(fontSize: 22))),
              TextButton(
                  onPressed: () {
                    router.pushNamed('/tab1/nestedtest/page7');
                  },
                  child:
                      const Text("to page7", style: TextStyle(fontSize: 22))),
              TextButton(
                  onPressed: () {
                    router.pushNamed('/tab1/page4?test=2');
                  },
                  child: const Text("to page4?test=2",
                      style: TextStyle(fontSize: 22))),
              TextButton(
                  onPressed: () {
                    AppRouter.of(context).pop();
                  },
                  child:
                      const Text("test pop", style: TextStyle(fontSize: 22))),
            ],
          ),
        ));
  }
}

class Page5 extends StatelessWidget {
  const Page5({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.of(context);
    return Scaffold(
        appBar: AppBar(
            leading: const BackButton(key: ValueKey('back_btn')),
            title: const Text("page5")),
        body: Center(
          child: Column(
            children: [
              const Text(
                "page5",
                style: TextStyle(fontSize: 22),
              ),
              TextButton(
                  onPressed: () {
                    router.pushNamed('page9');
                  },
                  child: const Text("to tab2 page9",
                      style: TextStyle(fontSize: 22))),
            ],
          ),
        ));
  }
}

class Page9 extends StatelessWidget {
  const Page9({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.of(context);
    return Scaffold(
        appBar: AppBar(
            leading: const BackButton(key: ValueKey('back_btn')),
            title: const Text("page9")),
        body: Center(
          child: Column(
            children: [
              const Text(
                "page9",
                style: TextStyle(fontSize: 22),
              ),
              TextButton(
                  onPressed: () {
                    router.pushNamed('/tab2/page5');
                  },
                  child: const Text("to tab2 page5",
                      style: TextStyle(fontSize: 22))),
            ],
          ),
        ));
  }
}
