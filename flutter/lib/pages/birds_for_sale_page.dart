import 'package:flutter/material.dart';
import 'package:app_volailles/models/bird.dart';
import 'package:app_volailles/services/bird_transfer_service.dart';
import 'package:app_volailles/services/bird_service.dart';

class BirdsForSalePage extends StatefulWidget {
  final Map<String, dynamic>? currentUser;
  const BirdsForSalePage(this.currentUser, {super.key});

  @override
  State<BirdsForSalePage> createState() => _BirdsForSalePageState();
}

class _BirdsForSalePageState extends State<BirdsForSalePage> {
  final nationalIdController = TextEditingController();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final BirdTransferService _birdTransferService = BirdTransferService();
  final BirdService _birdService = BirdService();
  List<Bird> _birdsForSale = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initInputs();
    _loadBirdsForSale();
  }

  _initInputs() {
    nationalIdController.text = widget.currentUser?["nationalId"];
    phoneController.text = widget.currentUser?["phone"] ?? "";
    fullNameController.text = widget.currentUser?["fullName"];
  }

  Future<void> _loadBirdsForSale() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final birdsForSale = await _birdTransferService.getBirdsForSale();

      // Filter out sold birds
      final availableBirds = birdsForSale.where((bird) => !bird.sold).toList();

      setState(() {
        _birdsForSale = availableBirds;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur lors du chargement des oiseaux en vente: $e';
      });
    }
  }

  Future<void> _purchaseBird(Bird bird) async {
    try {
      setState(() => _isLoading = true);

      // Show dialog to enter buyer information
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => _buildPurchaseDialog(bird, context),
      );

      if (result == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Purchase the bird
      final purchasedBird = await _birdTransferService.purchaseBird(
        bird.id!,
        result['nationalId'],
        result['fullName'],
        buyerPhone: result['phone'],
        soldPrice: result['price'],
      );

      // Add the purchased bird to the user's collection
     // await _birdService.createBird(purchasedBird);

      // Remove the bird from the for sale list
      setState(() {
        _birdsForSale.removeWhere((b) => b.id == bird.id);
        _isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oiseau acheté avec succès'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
       if (!mounted) return;
      setState(() => _isLoading = false);

     

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'achat: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildPurchaseDialog(Bird bird, BuildContext dialogContext) {
    final priceController = TextEditingController(
      text: bird.askingPrice?.toString() ?? '',
    );

    final formKey = GlobalKey<FormState>();

    return AlertDialog(
      title: const Text('Acheter l\'oiseau'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Oiseau: ${bird.identifier}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Categorie:${bird.category}'),
              Text('Espèce: ${bird.species}'),
              Text('Couleur: ${bird.color}'),
              Text('Prix demandé: ${bird.askingPrice} DT'),
              const SizedBox(height: 16),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Prix final'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un prix';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: nationalIdController,
                decoration: const InputDecoration(
                  labelText: 'CIN de l\'acheteur',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le CIN';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: fullNameController,
                decoration: const InputDecoration(labelText: 'Nom complet'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom complet';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone (optionnel)',
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.of(dialogContext).pop({
                'price': double.parse(priceController.text),
                'nationalId': nationalIdController.text,
                'fullName': fullNameController.text,
                'phone': phoneController.text,
              });
            }
          },
          child: const Text('Acheter'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oiseaux à vendre'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBirdsForSale,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadBirdsForSale,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              )
              : _birdsForSale.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "Aucun oiseau à vendre pour le moment",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: _birdsForSale.length,
                itemBuilder: (context, index) {
                  final bird = _birdsForSale[index];
                  print("${bird.userId} widget : ${widget.currentUser}");
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple.shade100,
                        child: const Icon(Icons.pets, color: Colors.deepPurple),
                      ),
                      title: Text(
                        bird.identifier,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Espèce: ${bird.species}'),
                          Text('Variété: ${bird.color}'),
                          Text('Genre: ${bird.gender}'),
                          Text('Prix demandé: ${bird.askingPrice} DT'),
                        ],
                      ),
                      trailing:
                          widget.currentUser?["id"] == bird.userId
                              ? SizedBox()
                              : ElevatedButton(
                                onPressed: () => _purchaseBird(bird),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Acheter'),
                              ),
                    ),
                  );
                },
              ),
    );
  }
}
