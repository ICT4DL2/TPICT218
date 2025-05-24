// lib/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/game_state.dart';
import 'models/base_virale.dart'; // Assurez-vous d'importer BaseVirale
import 'models/anticorps.dart'; // Assurez-vous d'importer Anticorps
import 'models/ressources_defensives.dart'; // Assurez-vous d'importer RessourcesDefensives

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isLoading = false;
  bool _isLogin = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _tryAuthenticate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      String? effectivePlayerName;
      String? playerUid; // Pour stocker l'UID de l'utilisateur

      final gameState = ref.read(gameStateProvider); // Accédez au GameState une seule fois

      if (_isLogin) {
        // --- Mode Connexion ---
        UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          playerUid = userCredential.user!.uid;
          print("Connexion réussie pour UID: $playerUid");

          // Définir l'UID du joueur dans le GameState dès la connexion
          gameState.setPlayerUid(playerUid!);

          // Tente de charger les données publiques du joueur depuis Firestore
          final Map<String, dynamic>? loadedData = await gameState.loadPlayerPublicDataFromFirestore(playerUid!);

          if (loadedData != null) {
            effectivePlayerName = loadedData['playerName'] as String?;
            print("Login: Données joueur chargées depuis Firestore: $effectivePlayerName");

            // Met à jour le GameState avec les données chargées
            // NOTE: La logique de `loadPlayerPublicDataFromFirestore` devrait déjà
            // hydrater le GameState avec ces données. Si ce n'est pas le cas,
            // alors les lignes ci-dessous sont nécessaires.
            // Cependant, idéalement, `loadPlayerPublicDataFromFirestore`
            // devrait aussi gérer la mise à jour des propriétés du GameState.

            if (effectivePlayerName != null && effectivePlayerName.isNotEmpty) {
              gameState.setPlayerName(effectivePlayerName);
            }
            // Mettre à jour les autres propriétés du GameState si `loadPlayerPublicDataFromFirestore` ne le fait pas
            // Par exemple:
            if (loadedData.containsKey('baseVirale')) {
              // Assurez-vous que BaseVirale est bien désérialisée ici si elle ne l'est pas déjà par Hive
              // C'est un point où vous pourriez avoir besoin d'une méthode `fromMap` dans BaseVirale
              // ou un adaptateur Hive qui gère la conversion depuis Firestore
              // Pour l'instant, je laisse le casting direct si votre `loadPlayerPublicDataFromFirestore`
              // retourne des objets déjà typés.
              gameState.baseVirale = loadedData['baseVirale'] as BaseVirale;
            }
            if (loadedData.containsKey('playerAnticorps')) {
              gameState.anticorps = loadedData['playerAnticorps'] as List<Anticorps>;
            }
            if (loadedData.containsKey('playerRessources')) {
              gameState.ressources = loadedData['playerRessources'] as RessourcesDefensives;
            }
            if (loadedData.containsKey('immuneSystemLevel')) {
              gameState.immuneSystemLevel = loadedData['immuneSystemLevel'] as int;
            }
            gameState.notifyListeners(); // Notifier les écouteurs après avoir mis à jour les données
            print("AuthScreen: GameState mis à jour avec les données de Firestore.");

          } else {
            print("Login: Aucune donnée publique trouvée dans Firestore pour UID: $playerUid. "
                "Un nouveau document de base sera créé ou le GameState existant sera utilisé.");
            // Si l'utilisateur s'est connecté mais n'a pas de données Firestore,
            // cela pourrait signifier qu'il est un ancien utilisateur ou qu'il s'est inscrit
            // via une autre méthode et que ses données Firestore n'ont pas été initialisées.
            // Dans ce cas, on peut initialiser ses données Firestore avec l'état actuel de GameState
            // (qui sera chargé depuis Hive s'il existe).
            await gameState.savePlayerPublicDataToFirestore(); // Sauvegarde l'état actuel du GameState vers Firestore
          }
        }
        print("Connexion terminée.");

      } else {
        // --- Mode Inscription ---
        effectivePlayerName = _nameController.text.trim();
        print("Inscription: Nom saisi: $effectivePlayerName");

        UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          playerUid = userCredential.user!.uid;
          print("Inscription Firebase réussie pour UID: $playerUid");

          // Définir l'UID et le nom du joueur dans le GameState dès l'inscription
          gameState.setPlayerUid(playerUid!);
          if (effectivePlayerName.isNotEmpty) {
            gameState.setPlayerName(effectivePlayerName);
            print("AuthScreen: Nom du joueur '$effectivePlayerName' défini dans GameState lors de l'inscription.");
          } else {
            gameState.setPlayerName("Nouveau Joueur"); // Nom par défaut
            print("AuthScreen: Nom du joueur défini par défaut dans GameState lors de l'inscription.");
          }

          // Initialisation des données par défaut du GameState pour un nouvel utilisateur
          // (Si votre GameState n'a pas déjà des valeurs par défaut dans son constructeur)
          // Par exemple, en appelant une méthode d'initialisation explicite si vous en avez une:
          // await gameState.initializeNewPlayerDefaults();

          // Puis sauvegarde toutes les données publiques initiales dans Firestore
          // Ceci inclura la base virale, anticorps par défaut, etc. qui sont dans gameState
          await gameState.savePlayerPublicDataToFirestore();
          print("Inscription: Données publiques initiales créées dans Firestore pour $playerUid");
        }
        print("Inscription terminée.");
      }

      // --- Synchronisation finale et sauvegarde locale ---
      // Assurez-vous que GameState.playerUid est toujours défini ici.
      if (playerUid != null) {
        gameState.setPlayerUid(playerUid);
      }
      // Sauvegarde l'état pour persister le nom du joueur et l'UID localement via Hive.
      // C'est important car GameState.loadState() est appelé au démarrage
      // de GameState, et cette sauvegarde assure que les dernières données sont là.
      await gameState.saveState();
      print("AuthScreen: GameState sauvegardé localement après authentification/inscription.");


    } on FirebaseAuthException catch (e) {
      String message = "Une erreur est survenue.";

      if (e.code == 'weak-password') {
        message = "Le mot de passe est trop faible.";
      } else if (e.code == 'email-already-in-use') {
        message = "Cette adresse email est déjà utilisée.";
      } else if (e.code == 'user-not-found') {
        message = "Aucun utilisateur trouvé pour cette adresse email.";
      } else if (e.code == 'wrong-password') {
        message = "Mot de passe incorrect.";
      } else {
        message = e.message ?? message;
        print("Erreur Firebase Auth: ${e.code} - ${e.message}");
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      String message = "Une erreur inattendue est survenue: $e";
      print("Erreur inattendue: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if(mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? "Connexion" : "Inscription"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Champ Nom d'utilisateur (visible seulement en mode Inscription)
                    if (!_isLogin)
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: "Nom d'utilisateur"),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.isEmpty || value.trim().length < 3) {
                            return "Veuillez entrer un nom d'utilisateur valide (au moins 3 caractères).";
                          }
                          return null;
                        },
                      ),
                    if (!_isLogin) const SizedBox(height: 12),

                    // Champ Email
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: "Adresse Email"),
                      keyboardType: TextInputType.emailAddress,
                      textCapitalization: TextCapitalization.none,
                      autocorrect: false,
                      validator: (value) {
                        if (value == null || value.isEmpty || !value.contains('@')) {
                          return "Veuillez entrer une adresse email valide.";
                        }
                        return null;
                      },
                    ),
                    // Champ Mot de passe
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: "Mot de Passe"),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty || value.length < 6) {
                          return "Le mot de passe doit contenir au moins 6 caractères.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Affiche un indicateur de chargement ou les boutons
                    if (_isLoading)
                      const CircularProgressIndicator(),
                    if (!_isLoading)
                      ElevatedButton(
                        onPressed: _tryAuthenticate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                        ),
                        child: Text(_isLogin ? "Se Connecter" : "S'inscrire"),
                      ),
                    if (!_isLoading)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                            _formKey.currentState!.reset();
                            _nameController.clear(); // Efface aussi le champ nom
                          });
                        },
                        child: Text(_isLogin ? "Créer un compte" : "J'ai déjà un compte"),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}