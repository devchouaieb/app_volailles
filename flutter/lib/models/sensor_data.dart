import 'package:intl/intl.dart';

class SensorData {
  final String id;
  final DateTime timestamp;
  final double temperature1;
  final double temperature2;
  final double temperature3;
  final double temperature4;
  final double temperature5;
  final double temperature6;
  final double temperature7;
  final double humidite1;
  final double humidite2;
  final double humidite3;
  final double humidite4;
  final double humidite5;
  final double humidite6;
  final double humidite7;
  final double ldr1;
  final double ldr2;

  SensorData({
    required this.id,
    required this.timestamp,
    required this.temperature1,
    required this.temperature2,
    required this.temperature3,
    required this.temperature4,
    required this.temperature5,
    required this.temperature6,
    required this.temperature7,
    required this.humidite1,
    required this.humidite2,
    required this.humidite3,
    required this.humidite4,
    required this.humidite5,
    required this.humidite6,
    required this.humidite7,
    required this.ldr1,
    required this.ldr2,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp is DateTime) {
        return timestamp;
      }
      if (timestamp is String) {
        try {
          // Try parsing ISO format first
          return DateTime.parse(timestamp);
        } catch (e) {
          try {
            // Try parsing custom format
            final formatter = DateFormat('yyyy-MM-ddTHH:mm:ss');
            return formatter.parse(timestamp);
          } catch (e) {
            // If all parsing fails, return current time
            print('Error parsing timestamp: $timestamp');
            return DateTime.now();
          }
        }
      }
      // If timestamp is not a string or DateTime, return current time
      return DateTime.now();
    }

    return SensorData(
      id: json['_id'] ?? '',
      timestamp: parseTimestamp(json['timestamp']),
      temperature1: (json['Temp_1'] ?? 0).toDouble(),
      temperature2: (json['Temp_2'] ?? 0).toDouble(),
      temperature3: (json['Temp_3'] ?? 0).toDouble(),
      temperature4: (json['Temp_4'] ?? 0).toDouble(),
      temperature5: (json['Temp_5'] ?? 0).toDouble(),
      temperature6: (json['Temp_6'] ?? 0).toDouble(),
      temperature7: (json['Temp_7'] ?? 0).toDouble(),
      humidite1: (json['Humidity_1'] ?? 0).toDouble(),
      humidite2: (json['Humidity_2'] ?? 0).toDouble(),
      humidite3: (json['Humidity_3'] ?? 0).toDouble(),
      humidite4: (json['Humidity_4'] ?? 0).toDouble(),
      humidite5: (json['Humidity_5'] ?? 0).toDouble(),
      humidite6: (json['Humidity_6'] ?? 0).toDouble(),
      humidite7: (json['Humidity_7'] ?? 0).toDouble(),
      ldr1: (json['LDR_1'] ?? 0).toDouble(),
      ldr2: (json['LDR_2'] ?? 0).toDouble(),
    );
  }

  String get formattedTimestamp {
    final formatter = DateFormat('dd/MM/yyyy HH:mm:ss');
    return formatter.format(timestamp);
  }
}
