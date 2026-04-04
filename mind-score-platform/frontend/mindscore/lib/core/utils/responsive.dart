import 'package:flutter/material.dart';

enum ScreenSize { mobile, tablet, desktop }

class Responsive {
  Responsive._();

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  // Keep underscore aliases for any existing callers
  static const double _mobileBreakpoint = mobileBreakpoint;
  static const double _tabletBreakpoint = tabletBreakpoint;

  static ScreenSize of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < _mobileBreakpoint) return ScreenSize.mobile;
    if (width < _tabletBreakpoint) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }

  static bool isMobile(BuildContext context) => of(context) == ScreenSize.mobile;
  static bool isTablet(BuildContext context) => of(context) == ScreenSize.tablet;
  static bool isDesktop(BuildContext context) => of(context) == ScreenSize.desktop;

  static double contentMaxWidth(BuildContext context) {
    return switch (of(context)) {
      ScreenSize.mobile  => double.infinity,
      ScreenSize.tablet  => 720,
      ScreenSize.desktop => 1100,
    };
  }

  static int gridColumns(BuildContext context) {
    return switch (of(context)) {
      ScreenSize.mobile  => 1,
      ScreenSize.tablet  => 2,
      ScreenSize.desktop => 3,
    };
  }

  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    return switch (of(context)) {
      ScreenSize.mobile  => mobile,
      ScreenSize.tablet  => tablet ?? desktop,
      ScreenSize.desktop => desktop,
    };
  }
}

/// Switches between mobile / tablet / desktop builders using LayoutBuilder so
/// it reacts to widget-tree width rather than the full screen width.
class ResponsiveWrapper extends StatelessWidget {
  final Widget Function(BuildContext) mobile;
  final Widget Function(BuildContext)? tablet;
  final Widget Function(BuildContext) desktop;

  const ResponsiveWrapper({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        if (w >= Responsive.tabletBreakpoint) return desktop(context);
        if (w >= Responsive.mobileBreakpoint) return (tablet ?? desktop)(context);
        return mobile(context);
      },
    );
  }
}
