// lib/services/http_interceptor.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app_volailles/services/auth_service.dart';

class AuthenticatedHttpClient {
  final http.Client _innerClient;
  final AuthService _authService;
  final BuildContext? context;

  AuthenticatedHttpClient({
    required AuthService authService,
    this.context,
    http.Client? innerClient,
  }) : _authService = authService,
       _innerClient = innerClient ?? http.Client();

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final authHeaders = await _addAuthHeader(headers ?? {});
    final response = await _innerClient.get(url, headers: authHeaders);
    return await _handleResponse(response);
  }

  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final authHeaders = await _addAuthHeader(headers ?? {});
    final response = await _innerClient.post(
      url,
      headers: authHeaders,
      body: body,
    );
    return await _handleResponse(response);
  }

  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final authHeaders = await _addAuthHeader(headers ?? {});
    final response = await _innerClient.put(
      url,
      headers: authHeaders,
      body: body,
    );
    return await _handleResponse(response);
  }

  Future<http.Response> delete(Uri url, {Map<String, String>? headers}) async {
    final authHeaders = await _addAuthHeader(headers ?? {});
    final response = await _innerClient.delete(url, headers: authHeaders);
    return await _handleResponse(response);
  }

  Future<Map<String, String>> _addAuthHeader(
    Map<String, String> headers,
  ) async {
    final token = await _authService.getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    if (!headers.containsKey('Content-Type')) {
      headers['Content-Type'] = 'application/json';
    }
    return headers;
  }

  Future<http.Response> _handleResponse(http.Response response) async {
    if (response.statusCode == 401) {
      // Token expiré ou invalide, déconnexion
      await _authService.logout();

      // Rediriger vers la page de connexion si un contexte est disponible
      if (context != null && context!.mounted) {
        // Mise à jour nécessaire pour utiliser le contexte correctement
        Navigator.of(
          context!,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }

    return response;
  }

  void close() {
    _innerClient.close();
  }
}
