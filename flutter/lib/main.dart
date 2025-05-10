// lib/main.dart
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:app_volailles/routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('App started');
    return MaterialApp(
      title: 'Volailles App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          color: Colors.deepPurple,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.deepPurple,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const InitialRoute(),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        final routes = AppRoutes.getRoutes();
        final builder = routes[settings.name];
        if (builder != null) {
          return MaterialPageRoute(builder: builder, settings: settings);
        }
        return null;
      },
    );
  }
}

class InitialRoute extends StatefulWidget {
  const InitialRoute({super.key});

  @override
  State<InitialRoute> createState() => _InitialRouteState();
}

class _InitialRouteState extends State<InitialRoute> {
  late Future<String> _initialRouteFuture;

  @override
  void initState() {
    super.initState();
    _initialRouteFuture = _getInitialRoute();
    _initUniLinks();
  }

  void _initUniLinks() {
    AppLinks().uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });
  }

  void _handleDeepLink(Uri uri) {
    print("Uri : $uri");
    if (uri.host == 'reset-password') {
      final token = uri.queryParameters['resettoken'];
      if (token != null) {
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.resetPassword, arguments: {'resettoken': token});
      }
    }
  }

  Future<String> _getInitialRoute() async {
    try {
      return await AppRoutes.getInitialRoute().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          print('Timeout getting initial route, defaulting to login');
          return AppRoutes.login;
        },
      );
    } catch (e) {
      print('Error getting initial route: $e');
      return AppRoutes.login;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _initialRouteFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement...'),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Une erreur est survenue'),
                  Text('${snapshot.error}'),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _initialRouteFuture = _getInitialRoute();
                      });
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        final route = snapshot.data ?? AppRoutes.login;
        return Navigator(
          onGenerateRoute: (settings) {
            final routes = AppRoutes.getRoutes();
            final builder = routes[route];
            if (builder != null) {
              return MaterialPageRoute(builder: builder, settings: settings);
            }
            return MaterialPageRoute(
              builder:
                  (context) => const Scaffold(
                    body: Center(child: Text('Route non trouvée')),
                  ),
            );
          },
        );
      },
    );
  }
}
