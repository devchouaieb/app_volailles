import 'dart:convert';
import 'package:app_volailles/config/config.dart';
import 'package:app_volailles/data/associations.dart' as data;
import 'package:app_volailles/services/auth_service.dart';
import 'package:http/http.dart' as http;

/// Service pour gérer les opérations liées aux associations
class AssociationService {
  final AuthService _authService = AuthService();

  /// Récupère l'association sélectionnée par l'utilisateur
  Future<data.Association?> getSelectedAssociation() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('${Config.baseUrl}/associations/selected'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          return data.Association.fromJson(responseData['data']);
        }
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération de l\'association: $e');
      return null;
    }
  }

  /// Sélectionne une association pour l'utilisateur
  Future<bool> selectAssociation(String associationName) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('${Config.baseUrl}/associations/select'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'associationName': associationName}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erreur lors de la sélection de l\'association: $e');
      return false;
    }
  }

  /// Met à jour l'année d'enregistrement de l'association
  Future<bool> updateRegistrationYear(String year) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('${Config.baseUrl}/associations/year-joined'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'registrationYear': year}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'année: $e');
      return false;
    }
  }

  /// Récupère la liste de toutes les associations
  Future<List<data.Association>> getAllAssociations() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('${Config.baseUrl}/associations'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          final List<dynamic> associationsJson = responseData['data'];
          return associationsJson
              .map((json) => data.Association.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Erreur lors de la récupération des associations: $e');
      return [];
    }
  }
}
