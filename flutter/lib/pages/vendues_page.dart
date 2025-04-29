import 'package:flutter/material.dart';
import 'package:app_volailles/models/bird.dart';
import 'package:app_volailles/utils/date_utils.dart';

class VenduesPage extends StatelessWidget {
  final List<Bird> birds;
  final List<Bird> soldBirds;

  const VenduesPage({
    Key? key,
    this.birds = const [],
    this.soldBirds = const [],
     Future<void> Function(
      Bird bird,
      double price,
      String buyerNationalId,
      String buyerFullName, {
      String? buyerPhone,
    })?
    onSellBird,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oiseaux vendus'),
        backgroundColor: Colors.deepPurple,
      ),
      body:
          soldBirds.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sell, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "Aucun oiseau vendu",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: soldBirds.length,
                itemBuilder: (context, index) {
                  final bird = soldBirds[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple.shade100,
                        child: const Icon(Icons.pets, color: Colors.deepPurple),
                      ),
                      title: Text(
                        bird.identifier,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Espèce: ${bird.species}'),
                          Text('Variété: ${bird.variety}'),
                          Text('Prix de vente: ${bird.soldPrice} DT'),
                          if (bird.soldDate != null)
                            Text(
                              'Date de vente: ${formatDate(bird.soldDate!)}',
                            ),
                          if (bird.buyerInfo != null)
                            Text(
                              'CIN acheteur: ${bird.buyerInfo!['nationalId']}',
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
