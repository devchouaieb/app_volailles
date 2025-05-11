import 'package:flutter/material.dart';
import 'package:app_volailles/data/associations.dart';
import 'package:app_volailles/services/association_service.dart';

class AssociationsPage extends StatefulWidget {
  const AssociationsPage({super.key});

  @override
  State<AssociationsPage> createState() => _AssociationsPageState();
}

class _AssociationsPageState extends State<AssociationsPage> {
  final AssociationService _associationService = AssociationService();
  List<Association> _associations = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAssociations();
  }

  Future<void> _loadAssociations() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final associations = await _associationService.getAllAssociations();
      if (!mounted) return;

      setState(() {
        _associations = associations;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Associations'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadAssociations,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Erreur: $_errorMessage',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loadAssociations,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              )
              : _associations.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.group, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "Aucune association enregistrée",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadAssociations,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _associations.length,
                  itemBuilder: (context, index) {
                    final association = _associations[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple.shade100,
                          child: const Icon(
                            Icons.group,
                            color: Colors.deepPurple,
                          ),
                        ),
                        title: Text(
                          association.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tél: ${association.phone}'),
                            Text('Email: ${association.email}'),
                            Text('Adresse: ${association.address}'),
                            if (association.registrationYear.isNotEmpty)
                              Text(
                                'Membre depuis ${association.registrationYear}',
                                style: TextStyle(
                                  color: Colors.deepPurple.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
