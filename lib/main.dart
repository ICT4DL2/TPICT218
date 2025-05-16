// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importe Firebase Auth pour écouter l'état
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart'; // Assurez-vous que ce fichier existe et est correct

// Importe les écrans principaux de l'application
import 'accueil.dart';
import 'laboratoire_screen.dart';
import 'combat_screen.dart';
import 'login_screen.dart'; // Exemple si dans lib/auth/

// --- IMPORT : Importe l'écran de Recherche ---
import 'recherche_screen.dart'; // Assurez-vous que ce fichier existe et que le chemin est correct

import 'models/agent_pathogene.dart'; // Classe de base (peut ne pas avoir de .g.dart si abstraite)
import 'models/bacterie.dart';
import 'models/champignon.dart';
import 'models/virus.dart';
import 'models/anticorps.dart';
import 'models/base_virale.dart';
import 'models/memoire_immunitaire.dart';
import 'models/ressources_defensives.dart';
import 'models/game_state.dart'; // Le GameStateProvider
import 'models/laboratoire_recherche.dart'; // La classe LaboratoireCreation

/// Point d'entrée principal de l'application.
/// Initialise Firebase et Hive avant de lancer l'application Flutter.
Future<void> main() async {
  // S'assure que les bindings Flutter sont initialisés avant d'appeler des méthodes natives.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Firebase Core.
  // Ceci est nécessaire pour utiliser tout service Firebase (Auth, Firestore, etc.).
  // L'erreur [core/duplicate-app] se produit si cette ligne est exécutée plus d'une fois.
  // Le paramètre 'name' a aidé à résoudre l'erreur précédemment.
  await Firebase.initializeApp(
    name: "immunowariors", // Conserver le nom qui a aidé à résoudre l'erreur
    options: DefaultFirebaseOptions.currentPlatform, // Utilise les options générées par FlutterFire CLI
  );
  print("Firebase initialisé."); // Log pour vérifier l'initialisation

  // Initialisation de Hive pour la persistance locale des données.
  // Doit être appelée une seule fois.
  await Hive.initFlutter();
  print("Hive initialisé."); // Log

  // Enregistrez ici tous vos adaptateurs générés par Hive.
  // Ceci permet à Hive de savoir comment sérialiser/désérialiser vos objets personnalisés.
  Hive.registerAdapter(BacterieAdapter());
  Hive.registerAdapter(ChampignonAdapter());
  Hive.registerAdapter(VirusAdapter());
  Hive.registerAdapter(AnticorpsAdapter());
  Hive.registerAdapter(BaseViraleAdapter());
  Hive.registerAdapter(MemoireImmunitaireAdapter());
  Hive.registerAdapter(RessourcesDefensivesAdapter());
  // Enregistrez l'adaptateur pour DefaultAgentPathogene si vous l'utilisez et avez généré son .g.dart
  // Hive.registerAdapter(DefaultAgentPathogeneAdapter());
  print("Adaptateurs Hive enregistrés."); // Log


  // Lance l'application Flutter, encapsulée dans ProviderScope pour Riverpod.
  runApp(
    const ProviderScope( // Nécessaire pour que les providers Riverpod fonctionnent
      child: MyApp(),
    ),
  );
}

/// Widget racine de l'application.
/// Gère les observateurs du cycle de vie de l'application pour la sauvegarde Hive.
/// Utilise un StreamBuilder pour gérer l'affichage en fonction de l'état d'authentification Firebase.
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

/// L'état de MyApp, gérant l'observation du cycle de vie et la navigation basée sur l'auth.
class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // S'inscrit comme observateur du cycle de vie au démarrage du widget.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  // Se désinscrit comme observateur lorsque le widget est supprimé.
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Appelé lorsque l'état du cycle de vie de l'application change (ex: mise en arrière-plan, fermeture).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Sauvegarde l'état du jeu (via GameState) lorsque l'application est mise en pause ou détachée.
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      // Accède au conteneur Riverpod pour lire le GameStateProvider sans contexte de build.
      final container = ProviderScope.containerOf(context);
      final gameState = container.read(gameStateProvider);
      // Appelle la méthode de sauvegarde définie dans le GameState.
      gameState.saveState();
      print("Sauvegarde automatique de l'état Hive déclenchée."); // Log
    }
    super.didChangeAppLifecycleState(state);
  }


  /// Construit l'arbre de widgets principal de l'application.
  /// Utilise StreamBuilder pour écouter l'état d'authentification et afficher l'écran approprié.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ImmunoWarriors', // Titre de l'application
      theme: ThemeData( // Thème visuel
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Utilise StreamBuilder pour écouter les changements d'état d'authentification de Firebase.
      // Ce stream émet un User object (si connecté) ou null (si déconnecté).
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(), // Le stream à écouter
        builder: (ctx, userSnapshot) {
          // --- Écran de chargement (Splash Screen) ---
          // Affiché tant que l'état d'authentification initial n'est pas connu.
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            print("Authentification state: WAITING. Affichage splash screen."); // Log
            return const Scaffold( // Un simple Scaffold pour l'écran de chargement
              backgroundColor: Colors.deepPurple, // Couleur de fond
              body: Center( // Centrer l'indicateur
                child: Column( // Mettre l'indicateur et un texte en colonne
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator( // L'indicateur de chargement
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // Couleur de l'indicateur
                    ),
                    SizedBox(height: 20), // Espacement
                    Text(
                      "Chargement...", // Texte de chargement
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }

          // --- Si l'utilisateur est connecté ---
          // userSnapshot.hasData est true et userSnapshot.data contient l'objet User.
          if (userSnapshot.hasData && userSnapshot.data != null) {
            print("Authentification state: ACTIVE. Utilisateur connecté: ${userSnapshot.data!.uid}. Navigation vers Accueil."); // Log
            // L'utilisateur est connecté, afficher le Navigator principal de l'application.
            // Ce Navigator gère les routes des écrans "authentifiés".
            return Navigator(
              initialRoute: '/accueil', // L'écran de démarrage après connexion
              onGenerateRoute: (settings) { // Définit comment naviguer entre les écrans authentifiés
                Widget page;
                switch (settings.name) {
                  case '/accueil':
                    page = const Accueil();
                    break;
                  case '/laboratoire':
                    page = const LaboratoireScreen();
                    break;
                  case '/combat':
                    page = const CombatScreen();
                    break;
                // --- NOUVEAU : Ajoute la route pour l'écran de Recherche ---
                  case '/recherche':
                    page = const RechercheScreen();
                    break;
                  default:
                  // Route inconnue, afficher une page d'erreur ou rediriger vers l'accueil
                    page = Scaffold(appBar: AppBar(title: const Text("Erreur")), body: const Center(child: Text("Page inconnue!")));
                }
                return MaterialPageRoute(builder: (context) => page, settings: settings);
              },
            );
          }

          // --- Si l'utilisateur n'est PAS connecté ---
          // userSnapshot.hasData est false ou userSnapshot.data est null.
          print("Authentification state: ACTIVE. Aucun utilisateur connecté. Affichage de l'écran d'authentification."); // Log
          // Afficher l'écran de connexion/inscription.
          return const AuthScreen(); // Utilise la classe AuthScreen (définie dans login_screen.dart)
        },
      ),
      // Les routes nommées définies ici ne sont utilisées que par le Navigator principal (celui retourné
      // quand l'utilisateur est connecté). Si vous n'utilisez qu'un seul Navigator racine,
      // ces routes seraient utilisées par Navigator.pushNamed(context, ...).
      // Dans cette structure avec un Navigator imbriqué, elles sont gérées par onGenerateRoute.
      // On peut les laisser ici pour référence ou si elles sont utilisées dans d'autres contextes.
      /*
      routes: {
         '/accueil': (context) => const Accueil(),
         '/laboratoire': (context) => const LaboratoireScreen(),
         '/combat': (context) => const CombatScreen(),
         '/recherche': (context) => const RechercheScreen(), // Route Recherche (si accessible sans auth)
         '/login': (context) => const AuthScreen(), // La route pour l'écran de login si on y navigue manuellement
      },
      */
    );
  }
}
