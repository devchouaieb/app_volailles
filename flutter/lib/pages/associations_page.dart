import 'package:flutter/material.dart';
import 'package:app_volailles/models/association.dart';
import 'package:app_volailles/services/association_service.dart';

class AssociationsPage extends StatefulWidget {
  const AssociationsPage({super.key});

  @override
  State<AssociationsPage> createState() => _AssociationsPageState();
}

class _AssociationsPageState extends State<AssociationsPage> {
  final _associationService = AssociationService();
  List<Association> _associations = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAssociations();
  }

  Future<void> _loadAssociations() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final associations = await _associationService.getAssociations();
      if (!mounted) return;

      setState(() {
        _associations = associations;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddAssociationDialog() async {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String phone = '';
    String email = '';
    String address = '';
    String number = '';
    String registrationYear = '';

    final result = await showDialog<Association>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Nouvelle Association'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Numéro',
                        hintText: 'Entrez le numéro de l\'association',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le numéro est requis';
                        }
                        return null;
                      },
                      onSaved: (value) => number = value ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Année d\'enregistrement',
                        hintText: 'Entrez l\'année d\'enregistrement',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'L\'année d\'enregistrement est requise';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Veuillez entrer une année valide';
                        }
                        return null;
                      },
                      onSaved: (value) => registrationYear = value ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Nom',
                        hintText: 'Entrez le nom de l\'association',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le nom est requis';
                        }
                        return null;
                      },
                      onSaved: (value) => name = value ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Téléphone',
                        hintText: 'Entrez le numéro de téléphone',
                      ),
                      keyboardType: TextInputType.numberWithOptions(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le numéro de téléphone est requis';
                        }
                        return null;
                      },
                      onSaved: (value) => phone = value ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Entrez l\'email',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'L\'email est requis';
                        }
                        if (!value.contains('@')) {
                          return 'Email invalide';
                        }
                        return null;
                      },
                      onSaved: (value) => email = value ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Adresse',
                        hintText: 'Entrez l\'adresse',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'L\'adresse est requise';
                        }
                        return null;
                      },
                      onSaved: (value) => address = value ?? '',
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
                  if (formKey.currentState?.validate() ?? false) {
                    formKey.currentState?.save();
                    Navigator.pop(
                      context,
                      Association(
                        name: name,
                        phone: phone,
                        email: email,
                        address: address,
                        number: number,
                        registrationYear: registrationYear,
                      ),
                    );
                  }
                },
                child: const Text('Ajouter'),
              ),
            ],
          ),
    );

    if (result != null) {
      try {
        setState(() => _isLoading = true);
        await _associationService.createAssociation(result);
        if (!mounted) return;
        await _loadAssociations();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Association ajoutée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
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
  }

  Future<void> _showEditAssociationDialog(Association association) async {
    final formKey = GlobalKey<FormState>();
    String name = association.name;
    String phone = association.phone;
    String email = association.email;
    String address = association.address;
    String number = association.number;
    String registrationYear = association.registrationYear;

    final result = await showDialog<Association>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Modifier l\'Association'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: number,
                      decoration: const InputDecoration(
                        labelText: 'Numéro',
                        hintText: 'Entrez le numéro de l\'association',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le numéro est requis';
                        }
                        return null;
                      },
                      onSaved: (value) => number = value ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: registrationYear,
                      decoration: const InputDecoration(
                        labelText: 'Année d\'enregistrement',
                        hintText: 'Entrez l\'année d\'enregistrement',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'L\'année d\'enregistrement est requise';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Veuillez entrer une année valide';
                        }
                        return null;
                      },
                      onSaved: (value) => registrationYear = value ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: name,
                      decoration: const InputDecoration(
                        labelText: 'Nom',
                        hintText: 'Entrez le nom de l\'association',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le nom est requis';
                        }
                        return null;
                      },
                      onSaved: (value) => name = value ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: phone,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone',
                        hintText: 'Entrez le numéro de téléphone',
                      ),
                      keyboardType: TextInputType.numberWithOptions(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le numéro de téléphone est requis';
                        }
                        return null;
                      },
                      onSaved: (value) => phone = value ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: email,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Entrez l\'email',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'L\'email est requis';
                        }
                        if (!value.contains('@')) {
                          return 'Email invalide';
                        }
                        return null;
                      },
                      onSaved: (value) => email = value ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: address,
                      decoration: const InputDecoration(
                        labelText: 'Adresse',
                        hintText: 'Entrez l\'adresse',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'L\'adresse est requise';
                        }
                        return null;
                      },
                      onSaved: (value) => address = value ?? '',
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
                  if (formKey.currentState?.validate() ?? false) {
                    formKey.currentState?.save();
                    Navigator.pop(
                      context,
                      Association(
                        id: association.id,
                        name: name,
                        phone: phone,
                        email: email,
                        address: address,
                        number: number,
                        registrationYear: registrationYear,
                      ),
                    );
                  }
                },
                child: const Text('Modifier'),
              ),
            ],
          ),
    );

    if (result != null) {
      try {
        setState(() => _isLoading = true);
        await _associationService.updateAssociation(association.id!, result);
        if (!mounted) return;
        await _loadAssociations();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Association modifiée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Associations'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadAssociations,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Erreur: $_errorMessage',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loadAssociations,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              )
              : _associations.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.group, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      "Aucune association enregistrée",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _showAddAssociationDialog,
                      child: const Text('Ajouter une association'),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadAssociations,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _associations.length,
                  itemBuilder: (context, index) {
                    final association = _associations[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple.shade100,
                          child: const Icon(
                            Icons.group,
                            color: Colors.deepPurple,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                association.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Rejoindre en ${association.registrationYear}',
                                style: TextStyle(
                                  color: Colors.deepPurple.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Numéro: ${association.number}'),
                            Text('Tél: ${association.phone}'),
                            Text('Email: ${association.email}'),
                            Text('Adresse: ${association.address}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed:
                                  () => _showEditAssociationDialog(association),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: const Text(
                                          'Supprimer l\'association',
                                        ),
                                        content: Text(
                                          'Êtes-vous sûr de vouloir supprimer l\'association ${association.name} ?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                            child: const Text('Annuler'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.red.shade100,
                                            ),
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                            child: const Text('Confirmer'),
                                          ),
                                        ],
                                      ),
                                );

                                if (confirmed == true) {
                                  try {
                                    setState(() => _isLoading = true);
                                    await _associationService.deleteAssociation(
                                      association.id!,
                                    );
                                    if (!mounted) return;
                                    await _loadAssociations();
                                    if (mounted) return;
                                    setState(() => _isLoading = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Association supprimée avec succès',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } catch (e) {
                                    if (!mounted) return;
                                    setState(() => _isLoading = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Erreur: ${e.toString()}',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAssociationDialog,
        child: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
