// lib/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importe Firebase Auth
// Vous pourriez avoir besoin d'importer cloud_firestore ici si vous créez
// le document utilisateur initial dans Firestore directement dans ce fichier
// après l'inscription réussie (voir le TODO).
import 'package:cloud_firestore/cloud_firestore.dart';


/// Écran pour l'authentification (Inscription et Connexion) via Firebase Auth.
class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Clé pour identifier le formulaire (utilisé pour valider les champs).
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour récupérer le texte des champs email et mot de passe.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Variable pour suivre l'état de chargement (lors d'une requête Firebase).
  bool _isLoading = false;

  // Variable pour basculer entre les modes Inscription et Connexion.
  bool _isLogin = true; // True pour connexion, False pour inscription

  // Nettoie les contrôleurs lorsque le widget est supprimé.
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Tente de créer un nouvel utilisateur avec email et mot de passe.
  /// Appelle l'API Firebase Auth pour s'inscrire ou se connecter.
  Future<void> _tryAuthenticate() async {
    // Valide le formulaire. Si les champs ne sont pas valides, arrête la fonction.
    if (!_formKey.currentState!.validate()) {
      return; // Ne fait rien si le formulaire n'est pas valide
    }

    // Ferme le clavier.
    FocusScope.of(context).unfocus();

    // Met l'état de chargement à true et rafraîchit l'UI.
    setState(() {
      _isLoading = true;
    });

    try {
      // Obtient l'instance de Firebase Auth.
      final FirebaseAuth auth = FirebaseAuth.instance;

      // Logique pour l'inscription ou la connexion.
      if (_isLogin) {
        // Mode Connexion
        await auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(), // trim() enlève les espaces blancs inutiles
          password: _passwordController.text.trim(),
        );
        // Si la connexion réussit, l'écouteur d'état dans main.dart redirigera l'utilisateur.
        print("Connexion réussie!"); // Log

      } else {
        // Mode Inscription
        UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // Si l'inscription réussit, l'écouteur d'état dans main.dart redirigera l'utilisateur.
        // TODO: Ajouter ici la création du document utilisateur initial dans Firestore (étape B)
        // Vous auriez besoin de l'UID du nouvel utilisateur : userCredential.user!.uid
        // et d'une instance de FirebaseFirestore : FirebaseFirestore.instance
        // Exemple (à implémenter):
        /*
         await FirebaseFirestore.instance.collection('playerSystems').doc(userCredential.user!.uid).set({
             'uid': userCredential.user!.uid,
             'playerName': 'Nouveau Joueur', // Définir un nom par défaut ou demander à l'utilisateur
             'createdAt': FieldValue.serverTimestamp(),
             'baseVirale': { // Structure de base vide ou initiale
                 'nom': 'Base Initiale',
                 'agents': [],
             },
             // Ajouter d'autres champs initiaux si nécessaire
         });
         print("Document utilisateur initial créé dans Firestore pour ${userCredential.user!.uid}"); // Log
         */
        print("Inscription réussie!"); // Log
      }
    } on FirebaseAuthException catch (e) {
      // Gère les erreurs spécifiques de Firebase Auth.
      String message = "Une erreur est survenue."; // Message d'erreur par défaut

      // Adapte le message d'erreur en fonction du code d'erreur Firebase.
      if (e.code == 'weak-password') {
        message = "Le mot de passe est trop faible.";
      } else if (e.code == 'email-already-in-use') {
        message = "Cette adresse email est déjà utilisée.";
      } else if (e.code == 'user-not-found') {
        message = "Aucun utilisateur trouvé pour cette adresse email.";
      } else if (e.code == 'wrong-password') {
        message = "Mot de passe incorrect.";
      } else {
        message = e.message ?? message; // Utilise le message de Firebase si disponible
        print("Erreur Firebase Auth: ${e.code} - ${e.message}"); // Log l'erreur complète
      }

      // Affiche l'erreur à l'utilisateur (ex: via un SnackBar ou un AlertDialog).
      // Assurez-vous que le contexte est toujours valide (mounted).
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).colorScheme.error, // Couleur rouge pour les erreurs
          ),
        );
      }


    } catch (e) {
      // Gère les autres types d'erreurs.
      String message = "Une erreur inattendue est survenue: $e";
      print("Erreur inattendue: $e"); // Log l'erreur complète
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      // S'exécute toujours après le try/catch.
      // Met l'état de chargement à false et rafraîchit l'UI.
      if(mounted) { // Vérifie si le widget est toujours monté avant d'appeler setState
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
        title: Text(_isLogin ? "Connexion" : "Inscription"), // Titre dynamique
        backgroundColor: Colors.deepPurple,
      ),
      body: Center( // Centre le contenu verticalement et horizontalement
        child: Card( // Encadre le formulaire dans une carte
          margin: const EdgeInsets.all(20), // Marge autour de la carte
          child: SingleChildScrollView( // Permet de scroller si le contenu dépasse l'écran
            child: Padding( // Rembourrage à l'intérieur de la carte
              padding: const EdgeInsets.all(16),
              child: Form( // Widget Form pour la validation des champs
                key: _formKey, // Associe la clé de formulaire
                child: Column( // Organise les éléments en colonne
                  mainAxisSize: MainAxisSize.min, // Prend le minimum d'espace vertical
                  children: <Widget>[
                    // Champ Email
                    TextFormField(
                      controller: _emailController, // Lie le contrôleur
                      decoration: const InputDecoration(labelText: "Adresse Email"), // Label du champ
                      keyboardType: TextInputType.emailAddress, // Type de clavier
                      textCapitalization: TextCapitalization.none, // Pas de majuscule automatique
                      autocorrect: false, // Pas de correction automatique
                      validator: (value) { // Fonction de validation
                        if (value == null || value.isEmpty || !value.contains('@')) {
                          return "Veuillez entrer une adresse email valide.";
                        }
                        return null; // Le champ est valide
                      },
                    ),
                    // Champ Mot de passe
                    TextFormField(
                      controller: _passwordController, // Lie le contrôleur
                      decoration: const InputDecoration(labelText: "Mot de Passe"), // Label du champ
                      obscureText: true, // Cache le texte (pour les mots de passe)
                      validator: (value) { // Fonction de validation
                        if (value == null || value.isEmpty || value.length < 6) {
                          return "Le mot de passe doit contenir au moins 6 caractères.";
                        }
                        return null; // Le champ est valide
                      },
                    ),
                    const SizedBox(height: 12), // Espacement vertical

                    // Affiche un indicateur de chargement ou les boutons
                    if (_isLoading) // Si isLoading est true, affiche le CircularProgressIndicator
                      const CircularProgressIndicator(),
                    if (!_isLoading) // Si isLoading est false, affiche les boutons
                      ElevatedButton(
                        onPressed: _tryAuthenticate, // Appelle la fonction d'authentification
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                        ),
                        child: Text(_isLogin ? "Se Connecter" : "S'inscrire"), // Texte du bouton dynamique
                      ),
                    if (!_isLoading) // Si isLoading est false, affiche le bouton de basculement
                      TextButton(
                        onPressed: () {
                          // Bascule entre les modes Inscription et Connexion.
                          setState(() {
                            _isLogin = !_isLogin;
                            _formKey.currentState!.reset(); // Réinitialise la validation du formulaire
                          });
                        },
                        child: Text(_isLogin ? "Créer un compte" : "J'ai déjà un compte"), // Texte du bouton dynamique
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
