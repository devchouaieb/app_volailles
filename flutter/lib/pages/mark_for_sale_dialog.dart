import 'package:flutter/material.dart';
import 'package:app_volailles/models/bird.dart';

class MarkForSaleDialog extends StatefulWidget {
  final Bird bird;
  final BuildContext dialogContext;
  final void Function(double askingPrice) onSuccess;

  const MarkForSaleDialog({
    Key? key,
    required this.bird,
    required this.dialogContext,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<MarkForSaleDialog> createState() => _MarkForSaleDialogState();
}

class _MarkForSaleDialogState extends State<MarkForSaleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _askingPriceController = TextEditingController();

  @override
  void dispose() {
    _askingPriceController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.onSuccess(double.parse(_askingPriceController.text));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Mettre en vente'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Oiseau: ${widget.bird.identifier}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _askingPriceController,
                decoration: const InputDecoration(labelText: 'Prix demandé'),
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
              const Text(
                'Une fois mis en vente, l\'oiseau sera disponible pour achat par d\'autres utilisateurs.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(widget.dialogContext).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          child: const Text('Mettre en vente'),
        ),
      ],
    );
  }
}
