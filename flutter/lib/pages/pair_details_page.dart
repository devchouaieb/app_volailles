import 'package:flutter/material.dart';
import 'package:app_volailles/models/pair.dart';
import 'package:app_volailles/models/bird.dart';
import 'package:app_volailles/services/pair_service.dart';

class PairDetailsPage extends StatelessWidget {
  final Pair pair;

  const PairDetailsPage({super.key, required this.pair});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la paire'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Male Bird Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mâle',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildBirdInfo(pair.male),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Female Bird Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Femelle',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildBirdInfo(pair.female),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Pair Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations de la paire',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (pair.createdAt != null)
                      _buildInfoRow('Date de création', pair.createdAt!),
                    _buildInfoRow('Statut', pair.status ?? 'active'),
                    if (pair.notes != null && pair.notes!.isNotEmpty)
                      _buildInfoRow('Notes', pair.notes!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBirdInfo(Bird bird) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Identifiant', bird.identifier),
        _buildInfoRow('Espèce', bird.species),
        _buildInfoRow('Variété', bird.variety),
        _buildInfoRow('Cage', bird.cage),
        _buildInfoRow('Date de naissance', bird.birthDate),
        if (bird.price > 0) _buildInfoRow('Prix', '${bird.price} DT'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
