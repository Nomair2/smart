import 'package:flutter/material.dart';

import '../../../home/presentation/pages/home_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import 'alerts_placeholder_page.dart';
import 'routes_placeholder_page.dart';

/// The signed-in student's shell — bottom nav across Home / Routes / Alerts
/// / Profile (report Fig21's tab bar). An [IndexedStack] keeps each tab's
/// state alive when switching, rather than rebuilding from scratch.
class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _selectedIndex = 0;

  void _goToTab(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onOpenRoutes: () => _goToTab(1), onOpenProfile: () => _goToTab(3)),
      const RoutesPlaceholderPage(),
      const AlertsPlaceholderPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _goToTab,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFEAF3EE),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map_rounded), label: 'Routes'),
          NavigationDestination(
              icon: Icon(Icons.notifications_none_rounded),
              selectedIcon: Icon(Icons.notifications_rounded),
              label: 'Alerts'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
