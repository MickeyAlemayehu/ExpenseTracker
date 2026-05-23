import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom-nav shell used by go_router's StatefulShellRoute. Each tab keeps its
/// own navigator stack so deep-linking back to a tab doesn't lose state.
class MainScaffold extends StatelessWidget {
  const MainScaffold({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const _items = [
    (icon: Icons.dashboard_rounded, label: 'Home'),
    (icon: Icons.receipt_long_rounded, label: 'Transactions'),
    (icon: Icons.pie_chart_rounded, label: 'Analytics'),
    (icon: Icons.account_balance_wallet_rounded, label: 'Budget'),
    (icon: Icons.settings_rounded, label: 'Settings'),
  ];

  void _onTap(int i) {
    navigationShell.goBranch(
      i,
      initialLocation: i == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: [
          for (final item in _items)
            NavigationDestination(
              icon: Icon(item.icon),
              label: item.label,
            ),
        ],
      ),
    );
  }
}
