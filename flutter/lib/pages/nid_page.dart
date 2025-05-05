import 'package:app_volailles/models/nest.dart';
import 'package:flutter/material.dart';

import 'nid_details_page.dart';

class NidPage extends StatefulWidget {
  const NidPage({super.key});

  @override
  State<NidPage> createState() => _NidPageState();
}

class _NidPageState extends State<NidPage> {
  final List<Nest> _nids = [];

  void _addNid() async {
    final TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Ajouter un nid'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Nom du nid'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = controller.text.trim();
                  if (name.isNotEmpty) {
                    setState(() {
                      //_nids.add();
                    });
                  }
                  Navigator.pop(context);
                },
                child: const Text("Ajouter"),
              ),
            ],
          ),
    );
  }

  void _openNidDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NidDetailsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Liste des nids")),
      body:
          _nids.isEmpty
              ? const Center(child: Text("Aucun nid ajouté."))
              : ListView.builder(
                itemCount: _nids.length,
                itemBuilder: (context, index) {
                  final nest = _nids[index];
                  return ListTile(
                    title: Text(nest.cageNumber),
                    onTap: () => _openNidDetails(),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNid,
        child: const Icon(Icons.add),
      ),
    );
  }
}
