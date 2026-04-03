import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/token_storage.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();

  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final saved = await TokenStorage.load();
      if (saved != null) {
        headers['Authorization'] = 'Bearer ${saved.token}';
      }
    }
    return headers;
  }

  static Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    final response = await http.post(
      Uri.parse(url),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _handle(response);
  }

  static Future<Map<String, dynamic>> get(
    String url, {
    bool auth = true,
  }) async {
    final response = await http.get(
      Uri.parse(url),
      headers: await _headers(auth: auth),
    );
    return _handleObject(response);
  }

  static Future<List<dynamic>> getList(
    String url, {
    bool auth = true,
  }) async {
    final response = await http.get(
      Uri.parse(url),
      headers: await _headers(auth: auth),
    );
    _assertSuccess(response);
    final decoded = response.body.isNotEmpty ? jsonDecode(response.body) : [];
    return decoded as List<dynamic>;
  }

  static Map<String, dynamic> _handleObject(http.Response response) {
    final decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded as Map<String, dynamic>;
    }

    final body = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    final message = body['title'] as String? ??
        body['message'] as String? ??
        'Request failed (${response.statusCode})';

    throw ApiException(response.statusCode, message);
  }

  static void _assertSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    final body = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};
    final message = body['title'] as String? ??
        body['message'] as String? ??
        'Request failed (${response.statusCode})';
    throw ApiException(response.statusCode, message);
  }
}
