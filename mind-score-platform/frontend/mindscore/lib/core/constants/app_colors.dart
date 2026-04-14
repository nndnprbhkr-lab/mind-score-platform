import 'package:flutter/material.dart';

/// Centralised colour palette for the MindScore application.
///
/// All colours used anywhere in the UI must be referenced from this class
/// rather than defined inline, ensuring a single source of truth for the
/// brand palette.  This makes global theming changes trivial — one constant
/// update propagates everywhere.
///
/// Usage:
/// ```dart
/// Container(color: AppColors.accent)
/// Text('Hello', style: TextStyle(color: AppColors.textSecondary))
/// ```
class AppColors {
  // Prevent instantiation — this class is a pure namespace.
  AppColors._();

  // ── Core brand palette ────────────────────────────────────────────────────

  /// Deep navy — secondary dark surface, used for card backgrounds.
  static const Color primaryDark    = Color(0xFF1E0F3C);

  /// Mid-purple — card / container background colour.
  static const Color primaryMid     = Color(0xFF2A1850);

  /// Primary brand accent — violet, used for active elements and CTAs.
  static const Color accent         = Color(0xFF6B35C8);

  /// Lighter variant of the brand accent — labels, badges, secondary highlights.
  static const Color accentLight    = Color(0xFFA67CF0);

  /// Accent at 20 % opacity — applied as the selected answer tile background.
  ///
  /// The alpha channel (0x33 = 51 = ~20 %) creates a subtle selection state
  /// without obscuring the card border colour.
  static const Color accentSubtle   = Color(0x336B35C8);

  /// Brand highlight / secondary accent — pink-rose, used for CTAs and timers.
  static const Color highlight      = Color(0xFFFF6B9D);

  /// Light lavender surface — reserved for light-mode or surface overlays.
  static const Color surface        = Color(0xFFEDE8FF);

  /// Deepest background — root scaffold colour throughout the app.
  static const Color backgroundDark = Color(0xFF150A28);

  /// Primary text — pure white for high-contrast headings.
  static const Color textPrimary    = Color(0xFFFFFFFF);

  /// Secondary text — muted purple for body copy, descriptions, and metadata.
  static const Color textSecondary  = Color(0xFF9A85C8);

  /// Muted text — low-emphasis labels, hints, and disabled text.
  static const Color textMuted      = Color(0xFF5A4080);

  /// Option text — lighter purple applied to unselected answer options in the
  /// test screen, giving a clear visual hierarchy against selected options.
  static const Color optionText     = Color(0xFFC8B8F0);

  /// Card border — the subtle divider between a card surface and the background.
  static const Color cardBorder     = Color(0xFF3D2070);

  // ── Semantic aliases ──────────────────────────────────────────────────────
  // These map semantic intent to the raw palette, making widget code
  // self-documenting without scattering hex literals throughout the codebase.

  /// Alias for [accent] — the primary interactive / brand colour.
  static const Color primary        = accent;

  /// Alias for [accentLight] — lighter primary variant.
  static const Color primaryLight   = accentLight;

  /// Alias for [highlight] — secondary / pink accent.
  static const Color secondary      = highlight;

  /// Alias for [backgroundDark].
  static const Color backgroundLight = backgroundDark;

  /// Alias for [primaryMid] — dark card surface colour.
  static const Color surfaceDark    = primaryMid;

  /// Alias for [textMuted] — disabled / inactive text colour.
  static const Color textDisabled   = textMuted;

  /// Alias for [cardBorder] — divider line colour.
  static const Color divider        = cardBorder;

  // ── Status colours ────────────────────────────────────────────────────────

  /// Success state — green tones for positive feedback.
  static const Color success = Color(0xFF10B981);

  /// Warning state — amber for caution states.
  static const Color warning = Color(0xFFF59E0B);

  /// Error state — red for destructive actions and validation errors.
  static const Color error   = Color(0xFFEF4444);
}
