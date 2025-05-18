// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';

import 'accueil.dart';
import 'laboratoire_screen.dart';
import 'combat_screen.dart';
import 'login_screen.dart';
import 'setting_screen.dart';
import 'journal_screen.dart';

import 'recherche_screen.dart';

import 'models/agent_pathogene.dart';
import 'models/bacterie.dart';
import 'models/champignon.dart';
import 'models/virus.dart';
import 'models/anticorps.dart';
import 'models/base_virale.dart';
import 'models/memoire_immunitaire.dart';
import 'models/ressources_defensives.dart';
import 'models/game_state.dart';
import 'models/laboratoire_recherche.dart';
import 'models/combat_result.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    name: "immunowariors",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("Firebase initialisé.");

  await Hive.initFlutter();
  print("Hive initialisé.");

  // Enregistrez les adaptateurs générés par Hive.
  // Assurez-vous que les IDs de type sont uniques pour chaque adaptateur
  Hive.registerAdapter(BacterieAdapter()); // Type ID 2
  Hive.registerAdapter(ChampignonAdapter()); // Type ID 3
  Hive.registerAdapter(VirusAdapter()); // Type ID 5
  Hive.registerAdapter(AnticorpsAdapter()); // Type ID 1
  Hive.registerAdapter(BaseViraleAdapter()); // Type ID 4
  Hive.registerAdapter(MemoireImmunitaireAdapter()); // Type ID 7
  Hive.registerAdapter(RessourcesDefensivesAdapter()); // Type ID 8
  Hive.registerAdapter(CombatResultAdapter()); // Type ID 20 (Vérifiez qu'il est unique)
  Hive.registerAdapter(GameStateAdapter()); // Type ID 6 (Vérifiez qu'il est unique)


  print("Adaptateurs Hive enregistrés.");


  await Hive.openBox('gameStateBox');

  print("Boîte Hive 'gameStateBox' ouverte.");

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print("MyApp initState: Observation du cycle de vie ajoutée.");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    print("MyApp dispose: Observation du cycle de vie retirée.");
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      try {
        final container = ProviderScope.containerOf(context);
        final gameState = container.read(gameStateProvider);
        gameState.saveState();
        print("Sauvegarde automatique de l'état Hive déclenchée.");
      } catch (e) {
        print("Erreur lors de la récupération de GameState pour la sauvegarde: $e");
      }
    }
    super.didChangeAppLifecycleState(state);
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ImmunoWarriors',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            print("Authentification state: WAITING. Affichage splash screen.");
            return const Scaffold(
              backgroundColor: Colors.deepPurple,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Chargement...",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }

          if (userSnapshot.hasData && userSnapshot.data != null) {
            print("Authentification state: ACTIVE. Utilisateur connecté: ${userSnapshot.data!.uid}. Navigation vers Accueil.");
            return Navigator(
              initialRoute: '/accueil',
              onGenerateRoute: (settings) {
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
                  case '/recherche':
                    page = const RechercheScreen();
                    break;
                  case '/settings':
                    page = const SettingsScreen();
                    break;
                  case '/journal':
                    page = const JournalScreen();
                    break;
                  default:
                    page = Scaffold(appBar: AppBar(title: const Text("Erreur")), body: const Center(child: Text("Page inconnue!")));
                }
                return MaterialPageRoute(builder: (context) => page, settings: settings);
              },
            );
          }

          print("Authentification state: ACTIVE. Aucun utilisateur connecté. Affichage de l'écran d'authentification.");
          return const AuthScreen();
        },
      ),
    );
  }
}
