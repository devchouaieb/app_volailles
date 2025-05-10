import 'package:flutter/material.dart';
import 'package:app_volailles/models/sensor_data.dart';
import 'package:app_volailles/services/sensor_service.dart';
import 'package:app_volailles/pages/sensor_detail_page.dart';

class SensorDashboardPage extends StatefulWidget {
  const SensorDashboardPage({super.key});

  @override
  State<SensorDashboardPage> createState() => _SensorDashboardPageState();
}

class _SensorDashboardPageState extends State<SensorDashboardPage> {
  final SensorService _sensorService = SensorService();
  List<SensorData> _sensorData = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSensorData();
  }

  Future<void> _loadSensorData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final data = await _sensorService.getSensorData();
      setState(() {
        _sensorData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildSensorCard(int sensorIndex) {
    double getTemperature(SensorData data) {
      switch (sensorIndex) {
        case 0:
          return data.temperature1;
        case 1:
          return data.temperature2;
        case 2:
          return data.temperature3;
        case 3:
          return data.temperature4;
        case 4:
          return data.temperature5;
        case 5:
          return data.temperature6;
        case 6:
          return data.temperature7;
        default:
          return 0.0;
      }
    }

    double getHumidity(SensorData data) {
      switch (sensorIndex) {
        case 0:
          return data.humidite1;
        case 1:
          return data.humidite2;
        case 2:
          return data.humidite3;
        case 3:
          return data.humidite4;
        case 4:
          return data.humidite5;
        case 5:
          return data.humidite6;
        case 6:
          return data.humidite7;
        default:
          return 0.0;
      }
    }

    double getLight(SensorData data) {
      switch (sensorIndex) {
        case 0:
          return data.ldr1;
        case 1:
          return data.ldr2;
        default:
          return 0.0;
      }
    }

    final temperatures = _sensorData.map(getTemperature).toList();
    final humidities = _sensorData.map(getHumidity).toList();
    final lights = _sensorData.map(getLight).toList();

    if (temperatures.isEmpty) {
      return const Center(
        child: Text(
          'Aucune donnée disponible',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    final currentTemp = temperatures.last;
    final currentHumidity = humidities.last;
    final currentLight = lights.last;

    Color getTemperatureColor(double temp) {
      if (temp < 20) return Colors.blue;
      return Colors.red;
    }

    Color getHumidityColor(double humidity) {
      if (humidity < 40) return Colors.orange;
      if (humidity > 80) return Colors.blue;
      return Colors.green;
    }

    Color getLightColor(double light) {
      if (light < 100) return Colors.grey;
      if (light > 500) return Colors.yellow.shade700;
      return Colors.orange;
    }

    return Card(
      elevation: 4,
      shadowColor: Colors.deepPurple.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => SensorDetailPage(
                    sensorIndex: sensorIndex,
                    sensorData: _sensorData,
                  ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.deepPurple.shade50, Colors.white],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade100,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            Icons.sensors,
                            color: Colors.deepPurple.shade700,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Capteur ${sensorIndex + 1}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple.shade700,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.deepPurple.shade300,
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDataItem(
                      'Température',
                      '${currentTemp.toStringAsFixed(1)}°C',
                      Icons.thermostat,
                      getTemperatureColor(currentTemp),
                    ),
                    _buildDataItem(
                      'Humidité',
                      '${currentHumidity.toStringAsFixed(1)}%',
                      Icons.water_drop,
                      getHumidityColor(currentHumidity),
                    ),
                    if (sensorIndex <= 1) // Only show light for sensors 1 and 2
                      _buildDataItem(
                        'Luminosité',
                        '${currentLight.toStringAsFixed(0)} lux',
                        Icons.light_mode,
                        getLightColor(currentLight),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(
                      'Min',
                      '${temperatures.reduce((a, b) => a < b ? a : b).toStringAsFixed(1)}°C',
                      Colors.deepPurple.shade300,
                    ),
                    _buildStatItem(
                      'Max',
                      '${temperatures.reduce((a, b) => a > b ? a : b).toStringAsFixed(1)}°C',
                      Colors.deepPurple.shade500,
                    ),
                    _buildStatItem(
                      'Moy',
                      '${(temperatures.reduce((a, b) => a + b) / temperatures.length).toStringAsFixed(1)}°C',
                      Colors.deepPurple.shade700,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (label == 'Température') ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              _getTemperatureStatus(double.parse(value.replaceAll('°C', ''))),
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _getTemperatureStatus(double temp) {
    if (temp < 20) return 'Trop froid';
    return 'Optimal';
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSensorData,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade50, Colors.white],
          ),
        ),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Erreur: $_error',
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadSensorData,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
                : RefreshIndicator(
                  onRefresh: _loadSensorData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 7,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildSensorCard(index),
                      );
                    },
                  ),
                ),
      ),
    );
  }
}
