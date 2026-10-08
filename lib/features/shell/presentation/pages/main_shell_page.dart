import 'package:MasarKKU/features/notifications/presentation/pages/notifications_page.dart';
import 'package:MasarKKU/features/routing/presentation/pages/route_selection_page.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import 'alerts_placeholder_page.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final pages = [
      HomePage(
        onOpenRoutes: () => _goToTab(1),
        onOpenProfile: () => _goToTab(3),
      ),
      // const RoutesPlaceholderPage(),
      const RouteSelectionPage(),
      // const AlertsPlaceholderPage(),
      NotificationsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _goToTab,
        // Was hardcoded Colors.white / Color(0xFFEAF3EE) — theme tokens
        // so the always-visible nav bar actually responds to dark mode.
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: Theme.of(context).colorScheme.primaryContainer,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map_rounded),
            label: l10n.navRoutes,
          ),
          NavigationDestination(
            icon: const Icon(Icons.notifications_none_rounded),
            selectedIcon: const Icon(Icons.notifications_rounded),
            label: l10n.navAlerts,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}
