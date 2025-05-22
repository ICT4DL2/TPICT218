// lib/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game_state.dart';
import '../models/base_virale.dart'; // Assurez-vous d'importer BaseVirale
import '../models/anticorps.dart'; // Assurez-vous d'importer Anticorps
import '../models/ressources_defensives.dart'; // Assurez-vous d'importer RessourcesDefensives

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

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
      String? effectivePlayerName; // Le nom du joueur qui sera utilisé

      if (_isLogin) {
        // --- Mode Connexion ---
        UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          print("Connexion réussie pour UID: ${userCredential.user!.uid}");

          // Tente de charger les données publiques du joueur depuis Firestore
          // Cette méthode doit maintenant retourner les données complètes pour la base, anticorps, etc.
          final gameState = ref.read(gameStateProvider);
          final Map<String, dynamic>? loadedData = await gameState.loadPlayerPublicDataFromFirestore(userCredential.user!.uid);

          if (loadedData != null) {
            effectivePlayerName = loadedData['playerName'] as String?;
            print("Login: Données joueur chargées depuis Firestore: $effectivePlayerName");

            // Met à jour le GameState avec les données chargées
            // Le GameState.loadState() s'occupe déjà de charger depuis Hive
            // Ici, nous voulons spécifiquement charger les données publiques de Firestore
            // qui pourraient être plus récentes ou servir de référence.
            // Il est important de coordonner cela avec la logique de loadState() et saveState()
            // de GameState. Pour éviter les conflits, nous allons charger les données
            // nécessaires et les appliquer manuellement ou appeler une méthode spécifique
            // dans GameState si elle est conçue pour cela.

            // Si vous avez des constructeurs ou des setters pour ces propriétés
            // dans GameState, c'est le moment de les utiliser.
            // Pour l'exemple, nous allons directement mettre à jour les propriétés
            // et appeler notifyListeners() si nécessaire.

            // Mettre à jour le nom du joueur
            if (effectivePlayerName != null && effectivePlayerName.isNotEmpty) {
              gameState.setPlayerName(effectivePlayerName);
            }

            // Mettre à jour la base virale
            if (loadedData['baseVirale'] is BaseVirale) {
              gameState.baseVirale = loadedData['baseVirale'] as BaseVirale;
            }

            // Mettre à jour les anticorps
            if (loadedData['playerAnticorps'] is List<Anticorps>) {
              gameState.anticorps = loadedData['playerAnticorps'] as List<Anticorps>;
            }

            // Mettre à jour les ressources
            if (loadedData['playerRessources'] is RessourcesDefensives) {
              gameState.ressources = loadedData['playerRessources'] as RessourcesDefensives;
            }

            // Mettre à jour le niveau du système immunitaire
            if (loadedData['immuneSystemLevel'] is int) {
              gameState.immuneSystemLevel = loadedData['immuneSystemLevel'] as int;
            }
            // Notifier les écouteurs après avoir mis à jour les données du GameState
            gameState.notifyListeners();
            print("AuthScreen: GameState mis à jour avec les données de Firestore.");

          } else {
            print("Login: Aucune donnée publique trouvée dans Firestore pour UID: ${userCredential.user!.uid}. "
                "Un nouveau document de base sera créé ou le GameState existant sera utilisé.");
            // Si aucune donnée n'est trouvée, cela signifie peut-être que l'utilisateur n'a pas encore
            // de données publiques. On peut alors se fier à la logique d'initialisation de GameState.
            // Ou créer un document de base si c'est la première connexion.
            // Pour l'instant, on se base sur le nom par défaut ou celui de GameState.
          }
        }
        print("Connexion terminée.");

      } else {
        // --- Mode Inscription ---
        effectivePlayerName = _nameController.text.trim(); // Capture le nom saisi
        print("Inscription: Nom saisi: $effectivePlayerName");

        UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          print("Inscription Firebase réussie pour UID: ${userCredential.user!.uid}");

          // Initialise GameState pour le nouvel utilisateur avec le nom saisi
          final gameState = ref.read(gameStateProvider);
          if (effectivePlayerName != null && effectivePlayerName.isNotEmpty) {
            gameState.setPlayerName(effectivePlayerName);
            print("AuthScreen: Nom du joueur '$effectivePlayerName' défini dans GameState lors de l'inscription.");
          } else {
            gameState.setPlayerName("Nouveau Joueur"); // Nom par défaut si non saisi
            print("AuthScreen: Nom du joueur défini par défaut dans GameState lors de l'inscription.");
          }

          // Puis sauvegarde toutes les données publiques initiales dans Firestore
          // Ceci inclura la base virale, anticorps par défaut, etc. qui sont dans gameState
          await gameState.savePlayerPublicDataToFirestore();
          print("Inscription: Données publiques initiales créées dans Firestore pour ${userCredential.user!.uid}");

        }
        print("Inscription terminée.");
      }

      // --- Synchronisation finale du nom dans GameState et sauvegarde locale ---
      // Cette partie est cruciale pour s'assurer que le nom est bien défini localement.
      final gameState = ref.read(gameStateProvider);
      if (effectivePlayerName != null && effectivePlayerName.isNotEmpty) {
        gameState.setPlayerName(effectivePlayerName);
        print("AuthScreen: Nom du joueur '${effectivePlayerName}' finalisé et défini dans GameState.");
      } else {
        // Ce cas ne devrait normalement pas arriver si le flux est géré correctement,
        // mais c'est une sécurité.
        print("AuthScreen: Aucun nom effectif, le nom par défaut de GameState sera utilisé.");
        // Le nom par défaut est déjà géré par loadState de GameState.
      }
      // Sauvegarde l'état pour persister le nom du joueur localement via Hive
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