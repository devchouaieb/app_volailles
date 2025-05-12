import 'package:app_volailles/models/cage.dart';
import 'package:app_volailles/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:app_volailles/models/bird.dart';
import 'package:app_volailles/data/bird_species.dart';

class AddBirdPage extends StatefulWidget {
  final Function(Bird) onSave;
  final Bird? bird;
  final Cage? cage;
  final String? sppecie;

  const AddBirdPage({
    super.key,
    required this.onSave,
    this.bird,
    this.cage,
    this.sppecie,
  });

  @override
  State<AddBirdPage> createState() => _AddBirdPageState();
}

class _AddBirdPageState extends State<AddBirdPage> {
  final _formKey = GlobalKey<FormState>();

  String _identifier = '';
  String _gender = Constants.male;
  String? _selectedCategory;
  String? _selectedSpecies;
  String _selectedVariety = '';
  String? _selectedStatus;
  String _cage = '';
  DateTime? _birthDate;
  double _price = 0.0;

  // Fonction pour convertir les anciens états en nouveaux états
  String _convertOldStatusToNew(String oldStatus) {
    switch (oldStatus.toLowerCase()) {
      case 'healthy':
        return 'En bonne santé';
      case 'sick':
        return 'Malade';
      case 'in treatment':
        return 'En traitement';
      default:
        return 'En bonne santé'; // Valeur par défaut
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.bird != null) {
      final b = widget.bird!;
      _identifier = b.identifier;
      _gender = b.gender;
      _selectedSpecies = b.species;
      _selectedVariety = b.variety;
      _selectedStatus = _convertOldStatusToNew(
        b.status,
      ); // Conversion de l'état
      _cage = b.cage;
      _birthDate = DateTime.tryParse(b.birthDate);
      _price = b.price;

      // Set the category based on the species
      for (var category in birdCategories) {
        if (category.species.any((s) => s.commonName == b.species)) {
          _selectedCategory = category.name;
          break;
        }
      }
    } else {
      if (widget.cage != null) {
        _cage = widget.cage!.cageNumber;
      }
      // État par défaut pour les nouveaux oiseaux
      _selectedStatus = 'En bonne santé';
      if (widget.sppecie != null) {
        _selectedSpecies = widget.sppecie!;
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  void _saveBird() {
    if (_formKey.currentState!.validate()) {
      if (_birthDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner une date de naissance'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        _formKey.currentState!.save();
        final newBird = Bird(
          id: widget.bird?.id,
          identifier: _identifier.trim(),
          gender: _gender,
          species: _selectedSpecies!,
          variety: _selectedVariety.trim(),
          status: _selectedStatus!,
          cage: _cage.trim(),
          birthDate: _birthDate!.toIso8601String(),
          price: _price,
          motherId: widget.cage?.female?.id,
          fatherId: widget.cage?.male?.id
        );

        widget.onSave(newBird);
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.bird == null ? "Ajouter un oiseau" : "Modifier l'oiseau",
        ),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveBird),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              initialValue: _identifier,
              decoration: const InputDecoration(
                labelText: 'Identifiant / Bague *',
              ),
              validator:
                  (value) =>
                      value == null || value.isEmpty ? 'Champ requis' : null,
              onSaved: (value) => _identifier = value!,
            ),
            const SizedBox(height: 16),
            const Text("Genre *"),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text("Mâle"),
                    value: Constants.male,
                    groupValue: _gender,
                    onChanged: (value) => setState(() => _gender = value!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text("Femelle"),
                    value: Constants.female,
                    groupValue: _gender,
                    onChanged: (value) => setState(() => _gender = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Category Selection
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Catégorie *'),
              items:
                  getAllCategories()
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              validator: (value) => value == null ? 'Champ requis' : null,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                  _selectedSpecies =
                      null; // Reset species when category changes
                });
              },
            ),
            const SizedBox(height: 16),
            // Species Selection
            DropdownButtonFormField<String>(
              value: _selectedSpecies,
              decoration: const InputDecoration(labelText: 'Espèce *'),
              items:
                  _selectedCategory == null
                      ? []
                      : getBirdSpeciesByCategory(_selectedCategory!)
                          .map(
                            (species) => DropdownMenuItem(
                              value: species.commonName,
                              child: Text(
                                '${species.commonName} (${species.scientificName})',
                              ),
                            ),
                          )
                          .toList(),
              validator: (value) => value == null ? 'Champ requis' : null,
              onChanged:
                  _selectedCategory == null
                      ? null
                      : (value) => setState(() => _selectedSpecies = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(labelText: 'État de santé *'),
              items:
                  ['En bonne santé', 'Malade', 'En traitement', 'Mort', 'Vendu']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              validator: (value) => value == null ? 'Champ requis' : null,
              onChanged: (value) => setState(() => _selectedStatus = value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _cage,
              decoration: const InputDecoration(labelText: 'Cage'),
              onSaved: (value) => _cage = value ?? '',
            ),
            const SizedBox(height: 16),
            if (widget.bird != null)
              TextFormField(
                initialValue: _price.toString(),
                decoration: const InputDecoration(labelText: 'Prix (DT)'),
                keyboardType: TextInputType.number,
                onSaved:
                    (value) => _price = double.tryParse(value ?? '0') ?? 0.0,
              ),
            const SizedBox(height: 16),
            const Text("Date de naissance *"),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  _birthDate == null
                      ? "Aucune date sélectionnée"
                      : "${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text("Choisir la date"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
