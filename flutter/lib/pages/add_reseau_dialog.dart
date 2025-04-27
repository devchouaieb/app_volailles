import 'package:flutter/material.dart';
import 'package:app_volailles/models/reseau.dart';

class AddReseauDialog extends StatefulWidget {
  final Reseau? reseau;
  final Function(Reseau) onSave;

  const AddReseauDialog({super.key, this.reseau, required this.onSave});

  @override
  State<AddReseauDialog> createState() => _AddReseauDialogState();
}

class _AddReseauDialogState extends State<AddReseauDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _matriculeController;
  late TextEditingController _addressController;
  late TextEditingController _siteWebController;
  late TextEditingController _presidentController;
  late TextEditingController _comiteController;
  late TextEditingController _telephoneController;
  late TextEditingController _mailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.reseau?.name ?? '');
    _matriculeController = TextEditingController(
      text: widget.reseau?.matricule ?? '',
    );
    _addressController = TextEditingController(
      text: widget.reseau?.address ?? '',
    );
    _siteWebController = TextEditingController(
      text: widget.reseau?.siteWeb ?? '',
    );
    _presidentController = TextEditingController(
      text: widget.reseau?.president ?? '',
    );
    _comiteController = TextEditingController(
      text: widget.reseau?.comite ?? '',
    );
    _telephoneController = TextEditingController(
      text: widget.reseau?.telephone ?? '',
    );
    _mailController = TextEditingController(text: widget.reseau?.mail ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _matriculeController.dispose();
    _addressController.dispose();
    _siteWebController.dispose();
    _presidentController.dispose();
    _comiteController.dispose();
    _telephoneController.dispose();
    _mailController.dispose();
    super.dispose();
  }

  void _saveReseau() {
    if (_formKey.currentState!.validate()) {
      final reseau = Reseau(
        id: widget.reseau?.id,
        name: _nameController.text,
        matricule: _matriculeController.text,
        address: _addressController.text,
        siteWeb: _siteWebController.text,
        president: _presidentController.text,
        comite: _comiteController.text,
        telephone: _telephoneController.text,
        mail: _mailController.text,
      );
      widget.onSave(reseau);
      Navigator.pop(context);
    }
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    int? maxLines,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.reseau == null
                    ? 'Ajouter un réseau'
                    : 'Modifier le réseau',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildTextField(
                label: 'Nom du réseau',
                icon: Icons.business,
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom du réseau';
                  }
                  return null;
                },
              ),
              _buildTextField(
                label: 'Matricule',
                icon: Icons.badge,
                controller: _matriculeController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le matricule';
                  }
                  return null;
                },
              ),
              _buildTextField(
                label: 'Adresse',
                icon: Icons.location_on,
                controller: _addressController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer l\'adresse';
                  }
                  return null;
                },
                maxLines: 2,
              ),
              _buildTextField(
                label: 'Site Web',
                icon: Icons.web,
                controller: _siteWebController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le site web';
                  }
                  return null;
                },
                keyboardType: TextInputType.url,
              ),
              _buildTextField(
                label: 'Président',
                icon: Icons.person,
                controller: _presidentController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom du président';
                  }
                  return null;
                },
              ),
              _buildTextField(
                label: 'Comité',
                icon: Icons.group,
                controller: _comiteController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le comité';
                  }
                  return null;
                },
              ),
              _buildTextField(
                label: 'Téléphone',
                icon: Icons.phone,
                controller: _telephoneController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le numéro de téléphone';
                  }
                  return null;
                },
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                label: 'Email',
                icon: Icons.email,
                controller: _mailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer l\'email';
                  }
                  if (!value.contains('@')) {
                    return 'Veuillez entrer un email valide';
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _saveReseau,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      widget.reseau == null ? 'Ajouter' : 'Modifier',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
