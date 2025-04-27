import 'package:app_volailles/models/association.dart';
import 'package:app_volailles/services/api_service.dart';

class AssociationService {
  final _apiService = ApiService();

  // Récupérer toutes les associations
  Future<List<Association>> getAssociations() async {
    try {
      print('🔄 Récupération des associations...');
      final response = await _apiService.get('associations');
      print('📦 Réponse API: $response');

      if (response is List) {
        final associations =
            response.map((json) => Association.fromApi(json)).toList();
        print('✅ ${associations.length} associations récupérées');
        return associations;
      } else if (response is Map && response['data'] is List) {
        final associations =
            (response['data'] as List)
                .map((json) => Association.fromApi(json))
                .toList();
        print('✅ ${associations.length} associations récupérées');
        return associations;
      }

      print('⚠️ Format de réponse invalide: $response');
      throw Exception('Format de réponse invalide');
    } catch (e) {
      print('⚠️ Erreur lors de la récupération des associations: $e');
      rethrow;
    }
  }

  // Récupérer une association par ID
  Future<Association?> getAssociation(String id) async {
    try {
      print('🔄 Récupération de l\'association $id...');
      final response = await _apiService.get('associations/$id');
      print('📦 Réponse API: $response');

      if (response is Map && response['data'] != null) {
        final association = Association.fromApi(response['data']);
        print('✅ Association récupérée avec succès');
        return association;
      }

      print('⚠️ Association non trouvée');
      return null;
    } catch (e) {
      print('⚠️ Erreur lors de la récupération de l\'association: $e');
      return null;
    }
  }

  // Créer une nouvelle association
  Future<Association> createAssociation(Association association) async {
    try {
      print('🔄 Création d\'une nouvelle association...');
      final response = await _apiService.post(
        'associations',
        association.toJson(),
      );
      print('📦 Réponse API: $response');

      if (response is Map) {
        final createdAssociation = Association.fromApi(
          Map<String, dynamic>.from(response),
        );
        print('✅ Nouvelle association créée: ${createdAssociation.name}');
        return createdAssociation;
      }

      print('⚠️ Format de réponse invalide: $response');
      throw Exception('Format de réponse invalide');
    } catch (e) {
      print('⚠️ Erreur lors de la création de l\'association: $e');
      rethrow;
    }
  }

  // Mettre à jour une association
  Future<Association> updateAssociation(
    String id,
    Association association,
  ) async {
    try {
      print('🔄 Mise à jour de l\'association $id...');
      final response = await _apiService.put(
        'associations/$id',
        association.toJson(),
      );
      print('📦 Réponse API: $response');

      if (response is Map) {
        final updatedAssociation = Association.fromApi(
          Map<String, dynamic>.from(response),
        );
        print('✅ Association mise à jour: ${updatedAssociation.name}');
        return updatedAssociation;
      }

      print('⚠️ Format de réponse invalide: $response');
      throw Exception('Format de réponse invalide');
    } catch (e) {
      print('⚠️ Erreur lors de la mise à jour de l\'association: $e');
      rethrow;
    }
  }

  // Supprimer une association
  Future<void> deleteAssociation(String id) async {
    try {
      print('🔄 Suppression de l\'association $id...');
      final response = await _apiService.delete('associations/$id');
      print('📦 Réponse API: $response');

      if (response == null || (response is Map && response['id'] == id)) {
        print('✅ Association supprimée avec succès');
        return;
      }

      print('⚠️ Format de réponse invalide: $response');
      throw Exception('Format de réponse invalide');
    } catch (e) {
      print('⚠️ Erreur lors de la suppression de l\'association: $e');
      if (e.toString().contains('404')) {
        throw Exception('Association non trouvée');
      } else if (e.toString().contains('401')) {
        throw Exception('Non autorisé');
      } else if (e.toString().contains('500')) {
        throw Exception('Erreur serveur. Veuillez réessayer plus tard.');
      }
      rethrow;
    }
  }
}
