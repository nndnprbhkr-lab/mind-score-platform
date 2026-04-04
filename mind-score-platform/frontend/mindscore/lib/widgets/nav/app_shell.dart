import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import 'app_bottom_nav.dart';
import 'app_sidebar.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final screenSize = Responsive.of(context);

    if (screenSize == ScreenSize.mobile) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: child,
        bottomNavigationBar: AppBottomNav(currentRoute: location),
      );
    }

    // Tablet and desktop: sidebar layout
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Row(
        children: [
          AppSidebar(currentRoute: location),
          Expanded(child: child),
        ],
      ),
    );
  }
}
