// lib/routes/app_routes.dart
import 'package:flutter/material.dart';
import 'package:app_volailles/pages/auth/login_page.dart';
import 'package:app_volailles/pages/auth/register_page.dart';
import 'package:app_volailles/pages/home_page.dart';
import 'package:app_volailles/services/auth_service.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
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
    };
  }

  // Vérifier si l'utilisateur est connecté et rediriger en conséquence
  static Future<String> getInitialRoute() async {
    final AuthService authService = AuthService();
    final bool isLoggedIn = await authService.isLoggedIn();
    return isLoggedIn ? home : login;
  }
}
