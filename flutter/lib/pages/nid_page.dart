import 'package:flutter/material.dart';
import '../models/nid.dart';
import 'nid_details_page.dart';

class NidPage extends StatefulWidget {
  const NidPage({super.key});

  @override
  State<NidPage> createState() => _NidPageState();
}

class _NidPageState extends State<NidPage> {
  final List<Nid> _nids = [];

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
                      _nids.add(Nid(name: name));
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

  void _openNidDetails(Nid nid) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NidDetailsPage(nid: nid)),
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
                  final nid = _nids[index];
                  return ListTile(
                    title: Text(nid.name),
                    onTap: () => _openNidDetails(nid),
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
