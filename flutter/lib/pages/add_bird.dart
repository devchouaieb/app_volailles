import 'package:app_volailles/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:app_volailles/models/bird.dart';

class AddBirdPage extends StatefulWidget {
  final Function(Bird) onSave;
  final Bird? bird;
  final String? cage;
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
  String? _selectedSpecies;
  String _selectedVariety = '';
  String? _selectedStatus;
  String _cage = '';
  DateTime? _birthDate;
  double _price = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.bird != null) {
      final b = widget.bird!;
      _identifier = b.identifier;
      _gender = b.gender;
      _selectedSpecies = b.species;
      _selectedVariety = b.variety;
      _selectedStatus = b.status;
      _cage = b.cage;
      _birthDate = DateTime.tryParse(b.birthDate);
      _price = b.price;
    } else {
      if (widget.cage != null) {
        _cage = widget.cage!;
      }
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
                    title: const Text("Male"),
                    value: Constants.male,
                    groupValue: _gender,
                    onChanged: (value) => setState(() => _gender = value!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text("Female"),
                    value: Constants.female,
                    groupValue: _gender,
                    onChanged: (value) => setState(() => _gender = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSpecies,
              decoration: const InputDecoration(labelText: 'Espèce *'),
              items:
                  ['Pigeon', 'Canary', 'Parrot']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              validator: (value) => value == null ? 'Champ requis' : null,
              onChanged: (value) => setState(() => _selectedSpecies = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedVariety.isEmpty ? null : _selectedVariety,
              decoration: const InputDecoration(labelText: 'Variété'),
              items:
                  ['Rouge', 'Bleu', 'Vert']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              onChanged:
                  (value) => setState(() => _selectedVariety = value ?? ''),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(labelText: 'État de santé *'),
              items:
                  ['Healthy', 'Sick', 'In Treatment']
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
