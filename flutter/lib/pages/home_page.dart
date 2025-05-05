// lib/pages/home_page.dart
import 'package:app_volailles/pages/nest_page.dart';
import 'package:app_volailles/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:app_volailles/models/bird.dart';
import 'package:app_volailles/pages/add_bird.dart';
import 'package:app_volailles/pages/statistics_page.dart';
import 'package:app_volailles/pages/cages_page.dart';
import 'package:app_volailles/pages/nid_page.dart';
import 'package:app_volailles/pages/vendues_page.dart';
import 'package:app_volailles/pages/purchases_page.dart';
import 'package:app_volailles/pages/species_page.dart';
import 'package:app_volailles/pages/sell_bird_dialog.dart';
import 'package:app_volailles/pages/mark_for_sale_dialog.dart';
import 'package:app_volailles/pages/birds_for_sale_page.dart';
import 'package:app_volailles/services/bird_transfer_service.dart';
import 'package:app_volailles/utils/date_utils.dart';
import 'package:app_volailles/services/auth_service.dart';
import 'package:app_volailles/services/bird_service.dart';
import 'package:app_volailles/pages/auth/login_page.dart';
import 'package:app_volailles/services/bird_sync_service.dart';
import 'package:app_volailles/widgets/app_drawer.dart';
import 'package:app_volailles/pages/birds_page.dart';
import 'package:app_volailles/pages/associations_page.dart';
import 'package:app_volailles/pages/reseau_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final BirdService _birdService = BirdService();
  final BirdSyncService _birdSyncService = BirdSyncService();
  final BirdTransferService _birdTransferService = BirdTransferService();
  final AuthService _authService = AuthService();
  List<Bird> _birds = [];
  List<Bird> _soldBirds = [];
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _currentUser;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Charger les informations de l'utilisateur actuel
    try {
      final userData = await _authService.getUserData();
      if (!mounted) return;

      if (userData != null) {
        setState(() {
          _currentUser = userData;
        });
      } else {
        // Aucun utilisateur connecté, rediriger vers la page de connexion
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }
        return;
      }

      // Charger les données des oiseaux
      await _loadData();
    } catch (e) {
      print("Erreur d'initialisation: $e");
      if (mounted) {
        _showErrorSnackBar("Erreur lors de l'initialisation de l'application");
      }
    }
  }

  // Charger les données depuis l'API
  Future<void> _loadData() async {
    if (!mounted) return;

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Load data in batches to prevent UI blocking
      final futures = await Future.wait([
        _birdSyncService.syncBirds(),
        _birdSyncService.checkConflicts(_birds),
        _birdService.getSoldBirds(), // Récupérer également les oiseaux vendus
      ]);

      if (!mounted) return;

      final syncedBirds = futures[0];
      final conflicts = futures[1];
      final soldBirds = futures[2];

      if (conflicts.isNotEmpty) {
        await _birdSyncService.resolveConflicts(conflicts);
      }

      // Update the UI with the new data
      if (mounted) {
        setState(() {
          _birds =
              syncedBirds.where((bird) => !bird.sold && !bird.forSale).toList();
          _soldBirds = soldBirds.where((bird) => bird.sold).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Erreur de connexion au serveur. Vérifiez votre connexion internet.';
        });

        final currentContext = context;
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(
            content: Text('Erreur de synchronisation: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: 'Réessayer', onPressed: _loadData),
          ),
        );
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    final currentContext = context;
    ScaffoldMessenger.of(currentContext).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  // Ajouter ou mettre à jour un oiseau
  Future<void> _addOrUpdateBird(Bird bird) async {
    if (!mounted) return;

    try {
      setState(() => _isLoading = true);

      // First save to local service
      Bird updatedBird;
      if (bird.id == null) {
        updatedBird = await _birdService.createBird(bird);
      } else {
        updatedBird = await _birdService.updateBird(bird.id!, bird);
      }

      // Update the local list
      if (mounted) {
        setState(() {
          // Remove the old bird if it exists
          _birds.removeWhere((b) => b.id == updatedBird.id);
          // Add the new/updated bird
          _birds.add(updatedBird);
          _isLoading = false;
        });
      }

      // Show success message
      if (mounted) {
        final currentContext = context;
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(
            content: Text('Oiseau sauvegardé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final currentContext = context;
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Supprimer un oiseau
  Future<void> _deleteBird(Bird bird) async {
    if (!mounted) return;

    try {
      if (bird.id == null) return;

      // Create a local context reference
      final currentContext = context;

      setState(() => _isLoading = true);

      // Remove the bird from the list immediately for better UX
      setState(() {
        _birds.removeWhere((b) => b.id == bird.id);
      });

      // Then perform the API call
      await _birdService.deleteBird(bird.id!);

      if (mounted) {
        setState(() => _isLoading = false);

        // Show success message
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(
            content: Text('Oiseau supprimé avec succès'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Add the bird back to the list if deletion failed
          if (!_birds.any((b) => b.id == bird.id)) {
            _birds.add(bird);
          }
        });

        // Show error message
        final currentContext = context;
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Vendre un oiseau
  Future<void> _sellBird(
    Bird bird,
    double price,
    String buyerNationalId,
    String buyerFullName, {
    String? buyerPhone,
  }) async {
    if (!mounted) return;

    // Vérifier que l'ID de l'oiseau n'est pas null
    if (bird.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur: ID de l\'oiseau manquant'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Mettre à jour l'oiseau localement pour une meilleure expérience utilisateur
      final updatedBird = Bird(
        id: bird.id,
        identifier: bird.identifier,
        species: bird.species,
        variety: bird.variety,
        gender: bird.gender,
        birthDate: bird.birthDate,
        cage: bird.cage,
        status: 'Vendu',
        price: price,
        sold: true,
        soldDate: DateTime.now().toIso8601String(),
        soldPrice: price,
        buyerInfo: {
          'nationalId': buyerNationalId,
          'fullName': buyerFullName,
          'phone': buyerPhone ?? '',
        },
        // S'assurer que ces propriétés sont correctement définies
        forSale: false,
        sellerId: bird.sellerId,
      );

      // Mettre à jour l'oiseau dans la base de données
      final soldBird = await BirdService().sellBird(
        bird.id!,
        price,
        buyerNationalId,
        buyerFullName,
        buyerPhone: buyerPhone,
      );

      if (!mounted) return;

      setState(() {
        // Retirer l'oiseau de la liste des oiseaux disponibles
        _birds.removeWhere((b) => b.id == bird.id);
        // Ajouter l'oiseau à la liste des oiseaux vendus
        _soldBirds.add(soldBird);
        _soldBirds = _soldBirds.where((b) => b.sold).toList();
        _isLoading = false;
      });

      // Forcer une synchronisation pour s'assurer que les listes sont à jour
      await _birdSyncService.syncBirds();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oiseau vendu avec succès'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la vente: ${e.toString()}'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Afficher le dialogue de vente
  void _showSellBirdDialog(Bird bird) {
    showDialog<void>(
      context: context,
      builder:
          (dialogContext) => SellBirdDialog(
            bird: bird,
            onSuccess: (double price, String buyerNationalId) {
              _sellBird(
                bird,
                price,
                buyerNationalId,
                'Acheteur',
                buyerPhone: '',
              );
            },
          ),
    );
  }




  // Afficher le dialogue pour mettre un oiseau en vente
  void _showMarkForSaleDialog(Bird bird) {
    showDialog<void>(
      context: context,
      builder:
          (dialogContext) => MarkForSaleDialog(
            bird: bird,
            dialogContext: dialogContext,
            onSuccess: (double askingPrice) {
              _markBirdForSale(bird, askingPrice);
            },
          ),
    );
  }
   

  // Marquer un oiseau comme étant à vendre
  Future<void> _markBirdForSale(Bird bird, double askingPrice) async {
    if (!mounted) return;

    // Vérifier que l'ID de l'oiseau n'est pas null
    if (bird.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur: ID de l\'oiseau manquant'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Mettre à jour l'oiseau localement pour une meilleure expérience utilisateur
      final updatedBird = bird.copyWith(
        forSale: true,
        askingPrice: askingPrice,
        sellerId: _currentUser?['id'],
      );

      // Mettre à jour l'oiseau dans la base de données
      await _birdTransferService.markBirdForSale(bird.id!, askingPrice);

      if (!mounted) return;

      setState(() {
        // Retirer l'oiseau de la liste des oiseaux disponibles car il est maintenant en vente
        _birds.removeWhere((b) => b.id == bird.id);
        _isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oiseau mis en vente avec succès'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise en vente: ${e.toString()}'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmationDialog(Bird bird) {
    if (!mounted) return;
    final currentContext = context;

    showDialog(
      context: currentContext,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text(
              "Supprimer l'oiseau",
              style: TextStyle(color: Colors.red),
            ),
            content: Text(
              "Êtes-vous sûr de vouloir supprimer l'oiseau ${bird.identifier} ?",
            ),
            actions: [
              TextButton(
                child: const Text("Annuler"),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade100,
                ),
                child: const Text("Confirmer"),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _deleteBird(bird);
                },
              ),
            ],
          ),
    );
  }

  void _navigateToAddBirdPage({Bird? bird}) async {
    if (!mounted) return;
    final currentContext = context;

    final result = await Navigator.push(
      currentContext,
      MaterialPageRoute(
        builder: (context) => AddBirdPage(onSave: _addOrUpdateBird, bird: bird),
      ),
    );

    // Rafraîchir les données si nécessaire
    if (result == true && mounted) {
      await _loadData();
    }
  }

  // Gérer les actions du drawer
  void onDrawerItemClicked(String title) async {
    if (!mounted) return;
    final currentContext = context;
    Navigator.pop(currentContext);

    if (title == 'Tous les oiseaux') {
      if (!mounted) return;
      Navigator.push(
        currentContext,
        MaterialPageRoute(builder: (_) => const BirdsPage()),
      );
    } else if (title == 'Statistiques') {
      if (!mounted) return;
      Navigator.push(
        currentContext,
        MaterialPageRoute(builder: (_) => StatisticsPage(birds: _birds)),
      );
    } else if (title == 'Cages') {
      if (!mounted) return;
      Navigator.push(
        currentContext,
        MaterialPageRoute(builder: (_) => CagesPage(birds: _birds)),
      );
    } else if (title == 'Couvés') {
      if (!mounted) return;
      Navigator.push(
        currentContext,
        MaterialPageRoute(builder: (_) => const NestPage()),
      );
    } else if (title == 'Réseaux') {
      if (!mounted) return;
      Navigator.push(
        currentContext,
        MaterialPageRoute(builder: (_) => const ReseauPage()),
      );
    } else if (title == 'vendues') {
      try {
        setState(() => _isLoading = true);
        final soldBirds = await _birdService.getSoldBirds();
        if (!mounted) return;

        setState(() {
          _soldBirds = soldBirds.where((bird) => bird.sold).toList();
          _isLoading = false;
        });

        Navigator.push(
          currentContext,
          MaterialPageRoute(
            builder:
                (_) => VenduesPage(
                  birds: _birds,
                  soldBirds: _soldBirds,
                  onSellBird: _sellBird,
                ),
          ),
        );
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(currentContext).showSnackBar(
            SnackBar(
              content: Text('Erreur lors du chargement des oiseaux vendus: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Réessayer',
                onPressed: () => onDrawerItemClicked('vendues'),
              ),
            ),
          );
        }
      }
    } else if (title == 'Achats') {
      if (!mounted) return;
      Navigator.push(
        currentContext,
        MaterialPageRoute(
          builder:
              (_) => PurchasesPage(birds: _birds, onAddBird: _addOrUpdateBird),
        ),
      );
    } else if (title == 'Vendues') {
      try {
        setState(() => _isLoading = true);
        final soldBirds = await BirdService().getSoldBirds();
        if (!mounted) return;

        setState(() {
          _soldBirds = soldBirds;
          _isLoading = false;
        });

        Navigator.push(
          currentContext,
          MaterialPageRoute(
            builder:
                (_) => VenduesPage(
                  birds: _birds,
                  soldBirds: _soldBirds,
                  onSellBird: _sellBird,
                ),
          ),
        );
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(currentContext).showSnackBar(
            SnackBar(
              content: Text('Erreur lors du chargement des oiseaux vendus: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Réessayer',
                onPressed: () => onDrawerItemClicked('Vendues'),
              ),
            ),
          );
        }
      }
    } else if (title == 'Oiseaux à vendre') {
      if (!mounted) return;
      Navigator.push(
        currentContext,
        MaterialPageRoute(builder: (_) => const BirdsForSalePage()),
      );
    } else if (title == 'Espèces') {
      if (!mounted) return;
      Navigator.push(
        currentContext,
        MaterialPageRoute(builder: (_) => SpeciesPage()),
      );
    } else if (title == 'Associations') {
      if (!mounted) return;
      Navigator.push(
        currentContext,
        MaterialPageRoute(builder: (_) => const AssociationsPage()),
      );
    } else if (title == 'Déconnexion') {
      await _authService.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        currentContext,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  // Déterminer la couleur de fond de la carte d'oiseau en fonction du sexe
  Color _getBirdColor(Bird bird) {
    if (bird.gender.toLowerCase() == Constants.male) {
      return Colors.blue.shade100;
    } else if (bird.gender.toLowerCase() == Constants.female) {
      return Colors.pink.shade100;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        backgroundColor: Colors.deepPurple,
        title: const Text(
          "Volailles",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.menu, size: 30),
            );
          },
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            IconButton(
              onPressed: () => _loadData(),
              icon: const Icon(Icons.refresh, size: 25),
              tooltip: 'Rafraîchir',
            ),
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: BirdSearchDelegate(_birds, _navigateToAddBirdPage),
              );
            },
            icon: const Icon(Icons.search, size: 25),
            tooltip: 'Rechercher',
          ),
        ],
      ),
      drawer: AppDrawer(
        currentUser: _currentUser,
        soldBirds: _soldBirds,
        onDrawerItemClicked: onDrawerItemClicked,
      ),
      body:
          _isLoading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Chargement des données...',
                      style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                    ),
                  ],
                ),
              )
              : _errorMessage.isNotEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur: $_errorMessage',
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Liste des volailles",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        if (_currentUser != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.deepPurple.shade200,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  color: Colors.deepPurple,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "Connecté en tant que: ${_currentUser!['fullName']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 30),
                        if (_birds.isEmpty)
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.pets,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "Aucun oiseau ajouté",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => _navigateToAddBirdPage(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                  ),
                                  child: const Text('Ajouter un oiseau'),
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _birds.length,
                            itemBuilder: (context, index) {
                              final bird = _birds[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
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
                                            : bird.gender.toLowerCase() ==
                                                'female'
                                            ? Colors.pink.shade200
                                            : Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.pets,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    bird.identifier,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "${bird.species} | ${bird.status} | Age: ${calculateAge(bird.birthDate)}",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (bird.price > 0)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade100,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Text(
                                            "${bird.price} DT",
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.sell,
                                          color: Colors.deepPurple,
                                        ),
                                        onPressed:
                                            () => _showMarkForSaleDialog(bird),
                                        tooltip: 'Vendre',
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed:
                                            () => _showDeleteConfirmationDialog(
                                              bird,
                                            ),
                                        tooltip: 'Supprimer',
                                      ),
                                    ],
                                  ),
                                  onTap:
                                      () => _navigateToAddBirdPage(bird: bird),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
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

// Classe pour implémenter la recherche d'oiseaux
class BirdSearchDelegate extends SearchDelegate<Bird?> {
  final List<Bird> birds;
  final Function({Bird? bird}) onBirdSelected;

  BirdSearchDelegate(this.birds, this.onBirdSelected);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    // Filtrer les oiseaux en fonction de la requête
    final filteredBirds =
        birds.where((bird) {
          return bird.identifier.toLowerCase().contains(query.toLowerCase()) ||
              bird.species.toLowerCase().contains(query.toLowerCase()) ||
              bird.variety.toLowerCase().contains(query.toLowerCase()) ||
              bird.cage.toLowerCase().contains(query.toLowerCase());
        }).toList();

    // Trier les résultats
    filteredBirds.sort((a, b) => a.identifier.compareTo(b.identifier));

    return ListView.builder(
      itemCount: filteredBirds.length,
      itemBuilder: (context, index) {
        final bird = filteredBirds[index];
        return ListTile(
          title: Text(bird.identifier),
          subtitle: Text(
            '${bird.species} | ${bird.gender} | Cage: ${bird.cage}',
          ),
          leading: Icon(
            Icons.pets,
            color:
                bird.gender.toLowerCase() == 'male'
                    ? Colors.blue
                    : bird.gender.toLowerCase() == 'female'
                    ? Colors.pink
                    : Colors.grey,
          ),
          onTap: () {
            close(context, bird);
            onBirdSelected(bird: bird);
          },
        );
      },
    );
  }
}
