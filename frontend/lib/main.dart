import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart'; 

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion Achats',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark, // Design sombre pour le login
        primarySwatch: Colors.brown,
      ),
      // Le Consumer écoute le AuthProvider. 
      // Dès que notifyListeners() est appelé dans login(), ce bloc se relance.
      home: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          if (auth.isAuthenticated) {
            return const HomeScreen(); // Bascule automatique vers le Dashboard
          } else {
            return const LoginScreen(); // Reste sur le Login
          }
        },
      ),
    );
  }
}
