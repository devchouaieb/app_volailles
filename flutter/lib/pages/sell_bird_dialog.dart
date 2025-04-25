import 'package:flutter/material.dart';
import 'package:app_volailles/models/bird.dart';

class SellBirdDialog extends StatefulWidget {
  final Bird bird;
  final void Function(double price, String buyerNationalId) onSuccess;

  const SellBirdDialog({Key? key, required this.bird, required this.onSuccess})
    : super(key: key);

  @override
  State<SellBirdDialog> createState() => _SellBirdDialogState();
}

class _SellBirdDialogState extends State<SellBirdDialog> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _buyerNationalIdController = TextEditingController();

  @override
  void dispose() {
    _priceController.dispose();
    _buyerNationalIdController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.onSuccess(
        double.parse(_priceController.text),
        _buyerNationalIdController.text,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Vendre l\'oiseau'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Prix de vente'),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _buyerNationalIdController,
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
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(onPressed: _handleSubmit, child: const Text('Vendre')),
      ],
    );
  }
}
