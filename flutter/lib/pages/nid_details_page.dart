import 'package:flutter/material.dart';
import '../models/nid.dart';

class NidDetailsPage extends StatelessWidget {
  final Nid nid;

  const NidDetailsPage({super.key, required this.nid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Détails de ${nid.name}")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("🌡️ Température : 30°C", style: TextStyle(fontSize: 20)),
            SizedBox(height: 16),
            Text("💧 Humidité : 20%", style: TextStyle(fontSize: 20)),
            SizedBox(height: 16),
            Text("💡 Luminosité : 70%", style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
