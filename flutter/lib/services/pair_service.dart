import 'package:flutter/material.dart';
import 'package:app_volailles/models/pair.dart';
import 'package:app_volailles/models/bird.dart';
import 'package:app_volailles/services/api_service.dart';

class PairService {
  final _apiService = ApiService();

  Future<List<Pair>> getPairs() async {
    try {
      final response = await _apiService.get('pairs');
      if (response["success"] == true) {
        final Map<String, dynamic> data = response['data'];
        List<Pair> pairs = [];

        // Convert the species-based pairs into a list of Pair objects
        data.forEach((species, speciesData) {
          final males = speciesData['males'] as List;
          final females = speciesData['females'] as List;

          // Create pairs from available males and females
          for (var male in males) {
            for (var female in females) {
              pairs.add(
                Pair(
                  id: null, // The backend will assign an ID
                  male: Bird.fromApi(male),
                  female: Bird.fromApi(female),
                  species: species,
                  cageNumber: "",
                ),
              );
            }
          }
        });

        return pairs;
      } else {
        throw Exception('Failed to load pairs: ${response.data['message']}');
      }
    } catch (e) {
      print('Error in getPairs: $e');
      throw Exception('Error loading pairs: $e');
    }
  }

  Future<Pair> createPair(Pair pair) async {
    try {
      final response = await _apiService.post('/pairs', pair.toJson());
      if (response.statusCode == 201) {
        return Pair.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to create pair: ${response.data['message']}');
      }
    } catch (e) {
      print('Error in createPair: $e');
      throw Exception('Error creating pair: $e');
    }
  }

  Future<void> deletePair(String id) async {
    try {
      final response = await _apiService.delete('/pairs/$id');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete pair: ${response.data['message']}');
      }
    } catch (e) {
      print('Error in deletePair: $e');
      throw Exception('Error deleting pair: $e');
    }
  }
}
