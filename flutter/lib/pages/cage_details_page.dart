import 'package:app_volailles/utils/date_utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:app_volailles/models/cage.dart';
import 'package:app_volailles/models/bird.dart';
import 'package:app_volailles/services/cage_service.dart';
import 'package:app_volailles/services/bird_service.dart';

class CageDetailsPage extends StatefulWidget {
  final Cage cage;
  final List<Cage> availableCages;
  final Function() onCageUpdated;

  const CageDetailsPage({
    super.key,
    required this.cage,
    required this.availableCages,
    required this.onCageUpdated,
  });

  @override
  State<CageDetailsPage> createState() => _CageDetailsPageState();
}

class _CageDetailsPageState extends State<CageDetailsPage> {
  final BirdService _birdService = BirdService();
  final CageService _cageService = CageService();
  List<Bird>? _availableBirds;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableBirds();
  }
_navigateBack(){
    Navigator.of(context).pop();
}

  Future<void> _loadAvailableBirds() async {
    setState(() => _isLoading = true);
    try {
      final birds = await _birdService.getAvailableBirds();
      _availableBirds = birds.where((bird) => bird.cage == null).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des oiseaux: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddBirdDialog(String gender) async {
    if (_availableBirds == null || _availableBirds!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Aucun oiseau disponible')));
      return;
    }

    final availableBirdsOfGender =
        _availableBirds!
            .where((bird) => bird.gender.toLowerCase() == gender.toLowerCase())
            .toList();

    if (availableBirdsOfGender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aucun oiseau ${gender.toLowerCase()} disponible'),
        ),
      );
      return;
    }

    final Bird? selectedBird = await showDialog<Bird>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Sélectionner un oiseau ${gender.toLowerCase()}'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: availableBirdsOfGender.length,
                itemBuilder: (context, index) {
                  final bird = availableBirdsOfGender[index];
                  return ListTile(
                    title: Text(bird.identifier),
                    subtitle: Text('${bird.species} - ${bird.color}'),
                    onTap: () => Navigator.of(context).pop(bird),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
            ],
          ),
    );

    if (selectedBird != null) {
      try {
        await _birdService.updateBirdCage(selectedBird.id!, widget.cage.id,widget.cage.cageNumber);
        if(gender == 'male'){
          await _cageService.updateCageBirds(widget.cage.id!, male: selectedBird , female: widget.cage.female );
        }else{
          await _cageService.updateCageBirds(widget.cage.id!,male: widget.cage.male, female: selectedBird);
        }
        _navigateBack();
    //    widget.onCageUpdated();

        // Refresh the page
       // _loadAvailableBirds();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Oiseau ajouté avec succès')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de l\'ajout de l\'oiseau: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la cage'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add Birds Buttons
            if (widget.cage.male == null || widget.cage.female == null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ajouter des oiseaux',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (widget.cage.male == null)
                            ElevatedButton.icon(
                              onPressed:
                                  _isLoading
                                      ? null
                                      : () => _showAddBirdDialog('male'),
                              icon: const Icon(Icons.add),
                              label: const Text('Ajouter un mâle'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          if (widget.cage.female == null)
                            ElevatedButton.icon(
                              onPressed:
                                  _isLoading
                                      ? null
                                      : () => _showAddBirdDialog('female'),
                              icon: const Icon(Icons.add),
                              label: const Text('Ajouter une femelle'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink,
                                foregroundColor: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            if (widget.cage.male == null || widget.cage.female == null)
              const SizedBox(height: 16),

            // Male Bird Card
            if (widget.cage.male != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mâle',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildBirdInfo(widget.cage.male!),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed:
                                () => _showDeleteBirdDialog(
                                  context,
                                  widget.cage.male!,
                                ),
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text('Supprimer'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.red,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed:
                                () => _showMoveBirdDialog(
                                  context,
                                  widget.cage.male!,
                                ),
                            icon: const Icon(Icons.swap_horiz),
                            label: const Text('Déplacer'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            if (widget.cage.male != null) const SizedBox(height: 16),

            // Female Bird Card
            if (widget.cage.female != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Femelle',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildBirdInfo(widget.cage.female!),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed:
                                () => _showDeleteBirdDialog(
                                  context,
                                  widget.cage.female!,
                                ),
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text('Supprimer'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.red,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed:
                                () => _showMoveBirdDialog(
                                  context,
                                  widget.cage.female!,
                                ),
                            icon: const Icon(Icons.swap_horiz),
                            label: const Text('Déplacer'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            if (widget.cage.female != null) const SizedBox(height: 16),

            // Cage Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations de la cage',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (widget.cage.createdAt != null)
                      _buildInfoRow(
                        'Date de création',
                        formatDate(widget.cage.createdAt!.toIso8601String()),
                      ),
                    _buildInfoRow('Statut', widget.cage.status ?? 'active'),
                    if (widget.cage.notes != null &&
                        widget.cage.notes!.isNotEmpty)
                      _buildInfoRow('Notes', widget.cage.notes!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteBirdDialog(BuildContext context, Bird bird) async {
    final birdService = BirdService();
    final cageService = CageService();

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Supprimer l\'oiseau'),
            content: Text(
              'Voulez-vous vraiment supprimer l\'oiseau ${bird.identifier} du cage ${widget.cage.cageNumber} ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        // Supprimer l'oiseau
        await birdService.updateBirdCage(bird.id!, null,"");

        // Mettre à jour la cage
        if (bird.gender == 'male') {
          await cageService.updateCageBirds(widget.cage.id!, male: null , female: widget.cage.female);
        } else {
          await cageService.updateCageBirds(widget.cage.id!, female: null , male: widget.cage.male);
        }

        // Rafraîchir la page
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Oiseau supprimé du cage avec succès')),
          );
          Navigator.of(context).pop(); // Retour à la page des cages
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
        }
      }
    }
  }

  Future<void> _showMoveBirdDialog(BuildContext context, Bird bird) async {
    final birdService = BirdService();
    final cageService = CageService();

    final selectedCage = await showDialog<Cage>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Déplacer l\'oiseau'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.availableCages.length,
                itemBuilder: (context, index) {
                  final targetCage = widget.availableCages[index];
                  // Ne pas afficher la cage actuelle
                  if (targetCage.id == widget.cage.id)
                    return const SizedBox.shrink();
                  // Ne pas afficher les cages qui ont déjà un oiseau du même genre
                  if (bird.gender == 'male' && targetCage.male != null)
                    return const SizedBox.shrink();
                  if (bird.gender == 'female' && targetCage.female != null)
                    return const SizedBox.shrink();

                  return ListTile(
                    title: Text('Cage ${targetCage.cageNumber}'),
                    subtitle: Text('Espèce: ${targetCage.species}'),
                    onTap: () => Navigator.of(context).pop(targetCage),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
            ],
          ),
    );

    if (selectedCage != null) {
      try {
        // Mettre à jour la cage de l'oiseau
        await birdService.updateBirdCage(bird.id!, selectedCage.id,selectedCage.cageNumber);

        // Mettre à jour l'ancienne cage
        if (bird.gender == 'male') {
          await cageService.updateCageBirds(widget.cage.id!, male: null,female: widget.cage.female);
        } else {
          await cageService.updateCageBirds(widget.cage.id!,male: widget.cage.male, female: null);
        }

        // Mettre à jour la nouvelle cage
        if (bird.gender == 'male') {
          await cageService.updateCageBirds(selectedCage.id!, male: bird,female: selectedCage.female);
        } else {
          await cageService.updateCageBirds(selectedCage.id!, female: bird,male: selectedCage.male);
        }

        // Rafraîchir la page
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Oiseau déplacé avec succès')),
          );
          Navigator.of(context).pop(); // Retour à la page des cages
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
        }
      }
    }
  }

  Widget _buildBirdInfo(Bird bird) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Identifiant', bird.identifier),
        _buildInfoRow('Categorie', bird.category),
        _buildInfoRow('Espèce', bird.species),
        _buildInfoRow('Couleur', bird.color),
        _buildInfoRow('Cage', bird.cageNumber),
        _buildInfoRow('Date de naissance:', formatDateTime(bird.birthDate)),
        if (bird.price > 0) _buildInfoRow('Prix', '${bird.price} DT'),
        _buildStatusRow('État ', bird.isAvailable()),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool available) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text( available ? 'Disponible' : 'Non disponible' , style:  TextStyle(
            fontWeight: FontWeight.bold,
            color: available ? Colors.green : Colors.red,
          ),)),
        ],
      ),
    );
  }
}
