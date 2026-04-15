/// Centralises all named route paths used with [GoRouter].
///
/// Using a single constants class ensures that any route rename propagates
/// everywhere via a single edit rather than through scattered string literals,
/// and prevents typos that would cause silent navigation failures at runtime.
///
/// Usage:
/// ```dart
/// context.go(AppRoutes.dashboard);
/// context.go(AppRoutes.testWithId('abc-123'));
/// ```
class AppRoutes {
  // Prevent instantiation — this class is a pure namespace.
  AppRoutes._();

  /// Login screen — entry point for returning registered users.
  static const String login            = '/login';

  /// Registration screen — new account creation flow.
  static const String register         = '/register';

  /// Main dashboard — lists available assessments and recent activity.
  static const String dashboard        = '/dashboard';

  /// Historical results list — shows all past completed assessments.
  static const String history          = '/history';

  /// PDF report downloads page.
  static const String reports          = '/reports';

  /// User profile / account settings screen.
  static const String profile          = '/profile';

  /// Context selection screen — lets the user pick the lens for their
  /// assessment before the adaptive session begins.
  static const String contextSelection = '/context-selection';

  /// Assessment test screen — parameterised by [testId].
  ///
  /// Use [testWithId] to construct the concrete path for navigation.
  static const String test             = '/test/:testId';

  /// MPI (MindType Profile Inventory) results screen.
  ///
  /// Displays personality type code, radar chart, strengths, growth areas,
  /// career paths, and a downloadable PDF report.
  static const String results          = '/results';

  /// MindScore cognitive-performance results screen.
  ///
  /// Shows overall score tier, per-module percentiles, and recommended
  /// action steps tailored to the user's age band.
  static const String mindScoreResults = '/results/mindscore';

  /// Admin panel — restricted to users with the `admin` role.
  static const String adminPanel       = '/admin';

  /// Constructs the concrete test route path for a specific assessment.
  ///
  /// Example:
  /// ```dart
  /// context.go(AppRoutes.testWithId('abc-123')); // navigates to /test/abc-123
  /// ```
  static String testWithId(String id) => '/test/$id';
}
