import 'package:flutter/material.dart';
import 'package:app_volailles/models/pair.dart';
import 'package:app_volailles/models/bird.dart';
import 'package:app_volailles/pages/add_pair_dialog.dart';
import 'package:app_volailles/pages/pair_details_page.dart';
import 'package:app_volailles/services/pair_service.dart';

class PairsPage extends StatefulWidget {
  final List<Bird> birds;

  const PairsPage({super.key,  this.birds = const []});

  @override
  State<PairsPage> createState() => _PairsPageState();
}

class _PairsPageState extends State<PairsPage> {
  final _pairService = PairService();
  List<Pair> _pairs = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPairs();
  }

  Future<void> _loadPairs() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pairs = await _pairService.getPairs();
      if (!mounted) return;

      setState(() {
        _pairs = pairs;
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

  Future<void> _addPair(Pair pair) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final newPair = await _pairService.createPair(pair);
      if (!mounted) return;

      setState(() {
        _pairs.add(newPair);
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paire ajoutée avec succès'),
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

  Future<void> _deletePair(Pair pair) async {
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Supprimer la paire ?"),
            content: const Text(
              "Êtes-vous sûr de vouloir supprimer cette paire ?",
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
      await _pairService.deletePair(pair.id!);
      if (!mounted) return;

      setState(() {
        _pairs.removeWhere((p) => p.id == pair.id);
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paire supprimée avec succès'),
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

  void _openAddPairDialog() async {
    if (!mounted) return;

    final Pair? newPair = await showDialog<Pair>(
      context: context,
      builder: (_) => AddPairDialog(birds: widget.birds),
    );

    if (newPair != null) {
      await _addPair(newPair);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paires"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadPairs,
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
                      onPressed: _loadPairs,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              )
              : _pairs.isEmpty
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
                      'Aucune paire enregistrée',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _openAddPairDialog,
                      child: const Text('Créer une paire'),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadPairs,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pairs.length,
                  itemBuilder: (context, index) {
                    final pair = _pairs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.pink.shade50,
                          child: const Icon(Icons.favorite, color: Colors.pink),
                        ),
                        title: Text(
                          "♂ ${pair.male.identifier}     X     ♀ ${pair.female.identifier}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "${pair.male.species} | ${pair.female.species}",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deletePair(pair),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PairDetailsPage(pair: pair),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _openAddPairDialog,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
}
