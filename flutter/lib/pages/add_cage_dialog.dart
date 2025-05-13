import 'package:flutter/material.dart';
import 'package:app_volailles/models/cage.dart';
import 'package:app_volailles/models/bird.dart';
import 'package:app_volailles/utils/constants.dart';

class AddCageDialog extends StatefulWidget {
  final List<Bird> birds;

  const AddCageDialog({super.key, required this.birds});

  @override
  State<AddCageDialog> createState() => _AddCageDialogState();
}

class _AddCageDialogState extends State<AddCageDialog> {
  Bird? _selectedMale;
  Bird? _selectedFemale;
  String _status = 'active';
  String _notes = '';
  String _cageNumber = '';
  final _formKey = GlobalKey<FormState>();

  late List<Bird> _males;
  late List<Bird> _females;

  @override
  void initState() {
    super.initState();
    _males =
        widget.birds
            .where(
              (bird) =>
                  bird.gender.toLowerCase() == Constants.male &&
                  bird.cageNumber == "",
            )
            .toList();
    _females =
        widget.birds
            .where(
              (bird) =>
                  bird.gender.toLowerCase() == Constants.female &&
                  bird.cageNumber == "",
            )
            .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Créer une cage'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cage Number
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Numéro de cage',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home),
                ),
                onChanged: (value) {
                  setState(() {
                    _cageNumber = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le numéro de cage';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Male Selection
              DropdownButtonFormField<Bird>(
                decoration: const InputDecoration(
                  labelText: 'Mâle',
                  border: OutlineInputBorder(),
                ),
                hint: const Text("Sélectionner un mâle"),
                value: _selectedMale,
                isExpanded: true,
                items:
                    _males.map((bird) {
                      return DropdownMenuItem(
                        value: bird,
                        child: Text("${bird.identifier} - ${bird.species}"),
                      );
                    }).toList(),
                onChanged: (bird) {
                  setState(() {
                    _selectedMale = bird;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un mâle';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Female Selection
              DropdownButtonFormField<Bird>(
                decoration: const InputDecoration(
                  labelText: 'Femelle',
                  border: OutlineInputBorder(),
                ),
                hint: const Text("Sélectionner une femelle"),
                value: _selectedFemale,
                isExpanded: true,
                items:
                    _females.map((bird) {
                      return DropdownMenuItem(
                        value: bird,
                        child: Text("${bird.identifier} - ${bird.species}"),
                      );
                    }).toList(),
                onChanged: (bird) {
                  setState(() {
                    _selectedFemale = bird;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner une femelle';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) {
                  setState(() {
                    _notes = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              if (_selectedMale!.species != _selectedFemale!.species) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Les oiseaux doivent être de la même espèce'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final cage = Cage(
                male: _selectedMale!,
                female: _selectedFemale!,
                species: _selectedMale!.species,
                cageNumber: _cageNumber,
                status: _status,
                notes: _notes,
              );

              Navigator.pop(context, cage);
            }
          },
          child: const Text('Créer'),
        ),
      ],
    );
  }
}
