import 'package:app_volailles/utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:app_volailles/models/bird.dart';
import 'package:app_volailles/services/bird_service.dart';

class BirdDetailsPage extends StatefulWidget {
  final Bird bird;
  final String? userId ;

  const BirdDetailsPage({Key? key, required this.bird , required this.userId}) : super(key: key);

  @override
  State<BirdDetailsPage> createState() => _BirdDetailsPageState();
}

class _BirdDetailsPageState extends State<BirdDetailsPage> {
  final BirdService _birdService = BirdService();
  Bird? motherBird;
  Bird? fatherBird;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadParentBirds();
  }

  Future<void> _loadParentBirds() async {
    try {
      if (widget.bird.motherId != null) {
        motherBird = await _birdService.getBird(widget.bird.motherId!);
      }
      if (widget.bird.fatherId != null) {
        fatherBird = await _birdService.getBird(widget.bird.fatherId!);
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildInfoColumn(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
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

  Widget _buildBirdDetails(Bird bird) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Identifiant:', bird.identifier),
        _buildInfoRow('Genre:', bird.gender),
        _buildInfoRow('Categorie:', bird.category),
        _buildInfoRow('Espèce:', bird.species),
        _buildInfoRow('Couleur:', bird.color),
       _buildInfoRow('Statut:', bird.getStatus(widget.userId)),
        _buildInfoRow('Cage:', bird.cageNumber),
        _buildInfoColumn("Date de naissance", formatDate(bird.birthDate)),
     /*   _buildInfoRow('Prix:', '${bird.price} €'),
        if (bird.sold) ...[
          _buildInfoRow('Date de vente:', bird.soldDate ?? 'N/A'),
          _buildInfoRow('Prix de vente:', '${bird.soldPrice ?? 0} €'),
          if (bird.buyerInfo != null)
            _buildInfoRow('Acheteur:', bird.buyerInfo!['fullName'] ?? 'N/A'),
        ],*/
      /*  if (bird.forSale)
          _buildInfoRow('Prix demandé:', '${bird.askingPrice ?? 0} €'),*/
      ],
    );
  }

  Widget _buildParentCard(String title, Bird? parentBird) {
    return GestureDetector(
      onTap: () {
        if (parentBird != null) {
          _navigateToBirdDetailsPage(parentBird);
        }
      },
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (parentBird != null)
                _buildBirdDetails(parentBird)
              else
                const Text('Non spécifié'),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToBirdDetailsPage(Bird bird) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BirdDetailsPage(bird: bird , userId: widget.userId,)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de l\'oiseau ${widget.bird.identifier}'),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informations de l\'oiseau',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildBirdDetails(widget.bird),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Parents',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildParentCard('Mère', motherBird)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildParentCard('Père', fatherBird)),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }
}
