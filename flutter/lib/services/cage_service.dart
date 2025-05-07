import 'package:flutter/material.dart';
import 'package:app_volailles/models/cage.dart';
import 'package:app_volailles/models/bird.dart';
import 'package:app_volailles/services/api_service.dart';

class CageService {
  final _apiService = ApiService();

  Future<List<Cage>> getCages() async {
    try {
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
      throw Exception('Format de réponse invalide');
    } catch (e) {
      print('⚠️ Erreur lors de la récupération des cages: $e');
      rethrow;
    }
  }

  Future<Cage> createCage(Cage cage) async {
    try {
      final response = await _apiService.post('cages', cage.toJson());
      if (response["success"] == true) {
        return Cage.fromJson(response['data']);
      } else {
        throw Exception('Failed to create cage: ${response['message']}');
      }
    } catch (e) {
      print('Error in createCage: $e');
      throw Exception('Error creating cage: $e');
    }
  }

  Future<void> deleteCage(String id) async {
    try {
      final response = await _apiService.delete('cages/$id');
      if (response["success"] != true) {
        throw Exception('Failed to delete cage: ${response.data['message']}');
      }
    } catch (e) {
      print('Error in deleteCage: $e');
      throw Exception('Error deleting cage: $e');
    }
  }
}
