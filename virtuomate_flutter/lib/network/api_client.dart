import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:virtuomate_flutter/network/connection_error.dart';

typedef TokenProvider = Future<String?> Function();

class ApiClient {
  ApiClient({required String baseUrl, required TokenProvider tokenProvider})
    : _baseUrl = baseUrl,
      _tokenProvider = tokenProvider;

  final String _baseUrl;
  final TokenProvider _tokenProvider;

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<Map<String, dynamic>> getJson(String path) async {
    try {
      final token = await _tokenProvider();
      final response = await http
          .get(_uri(path), headers: _headers(token))
          .timeout(const Duration(seconds: 30));
      return _decode(response);
    } on TimeoutException catch (e) {
      throw Exception(friendlyConnectionError(e, apiBaseUrl: _baseUrl));
    } on SocketException catch (e) {
      throw Exception(friendlyConnectionError(e, apiBaseUrl: _baseUrl));
    } on http.ClientException catch (e) {
      throw Exception(friendlyConnectionError(e, apiBaseUrl: _baseUrl));
    }
  }

  /// Public endpoints (e.g. demo login) that do not require a Firebase ID token.
  Future<Map<String, dynamic>> postJsonUnauthenticated(
    String path,
    Map<String, dynamic> payload,
  ) async {
    final response = await http
        .post(
          _uri(path),
          headers: _headers(null),
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 30));
    return _decode(response);
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> payload, {
    Duration timeout = const Duration(seconds: 90),
  }) async {
    try {
      final token = await _tokenProvider();
      final response = await http
          .post(
            _uri(path),
            headers: _headers(token),
            body: jsonEncode(payload),
          )
          .timeout(timeout);
      return _decode(response);
    } on TimeoutException catch (e) {
      throw Exception(friendlyConnectionError(e, apiBaseUrl: _baseUrl));
    } on SocketException catch (e) {
      throw Exception(friendlyConnectionError(e, apiBaseUrl: _baseUrl));
    } on http.ClientException catch (e) {
      throw Exception(friendlyConnectionError(e, apiBaseUrl: _baseUrl));
    }
  }

  Future<Map<String, dynamic>> putJson(
    String path,
    Map<String, dynamic> payload,
  ) async {
    final token = await _tokenProvider();
    final response = await http.put(
      _uri(path),
      headers: _headers(token),
      body: jsonEncode(payload),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> deleteJson(String path) async {
    final token = await _tokenProvider();
    final response = await http.delete(_uri(path), headers: _headers(token));
    return _decode(response);
  }

  Map<String, String> _headers(String? token) => {
    'Content-Type': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  Map<String, dynamic> _decode(http.Response response) {
    if (response.statusCode >= 400) {
      final snippet = response.body.length > 200
          ? '${response.body.substring(0, 200)}…'
          : response.body;
      try {
        final errJson = jsonDecode(response.body) as Map<String, dynamic>;
        final code = errJson['code']?.toString();
        final errText = errJson['error']?.toString() ?? 'API request failed (${response.statusCode}).';
        final detail = errJson['detail']?.toString().trim();
        final fullErr = (detail != null && detail.isNotEmpty) ? '$errText: $detail' : errText;
        if (response.statusCode == 401) {
          throw Exception('Please sign in again to use cloud features.');
        }
        if (response.statusCode == 402 || code == 'SESSION_LIMIT') {
          throw Exception(fullErr);
        }
        throw Exception(fullErr);
      } catch (e) {
        if (e is Exception &&
            !e.toString().contains('FormatException') &&
            !e.toString().startsWith('Exception: Invalid')) {
          rethrow;
        }
        throw Exception(
          'API request failed (${response.statusCode}): '
          '${snippet.isEmpty ? "non-JSON response" : snippet}',
        );
      }
    }

    if (response.body.isEmpty) return <String, dynamic>{};

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw const FormatException('Expected JSON object');
    } on FormatException catch (e) {
      final snippet = response.body.length > 120
          ? '${response.body.substring(0, 120)}…'
          : response.body;
      throw Exception(
        'Server returned invalid JSON (${response.statusCode}): $snippet. '
        'Original: $e',
      );
    }
  }
}
