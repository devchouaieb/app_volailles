import 'package:app_volailles/models/bird.dart';
import 'package:app_volailles/models/cage.dart';
import 'package:app_volailles/services/api_service.dart';
import 'package:app_volailles/utils/api_exception.dart';

class CageService {
  final _apiService = ApiService();

  Future<List<Cage>> getCages() async {
    try {
      print(' Récupération des cages...');
      print('🔄 Récupération des cages...');
      final response = await _apiService.get('cages');
      print('📦 Réponse API: $response');

      if (response is List) {
        final cages = response.map((json) => Cage.fromJson(json)).toList();
        print('✅ ${cages.length} cages récupérées');
        return cages;
      } else if (response is Map) {
        if (response['data'] is List) {
          final cages =
              (response['data'] as List)
                  .map((json) => Cage.fromJson(json))
                  .toList();
          print('✅ ${cages.length} cages récupérées');
          return cages;
        } else if (response['cages'] is List) {
          final cages =
              (response['cages'] as List)
                  .map((json) => Cage.fromJson(json))
                  .toList();
          print('✅ ${cages.length} cages récupérées');
          return cages;
        }
      }

      print('⚠️ Format de réponse invalide: $response');
      throw ApiException('Erreur lors de la récupération des cages.');
    } catch (e) {
      print('⚠️ Erreur lors de la récupération des cages: $e');
      if (e is ApiException) {
        rethrow;
      } else {
        throw ApiException('Erreur lors de la récupération des cages.');
      }

    }
  }

  Future<Cage> createCage(Cage cage) async {
    try {
      final response = await _apiService.post('cages', cage.toJson());
      if (response["success"] == true) {
        return Cage.fromJson(response['data']);
      } else {
        throw ApiException(
          response['message'] ?? "Erreur lors de la création de la cage.",
        );
      }
    } catch (e) {
      print('Error in createCage: $e');
      if (e is ApiException) {
        rethrow;
      } else {
        throw ApiException("Erreur lors de la création de la cage.");
      }
    }
  }

  Future<void> deleteCage(String id) async {
    try {
      final response = await _apiService.delete('cages/$id');
      if (response["success"] != true) {
        throw ApiException(
          response['message'] ?? "Erreur lors de la suppression de la cage.",
        );
      }
    } catch (e) {
      print('Error in deleteCage: $e');
      if (e is ApiException) {
        rethrow;
      } else {
        throw ApiException("Erreur lors de la suppression de la cage.");
      }
    }
  }

  Future<void> updateCageBirds(
    String cageId, {
    Bird? male,
    Bird? female,
  }) async {
    try {
      final response = await _apiService.put('cages/$cageId', {
        'male': male?.id,
        'female': female?.id,
      });
      if (response['success'] != true) {
        print('Failed to update cage birds: ${response['message']}');
        throw ApiException(
          response['message'] ??
              "Erreur lors de la mise à jour des oiseaux de la cage.",
        );
      }
    } catch (e) {
      print('Error in updateCageBirds: $e');
      if (e is ApiException) {
        rethrow;
      } else {
        throw ApiException(
          "Erreur lors de la mise à jour des oiseaux de la cage.",
        );
      }
    }
  }
}
