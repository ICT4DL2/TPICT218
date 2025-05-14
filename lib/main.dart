import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'accueil.dart'; // Page d'accueil
import 'laboratoire_screen.dart'; // Écran LaboratoireScreen
import 'combat_screen.dart'; // Écran LaboratoireScreen

import 'models/bacterie.dart';
import 'models/champignon.dart';
import 'models/virus.dart';
import 'models/anticorps.dart';
import 'models/base_virale.dart';
import 'models/memoire_immunitaire.dart';
import 'models/ressources_defensives.dart';
import 'models/game_state.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Initialisation de Hive pour Flutter.
  await Hive.initFlutter();

  // Enregistrez ici vos adaptateurs générés par Hive.
  Hive.registerAdapter(BacterieAdapter());
  Hive.registerAdapter(ChampignonAdapter());
  Hive.registerAdapter(VirusAdapter());
  Hive.registerAdapter(AnticorpsAdapter());
  Hive.registerAdapter(BaseViraleAdapter());
  Hive.registerAdapter(MemoireImmunitaireAdapter());
  Hive.registerAdapter(RessourcesDefensivesAdapter());

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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      final gameState = ProviderScope.containerOf(context).read(gameStateProvider);
      gameState.saveState();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ImmunoWarriors',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/accueil', // Écran d'accueil
      routes: {
        '/accueil': (context) => const Accueil(),
        '/laboratoire': (context) => const LaboratoireScreen(),
        '/combat': (context) => const CombatScreen(),
      },
    );
  }
}