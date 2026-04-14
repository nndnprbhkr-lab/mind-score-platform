// HTTP client abstraction for the MindScore backend API.
//
// All API calls in the app go through [ApiClient], which handles:
//   - JSON serialisation / deserialisation
//   - Attaching the JWT Authorization header for protected endpoints
//   - Normalising HTTP errors into typed [ApiException] objects
//
// Usage:
//   final json = await ApiClient.post(ApiConstants.login, body);
//   final list = await ApiClient.getList(ApiConstants.results);

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/token_storage.dart';

// ─── ApiException ─────────────────────────────────────────────────────────────

/// A typed exception thrown by [ApiClient] when the server returns a non-2xx
/// HTTP response.
///
/// The [statusCode] maps to the raw HTTP status (e.g. 401, 404, 500) and
/// [message] is extracted from the response body's `title` or `message`
/// field — or falls back to a generic description if neither is present.
///
/// Example handling:
/// ```dart
/// try {
///   final json = await ApiClient.post(url, body);
/// } on ApiException catch (e) {
///   showError(e.message); // e.g. "Invalid credentials."
/// }
/// ```
class ApiException implements Exception {
  /// The raw HTTP status code returned by the server.
  final int statusCode;

  /// Human-readable error message suitable for display to the user.
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

// ─── ApiClient ────────────────────────────────────────────────────────────────

/// A static HTTP client that wraps the `http` package for the MindScore API.
///
/// All methods are static for ergonomic use from Riverpod providers and
/// services without needing to inject an instance.  The class itself is
/// non-instantiable (private constructor).
class ApiClient {
  ApiClient._();

  /// Builds the base request headers, optionally adding the JWT bearer token.
  ///
  /// When [auth] is `true`, the stored token is read from [TokenStorage] and
  /// appended as `Authorization: Bearer <token>`.  If no token is found, the
  /// header is simply omitted (the server will respond with 401).
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

  /// Sends a `POST` request and returns the parsed JSON object.
  ///
  /// [url] should be an absolute URL from [ApiConstants].
  /// [body] is serialised to JSON automatically.
  /// Set [auth] to `true` for endpoints that require authentication.
  ///
  /// Throws [ApiException] on non-2xx responses.
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
    return _handleObject(response);
  }

  /// Sends a `PATCH` request to partially update a resource.
  ///
  /// Unlike [post], this returns `void` — callers only care whether the
  /// update succeeded (no body is expected on success).
  ///
  /// Throws [ApiException] on non-2xx responses.
  static Future<void> patch(
    String url,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    final response = await http.patch(
      Uri.parse(url),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    _assertSuccess(response);
  }

  /// Sends a `GET` request and returns the parsed JSON object.
  ///
  /// Defaults to [auth] = `true` since most GET endpoints are protected.
  ///
  /// Throws [ApiException] on non-2xx responses.
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

  /// Sends a `GET` request and returns the parsed JSON array.
  ///
  /// Use this for endpoints that return a list (e.g. `GET /api/results`).
  /// Defaults to [auth] = `true`.
  ///
  /// Throws [ApiException] on non-2xx responses.
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

  /// Parses a response body as a JSON object and returns it, or throws
  /// [ApiException] if the status code indicates an error.
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

  /// Asserts that [response] has a 2xx status code.
  ///
  /// Used for responses that carry no JSON body (e.g. PATCH).
  /// Throws [ApiException] otherwise.
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
