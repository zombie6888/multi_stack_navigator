import 'package:flutter/material.dart';
import 'package:multi_stack_navigator/multi_stack_navigator.dart';

import 'hardware_back_handler.dart';

class Page6 extends StatelessWidget {
  const Page6({super.key});

  @override
  Widget build(BuildContext context) {
    print('build page6');
    final router = AppRouter.of(context, true);
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
                    router.navigate('/tab2/page5');
                  },
                  child: const Text("/tab2/page5",
                      style: TextStyle(fontSize: 22))),
              TextButton(
                  onPressed: () {
                    router.navigate('/page8');
                  },
                  child: const Text("to page8 redirect",
                      style: TextStyle(fontSize: 22))),
              TextButton(
                  onPressed: () {
                    router.navigate('page6?test=2&testother=3');
                  },
                  child: const Text("page6?test=2&testother=3",
                      style: TextStyle(fontSize: 22))),
              TextButton(
                  key: const ValueKey('btn_replace_page6'),
                  onPressed: () {
                    router.replaceWith('/page6?test=2');
                  },
                  child: const Text("replace with /page6?test=2",
                      style: TextStyle(fontSize: 22))),
              TextButton(
                  key: const ValueKey('btn_replace_page8'),
                  onPressed: () {
                    router.replaceWith('/page8');
                  },
                  child: const Text("replace with page8",
                      style: TextStyle(fontSize: 22))),
              TextButton(
                  onPressed: () {
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
    return Scaffold(
        appBar: AppBar(
            leading: const BackButton(key: ValueKey('back_btn')),
            title: const Text("page8")),
        body: Center(
          child: Column(
            children: [
              const Text(
                "page8",
                style: TextStyle(fontSize: 22),
              ),
              TextButton(
                  onPressed: () {
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
    final router = AppRouter.of(context);
    return Scaffold(
        appBar: AppBar(title: const Text("page7")),
        body: Center(
          child: Column(
            children: [
              const Text(
                "page7",
                style: TextStyle(fontSize: 22),
              ),
              TextButton(
                  key: const ValueKey('btn_tab1_page5'),
                  onPressed: () {
                    router.replaceWith('/tab1/page5');
                  },
                  child: const Text("replace with /tab1/page5",
                      style: TextStyle(fontSize: 22)))
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
                    router.navigate('/tab3/page2');
                  },
                  child:
                      const Text("to page2", style: TextStyle(fontSize: 22))),
              TextButton(
                  key: const ValueKey('btn_tab2_page5'),
                  onPressed: () {
                    router.navigate('/tab2/page5');
                  },
                  child: const Text("to tab2 page5",
                      style: TextStyle(fontSize: 22))),
              TextButton(
                  key: const ValueKey('btn_tab2_page8'),
                  onPressed: () {
                    router.navigate('/tab2/page8');
                  },
                  child:
                      const Text("to page8", style: TextStyle(fontSize: 22))),
              TextButton(
                  key: const ValueKey('btn_tab1_page4'),
                  onPressed: () {
                    router.navigate('/tab1/page4?test=1');
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
          print(
              'Home page navigation event. event type: ${snapshot.data?.type}, current location: ${snapshot.data?.currentLocation}, previous location: ${snapshot.data?.previousLocation}');
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
                            router.navigate('/tab2/page1');
                          },
                          child: const Text("to page1",
                              style: TextStyle(fontSize: 22))),
                      TextButton(
                          key: const ValueKey('btn_tab1_page4'),
                          onPressed: () {
                            router.navigate('/tab1/page4?test=1');
                          },
                          child: const Text("to page4",
                              style: TextStyle(fontSize: 22))),
                      TextButton(
                          key: const ValueKey('btn_page6'),
                          onPressed: () {
                            router.navigate('/page6?test=1');
                          },
                          child: const Text("to page6",
                              style: TextStyle(fontSize: 22))),
                      TextButton(
                          key: const ValueKey('btn_tab1_page5'),
                          onPressed: () {
                            router.navigate('/tab1/page5');
                          },
                          child: const Text("/tab1/page5",
                              style: TextStyle(fontSize: 22))),
                      TextButton(
                          key: const ValueKey('btn_tab2_page5'),
                          onPressed: () {
                            router.navigate('/tab2/page5');
                          },
                          child: const Text("/tab2/page5",
                              style: TextStyle(fontSize: 22))),
                      TextButton(
                          key: const ValueKey('btn_route_not_found'),
                          onPressed: () {
                            router.navigate('/abrakadabra');
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
                    router.navigate('/tab1/page5');
                  },
                  child:
                      const Text("to page5", style: TextStyle(fontSize: 22))),
              TextButton(
                  key: const ValueKey('btn_tab1_nestedtest_page7'),
                  onPressed: () {
                    router.navigate('/tab1/nestedtest/page7');
                  },
                  child: const Text("to tab1/nestedtest/page7",
                      style: TextStyle(fontSize: 22))),
              TextButton(
                  onPressed: () {
                    router.navigate('/tab1/page4?test=2');
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

  showDialog(BuildContext context) {
    showGeneralDialog<String>(
        context: context,
        useRootNavigator: true,
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return Container(
            color: Colors.white,
            child: SafeArea(
                child: Stack(children: [
              BackButtonListener(
                  onBackButtonPressed: () {
                    print('modal back pressed');
                    return Future.value(true);
                  },
                  child: const Scaffold(body: const Text("modal"))),
              Positioned(
                  top: 5,
                  right: 5,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Icon(Icons.close, color: Colors.black),
                    ),
                  )),
            ])),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.of(context);
    print('build page 5');
    return HardwareBackHandler(
      onBackButtonPressed: () {
        print('page 5 back dispatcher!');
        return Future.value(true);
      },
      child: Scaffold(
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
                      router.navigate('page9');
                    },
                    child: const Text("to related path page9",
                        style: TextStyle(fontSize: 22))),
                TextButton(
                    key: const ValueKey('btn_show_modal'),
                    onPressed: () {
                      showDialog(context);
                    },
                    child: const Text("show modal",
                        style: TextStyle(fontSize: 22))),
              ],
            ),
          )),
    );
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
                    router.navigate('/tab2/page5');
                  },
                  child: const Text("to tab2 page5",
                      style: TextStyle(fontSize: 22))),
            ],
          ),
        ));
  }
}
