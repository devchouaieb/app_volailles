import 'package:flutter/material.dart';
import 'package:app_volailles/models/cage.dart';
import 'package:app_volailles/models/bird.dart';
import 'package:app_volailles/pages/add_cage_dialog.dart';
import 'package:app_volailles/pages/cage_details_page.dart';
import 'package:app_volailles/services/cage_service.dart';

class CagesPage extends StatefulWidget {
  final List<Bird> birds;

  const CagesPage({super.key, this.birds = const []});

  @override
  State<CagesPage> createState() => _CagesPageState();
}

class _CagesPageState extends State<CagesPage> {
  final _cageService = CageService();
  List<Cage> _cages = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCages();
  }

  Future<void> _loadCages() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cages = await _cageService.getCages();
      if (!mounted) return;

      setState(() {
        _cages = cages;
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

  Future<void> _addCage(Cage cage) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final newCage = await _cageService.createCage(cage);
      if (!mounted) return;

      setState(() {
        _cages.add(newCage);
        widget.birds.firstWhere((bird) => bird.id == newCage.male.id).cage =
            newCage.cageNumber;
             widget.birds.firstWhere((bird) => bird.id == newCage.female.id).cage =
            newCage.cageNumber;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cage ajoutée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'ajout: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteCage(Cage cage) async {
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Supprimer la cage ?"),
            content: const Text(
              "Êtes-vous sûr de vouloir supprimer cette cage ?",
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
      _errorMessage = null;
    });

    try {
      await _cageService.deleteCage(cage.id!);
      if (!mounted) return;

      setState(() {
        _cages.removeWhere((c) => c.id == cage.id);
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cage supprimée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
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

  void _openAddCageDialog() async {
    if (!mounted) return;

    final Cage? newCage = await showDialog<Cage>(
      context: context,
      builder: (_) => AddCageDialog(birds: widget.birds),
    );

    if (newCage != null) {
      await _addCage(newCage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cages"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadCages,
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
                      onPressed: _loadCages,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              )
              : _cages.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      size: 60,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Aucune cage enregistrée',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _openAddCageDialog,
                      child: const Text('Créer une cage'),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadCages,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _cages.length,
                  itemBuilder: (context, index) {
                    final cage = _cages[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.pink.shade50,
                          child: const Icon(Icons.favorite, color: Colors.pink),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Num : ${cage.cageNumber}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              "♂ ${cage.male.identifier}     X     ♀ ${cage.female.identifier}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          "${cage.male.species} | ${cage.female.species}",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCage(cage),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CageDetailsPage(cage: cage),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _openAddCageDialog,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
}
