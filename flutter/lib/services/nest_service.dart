import 'package:app_volailles/models/nest.dart';
import 'package:app_volailles/services/api_service.dart';

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
        throw Exception('Failed to create nest: ${response.data['message']}');
      }
    } catch (e) {
      print('Error in createNest: $e');
      throw Exception('Error creating nest: $e');
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
        throw Exception('Failed to update nest: ${response.data['message']}');
      }
    } catch (e) {
      print('Error in updateNest: $e');
      throw Exception('Error updating nest: $e');
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
