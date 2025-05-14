import 'package:flutter/material.dart';
import 'package:app_volailles/utils/constants.dart';
import 'package:app_volailles/models/bird.dart';

class AppDrawer extends StatelessWidget {
  final Map<String, dynamic>? currentUser;
  final List<Bird> soldBirds;
  final Function(String) onDrawerItemClicked;

  const AppDrawer({
    super.key,
    required this.currentUser,
    required this.soldBirds,
    required this.onDrawerItemClicked,
  });

  Widget _buildDrawerItem(IconData icon, String title, {String? trailing}) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing:
          trailing != null
              ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trailing,
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              : null,
      onTap: () => onDrawerItemClicked(title),
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.flutter_dash, size: 40, color: Colors.white),
          const Text(
            'Menu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (currentUser != null) ...[
            Text(
              currentUser!['fullName'] ?? 'Utilisateur',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              currentUser!['email'] ?? '',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),
          _buildDrawerItem(Icons.home, "Accueil"),
          _buildDrawerItem(Icons.pets, 'Tous les oiseaux'),
          _buildDrawerItem(Icons.favorite, 'Cages'),
          _buildDrawerItem(Icons.egg, 'Couvés'),
          _buildDrawerItem(
            Icons.sell,
            'Vendues',
            trailing: soldBirds.isNotEmpty ? soldBirds.length.toString() : null,
          ),
       //   _buildDrawerItem(Icons.shopping_cart, 'Achats'),
          _buildDrawerItem(Icons.store, 'Oiseaux à vendre'),
          _buildDrawerItem(Icons.bar_chart, 'Statistiques'),
          _buildDrawerItem(Icons.device_hub, 'Espèces'),
          _buildDrawerItem(Icons.shopping_cart, 'Produits'),
          const Divider(),
          _buildDrawerItem(Icons.thermostat, 'Capteurs'),
          _buildDrawerItem(Icons.group, 'Associations'),
          _buildDrawerItem(Icons.account_tree, 'Réseaux'),
          const Divider(),
          _buildDrawerItem(Icons.ring_volume, 'Ring pending'),
          _buildDrawerItem(Icons.egg, 'Incubation', trailing: 'auto'),
          const Divider(),
          _buildDrawerItem(Icons.money_off, 'Budget'),
          _buildDrawerItem(Icons.account_balance_wallet, 'Balance'),
          _buildDrawerItem(Icons.category, 'Paramètres'),
          const Divider(),
          _buildDrawerItem(Icons.settings, 'À propos'),
          _buildDrawerItem(Icons.logout, 'Déconnexion'),
        ],
      ),
    );
  }
}
