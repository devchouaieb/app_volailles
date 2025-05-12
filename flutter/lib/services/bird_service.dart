// lib/services/bird_service.dart
import 'package:flutter/material.dart';
import 'package:app_volailles/models/bird.dart';
import 'package:app_volailles/services/api_service.dart';

class BirdService {
  final _apiService = ApiService();

  // Convertir le genre en anglais pour l'API
  Map<String, dynamic> _convertGenderForApi(Map<String, dynamic> data) {
    final Map<String, dynamic> converted = Map<String, dynamic>.from(data);
    if (converted['gender'] == 'mâle') {
      converted['gender'] = 'male';
    } else if (converted['gender'] == 'femelle') {
      converted['gender'] = 'female';
    }
    return converted;
  }

  // Récupérer tous les oiseaux
  Future<List<Bird>> getBirds() async {
    try {
      print('🔄 Récupération des oiseaux...');
      final response = await _apiService.get('birds');
      print('📦 Réponse API: $response');

      if (response is List) {
        final birds = response.map((json) => Bird.fromApi(json)).toList();
        print('✅ ${birds.length} oiseaux récupérés');
        return birds;
      } else if (response is Map) {
        if (response['data'] is List) {
          final birds =
              (response['data'] as List)
                  .map((json) => Bird.fromApi(json))
                  .toList();
          print('✅ ${birds.length} oiseaux récupérés');
          return birds;
        } else if (response['birds'] is List) {
          final birds =
              (response['birds'] as List)
                  .map((json) => Bird.fromApi(json))
                  .toList();
          print('✅ ${birds.length} oiseaux récupérés');
          return birds;
        }
      }

      print('⚠️ Format de réponse invalide: $response');
      throw Exception('Format de réponse invalide');
    } catch (e) {
      print('⚠️ Erreur lors de la récupération des oiseaux: $e');
      rethrow;
    }
  }

  // Récupérer les oiseaux vendus
  Future<List<Bird>> getSoldBirds() async {
    try {
      print('🔄 Récupération des oiseaux vendus...');
      final response = await _apiService.get('birds/sold');
      print('📦 Réponse API: $response');
      if (response is List) {
        final birds = response.map((json) => Bird.fromApi(json)).toList();
        print('✅ ${birds.length} oiseaux récupérés');
        return birds;
      } else if (response is Map && response['data'] is List) {
        final birds =
            (response['data'] as List)
                .map((json) => Bird.fromApi(json))
                .toList();
        print('✅ ${birds.length} oiseaux vendus récupérés');
        return birds;
      }

      print('⚠️ Format de réponse invalide: $response');
      return [];
    } catch (e) {
      print('⚠️ Erreur lors de la récupération des oiseaux vendus: $e');
      return [];
    }
  }

  // Récupérer les oiseaux vendus par un vendeur spécifique
  Future<List<Bird>> getSoldBirdsBySeller(String sellerId) async {
    try {
      print('🔄 Récupération des oiseaux vendus par le vendeur $sellerId...');
      final response = await _apiService.get('birds/sold/seller/$sellerId');
      print('📦 Réponse API: $response');

      if (response is Map && response['data'] is List) {
        final birds =
            (response['data'] as List)
                .map((json) => Bird.fromApi(json))
                .toList();
        print('✅ ${birds.length} oiseaux vendus par ce vendeur récupérés');
        return birds;
      }

      print('⚠️ Format de réponse invalide: $response');
      return [];
    } catch (e) {
      print(
        '⚠️ Erreur lors de la récupération des oiseaux vendus par vendeur: $e',
      );
      return [];
    }
  }

  // Récupérer les oiseaux vendus avec les informations des acheteurs
  Future<List<Bird>> getSoldBirdsWithBuyers() async {
    try {
      print(
        '🔄 Récupération des oiseaux vendus avec informations acheteurs...',
      );
      final response = await _apiService.get('birds/sold/with-buyers');
      print('📦 Réponse API: $response');

      if (response is Map && response['data'] is List) {
        final birds =
            (response['data'] as List)
                .map((json) => Bird.fromApi(json))
                .toList();
        print('✅ ${birds.length} oiseaux vendus avec acheteurs récupérés');
        return birds;
      }

      print('⚠️ Format de réponse invalide: $response');
      return [];
    } catch (e) {
      print(
        '⚠️ Erreur lors de la récupération des oiseaux vendus par vendeur: $e',
      );
      return [];
    }
  }

  // Récupérer un oiseau par ID
  Future<Bird?> getBird(String id) async {
    try {
      print('🔄 Récupération de l\'oiseau $id...');
      final response = await _apiService.get('birds/$id');
      print('📦 Réponse API: $response');

      if (response is Map ) {
        final bird = Bird.fromApi(Map<String, dynamic>.from(response));
        print('✅ Oiseau récupéré avec succès');
        return bird;
      }

      print('⚠️ Oiseau non trouvé');
      return null;
    } catch (e) {
      print('⚠️ Erreur lors de la récupération de l\'oiseau: $e');
      return null;
    }
  }

  // Créer un nouvel oiseau
  Future<Bird> createBird(Bird bird) async {
    try {
      print('🔄 Création d\'un nouvel oiseau...');
      final jsonData = _convertGenderForApi(bird.toJson());
      final response = await _apiService.post('birds', jsonData);
      print('📦 Réponse API: $response');

      if (response is Map) {
        final data = response['data'] ?? response;
        final createdBird = Bird.fromApi(Map<String, dynamic>.from(data));
        print('✅ Nouvel oiseau créé: ${createdBird.identifier}');
        return createdBird;
      }

      print('⚠️ Format de réponse invalide: $response');
      throw Exception('Format de réponse invalide');
    } catch (e) {
      print('⚠️ Erreur lors de la création de l\'oiseau: $e');
      rethrow;
    }
  }

  // Mettre à jour un oiseau
  Future<Bird> updateBird(String id, Bird bird) async {
    try {
      print('🔄 Mise à jour de l\'oiseau $id...');
      final jsonData = _convertGenderForApi(bird.toJson());
      final response = await _apiService.put('birds/$id', jsonData);
      print('📦 Réponse API: $response');

      if (response is Map) {
        final data = response['data'] ?? response;
        final updatedBird = Bird.fromApi(Map<String, dynamic>.from(data));
        print('✅ Oiseau mis à jour: ${updatedBird.identifier}');
        return updatedBird;
      }

      print('⚠️ Format de réponse invalide: $response');
      throw Exception('Format de réponse invalide');
    } catch (e) {
      print('⚠️ Erreur lors de la mise à jour de l\'oiseau: $e');
      rethrow;
    }
  }

  // Supprimer un oiseau
  Future<void> deleteBird(String id) async {
    try {
      print('🔄 Suppression de l\'oiseau $id...');
      final response = await _apiService.delete('birds/$id');
      print('📦 Réponse API: $response');

      if (response == null || (response is Map && response['id'] == id)) {
        print('✅ Oiseau supprimé avec succès');
        return;
      }

      print('⚠️ Format de réponse invalide: $response');
      throw Exception('Format de réponse invalide');
    } catch (e) {
      print('⚠️ Erreur lors de la suppression de l\'oiseau: $e');
      if (e.toString().contains('404')) {
        throw Exception('Oiseau non trouvé');
      } else if (e.toString().contains('401')) {
        throw Exception('Non autorisé');
      } else if (e.toString().contains('500')) {
        throw Exception('Erreur serveur. Veuillez réessayer plus tard.');
      }
      rethrow;
    }
  }

  // Marquer un oiseau comme vendu
  Future<Bird> sellBird(
    String id,
    double price,
    String buyerNationalId,
    String buyerFullName, {
    String? buyerPhone,
  }) async {
    try {
      print('🔄 Marquage de l\'oiseau $id comme vendu...');
      final response = await _apiService.put('birds/$id/sell', {
        'price': price,
        'buyerInfo': {
          'nationalId': buyerNationalId,
          'fullName': buyerFullName,
          'phone': buyerPhone ?? '',
        },
      });

      if (response is Map) {
        final updatedBird = Bird.fromApi(Map<String, dynamic>.from(response));
        print('✅ Oiseau marqué comme vendu: ${updatedBird.identifier}');
        return updatedBird;
      }

      print('⚠️ Format de réponse invalide: $response');
      throw Exception('Format de réponse invalide');
    } catch (e) {
      print('⚠️ Erreur lors de la vente de l\'oiseau: $e');
      throw Exception('Error selling bird: ${e.toString()}');
    }
  }

  // Récupérer les oiseaux disponibles à la vente
  Future<List<Bird>> getBirdsForSale() async {
    try {
      print('🔄 Récupération des oiseaux disponibles à la vente...');
      final response = await _apiService.get('birds/for-sale');
      print('📦 Réponse API: $response');

      if (response is List) {
        final birds = response.map((json) => Bird.fromApi(json)).toList();
        print('✅ ${birds.length} oiseaux disponibles à la vente récupérés');
        return birds;
      } else if (response is Map && response['data'] is List) {
        final birds =
            (response['data'] as List)
                .map((json) => Bird.fromApi(json))
                .toList();
        print('✅ ${birds.length} oiseaux disponibles à la vente récupérés');
        return birds;
      }

      print('⚠️ Format de réponse invalide: $response');
      return [];
    } catch (e) {
      print(
        '⚠️ Erreur lors de la récupération des oiseaux disponibles à la vente: $e',
      );
      return [];
    }
  }

  // Récupérer les oiseaux disponibles (non vendus et non appariés)
  Future<List<Bird>> getAvailableBirds() async {
    try {
      print('🔄 Récupération des oiseaux disponibles...');
      final response = await _apiService.get('birds/available');
      print('📦 Réponse API: $response');

      if (response is List) {
        final birds = response.map((json) => Bird.fromApi(json)).toList();
        print('✅ ${birds.length} oiseaux disponibles récupérés');
        return birds;
      } else if (response is Map && response['data'] is List) {
        final birds =
            (response['data'] as List)
                .map((json) => Bird.fromApi(json))
                .toList();
        print('✅ ${birds.length} oiseaux disponibles récupérés');
        return birds;
      }

      print('⚠️ Format de réponse invalide: $response');
      return [];
    } catch (e) {
      print('⚠️ Erreur lors de la récupération des oiseaux disponibles: $e');
      return [];
    }
  }
}
