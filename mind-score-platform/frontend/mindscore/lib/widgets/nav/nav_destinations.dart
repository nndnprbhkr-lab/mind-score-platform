import 'package:flutter/material.dart';
import '../../core/constants/app_routes.dart';

class NavDestination {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const NavDestination({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}

const List<NavDestination> appNavDestinations = [
  NavDestination(
    label: 'Home',
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    route: AppRoutes.dashboard,
  ),
  NavDestination(
    label: 'History',
    icon: Icons.history_outlined,
    activeIcon: Icons.history_rounded,
    route: AppRoutes.history,
  ),
  NavDestination(
    label: 'Reports',
    icon: Icons.bar_chart_outlined,
    activeIcon: Icons.bar_chart_rounded,
    route: AppRoutes.reports,
  ),
  NavDestination(
    label: 'Profile',
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
    route: AppRoutes.profile,
  ),
];
