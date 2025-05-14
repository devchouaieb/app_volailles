import 'dart:convert';

import 'package:app_volailles/config/config.dart';
import 'package:app_volailles/services/auth_service.dart';
import 'package:app_volailles/utils/api_exception.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = Config.baseUrl;
  final AuthService _authService = AuthService();

  // Test de connexion au serveur
  Future<bool> testConnection() async {
    try {
      print('🔍 Test de connexion au serveur...');
      print('🌐 URL de test: $baseUrl/auth/me');

      final token = await _authService.getToken();
      if (token == null) {
        print('⚠️ Aucun token trouvé, test de connexion de base');
        // Si pas de token, tester juste la connexion de base
        final response = await http
            .get(Uri.parse('$baseUrl/auth/login'))
            .timeout(const Duration(seconds: 5));

        print('📊 Code de statut (login): ${response.statusCode}');
        return response.statusCode < 500;
      }

      // Tester avec le token
      final response = await http
          .get(
            Uri.parse('$baseUrl/auth/me'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 5));

      print('📊 Code de statut: ${response.statusCode}');
      print('📦 Réponse: ${response.body}');

      return response.statusCode < 500;
    } catch (e) {
      print('⚠️ Erreur de test de connexion: $e');
      return false;
    }
  }

  // Méthode GET avec token d'authentification
  Future<dynamic> get(String endpoint) async {
    try {
      // Test de connexion avant chaque requête
      final isConnected = await testConnection();
      if (!isConnected) {
        throw ApiException(
          'Impossible de se connecter au serveur. \n '
              'Vérifiez votre connexion internet'

        );
      }

      final token = await _authService.getToken();
      final fullUrl = '$baseUrl/$endpoint';
      print('🌐 URL complète: $fullUrl');
      print('🔑 Token: ${token != null ? 'présent' : 'absent'}');

      final response = await http
          .get(
            Uri.parse(fullUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw Exception(
                'La requête a expiré. Veulliez réssayer\n'
               ,
              );
            },
          );

      print('📊 Code de statut: ${response.statusCode}');
      print('📦 Réponse brute: ${response.body}');

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        print('📦 Réponse décodée: $decodedResponse');
        return decodedResponse;
      } else if (response.statusCode == 401) {
        await _authService.logout();
        throw ApiException('Session expirée. Veuillez vous reconnecter.');
      } else if (response.statusCode == 404) {
        throw ApiException(
          'Le serveur n\'est pas accessible.\n'
              ' Vérifiez  votre connexion internet'

       );
      } else {
        throw Exception(
          'Erreur lors de la requête: ${response.statusCode}\n'
          'Message: ${response.body}',
        );
      }
    } on http.ClientException catch (e) {
      print('⚠️ Erreur client: $e');
      throw ApiException(
        'Impossible de se connecter au serveur. Vérifiez réssayer',
      );
    } catch (e) {
      print('⚠️ Erreur réseau: $e');
      if (e is ApiException) {
        rethrow;
      } else {
        throw Exception('Erreur de connexion');
      }
    }
  }

  // Méthode POST avec token d'authentification
  Future<dynamic> post(String endpoint, dynamic data) async {
    try {
      final token = await _authService.getToken();
      final fullUrl = '$baseUrl/$endpoint';
      print('🔄 POST request à: $fullUrl');
      print('📝 Données: $data');

      final response = await http.post(
        Uri.parse(fullUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      print('📊 Code de statut: ${response.statusCode}');
      print('📦 Réponse brute: ${response.body}');
      final decodedResponse = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('📦 Réponse décodée: $decodedResponse');
        return decodedResponse;
      } else if (response.statusCode == 401) {
        await _authService.logout();
        throw ApiException('Session expirée. Veuillez vous reconnecter.');
      } else {
        throw ApiException(
          decodedResponse['message'] ??
              'Erreur lors de la requête: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('⚠️ Erreur réseau: $e');
      if (e is ApiException) {
        rethrow;
      } else {
        throw Exception('Erreur réseau: $e');
    }}
  }

  // Méthode PUT avec token d'authentification
  Future<dynamic> put(String endpoint, dynamic data) async {
    try {
      final token = await _authService.getToken();
      final fullUrl = '$baseUrl/$endpoint';
      print('🔄 PUT request à: $fullUrl');
      print('📝 Données: $data');

      final response = await http.put(
        Uri.parse(fullUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      print('📊 Code de statut: ${response.statusCode}');
      print('📦 Réponse brute: ${response.body}');
      final decodedResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print('📦 Réponse décodée: $decodedResponse');
        return decodedResponse;
      } else if (response.statusCode == 401) {
        await _authService.logout();
        throw ApiException('Session expirée. Veuillez vous reconnecter.');
      } else {
        throw ApiException(
          decodedResponse['message'] ??
              'Erreur lors de la requête: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('⚠️ Erreur réseau: $e');
      if (e is ApiException) {
        rethrow;
      } else {
        throw Exception('Erreur réseau: $e');
      }
    }
  }

  // Méthode DELETE avec token d'authentification
  Future<dynamic> delete(String endpoint) async {
    try {
      final token = await _authService.getToken();
      final fullUrl = '$baseUrl/$endpoint';
      print('🔄 DELETE request à: $fullUrl');

      final response = await http.delete(
        Uri.parse(fullUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📊 Code de statut: ${response.statusCode}');
      print('📦 Réponse brute: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body.isEmpty) {
          return null;
        }
        final decodedResponse = jsonDecode(response.body);
        print('📦 Réponse décodée: $decodedResponse');
        return decodedResponse;
      } else if (response.statusCode == 401) {
        await _authService.logout();
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      } else {
        throw Exception('Erreur lors de la requête: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Erreur réseau: $e');
      throw Exception('Erreur réseau: $e');
    }
  }
}
