import 'package:flutter/material.dart';
import '../models/reseau.dart';
import '../services/reseau_service.dart';
import 'add_reseau_dialog.dart';

class ReseauPage extends StatefulWidget {
  const ReseauPage({super.key});

  @override
  State<ReseauPage> createState() => _ReseauPageState();
}

class _ReseauPageState extends State<ReseauPage> {
  final ReseauService _reseauService = ReseauService();
  List<Reseau> _reseaux = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReseaux();
  }

  Future<void> _loadReseaux() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final reseaux = await _reseauService.getReseaux();
      setState(() {
        _reseaux = reseaux;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement des réseaux: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _addOrUpdateReseau(Reseau reseau) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      Reseau updatedReseau;
      if (reseau.id == null) {
        updatedReseau = await _reseauService.createReseau(reseau);
      } else {
        updatedReseau = await _reseauService.updateReseau(reseau.id!, reseau);
      }

      if (!mounted) return;

      setState(() {
        _reseaux.removeWhere((r) => r.id == updatedReseau.id);
        _reseaux.add(updatedReseau);
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réseau sauvegardé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteReseau(Reseau reseau) async {
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Supprimer le réseau ?"),
            content: Text(
              "Êtes-vous sûr de vouloir supprimer le réseau ${reseau.name} ?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Supprimer"),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _reseauService.deleteReseau(reseau.id!);
      if (!mounted) return;

      setState(() {
        _reseaux.removeWhere((r) => r.id == reseau.id);
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réseau supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddReseauDialog({Reseau? reseau}) {
    showDialog<void>(
      context: context,
      builder:
          (context) =>
              AddReseauDialog(reseau: reseau, onSave: _addOrUpdateReseau),
    );
  }

  Widget _buildReseauCard(Reseau reseau) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => _showAddReseauDialog(reseau: reseau),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      reseau.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteReseau(reseau),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.badge, 'Matricule', reseau.matricule),
              _buildInfoRow(Icons.location_on, 'Adresse', reseau.address),
              _buildInfoRow(Icons.web, 'Site Web', reseau.siteWeb),
              _buildInfoRow(Icons.person, 'Président', reseau.president),
              _buildInfoRow(Icons.group, 'Comité', reseau.comite),
              _buildInfoRow(Icons.phone, 'Téléphone', reseau.telephone),
              _buildInfoRow(Icons.email, 'Email', reseau.mail),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.deepPurple.shade300),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Réseaux"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadReseaux,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Erreur: $_error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loadReseaux,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              )
              : _reseaux.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.account_tree,
                      size: 60,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Aucun réseau enregistré',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _showAddReseauDialog(),
                      child: const Text('Ajouter un réseau'),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadReseaux,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _reseaux.length,
                  itemBuilder: (context, index) {
                    return _buildReseauCard(_reseaux[index]);
                  },
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReseauDialog(),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
}
