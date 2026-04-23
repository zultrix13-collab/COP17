import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _tabs = [
    ('/home', Icons.home_outlined, 'Home'),
    ('/programme', Icons.calendar_month_outlined, 'Prog'),
    ('/information', Icons.info_outline, 'Info'),
    ('/services', Icons.shopping_bag_outlined, 'Serv'),
    ('/map', Icons.map_outlined, 'Map'),
    ('/profile', Icons.person_outline, 'Me'),
  ];

  int _currentIndex(String location) {
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].$1)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final idx = _currentIndex(location);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) => context.go(_tabs[i].$1),
        destinations: [
          for (final t in _tabs) NavigationDestination(icon: Icon(t.$2), label: t.$3),
        ],
      ),
    );
  }
}
