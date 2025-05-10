import 'package:app_volailles/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app_volailles/models/bird.dart';
import 'package:app_volailles/utils/date_utils.dart';

class StatisticsPage extends StatelessWidget {
  final List<Bird> birds;

  const StatisticsPage({super.key, required this.birds});

  @override
  Widget build(BuildContext context) {
    final maleCount =
        birds.where((b) => b.gender.toLowerCase() == Constants.male).length;
    final femaleCount =
        birds.where((b) => b.gender.toLowerCase() == Constants.female).length;

    // Calculer les statistiques par espèce
    final speciesCount = <String, int>{};
    for (var bird in birds) {
      speciesCount[bird.species] = (speciesCount[bird.species] ?? 0) + 1;
    }

    // Calculer les statistiques par cage
    final cageCount = <String, int>{};
    for (var bird in birds) {
      cageCount[bird.cage] = (cageCount[bird.cage] ?? 0) + 1;
    }

    // Calculer les statistiques par âge
    final ageGroups = <String, int>{
      '0-1 mois': 0,
      '1-2 mois': 0,
      '2-3 mois': 0,
      '3+ mois': 0,
    };

    for (var bird in birds) {
      final birthDate = DateTime.parse(bird.birthDate);
      final now = DateTime.now();
      final difference = now.difference(birthDate);
      final months = (difference.inDays / 30).floor();

      if (months <= 1)
        ageGroups['0-1 mois'] = (ageGroups['0-1 mois'] ?? 0) + 1;
      else if (months <= 2)
        ageGroups['1-2 mois'] = (ageGroups['1-2 mois'] ?? 0) + 1;
      else if (months <= 3)
        ageGroups['2-3 mois'] = (ageGroups['2-3 mois'] ?? 0) + 1;
      else
        ageGroups['3+ mois'] = (ageGroups['3+ mois'] ?? 0) + 1;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistiques des oiseaux"),
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCards(maleCount, femaleCount, birds.length),
              const SizedBox(height: 30),
              _buildGenderChart(maleCount, femaleCount),
              const SizedBox(height: 30),
              _buildSpeciesSection(speciesCount),
              const SizedBox(height: 30),
              _buildAgeDistributionSection(ageGroups),
              const SizedBox(height: 30),
              _buildCageDistributionSection(cageCount),
              const SizedBox(height: 30),
              _buildAdditionalStats(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(int maleCount, int femaleCount, int totalCount) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total',
            totalCount,
            Icons.pets,
            Colors.deepPurple,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard('Mâles', maleCount, Icons.male, Colors.blue),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Femelles',
            femaleCount,
            Icons.female,
            Colors.pink,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    int count,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.2)],
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderChart(int maleCount, int femaleCount) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Répartition par genre",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 30,
                  sections: [
                    PieChartSectionData(
                      color: Colors.blue,
                      value: maleCount.toDouble(),
                      title: '$maleCount',
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      radius: 60,
                    ),
                    PieChartSectionData(
                      color: Colors.pink,
                      value: femaleCount.toDouble(),
                      title: '$femaleCount',
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      radius: 60,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem('Mâles', Colors.blue, maleCount),
                _buildLegendItem('Femelles', Colors.pink, femaleCount),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          '$label ($count)',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSpeciesSection(Map<String, int> speciesCount) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Répartition par espèce",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            ...speciesCount.entries
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: LinearProgressIndicator(
                            value: entry.value / birds.length,
                            backgroundColor: Colors.deepPurple.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.deepPurple,
                            ),
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${entry.value}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeDistributionSection(Map<String, int> ageGroups) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Répartition par âge",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY:
                      ageGroups.values
                          .reduce((a, b) => a > b ? a : b)
                          .toDouble(),
                  barGroups:
                      ageGroups.entries.map((entry) {
                        return BarChartGroupData(
                          x: ageGroups.keys.toList().indexOf(entry.key),
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.toDouble(),
                              color: Colors.deepPurple,
                              width: 16,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              ageGroups.keys.elementAt(value.toInt()),
                              style: const TextStyle(
                                color: Colors.deepPurple,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCageDistributionSection(Map<String, int> cageCount) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Répartition par cage",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            ...cageCount.entries
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.grid_view,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Cage ${entry.key}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${entry.value}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalStats() {
    // Calculer les statistiques supplémentaires
    final totalValue = birds.fold<double>(0, (sum, bird) => sum + (bird.price));
    final averageValue = birds.isEmpty ? 0.0 : totalValue / birds.length;
    final forSaleCount = birds.where((b) => b.forSale).length;
    final soldCount = birds.where((b) => b.sold).length;
    final healthyCount = birds.where((b) => b.status == 'Healthy').length;
    final sickCount = birds.where((b) => b.status == 'Sick').length;
    final inTreatmentCount =
        birds.where((b) => b.status == 'In Treatment').length;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Statistiques supplémentaires",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            _buildStatRow(
              "Valeur totale",
              "${totalValue.toStringAsFixed(2)} DT",
            ),
            _buildStatRow(
              "Valeur moyenne",
              "${averageValue.toStringAsFixed(2)} DT",
            ),
            _buildStatRow("En vente", "$forSaleCount oiseaux"),
            _buildStatRow("Vendus", "$soldCount oiseaux"),
            _buildStatRow("Sains", "$healthyCount oiseaux"),
            _buildStatRow("Malades", "$sickCount oiseaux"),
            _buildStatRow("En traitement", "$inTreatmentCount oiseaux"),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }
}
