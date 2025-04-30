import 'package:flutter/material.dart'; // Importation du package Flutter pour créer l'interface utilisateur
import 'package:hive_flutter/hive_flutter.dart'; // Importation de Hive pour le stockage local et sa version Flutter
import 'package:firebase_core/firebase_core.dart'; // Importation de Firebase pour initialiser les services Firebase
import 'package:flutter/services.dart'; // Importation des services Flutter pour configurer l’orientation

void main() async {
  // Garantie de l'initialisation des liens entre Flutter et le moteur natif, nécessaire pour les opérations asynchrones dans main.
  WidgetsFlutterBinding.ensureInitialized();

  // Imposition du mode paysage.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Initialisation de Hive pour la gestion de la base de données locale.
  await Hive.initFlutter();

  // Lancement de l'application avec le widget racine MyApp.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'immunowarriors', // Titre de l'application utilisé dans certaines interfaces système.
      theme: ThemeData(
        // Génère une palette de couleurs à partir d'une couleur de base.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // La page d'accueil de l'application est définie ici.
      home: const BlankScreen(),
    );
  }
}

class BlankScreen extends StatelessWidget {
  const BlankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Suppression de la barre d'applications (AppBar) pour obtenir une page en plein écran.
      body: Container(
        // Définition de l'image de fond
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/fond.png"), // Veillez à déclarer cette image dans le fichier pubspec.yaml
            fit: BoxFit.fill, // L'image couvre l'intégralité de l'écran
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }
}