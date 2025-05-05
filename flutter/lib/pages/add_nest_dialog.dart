import 'package:flutter/material.dart';
import 'package:app_volailles/models/nest.dart';
import 'package:app_volailles/models/cage.dart';

class AddNestDialog extends StatefulWidget {
  final List<Cage> cages;
  final Nest? nest; // Optional nest for edit mode

  const AddNestDialog({super.key, required this.cages, this.nest});

  @override
  State<AddNestDialog> createState() => _AddNestDialogState();
}

class _AddNestDialogState extends State<AddNestDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCageNumber;
  int _numberOfEggs = 0;
  int _fertilizedEggs = 0;
  int _extractedEggs = 0;
  DateTime _exclusionDate = DateTime.now();
  String? _notes;

  @override
  void initState() {
    super.initState();
    if (widget.nest != null) {
      _selectedCageNumber = widget.nest!.cageNumber;
      _numberOfEggs = widget.nest!.numberOfEggs;
      _fertilizedEggs = widget.nest!.fertilizedEggs;
      _extractedEggs = widget.nest!.extractedEggs;
      _exclusionDate = widget.nest!.exclusionDate;
      _notes = widget.nest!.notes;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _exclusionDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _exclusionDate = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (widget.nest == null && _selectedCageNumber == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner une cage'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final nest = Nest(
        id: widget.nest?.id,
        cageNumber: _selectedCageNumber ?? widget.nest!.cageNumber,
        numberOfEggs: _numberOfEggs,
        fertilizedEggs: _fertilizedEggs,
        exclusionDate: _exclusionDate,
        extractedEggs: _extractedEggs,
        notes: _notes,
      );

      Navigator.pop(context, nest);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.nest != null;

    return AlertDialog(
      title: Text(isEditMode ? 'Modifier le Couvé' : 'Ajouter un Couvé'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isEditMode) ...[
                DropdownButtonFormField<String>(
                  value: _selectedCageNumber,
                  decoration: const InputDecoration(labelText: 'Cage *'),
                  items:
                      widget.cages.map((cage) {
                        return DropdownMenuItem(
                          value: cage.cageNumber,
                          child: Text('Cage ${cage.cageNumber}'),
                        );
                      }).toList(),
                  validator: (value) => value == null ? 'Champ requis' : null,
                  onChanged:
                      (value) => setState(() => _selectedCageNumber = value),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nombre d\'œufs *',
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: _numberOfEggs.toString(),
                  onChanged: (value) {
                    final number = int.tryParse(value);
                    _numberOfEggs = number ?? 0;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Champ requis';
                    final number = int.tryParse(value);
                    if (number == null || number < 0) return 'Nombre invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Date d\'exclusion *'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      "${_exclusionDate.day}/${_exclusionDate.month}/${_exclusionDate.year}",
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
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Œufs fécondés *'),
                keyboardType: TextInputType.number,
                initialValue: _fertilizedEggs.toString(),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Champ requis';
                  final number = int.tryParse(value);
                  if (number == null || number < 0) return 'Nombre invalide';
                  if (number > _numberOfEggs)
                    return 'Ne peut pas dépasser le nombre d\'œufs';
                  return null;
                },
                onChanged: (value) {
                  final number = int.tryParse(value);
                  _fertilizedEggs = number ?? 0;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Œufs extraits *'),
                keyboardType: TextInputType.number,
                initialValue: _extractedEggs.toString(),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Champ requis';
                  final number = int.tryParse(value);
                  if (number == null || number < 0) return 'Nombre invalide';
                  if (number > _fertilizedEggs)
                    return 'Ne peut pas dépasser le nombre d\'œufs fécondés';
                  return null;
                },
                onChanged: (value) {
                  final number = int.tryParse(value);
                  _extractedEggs = number ?? 0;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
                initialValue: _notes,
                onChanged: (value) => _notes = value,
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
          onPressed: _submit,
          child: Text(isEditMode ? 'Modifier' : 'Ajouter'),
        ),
      ],
    );
  }
}
