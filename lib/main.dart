import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';
void main() async {
  // Garantie de l'initialisation des liens entre Flutter et le moteur natif,
  // nécessaire pour les opérations asynchrones dans main.
  WidgetsFlutterBinding.ensureInitialized();

  // Imposition du mode paysage.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Initialisation de Hive pour la gestion de la base de données locale.
  await Hive.initFlutter();

  // Initialisation de Firebase (assurez-vous d'avoir configuré Firebase dans votre projet).
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Lancement de l'application avec le widget racine MyApp.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'immunowarriors',
      theme: ThemeData(
        // Génère une palette de couleurs à partir d'une couleur de base.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // L'écran d'accueil est défini ici.
      home: const LoginScreen(),
    );
  }
}