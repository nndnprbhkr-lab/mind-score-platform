/// Centralises all API endpoint URLs for the MindScore backend.
///
/// Automatically switches between [_devBaseUrl] and [_prodBaseUrl] based on
/// the Dart compile-time constant `dart.vm.product`, which is `true` in release
/// builds and `false` in debug/profile builds.  This avoids the need for
/// separate build configs or manual environment switching.
///
/// Usage:
/// ```dart
/// ApiClient.post(ApiConstants.login, body);
/// ApiClient.get(ApiConstants.results);
/// ```
class ApiConstants {
  // Prevent instantiation — this class is a pure namespace.
  ApiConstants._();

  /// Base URL used during local development (hot-reload / debug builds).
  static const String _devBaseUrl  = 'http://localhost:5041';

  /// Base URL for the production deployment on Render.
  static const String _prodBaseUrl = 'https://mind-score-backend.onrender.com';

  /// `true` when running as a release / production build.
  static const bool _isProduction = bool.fromEnvironment('dart.vm.product');

  /// Resolved base URL — switches between dev and prod automatically.
  static String get baseUrl => _isProduction ? _prodBaseUrl : _devBaseUrl;

  // ── Auth endpoints ─────────────────────────────────────────────────────────

  /// Create a new user account with name, email, and password.
  static String get register   => '$baseUrl/api/auth/register';

  /// Authenticate an existing user and receive a JWT token.
  static String get login      => '$baseUrl/api/auth/login';

  /// Create a temporary guest session — no email required.
  static String get guestLogin => '$baseUrl/api/auth/guest';

  // ── Resource endpoints ─────────────────────────────────────────────────────

  /// List all available assessments (MindType, MindScore).
  static String get tests     => '$baseUrl/api/tests';

  /// Retrieve ordered questions for a given test (filtered by age band for
  /// MindScore assessments).
  static String get questions => '$baseUrl/api/questions';

  /// Request the next adaptive question in a session.
  /// POST with [AdaptiveNextQuestionRequestDto] body.
  static String get questionsNext => '$baseUrl/api/questions/next';

  /// Submit user answers for server-side scoring.
  static String get responses => '$baseUrl/api/responses';

  /// Fetch all scored results for the authenticated user.
  static String get results   => '$baseUrl/api/results';

  /// Download or retrieve a signed URL for a generated PDF report.
  static String get reports   => '$baseUrl/api/reports';

  /// Read or update the authenticated user's profile (including date of birth).
  static String get userMe    => '$baseUrl/api/users/me';
}
