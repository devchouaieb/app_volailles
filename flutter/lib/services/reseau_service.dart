import 'package:flutter/material.dart';
import 'package:app_volailles/models/reseau.dart';
import 'package:app_volailles/services/api_service.dart';

class ReseauService {
  final _apiService = ApiService();

  Future<List<Reseau>> getReseaux() async {
    try {
      print('🔄 Récupération des réseaux...');
      final response = await _apiService.get('reseaux');
      print('📦 Réponse API: $response');

      if (response is List) {
        final reseaux = response.map((json) => Reseau.fromApi(json)).toList();
        print('✅ ${reseaux.length} réseaux récupérés');
        return reseaux;
      } else if (response is Map && response['data'] is List) {
        final reseaux =
            (response['data'] as List)
                .map((json) => Reseau.fromApi(json))
                .toList();
        print('✅ ${reseaux.length} réseaux récupérés');
        return reseaux;
      }

      print('⚠️ Format de réponse invalide: $response');
      throw Exception('Format de réponse invalide');
    } catch (e) {
      print('⚠️ Erreur lors de la récupération des réseaux: $e');
      rethrow;
    }
  }

  Future<Reseau> createReseau(Reseau reseau) async {
    try {
      print('🔄 Création d\'un nouveau réseau...');
      final response = await _apiService.post('reseaux', reseau.toJson());
      print('📦 Réponse API: $response');

      if (response is Map) {
        final createdReseau = Reseau.fromApi(
          Map<String, dynamic>.from(response),
        );
        print('✅ Nouveau réseau créé: ${createdReseau.name}');
        return createdReseau;
      }

      print('⚠️ Format de réponse invalide: $response');
      throw Exception('Format de réponse invalide');
    } catch (e) {
      print('⚠️ Erreur lors de la création du réseau: $e');
      rethrow;
    }
  }

  Future<Reseau> updateReseau(String id, Reseau reseau) async {
    try {
      print('🔄 Mise à jour du réseau $id...');
      final response = await _apiService.put('reseaux/$id', reseau.toJson());
      print('📦 Réponse API: $response');

      if (response is Map) {
        final updatedReseau = Reseau.fromApi(
          Map<String, dynamic>.from(response),
        );
        print('✅ Réseau mis à jour: ${updatedReseau.name}');
        return updatedReseau;
      }

      print('⚠️ Format de réponse invalide: $response');
      throw Exception('Format de réponse invalide');
    } catch (e) {
      print('⚠️ Erreur lors de la mise à jour du réseau: $e');
      rethrow;
    }
  }

  Future<void> deleteReseau(String id) async {
    try {
      print('🔄 Suppression du réseau $id...');
      final response = await _apiService.delete('reseaux/$id');
      print('📦 Réponse API: $response');

      if (response == null || (response is Map && response['id'] == id)) {
        print('✅ Réseau supprimé avec succès');
        return;
      }

      print('⚠️ Format de réponse invalide: $response');
      throw Exception('Format de réponse invalide');
    } catch (e) {
      print('⚠️ Erreur lors de la suppression du réseau: $e');
      if (e.toString().contains('404')) {
        throw Exception('Réseau non trouvé');
      } else if (e.toString().contains('401')) {
        throw Exception('Non autorisé');
      } else if (e.toString().contains('500')) {
        throw Exception('Erreur serveur. Veuillez réessayer plus tard.');
      }
      rethrow;
    }
  }
}
