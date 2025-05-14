import 'package:app_volailles/models/nest.dart';
import 'package:app_volailles/services/api_service.dart';
import 'package:app_volailles/utils/api_exception.dart';

class NestService {
  final _apiService = ApiService();

  Future<List<Nest>> getNests() async {
    try {
      final response = await _apiService.get('nests');
      if (response["success"] == true) {
        final List<dynamic> nestsData = response['data'];
        return nestsData.map((json) => Nest.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load nests: ${response["message"]}');
      }
    } catch (e) {
      print('Error in getNests: $e');
      throw Exception('Error loading nests: $e');
    }
  }

  Future<Nest> createNest(Nest nest) async {
    try {
      final response = await _apiService.post('nests', nest.toJson());
      if (response["success"] == true) {
        return Nest.fromJson(response['data']);
      } else {
        throw ApiException(response.data['message'] ?? "Erreur lors de la création du couvé.");
      }
    } catch (e) {
      print('Error in createNest: $e');
      if (e is ApiException) {
        rethrow ;
      } else {
        throw ApiException('Erreur lors de la création du couvé: ');
      }
    }
  }

  Future<Nest> updateNest(Nest nest) async {
    try {
      final response = await _apiService.put(
        'nests/${nest.id}',
        nest.toJson(),
      );
      if (response["success"] == true) {
        return Nest.fromJson(response['data']);
      } else {
        throw ApiException(response.data['message'] ?? "Erreur lors de la mise à jour du couvé.");
      }
    } catch (e) {
      print('Error in updateNest: $e');
      if (e is ApiException) {
        throw e;
      } else {
        throw ApiException('Erreur lors de la mise à jour du couvé: $e');
      }
    }
  }

  Future<void> deleteNest(String id) async {
    try {
      final response = await _apiService.delete('nests/$id');
      if (response["success"] != true) {
        throw Exception('Failed to delete nest: ${response['message']}');
      }
    } catch (e) {
      print('Error in deleteNest: $e');
      throw Exception('Error deleting nest: $e');
    }
  }
}
