// lib/routes/app_routes.dart
import 'package:flutter/material.dart';
import 'package:app_volailles/pages/auth/login_page.dart';
import 'package:app_volailles/pages/auth/register_page.dart';
import 'package:app_volailles/pages/auth/forgot_password_page.dart';
import 'package:app_volailles/pages/auth/reset_password_page.dart';
import 'package:app_volailles/pages/home_page.dart';
import 'package:app_volailles/pages/species_page.dart';
import 'package:app_volailles/pages/statistics_page.dart';
import 'package:app_volailles/pages/pairs_page.dart';
import 'package:app_volailles/pages/nid_page.dart';
import 'package:app_volailles/pages/vendues_page.dart';
import 'package:app_volailles/pages/purchases_page.dart';
import 'package:app_volailles/services/auth_service.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String resetPassword = '/reset-password';
  static const String species = '/species';
  static const String statistics = '/statistics';
  static const String pairs = '/pairs';
  static const String nid = '/nid';
  static const String vendues = '/vendues';
  static const String purchases = '/purchases';

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
      species: (context) =>  SpeciesPage(),
      statistics: (context) =>  StatisticsPage(),
      pairs: (context) => const PairsPage(),
      nid: (context) => const NidPage(),
      vendues: (context) =>  VenduesPage(),
      purchases: (context) =>  PurchasesPage(),
    };
  }

  // Vérifier si l'utilisateur est connecté et rediriger en conséquence
  static Future<String> getInitialRoute() async {
    final AuthService authService = AuthService();
    final bool isLoggedIn = await authService.isLoggedIn();
    return isLoggedIn ? home : login;
  }
}
