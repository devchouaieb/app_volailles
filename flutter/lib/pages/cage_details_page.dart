import 'package:flutter/material.dart';
import 'package:app_volailles/models/cage.dart';
import 'package:app_volailles/models/bird.dart';
import 'package:app_volailles/services/cage_service.dart';

class CageDetailsPage extends StatelessWidget {
  final Cage cage;

  const CageDetailsPage({super.key, required this.cage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la cage'),
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
                    _buildBirdInfo(cage.male),
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
                    _buildBirdInfo(cage.female),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Cage Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations de la cage',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (cage.createdAt != null)
                      _buildInfoRow('Date de création', cage.createdAt!),
                    _buildInfoRow('Statut', cage.status ?? 'active'),
                    if (cage.notes != null && cage.notes!.isNotEmpty)
                      _buildInfoRow('Notes', cage.notes!),
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
