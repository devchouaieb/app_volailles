import 'package:app_volailles/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app_volailles/models/bird.dart';

class StatisticsPage extends StatelessWidget {
  final List<Bird> birds;

  const StatisticsPage({super.key, required this.birds});

  @override
  Widget build(BuildContext context) {
    final maleCount = birds.where((b) => b.gender == Constants.male).length;
    final femaleCount = birds.where((b) => b.gender == Constants.female).length;

    return Scaffold(
      appBar: AppBar(title: const Text("Statistiques des oiseaux")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 30,
                  sections: [
                    PieChartSectionData(
                      color: Colors.blue,
                      value: maleCount.toDouble(),
                      title: '♂ $maleCount',
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    PieChartSectionData(
                      color: Colors.pink,
                      value: femaleCount.toDouble(),
                      title: '♀ $femaleCount',
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            GenderStatTile(
              label: "Mâles",
              count: maleCount,
              color: Colors.blue,
            ),
            const SizedBox(height: 10),
            GenderStatTile(
              label: "Femelles",
              count: femaleCount,
              color: Colors.pink,
            ),
          ],
        ),
      ),
    );
  }
}

class GenderStatTile extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const GenderStatTile({
    super.key,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      child: ListTile(
        leading: Icon(Icons.pets, color: color),
        title: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          '$count',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
