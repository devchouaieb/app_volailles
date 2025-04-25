import 'package:flutter/material.dart';
import 'package:app_volailles/models/pair.dart';
import 'package:app_volailles/utils/date_utils.dart'; // 👈 Pour calculateAge

class PairDetailsPage extends StatelessWidget {
  final Pair pair;

  const PairDetailsPage({super.key, required this.pair});

  @override
  Widget build(BuildContext context) {
    final male = pair.male;
    final female = pair.female;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails de la paire"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Bloc Mâle
            Card(
              color: Colors.lightBlue.shade50,
              child: ListTile(
                leading: const Icon(Icons.male, color: Colors.blue),
                title: Text("Mâle : ${male.identifier}"),
                subtitle: Text(
                  "Espèce : ${male.species}\n"
                  "Variété : ${male.variety}\n"
                  "Cage : ${male.cage}\n"
                  "Âge : ${calculateAge(male.birthDate)}",
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Bloc Femelle
            Card(
              color: Colors.pink.shade50,
              child: ListTile(
                leading: const Icon(Icons.female, color: Colors.pink),
                title: Text("Femelle : ${female.identifier}"),
                subtitle: Text(
                  "Espèce : ${female.species}\n"
                  "Variété : ${female.variety}\n"
                  "Cage : ${female.cage}\n"
                  "Âge : ${calculateAge(female.birthDate)}",
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Suivi",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    showEggCountDialog(context);
                  },
                  icon: const Icon(Icons.egg),
                  label: const Text("Œufs"),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Naviguer vers descendants
                  },
                  icon: const Icon(Icons.family_restroom),
                  label: const Text("Descendants"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showEggCountDialog(BuildContext context) {
    int eggCount = 0;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Nombre d'œufs"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Choisissez le nombre d'œufs"),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.blueAccent,
                        ),
                        onPressed: () {
                          if (eggCount > 0) {
                            setState(() => eggCount--);
                          }
                        },
                      ),
                      Text(
                        eggCount.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle,
                          color: Colors.blueAccent,
                        ),
                        onPressed: () {
                          setState(() => eggCount++);
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: enregistrer dans SharedPreferences ou base
                Navigator.pop(context);
              },
              child: const Text("Enregistrer"),
            ),
          ],
        );
      },
    );
  }
}
