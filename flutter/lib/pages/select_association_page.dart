import 'package:flutter/material.dart';
import 'package:app_volailles/data/associations.dart';
import 'package:app_volailles/services/association_service.dart';

class SelectAssociationPage extends StatefulWidget {
  const SelectAssociationPage({super.key});

  @override
  State<SelectAssociationPage> createState() => _SelectAssociationPageState();
}

class _SelectAssociationPageState extends State<SelectAssociationPage> {
  final AssociationService _associationService = AssociationService();
  final _yearController = TextEditingController();
  Association? _selectedAssociation;
  bool _isLoading = false;
  String? _errorMessage;

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
        if (association.registrationYear.isNotEmpty) {
          // Si l'année est déjà définie, on peut quitter
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        } else {
          setState(() {
            _selectedAssociation = association;
          });
        }
      } else {
        setState(() => _errorMessage = 'Aucune association sélectionnée');
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveRegistrationYear() async {
    if (_yearController.text.isEmpty) {
      setState(() => _errorMessage = 'Veuillez entrer votre année d\'adhésion');
      return;
    }

    try {
      final year = _yearController.text;
      final currentYear = DateTime.now().year.toString();
      if (int.parse(year) < 1900 || int.parse(year) > int.parse(currentYear)) {
        setState(() => _errorMessage = 'Veuillez entrer une année valide');
        return;
      }

      setState(() => _isLoading = true);

      // Mettre à jour l'année d'enregistrement
      final success = await _associationService.updateRegistrationYear(year);
      if (!success) {
        setState(() {
          _errorMessage = 'Erreur lors de l\'enregistrement de l\'année';
          _isLoading = false;
        });
        return;
      }

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Veuillez entrer une année valide';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_selectedAssociation == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Année d\'adhésion'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'Une erreur est survenue',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Année d\'adhésion'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Bienvenue !',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pour finaliser votre inscription, veuillez indiquer votre année d\'adhésion à l\'association.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Votre association :',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedAssociation!.name,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedAssociation!.address,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade900),
                ),
              ),
            const Text(
              'Année d\'adhésion :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _yearController,
              decoration: const InputDecoration(
                labelText: 'Année',
                hintText: 'Ex: 2024',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveRegistrationYear,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Confirmer', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
