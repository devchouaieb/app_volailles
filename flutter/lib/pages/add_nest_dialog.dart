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
  Cage? _selectedCage;
  int _numberOfEggs = 0;
  int _fertilizedEggs = 0;
  int _extractedEggs = 0;
  DateTime _exclusionDate = DateTime.now();
  String? _notes;
  String? _nestNumber;
  DateTime? _firstEggDate;
  int _maleExits = 0;
  int _femaleExits = 0;
  int _totalExits = 0;


  @override
  void initState() {
    super.initState();
    if (widget.nest != null) {
      _selectedCageNumber = widget.nest!.cageNumber;
      _selectedCage = widget.nest!.cage;
      _numberOfEggs = widget.nest!.numberOfEggs;
      _fertilizedEggs = widget.nest!.fertilizedEggs;
      _extractedEggs = widget.nest!.extractedEggs;
      _exclusionDate = widget.nest!.exclusionDate;
      _notes = widget.nest!.notes;
      _nestNumber = widget.nest!.nestNumber;
      _firstEggDate = widget.nest!.firstEggDate;
      _maleExits = widget.nest!.maleExits;
      _femaleExits = widget.nest!.femaleExits;
      _totalExits = widget.nest!.birdsExited;
    }
  }

  Future<void> _selectDate(BuildContext context, bool isExclusion) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isExclusion ? _exclusionDate : _firstEggDate ??
          DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isExclusion) {
          _exclusionDate = picked;
        } else {
          _firstEggDate = picked;
        }
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
        firstBirdExitDate: widget.nest?.firstBirdExitDate,
        status: widget.nest?.status ?? 'active',
        notes: _notes,
        cage: _selectedCage ?? widget.nest?.cage  ,
        nestNumber: _nestNumber,
        firstEggDate: _firstEggDate,
        maleExits: _maleExits,
        femaleExits: _femaleExits,
        birdsExited: _totalExits,
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

              const SizedBox(height: 16),
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
                      (value) => setState(() {
                        _selectedCageNumber = value ;
                        _selectedCage = widget.cages.firstWhere((cage) => cage.cageNumber == value);
                      }),
                ),
                const SizedBox(height: 16),

              ],
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Numéro de Couvé *',
                ),
                keyboardType: TextInputType.number,
                initialValue: _nestNumber,
                onChanged: (value) {
                  _nestNumber = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Champ requis';
                  return null;
                },
              ),
              const Text('Date du 1er Oeuf '),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    _firstEggDate != null ?  "${_firstEggDate?.day}/${_firstEggDate
                        ?.month}/${_firstEggDate?.year}" : "",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => _selectDate(context , false),
                    child: const Text("Choisir la date"),
                  ),
                ],
              ),
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
                    "${_exclusionDate.day}/${_exclusionDate
                        .month}/${_exclusionDate.year}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => _selectDate(context,true),
                    child: const Text("Choisir la date"),
                  ),
                ],
              ),

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
