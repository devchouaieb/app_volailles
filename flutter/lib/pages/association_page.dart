import 'package:flutter/material.dart';
import 'package:app_volailles/data/associations.dart';
import 'package:app_volailles/services/association_service.dart';

class AssociationPage extends StatefulWidget {
  const AssociationPage({super.key});

  @override
  State<AssociationPage> createState() => _AssociationPageState();
}

class _AssociationPageState extends State<AssociationPage> {
  final AssociationService _associationService = AssociationService();
  Association? _selectedAssociation;
  bool _isLoading = true;
  final _yearController = TextEditingController();
  bool _showYearInput = false;

  @override
  void initState() {
    super.initState();
    _loadSelectedAssociation();
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _loadSelectedAssociation() async {
    setState(() => _isLoading = true);
    try {
      final association = await _associationService.getSelectedAssociation();
      if (association != null) {
        setState(() {
          _selectedAssociation = association;
          _showYearInput = association.registrationYear.isEmpty;
          if (association.registrationYear.isNotEmpty) {
            _yearController.text = association.registrationYear;
          }
        });
      }
    } catch (e) {
      print('Erreur lors du chargement de l\'association: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveRegistrationYear() async {
    if (_yearController.text.isEmpty) return;

    try {
      final year = _yearController.text;
      final currentYear = DateTime.now().year.toString();
      if (int.parse(year) < 1900 || int.parse(year) > int.parse(currentYear)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez entrer une année valide'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final success = await _associationService.updateRegistrationYear(year);
      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Année d\'enregistrement mise à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        _loadSelectedAssociation();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la mise à jour de l\'année'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_selectedAssociation == null) {
      return const Center(child: Text('Aucune association sélectionnée'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedAssociation!.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('Téléphone: ${_selectedAssociation!.phone}'),
                  Text('Email: ${_selectedAssociation!.email}'),
                  Text('Adresse: ${_selectedAssociation!.address}'),
                  Text('Numéro: ${_selectedAssociation!.number}'),
                  if (_selectedAssociation!.registrationYear.isNotEmpty)
                    Text(
                      'Année d\'enregistrement: ${_selectedAssociation!.registrationYear}',
                    ),
                ],
              ),
            ),
          ),
          if (_showYearInput) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _yearController,
              decoration: const InputDecoration(
                labelText: 'Année d\'enregistrement',
                hintText: 'Entrez l\'année d\'enregistrement',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveRegistrationYear,
              child: const Text('Enregistrer l\'année'),
            ),
          ],
        ],
      ),
    );
  }
}
