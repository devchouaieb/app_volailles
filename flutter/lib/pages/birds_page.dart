import 'package:app_volailles/services/bird_transfer_service.dart';
import 'package:flutter/material.dart';
import 'package:app_volailles/models/bird.dart';
import 'package:app_volailles/pages/add_bird.dart';
import 'package:app_volailles/pages/sell_bird_dialog.dart';
import 'package:app_volailles/pages/mark_for_sale_dialog.dart';
import 'package:app_volailles/services/bird_service.dart';
import 'package:app_volailles/utils/date_utils.dart';
import 'package:app_volailles/utils/dialog_error_helpers.dart';

class BirdsPage extends StatefulWidget {
  final String? userId;
  const BirdsPage(this.userId, {super.key});

  @override
  State<BirdsPage> createState() => _BirdsPageState();
}

class _BirdsPageState extends State<BirdsPage> {
  final _birdService = BirdService();
  final _birdTransferService = BirdTransferService();
  List<Bird> _birds = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBirds();
  }

  Future<void> _loadBirds() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final birds = await _birdService.getBirds();
      if (!mounted) return;

      setState(() {
        _birds = birds;
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

  Future<void> _addOrUpdateBird(Bird bird) async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      if (bird.id == null) {
        await _birdService.createBird(bird);
      } else {
        await _birdService.updateBird(bird.id!, bird);
      }

      if (!mounted) return;

      // Forcer le rechargement de la liste depuis l'API
      await _loadBirds();

      if (mounted) {
        DialogErrorHelpers.showSuccessSnackBar(
          context,
          message: 'Oiseau sauvegardé avec succès',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      DialogErrorHelpers.showErrorSnackBar(
        context,
        message: 'Erreur lors de la sauvegarde: $e',
      );
    }
  }

  Future<void> _deleteBird(Bird bird) async {
    if (!mounted) return;

    final confirmed = await DialogErrorHelpers.showConfirmationDialog(
      context,
      title: "Supprimer l'oiseau",
      message: "Êtes-vous sûr de vouloir supprimer l'oiseau ${bird.identifier} ?",
      confirmText: 'Supprimer',
      cancelText: 'Annuler',
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await _birdService.deleteBird(bird.id!);
      if (!mounted) return;

      setState(() {
        _birds.removeWhere((b) => b.id == bird.id);
        _isLoading = false;
      });

      if (mounted) {
        DialogErrorHelpers.showSuccessSnackBar(
          context,
          message: 'Oiseau supprimé avec succès',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      DialogErrorHelpers.showErrorSnackBar(
        context,
        message: 'Erreur lors de la suppression: $e',
      );
    }

    setState(() => _isLoading = true);

    try {
      await _birdService.deleteBird(bird.id!);
      if (!mounted) return;

      setState(() {
        _birds.removeWhere((b) => b.id == bird.id);
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Oiseau supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSellBirdDialog(Bird bird) {
    showDialog<void>(
      context: context,
      builder:
          (dialogContext) => SellBirdDialog(
            bird: bird,
            onSuccess: (double price, String buyerNationalId) async {
              try {
                setState(() => _isLoading = true);

                // Mettre à jour l'oiseau dans la base de données
                final soldBird = await _birdService.sellBird(
                  bird.id!,
                  price,
                  buyerNationalId,
                  'Acheteur',
                  buyerPhone: '',
                );

                if (!mounted) return;

                setState(() {
                  _birds.removeWhere((b) => b.id == bird.id);
                  _isLoading = false;
                });

                DialogErrorHelpers.showSuccessSnackBar(
                  context,
                  message: 'Oiseau vendu avec succès',
                );
              } catch (e) {
                if (!mounted) return;
                setState(() => _isLoading = false);
                DialogErrorHelpers.showErrorSnackBar(
                  context,
                  message: 'Erreur lors de la vente: $e',
                );
              }
            },
          ),
    );
  }

  void _showMarkForSaleDialog(Bird bird) {
    showDialog<void>(
      context: context,
      builder:
          (dialogContext) => MarkForSaleDialog(
            bird: bird,
            dialogContext: dialogContext,
            onSuccess: (double askingPrice) async {
              // Implement mark for sale functionality
              _markForSale(bird, askingPrice);
            },
          ),
    );
  }

  void _markForSale(Bird bird, double askingPrice) async {
    setState(() => _isLoading = true);

    try {
      await _birdTransferService.markBirdForSale(bird.id!, askingPrice);
      if (!mounted) return;

      setState(() {
        _birds.removeWhere((b) => b.id == bird.id);
        _isLoading = false;
      });

      if (mounted) {
        DialogErrorHelpers.showSuccessSnackBar(
          context,
          message: 'Oiseau marqué à vendre',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      DialogErrorHelpers.showErrorSnackBar(
        context,
        message: 'Erreur lors de marquer à vendre: $e',
      );
    }
  }

  void _navigateToAddBirdPage({Bird? bird}) async {
    if (!mounted) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBirdPage(onSave: _addOrUpdateBird, bird: bird),
      ),
    );

    if (result == true && mounted) {
      await _loadBirds();
    }
  }

  Color _getBirdColor(Bird bird) {
    print(widget.userId);
    if (bird.sellerId == widget.userId) {
      return Colors.purple.shade300;
    } else if (bird.gender.toLowerCase() == 'male') {
      return Colors.blue.shade100;
    } else if (bird.gender.toLowerCase() == 'female') {
      return Colors.pink.shade100;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tous les oiseaux"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadBirds,
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
                      onPressed: _loadBirds,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              )
              : _birds.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.pets, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      "Aucun oiseau enregistré",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _navigateToAddBirdPage(),
                      child: const Text('Ajouter un oiseau'),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadBirds,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _birds.length,
                  itemBuilder: (context, index) {
                    final bird = _birds[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: _getBirdColor(bird),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor:
                              bird.gender.toLowerCase() == 'male'
                                  ? Colors.blue.shade200
                                  : bird.gender.toLowerCase() == 'female'
                                  ? Colors.pink.shade200
                                  : Colors.grey.shade200,
                          child: const Icon(Icons.pets, color: Colors.white),
                        ),
                        title: Text(
                          bird.identifier,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "${bird.species} | ${bird.getStatus(widget.userId)} | Age: ${calculateAge(bird.birthDate)}",
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if ((bird.soldPrice ?? 0) > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  "${bird.soldPrice} DT",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            if ((!bird.forSale )&& widget.userId == bird.userId && bird.isAvailable())
                              IconButton(
                                icon: const Icon(
                                  Icons.sell,
                                  color: Colors.deepPurple,
                                ),
                                onPressed: () => _showMarkForSaleDialog(bird),
                                tooltip: 'Marquer à Vendre',
                              ),
                             if ((!bird.forSale && bird.sellerId == null) && widget.userId == bird.userId && bird.isAvailable())
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteBird(bird),
                                tooltip: 'Supprimer',
                              ) 
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddBirdPage(),
        child: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
        tooltip: 'Ajouter un oiseau',
      ),
    );
  }
}
