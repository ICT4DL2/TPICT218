// lib/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game_state.dart';


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
      String? playerName; // Variable pour stocker le nom récupéré ou saisi

      if (_isLogin) {
        // Mode Connexion
        UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          print("Connexion réussie pour UID: ${userCredential.user!.uid}");
          DocumentSnapshot userDoc = await firestore.collection('playerSystems').doc(userCredential.user!.uid).get();
          if (userDoc.exists && userDoc.data() != null) {
            // Récupère le nom du joueur depuis le document Firestore
            playerName = (userDoc.data() as Map<String, dynamic>)['playerName'] as String?;
            print("Login: Nom du joueur chargé depuis Firestore: $playerName"); // --- DEBUG PRINT ---
          } else {
            print("Login: Document utilisateur Firestore non trouvé ou vide pour UID: ${userCredential.user!.uid}");
            // Si le doc n'existe pas (ancien compte ?), on peut créer un doc de base ici si nécessaire
            // Ou laisser playerName à null, ce qui déclenchera le nom par défaut dans GameState
          }
        }
        print("Connexion terminée.");

      } else {
        // Mode Inscription
        playerName = _nameController.text.trim(); // Capture le nom saisi
        print("Inscription: Nom saisi: $playerName"); // --- DEBUG PRINT ---

        UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          print("Inscription Firebase réussie pour UID: ${userCredential.user!.uid}");
          // Crée le document utilisateur initial dans Firestore
          await firestore.collection('playerSystems').doc(userCredential.user!.uid).set({
            'uid': userCredential.user!.uid,
            'playerName': playerName, // Sauvegarde le nom du joueur
            'createdAt': FieldValue.serverTimestamp(),
            'baseVirale': { // Structure de base vide ou initiale (ajustez selon vos besoins)
              'nom': 'Base Initiale',
              'agents': [],
            },
            'immuneSystemLevel': 1, // Niveau immunitaire initial
            // TODO: Ajouter d'autres champs initiaux si nécessaire (ressources, mémoire, etc.)
          }, SetOptions(merge: true));

          print("Inscription: Document utilisateur initial créé dans Firestore pour ${userCredential.user!.uid} avec nom: $playerName"); // --- DEBUG PRINT ---
        }
        print("Inscription terminée.");
      }

      // --- Définir le nom du joueur dans GameState et sauvegarder ---
      final gameState = ref.read(gameStateProvider);
      if (playerName != null && playerName.isNotEmpty) {
        gameState.setPlayerName(playerName); // Appelle la méthode setPlayerName
        print("AuthScreen: Nom du joueur '$playerName' défini dans GameState."); // --- DEBUG PRINT ---
      } else {
        gameState.setPlayerName("Joueur Anonyme"); // Définit un nom par défaut si playerName est null ou vide
        print("AuthScreen: Nom du joueur défini par défaut dans GameState."); // --- DEBUG PRINT ---
      }
      // Sauvegarde l'état pour persister le nom du joueur localement via Hive
      await gameState.saveState();
      print("AuthScreen: GameState sauvegardé après authentification.");


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
