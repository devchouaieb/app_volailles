import 'package:app_volailles/models/sensor_data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SensorService {
  final String baseUrl = 'http://10.0.2.2:5000/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<SensorData>> getSensorData() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/sensor_data'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] is List) {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => SensorData.fromJson(json)).toList();
        } else {
          throw Exception('Invalid response format from server');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        throw Exception('Failed to load sensor data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching sensor data: $e');
      throw Exception('Failed to load sensor data: $e');
    }
  }
}
