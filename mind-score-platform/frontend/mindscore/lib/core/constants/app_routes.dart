class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String history = '/history';
  static const String reports = '/reports';
  static const String profile = '/profile';
  static const String test = '/test/:testId';
  static String testWithId(String id) => '/test/$id';
  static const String results = '/results';
  static const String mindScoreResults = '/results/mindscore';
  static const String adminPanel = '/admin';
}
