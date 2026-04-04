import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import 'nav_destinations.dart';

class AppBottomNav extends StatelessWidget {
  final String currentRoute;

  const AppBottomNav({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _selectedIndex(currentRoute);

    return NavigationBar(
      backgroundColor: AppColors.primaryMid,
      indicatorColor: AppColors.accent.withOpacity(0.18),
      selectedIndex: selectedIndex,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: (i) => context.go(appNavDestinations[i].route),
      destinations: appNavDestinations.map((d) {
        return NavigationDestination(
          icon: Icon(d.icon, color: AppColors.textSecondary),
          selectedIcon: Icon(d.activeIcon, color: AppColors.accent),
          label: d.label,
        );
      }).toList(),
    );
  }

  int _selectedIndex(String route) {
    for (int i = 0; i < appNavDestinations.length; i++) {
      if (route.startsWith(appNavDestinations[i].route)) return i;
    }
    return 0;
  }
}
