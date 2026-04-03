import 'package:flutter/material.dart';

enum ScreenSize { mobile, tablet, desktop }

class Responsive {
  Responsive._();

  static const double _mobileBreakpoint = 600;
  static const double _tabletBreakpoint = 1024;

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
      ScreenSize.mobile => double.infinity,
      ScreenSize.tablet => 720,
      ScreenSize.desktop => 1100,
    };
  }

  static int gridColumns(BuildContext context) {
    return switch (of(context)) {
      ScreenSize.mobile => 1,
      ScreenSize.tablet => 2,
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
      ScreenSize.mobile => mobile,
      ScreenSize.tablet => tablet ?? desktop,
      ScreenSize.desktop => desktop,
    };
  }
}
