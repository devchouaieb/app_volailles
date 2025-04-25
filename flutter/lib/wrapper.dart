// lib/wrapper.dart
import 'package:flutter/material.dart';
import 'package:app_volailles/pages/auth/login_page.dart';
import 'package:app_volailles/pages/home_page.dart';
import 'package:app_volailles/services/auth_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService().isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          return const HomePage();
        }

        return const LoginPage();
      },
    );
  }
}
