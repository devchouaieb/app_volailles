import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app_volailles/models/sensor_data.dart';

class SensorDetailPage extends StatelessWidget {
  final int sensorIndex;
  final List<SensorData> sensorData;

  const SensorDetailPage({
    super.key,
    required this.sensorIndex,
    required this.sensorData,
  });

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(
    String title,
    List<double> values,
    List<DateTime> timestamps,
    Color color,
    String unit,
    double minY,
    double maxY,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: (maxY - minY) / 5,
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: (maxY - minY) / 5,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}$unit',
                        style: TextStyle(color: color, fontSize: 12),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: (timestamps.length / 4).ceil().toDouble(),
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= timestamps.length)
                        return const Text('');
                      final date = timestamps[value.toInt()];
                      return Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Text(
                          '${date.hour.toString().padLeft(2, '0')}:00',
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipRoundedRadius: 8,
                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                    return touchedSpots.map((spot) {
                      final date = timestamps[spot.x.toInt()];
                      return LineTooltipItem(
                        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}\n${spot.y.toStringAsFixed(1)}$unit',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
                handleBuiltInTouches: true,
                getTouchedSpotIndicator: (
                  LineChartBarData barData,
                  List<int> spotIndexes,
                ) {
                  return spotIndexes.map((spotIndex) {
                    return TouchedSpotIndicatorData(
                      FlLine(color: color, strokeWidth: 2),
                      FlDotData(
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: color,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                    );
                  }).toList();
                },
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(
                    values.length,
                    (index) => FlSpot(index.toDouble(), values[index]),
                  ),
                  isCurved: true,
                  color: color,
                  barWidth: 2,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 2,
                        color: color,
                        strokeWidth: 0,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
              minY: minY,
              maxY: maxY,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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

    final temperatures =
        sensorData.map(getTemperature).toList().reversed.toList();
    final humidities = sensorData.map(getHumidity).toList().reversed.toList();
    final lights = sensorData.map(getLight).toList().reversed.toList();
    final timestamps =
        sensorData.map((data) => data.timestamp).toList().reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Capteur ${sensorIndex + 1}'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Temperature Section
                Card(
                  elevation: 6,
                  shadowColor: Colors.deepPurple.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
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
                                      color: const Color.fromARGB(
                                        255,
                                        234,
                                        229,
                                        230,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Icon(
                                      Icons.thermostat,
                                      color: Colors.red.shade700,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Température',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              if (temperatures.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple.shade100,
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.deepPurple.withOpacity(
                                          0.1,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        '${temperatures.last.toStringAsFixed(1)}°C',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              (() {
                                                final temp = temperatures.last;
                                                if (temp < 20)
                                                  return Colors.blue
                                                      .withOpacity(0.1);
                                                return Colors.red.withOpacity(
                                                  0.1,
                                                );
                                              })(),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color:
                                                (() {
                                                  final temp =
                                                      temperatures.last;
                                                  if (temp < 20)
                                                    return Colors.blue
                                                        .withOpacity(0.3);
                                                  return Colors.red.withOpacity(
                                                    0.3,
                                                  );
                                                })(),
                                          ),
                                        ),
                                        child: Text(
                                          (() {
                                            final temp = temperatures.last;
                                            if (temp < 20) return 'Trop froid';
                                            return 'Optimal';
                                          })(),
                                          style: TextStyle(
                                            color:
                                                (() {
                                                  final temp =
                                                      temperatures.last;
                                                  if (temp < 20)
                                                    return Colors.blue;
                                                  return Colors.red;
                                                })(),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          if (temperatures.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                  'Aucune donnée disponible',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 18,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            )
                          else ...[
                            _buildChart(
                              'Évolution de la température',
                              temperatures,
                              timestamps,
                              Colors.deepPurple,
                              '°C',
                              temperatures.reduce((a, b) => a < b ? a : b) - 5,
                              temperatures.reduce((a, b) => a > b ? a : b) + 5,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatItem(
                                  'Min',
                                  '${temperatures.reduce((a, b) => a < b ? a : b).toStringAsFixed(1)}°C',
                                  Icons.arrow_downward,
                                  Colors.deepPurple.shade300,
                                ),
                                _buildStatItem(
                                  'Max',
                                  '${temperatures.reduce((a, b) => a > b ? a : b).toStringAsFixed(1)}°C',
                                  Icons.arrow_upward,
                                  Colors.deepPurple.shade500,
                                ),
                                _buildStatItem(
                                  'Moyenne',
                                  '${(temperatures.reduce((a, b) => a + b) / temperatures.length).toStringAsFixed(1)}°C',
                                  Icons.calculate,
                                  Colors.deepPurple.shade700,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Humidity Section
                Card(
                  elevation: 6,
                  shadowColor: Colors.blue.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.blue.shade50, Colors.white],
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
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Icon(
                                      Icons.water_drop,
                                      color: Colors.blue.shade700,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Humidité',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              if (humidities.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '${humidities.last.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          if (humidities.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                  'Aucune donnée disponible',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 18,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            )
                          else ...[
                            _buildChart(
                              'Évolution de l\'humidité',
                              humidities,
                              timestamps,
                              Colors.blue,
                              '%',
                              0,
                              100,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatItem(
                                  'Min',
                                  '${humidities.reduce((a, b) => a < b ? a : b).toStringAsFixed(1)}%',
                                  Icons.arrow_downward,
                                  Colors.deepPurple.shade300,
                                ),
                                _buildStatItem(
                                  'Max',
                                  '${humidities.reduce((a, b) => a > b ? a : b).toStringAsFixed(1)}%',
                                  Icons.arrow_upward,
                                  Colors.deepPurple.shade500,
                                ),
                                _buildStatItem(
                                  'Moyenne',
                                  '${(humidities.reduce((a, b) => a + b) / humidities.length).toStringAsFixed(1)}%',
                                  Icons.calculate,
                                  Colors.deepPurple.shade700,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                if (sensorIndex <= 1) ...[
                  // Only show light section for sensors 1 and 2
                  const SizedBox(height: 16),
                  // Light Section
                  Card(
                    elevation: 6,
                    shadowColor: Colors.orange.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.orange.shade50, Colors.white],
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
                                        color: Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Icon(
                                        Icons.light_mode,
                                        color: Colors.orange.shade700,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Luminosité',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                if (lights.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.orange.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      '${lights.last.toStringAsFixed(0)} lux',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            if (lights.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text(
                                    'Aucune donnée disponible',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 18,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              )
                            else ...[
                              _buildChart(
                                'Évolution de la luminosité',
                                lights,
                                timestamps,
                                Colors.orange,
                                ' lux',
                                0,
                                lights.reduce((a, b) => a > b ? a : b) * 1.2,
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildStatItem(
                                    'Min',
                                    '${lights.reduce((a, b) => a < b ? a : b).toStringAsFixed(0)} lux',
                                    Icons.arrow_downward,
                                    Colors.deepPurple.shade300,
                                  ),
                                  _buildStatItem(
                                    'Max',
                                    '${lights.reduce((a, b) => a > b ? a : b).toStringAsFixed(0)} lux',
                                    Icons.arrow_upward,
                                    Colors.deepPurple.shade500,
                                  ),
                                  _buildStatItem(
                                    'Moyenne',
                                    '${(lights.reduce((a, b) => a + b) / lights.length).toStringAsFixed(0)} lux',
                                    Icons.calculate,
                                    Colors.deepPurple.shade700,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
