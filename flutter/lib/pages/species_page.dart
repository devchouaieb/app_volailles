import 'package:flutter/material.dart';

class SpeciesPage extends StatelessWidget {
  SpeciesPage({super.key});

  final List<Map<String, dynamic>> birdSpecies = [
    {'name': 'Autruche', 'incubationDays': 42},
    {'name': 'Canard', 'incubationDays': 28},
    {'name': 'Caille', 'incubationDays': 17},
    {'name': 'Colombe', 'incubationDays': 14},
    {'name': 'Corbeau', 'incubationDays': 20},
    {'name': 'Faisan', 'incubationDays': 23},
    {'name': 'Flamant', 'incubationDays': 28},
    {'name': 'Geai', 'incubationDays': 18},
    {'name': 'Goéland', 'incubationDays': 25},
    {'name': 'Grue', 'incubationDays': 29},
    {'name': 'Héron', 'incubationDays': 27},
    {'name': 'Manchot', 'incubationDays': 39},
    {'name': 'Moineau', 'incubationDays': 12},
    {'name': 'Paon', 'incubationDays': 29},
    {'name': 'Perroquet', 'incubationDays': 26},
    {'name': 'Pigeon', 'incubationDays': 18},
    {'name': 'Poulet', 'incubationDays': 21},
    {'name': 'Rouge-gorge', 'incubationDays': 13},
    {'name': 'Toucan', 'incubationDays': 18},
    {'name': 'Tourterelle', 'incubationDays': 15},
  ]..sort((a, b) => a['name'].compareTo(b['name']));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Espèces d\'oiseaux'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: birdSpecies.length,
        itemBuilder: (context, index) {
          final species = birdSpecies[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ExpansionTile(
              title: Text(species['name']),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Période d'incubation : ${species['incubationDays']} jours",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
