import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../notifications/push_registration.dart';

class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  // (Path, Inactive Icon, Active Icon, Label)
  static const _tabs = [
    ('/home', Icons.home_outlined, Icons.home, 'Home'),
    ('/programme', Icons.calendar_month_outlined, Icons.calendar_month, 'Agenda'),
    ('/information', Icons.feed_outlined, Icons.feed, 'Info'),
    ('/services', Icons.eco_outlined, Icons.eco, 'Services'),
    ('/map', Icons.pin_drop_outlined, Icons.pin_drop, 'Map'),
    ('/profile', Icons.person_outline, Icons.person, 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    registerPushToken(ref);
  }

  @override
  void dispose() {
    cancelPushRegistration();
    super.dispose();
  }

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
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) => context.go(_tabs[i].$1),
        destinations: [
          for (final t in _tabs)
            NavigationDestination(
              icon: Icon(t.$2),
              selectedIcon: Icon(t.$3),
              label: t.$4,
            ),
        ],
      ),
    );
  }
}
