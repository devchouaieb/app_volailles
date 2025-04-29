import 'package:flutter/material.dart';
import 'package:app_volailles/models/bird.dart';
import 'package:app_volailles/services/bird_service.dart';
import 'package:app_volailles/utils/date_utils.dart';

class PurchasesPage extends StatefulWidget {
  final List<Bird> birds;
  final Function(Bird)? onAddBird;

  const PurchasesPage({
    super.key,
    this.birds = const [],
    this.onAddBird,
  });

  @override
  State<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends State<PurchasesPage> {
  final _formKey = GlobalKey<FormState>();
  final _birdService = BirdService();
  bool _isLoading = false;
  String? _errorMessage;

  // Contrôleurs pour les champs du formulaire
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _cageController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String _gender = 'Male';
  String? _selectedSpecies;
  String _selectedVariety = '';
  String _selectedStatus = 'Healthy';
  DateTime? _birthDate;

  @override
  void dispose() {
    _identifierController.dispose();
    _cageController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _addBird() async {
    try {
      setState(() => _isLoading = true);

      final bird = Bird(
        identifier: _identifierController.text,
        species: _selectedSpecies!,
        variety: _selectedVariety,
        gender: _gender,
        birthDate: _birthDate?.toIso8601String() ?? '',
        cage: _cageController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        status: _selectedStatus,
      );

      final createdBird = await _birdService.createBird(bird);

      if (createdBird != null) {
        widget.onAddBird?.call(createdBird);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Oiseau "${createdBird.identifier}" ajouté avec succès',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'ajout de l\'oiseau'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _identifierController.clear();
    _cageController.clear();
    _priceController.clear();
    setState(() {
      _gender = 'Male';
      _selectedSpecies = null;
      _selectedVariety = '';
      _selectedStatus = 'Healthy';
      _birthDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Achats d'oiseaux",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 4,
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
                      'Ajout en cours...',
                      style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre de la section formulaire
                    const Text(
                      "Nouvel achat d'oiseau",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_errorMessage != null) const SizedBox(height: 16),

                    // Formulaire
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _identifierController,
                            decoration: const InputDecoration(
                              labelText: 'Identifiant / Bague *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.pets),
                              hintText:
                                  'Entrez l\'identifiant ou le numéro de bague',
                            ),
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Champ requis'
                                        : null,
                          ),
                          const SizedBox(height: 16),

                          // Genre
                          const Text(
                            "Genre *",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text("Male"),
                                  value: "Male",
                                  groupValue: _gender,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _gender = value);
                                    }
                                  },
                                  activeColor: Colors.deepPurple,
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text("Female"),
                                  value: "Female",
                                  groupValue: _gender,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _gender = value);
                                    }
                                  },
                                  activeColor: Colors.deepPurple,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Espèce
                          DropdownButtonFormField<String>(
                            value: _selectedSpecies,
                            decoration: const InputDecoration(
                              labelText: 'Espèce *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.category),
                              hintText: 'Sélectionnez une espèce',
                            ),
                            items:
                                ['Pigeon', 'Canary', 'Parrot']
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                            validator:
                                (value) =>
                                    value == null ? 'Champ requis' : null,
                            onChanged: (value) {
                              setState(() => _selectedSpecies = value);
                            },
                          ),
                          const SizedBox(height: 16),

                          // Variété
                          DropdownButtonFormField<String>(
                            value:
                                _selectedVariety.isEmpty
                                    ? null
                                    : _selectedVariety,
                            decoration: const InputDecoration(
                              labelText: 'Variété',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.color_lens),
                              hintText: 'Sélectionnez une variété',
                            ),
                            items:
                                ['Rouge', 'Bleu', 'Vert']
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              setState(() => _selectedVariety = value ?? '');
                            },
                          ),
                          const SizedBox(height: 16),

                          // État de santé
                          DropdownButtonFormField<String>(
                            value: _selectedStatus,
                            decoration: const InputDecoration(
                              labelText: 'État de santé *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.health_and_safety),
                              hintText: 'Sélectionnez l\'état de santé',
                            ),
                            items:
                                ['Healthy', 'Sick', 'In Treatment']
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                            validator:
                                (value) =>
                                    value == null ? 'Champ requis' : null,
                            onChanged: (value) {
                              setState(() => _selectedStatus = value!);
                            },
                          ),
                          const SizedBox(height: 16),

                          // Cage
                          TextFormField(
                            controller: _cageController,
                            decoration: const InputDecoration(
                              labelText: 'Cage',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.home),
                              hintText: 'Entrez le numéro de cage',
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Prix
                          TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                              labelText: 'Prix (DT) *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.attach_money),
                              hintText: 'Entrez le prix d\'achat',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un prix';
                              }
                              final price = double.tryParse(value);
                              if (price == null || price <= 0) {
                                return 'Le prix doit être supérieur à 0';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Date de naissance
                          const Text(
                            "Date de naissance *",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.deepPurple.shade300,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _birthDate == null
                                      ? "Aucune date sélectionnée"
                                      : "${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const Spacer(),
                                ElevatedButton(
                                  onPressed: () => _selectDate(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text("Choisir la date"),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Bouton d'ajout
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _addBird,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child:
                                  _isLoading
                                      ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Text(
                                        'AJOUTER',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
