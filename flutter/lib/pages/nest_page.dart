import 'package:app_volailles/models/bird.dart';
import 'package:app_volailles/services/bird_service.dart';
import 'package:flutter/material.dart';
import 'package:app_volailles/models/nest.dart';
import 'package:app_volailles/models/cage.dart';
import 'package:app_volailles/services/nest_service.dart';
import 'package:app_volailles/services/cage_service.dart';
import 'package:app_volailles/pages/add_bird.dart';
import 'package:app_volailles/pages/add_nest_dialog.dart';

class NestPage extends StatefulWidget {
  const NestPage({super.key});

  @override
  State<NestPage> createState() => _NestPageState();
}

class _NestPageState extends State<NestPage> {
  final _nestService = NestService();
  final _cageService = CageService();
   final _birdService = BirdService();
  List<Nest> _nests = [];
  List<Cage> _cages = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final [nests, cages] = await Future.wait([
        _nestService.getNests(),
        _cageService.getCages(),
      ]);

      if (!mounted) return;

      setState(() {
        _nests = nests as List<Nest>;
        _cages = cages as List<Cage>;
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

  Future<void> _addNest(Nest nest) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final newNest = await _nestService.createNest(nest);
      if (!mounted) return;

      setState(() {
        _nests.add(newNest);
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Couvé ajouté avec succès'),
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
  Future<void> _addBird(Bird bird)async{
  if (!mounted) return;

    setState(() => _isLoading = true);

    try {
    
       await _birdService.createBird(bird);
      

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Oiseau sauvegardé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sauvegarde: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  
  }

  Future<void> _updateNest(Nest nest) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final updatedNest = await _nestService.updateNest(nest);
      if (!mounted) return;

      setState(() {
        final index = _nests.indexWhere((n) => n.id == updatedNest.id);
        if (index != -1) {
          _nests[index] = updatedNest;
        }
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Couvé mis à jour avec succès'),
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
            content: Text('Erreur lors de la mise à jour: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteNest(Nest nest) async {
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Supprimer le Couvé ?"),
            content: const Text(
              "Êtes-vous sûr de vouloir supprimer ce Couvé ?",
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
      await _nestService.deleteNest(nest.id!);
      if (!mounted) return;

      setState(() {
        _nests.removeWhere((n) => n.id == nest.id);
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Couvé supprimé avec succès'),
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

  void _openAddNestDialog() async {
    if (!mounted) return;

    final Nest? newNest = await showDialog<Nest>(
      context: context,
      builder: (_) => AddNestDialog(cages: _cages),
    );

    if (newNest != null) {
      await _addNest(newNest);
    }
  }

  void _openAddBirdDialog(Nest nest) async {
    if (!mounted) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => AddBirdPage(
              onSave: (bird) async {
                // Update nest with new bird
                final updatedNest = nest.copyWith(
                  birdsExited: nest.birdsExited + 1,
                  firstBirdExitDate: nest.firstBirdExitDate ?? DateTime.now(),
                );
                await _updateNest(updatedNest);
                await _addBird(bird);
              },
              cage: nest.cageNumber,
            ),
      ),
    );

    if (result == true) {
      await _loadData();
    }
  }

  void _openEditNestDialog(Nest nest) async {
    if (!mounted) return;

    final Nest? updatedNest = await showDialog<Nest>(
      context: context,
      builder: (_) => AddNestDialog(cages: _cages, nest: nest),
    );

    if (updatedNest != null) {
      await _updateNest(updatedNest);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Couvés"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadData,
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
                      onPressed: _loadData,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              )
              : _nests.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.egg, size: 60, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Aucun Couvé enregistré',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _openAddNestDialog,
                      child: const Text('Créer un Couvé'),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadData,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _nests.length,
                  itemBuilder: (context, index) {
                    final nest = _nests[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.amber.shade50,
                          child: const Icon(Icons.egg, color: Colors.amber),
                        ),
                        title: Text(
                          "Cage ${nest.cageNumber}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Œufs: ${nest.numberOfEggs} | Fécondés: ${nest.fertilizedEggs}",
                            ),
                            Text(
                              "Extraits: ${nest.extractedEggs} | Sortis: ${nest.birdsExited}",
                            ),
                            if (nest.firstBirdExitDate != null)
                              Text(
                                "Première sortie: ${nest.firstBirdExitDate!.day}/${nest.firstBirdExitDate!.month}/${nest.firstBirdExitDate!.year}",
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.add_circle,
                                color: Colors.green,
                              ),
                              onPressed: () => _openAddBirdDialog(nest),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _openEditNestDialog(nest),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteNest(nest),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _openAddNestDialog,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
}
