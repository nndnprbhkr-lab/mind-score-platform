import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Cosmic Intelligence palette
  static const Color primaryDark   = Color(0xFF1E0F3C);
  static const Color primaryMid    = Color(0xFF2A1850);
  static const Color accent        = Color(0xFF6B35C8);
  static const Color accentLight   = Color(0xFFA67CF0);
  static const Color highlight     = Color(0xFFFF6B9D);
  static const Color surface       = Color(0xFFEDE8FF);
  static const Color backgroundDark = Color(0xFF150A28);
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9A85C8);
  static const Color textMuted     = Color(0xFF5A4080);
  static const Color cardBorder    = Color(0xFF3D2070);

  // Semantic aliases used throughout the app
  static const Color primary        = accent;
  static const Color primaryLight   = accentLight;
  static const Color secondary      = highlight;
  static const Color backgroundLight = backgroundDark;
  static const Color surfaceDark    = primaryMid;
  static const Color textDisabled   = textMuted;
  static const Color divider        = cardBorder;

  // Status colours (unchanged)
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error   = Color(0xFFEF4444);
}
