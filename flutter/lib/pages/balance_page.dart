import 'package:flutter/material.dart';
import 'package:app_volailles/services/bird_service.dart';
import 'package:app_volailles/services/product_service.dart';
import 'package:app_volailles/utils/dialog_error_helpers.dart';

class BalancePage extends StatefulWidget {
  const BalancePage({super.key});

  @override
  State<BalancePage> createState() => _BalancePageState();
}

class _BalancePageState extends State<BalancePage> {
  final BirdService _birdService = BirdService();
  final ProductService _productService = ProductService();

  double _totalSold = 0.0;
  double _totalProductValue = 0.0;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadBalanceData();
  }

  Future<void> _loadBalanceData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final totalSold = await _birdService.getTotalSold();
      final totalProductValue = await _productService.getTotalProductValue();

      setState(() {
        _totalSold = totalSold;
        _totalProductValue = totalProductValue;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Impossible de charger les données financières';
      });

      DialogErrorHelpers.showErrorDialog(
        context, 
        title: 'Erreur de chargement', 
        message: e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord Financier'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildFinancialCard(
                        title: 'Revenus',
                        amount: _totalSold,
                        color: Colors.green,
                        icon: Icons.trending_up,
                      ),
                      const SizedBox(height: 16),
                      _buildFinancialCard(
                        title: 'Dépenses',
                        amount: _totalProductValue,
                        color: Colors.red,
                        icon: Icons.trending_down,
                      ),
                      const SizedBox(height: 16),
                      _buildFinancialCard(
                        title: 'Solde',
                        amount: _totalSold - _totalProductValue,
                        color: _totalSold >= _totalProductValue 
                            ? Colors.blue 
                            : Colors.orange,
                        icon: Icons.account_balance_wallet,
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadBalanceData,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildFinancialCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${amount.toStringAsFixed(2)} DT',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            Icon(icon, size: 50, color: color),
          ],
        ),
      ),
    );
  }
}
