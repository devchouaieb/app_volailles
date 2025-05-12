// lib/routes/app_routes.dart
import 'package:flutter/material.dart';
import 'package:app_volailles/pages/auth/login_page.dart';
import 'package:app_volailles/pages/auth/register_page.dart';
import 'package:app_volailles/pages/auth/forgot_password_page.dart';
import 'package:app_volailles/pages/auth/reset_password_page.dart';
import 'package:app_volailles/pages/home_page.dart';
import 'package:app_volailles/pages/birds_page.dart';
import 'package:app_volailles/pages/cages_page.dart';
import 'package:app_volailles/pages/nest_page.dart';
import 'package:app_volailles/pages/vendues_page.dart';
import 'package:app_volailles/pages/purchases_page.dart';
import 'package:app_volailles/pages/birds_for_sale_page.dart';
import 'package:app_volailles/pages/statistics_page.dart';
import 'package:app_volailles/pages/associations_page.dart';
import 'package:app_volailles/pages/reseau_page.dart';
import 'package:app_volailles/pages/sensor_dashboard_page.dart';
import 'package:app_volailles/pages/species_page.dart';
import 'package:app_volailles/pages/select_association_page.dart';
import 'package:app_volailles/services/auth_service.dart';
import 'package:app_volailles/models/bird.dart';
import 'package:provider/provider.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String resetPassword = '/reset-password';
  static const String species = '/species';
  static const String statistics = '/statistics';
  static const String cages = '/cages';
  static const String nest = '/nest';
  static const String vendues = '/vendues';
  static const String purchases = '/purchases';
  static const String sensorDashboard = '/sensor-dashboard';
  static const String birds = '/birds';
  static const String birdsForSale = '/birds-for-sale';
  static const String associations = '/associations';
  static const String reseau = '/reseau';
  static const String selectAssociation = '/select-association';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginPage(),
      register: (context) => const RegisterPage(),
      home: (context) => const HomePage(),
      resetPassword: (context) {
        final args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        final token = args?['resettoken'] as String?;
        if (token == null) {
          return const Scaffold(body: Center(child: Text('Token manquant')));
        }
        return ResetPasswordPage(token: token);
      },
      species: (context) => SpeciesPage(),
      statistics:
          (context) => StatisticsPage(birds: Provider.of<List<Bird>>(context)),
      cages: (context) => const CagesPage(),
      nest: (context) => const NestPage(),
      vendues: (context) => VenduesPage(),
      purchases: (context) => PurchasesPage(),
      sensorDashboard: (context) => const SensorDashboardPage(),
      birds: (context) => const BirdsPage(),
      birdsForSale: (context) =>  BirdsForSalePage(null),
      associations: (context) => const AssociationsPage(),
      reseau: (context) => const ReseauPage(),
      selectAssociation: (context) => const SelectAssociationPage(),
    };
  }

  // Vérifier si l'utilisateur est connecté et rediriger en conséquence
  static Future<String> getInitialRoute() async {
    final AuthService authService = AuthService();
    final bool isLoggedIn = await authService.isLoggedIn();
    return isLoggedIn ? home : login;
  }
}
