// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_volailles/config/config.dart';

class AuthService {
  final String baseUrl = Config.baseUrl;

  // Enregistrer un utilisateur
  Future<bool> register(
    String fullName,
    String nationalId,
    String email,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'fullName': fullName,
              'nationalId': nationalId,
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 201) {
        return true;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Erreur lors de l\'inscription');
      }
    } on http.ClientException {
      throw Exception(
        'Impossible de se connecter au serveur. Vérifiez votre connexion internet.',
      );
    } on FormatException {
      throw Exception('Erreur de format de réponse du serveur');
    } catch (e) {
      print('Erreur d\'inscription: $e');
      rethrow;
    }
  }

  // Connecter un utilisateur
  Future<Map<String, dynamic>> login(String nationalId, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'nationalId': nationalId, 'password': password}),
          )
          .timeout(const Duration(seconds: 5));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Sauvegarder le token et les informations utilisateur
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user', jsonEncode(data['user']));
        return data;
      } else {
        throw Exception(data['message'] ?? 'Identifiants invalides');
      }
    } on http.ClientException {
      throw Exception(
        'Impossible de se connecter au serveur. Vérifiez votre connexion internet.',
      );
    } on FormatException {
      throw Exception('Erreur de format de réponse du serveur');
    } catch (e) {
      print('Erreur de connexion: $e');
      rethrow;
    }
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    try {
      print('Checking if user is logged in...');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final hasToken = token != null;
      print('Token found: $hasToken');
      return hasToken;
    } catch (e) {
      print('Error checking login status: $e');
      // If there's any error, assume user is not logged in
      return false;
    }
  }

  // Récupérer le token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  // Récupérer les données utilisateur
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user');
      if (userData != null) {
        return jsonDecode(userData) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Déconnexion
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  // Mettre à jour les détails utilisateur
  Future<Map<String, dynamic>> updateDetails(
    String fullName,
    String email,
  ) async {
    try {
      final token = await getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/auth/updatedetails'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'fullName': fullName, 'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Mettre à jour les informations utilisateur stockées
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(data['data']));
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur lors de la mise à jour');
      }
    } catch (e) {
      print('Erreur de mise à jour: $e');
      rethrow;
    }
  }

  // Changer le mot de passe
  Future<bool> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final token = await getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/auth/updatepassword'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Mettre à jour le token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        return true;
      } else {
        throw Exception(
          data['message'] ?? 'Erreur lors du changement de mot de passe',
        );
      }
    } catch (e) {
      print('Erreur de changement de mot de passe: $e');
      rethrow;
    }
  }
}
