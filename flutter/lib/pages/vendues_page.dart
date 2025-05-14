import 'package:flutter/material.dart';
import 'package:app_volailles/models/bird.dart';
import 'package:app_volailles/utils/date_utils.dart';
import 'package:app_volailles/services/bird_service.dart';

class VenduesPage extends StatefulWidget {
  const VenduesPage({Key? key}) : super(key: key);

  @override
  State<VenduesPage> createState() => _VenduesPageState();
}

class _VenduesPageState extends State<VenduesPage> {
  final BirdService _birdService = BirdService();
  List<Bird> _soldBirds = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSoldBirds();
  }

  Future<void> _loadSoldBirds() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final soldBirds = await _birdService.getSoldBirds();

      if (!mounted) return;

      setState(() {
        _soldBirds = soldBirds;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oiseaux vendus'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSoldBirds,
            tooltip: 'Rafraîchir',
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
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadSoldBirds,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              )
              : _soldBirds.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sell, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "Aucun oiseau vendu",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: _soldBirds.length,
                itemBuilder: (context, index) {
                  final bird = _soldBirds[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple.shade100,
                        child: Icon(Icons.pets, color: ( bird.gender == "male") ? Colors.blue : Colors.red),
                      ),
                      title: Text(
                        bird.identifier,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Espèce: ${bird.species}'),
                          Text('Variété: ${bird.color}'),
                          Row(
                            children: [
                              Text('Prix de vente: '),
                              Text(
                                "${bird.soldPrice ?? bird.price} DT",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                          if (bird.soldDate != null)
                            Text(
                              'Date de vente: ${formatDate(bird.soldDate!)}',
                            ),
                          if (bird.buyerInfo != null)
                            Text(
                              'CIN acheteur: ${bird.buyerInfo!['nationalId']}',
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
