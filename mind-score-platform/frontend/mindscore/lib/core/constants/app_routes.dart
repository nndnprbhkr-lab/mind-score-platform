class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String test = '/test/:testId';
  static String testWithId(String id) => '/test/$id';
  static const String results = '/results';
  static const String adminPanel = '/admin';
}
