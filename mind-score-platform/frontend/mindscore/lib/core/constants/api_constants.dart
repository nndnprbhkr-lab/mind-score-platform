class ApiConstants {
  ApiConstants._();

  static const String _devBaseUrl = 'http://localhost:5041';
  static const String _prodBaseUrl = 'https://mindscore-api.onrender.com';

  static const bool _isProduction = bool.fromEnvironment('dart.vm.product');

  static String get baseUrl => _isProduction ? _prodBaseUrl : _devBaseUrl;

  static String get register => '$baseUrl/api/auth/register';
  static String get login    => '$baseUrl/api/auth/login';

  static String get tests     => '$baseUrl/api/tests';
  static String get questions => '$baseUrl/api/questions';
  static String get responses => '$baseUrl/api/responses';
  static String get results   => '$baseUrl/api/results';
  static String get reports   => '$baseUrl/api/reports';
}
