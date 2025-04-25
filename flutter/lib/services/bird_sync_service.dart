import 'package:app_volailles/models/bird.dart';
import 'package:app_volailles/services/bird_service.dart';
import 'package:app_volailles/services/auth_service.dart';
import 'package:app_volailles/config/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BirdSyncService {
  final BirdService _birdService = BirdService();
  final AuthService _authService = AuthService();
  final String baseUrl = Config.baseUrl;

  // Synchroniser les oiseaux avec le serveur
  Future<List<Bird>> syncBirds() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Non authentifié');
      }

      print('🔄 Synchronisation des oiseaux...');
      print('🌐 URL: $baseUrl/birds');
      print('🔑 Token: ${token != null ? 'présent' : 'absent'}');

      final response = await http.get(
        Uri.parse('$baseUrl/birds'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📊 Code de statut: ${response.statusCode}');
      print('📦 Réponse: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<Bird> allBirds = [];

        // Handle different response formats
        if (data is List) {
          // Direct list of birds
          allBirds = data.map((bird) => Bird.fromApi(bird)).toList();
          print('✅ ${allBirds.length} oiseaux récupérés au total');
        } else if (data is Map) {
          // Response with data field
          final List<dynamic> birdList = data['data'] ?? [];
          allBirds = birdList.map((bird) => Bird.fromApi(bird)).toList();
          print('✅ ${allBirds.length} oiseaux récupérés au total');
        } else {
          print('⚠️ Format de réponse invalide: $data');
          return [];
        }
        
        // Filtrer les oiseaux vendus
        final filteredBirds = allBirds.where((bird) => !bird.sold).toList();
        print('✅ ${filteredBirds.length} oiseaux non vendus synchronisés');
        return filteredBirds;
      } else if (response.statusCode == 404) {
        print('⚠️ Endpoint /birds non trouvé, tentative avec /api/birds');
        // Try with /api/birds
        final response2 = await http.get(
          Uri.parse('$baseUrl/api/birds'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        print('📊 Code de statut (2ème tentative): ${response2.statusCode}');
        print('📦 Réponse (2ème tentative): ${response2.body}');

        if (response2.statusCode == 200) {
          final data = jsonDecode(response2.body);
          List<Bird> allBirds = [];

          // Handle different response formats
          if (data is List) {
            // Direct list of birds
            allBirds = data.map((bird) => Bird.fromApi(bird)).toList();
            print('✅ ${allBirds.length} oiseaux récupérés au total');
          } else if (data is Map) {
            // Response with data field
            final List<dynamic> birdList = data['data'] ?? [];
            allBirds = birdList.map((bird) => Bird.fromApi(bird)).toList();
            print('✅ ${allBirds.length} oiseaux récupérés au total');
          } else {
            print('⚠️ Format de réponse invalide: $data');
            return [];
          }
          
          // Filtrer les oiseaux vendus
          final filteredBirds = allBirds.where((bird) => !bird.sold).toList();
          print('✅ ${filteredBirds.length} oiseaux non vendus synchronisés');
          return filteredBirds;
        } else {
          print('⚠️ Les deux tentatives ont échoué');
          return [];
        }
      } else {
        throw Exception('Erreur de synchronisation: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Erreur de synchronisation: $e');
      return [];
    }
  }

  // Vérifier les conflits de données
  Future<List<Bird>> checkConflicts(List<Bird> localBirds) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Non authentifié');
      }

      print('🔄 Vérification des conflits...');
      // Pour l'instant, retourner une liste vide car cette fonctionnalité n'est pas implémentée côté serveur
      return [];
    } catch (e) {
      print('Erreur de vérification des conflits: $e');
      rethrow;
    }
  }

  // Résoudre les conflits
  Future<void> resolveConflicts(List<Bird> resolvedBirds) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Non authentifié');
      }

      print('🔄 Résolution des conflits...');
      // Pour l'instant, ne rien faire car cette fonctionnalité n'est pas implémentée côté serveur
    } catch (e) {
      print('Erreur de résolution des conflits: $e');
      rethrow;
    }
  }

  // Sauvegarder les modifications en ligne
  Future<void> saveChanges(List<Bird> birds) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Non authentifié');
      }

      print('🔄 Sauvegarde des modifications...');

      for (final bird in birds) {
        try {
          if (bird.id == null) {
            // Create new bird
            await _birdService.createBird(bird);
            print('✅ Nouvel oiseau créé: ${bird.identifier}');
          } else {
            // Update existing bird
            await _birdService.updateBird(bird.id!, bird);
            print('✅ Oiseau mis à jour: ${bird.identifier}');
          }
        } catch (e) {
          print(
            '⚠️ Erreur lors de la sauvegarde de l\'oiseau ${bird.identifier}: $e',
          );
          // Continue with other birds even if one fails
          continue;
        }
      }

      print('✅ Toutes les modifications ont été sauvegardées');
    } catch (e) {
      print('⚠️ Erreur de sauvegarde: $e');
      rethrow;
    }
  }
}
