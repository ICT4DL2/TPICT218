// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importe Firebase Auth
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Importe Riverpod

// Importe le GameState pour accéder au nom du joueur
import '../models/game_state.dart';


/// Écran des Paramètres.
/// Affiche les informations du compte utilisateur.
class SettingsScreen extends ConsumerWidget { // Change en ConsumerWidget pour utiliser ref
  const SettingsScreen({Key? key}) : super(key: key);

  // Récupère l'utilisateur Firebase actuellement connecté
  User? get currentUser => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Ajoute WidgetRef ref
    // Écoute le GameState pour obtenir le nom du joueur
    final gameState = ref.watch(gameStateProvider);
    final String playerName = gameState.playerName; // Obtient le nom du joueur

    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres"),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Informations du Compte
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Informations du Compte",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    // Affiche les informations si un utilisateur est connecté
                    if (currentUser != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- NOUVEAU : Affiche le nom du joueur ---
                          Text("Nom: $playerName", style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 8),
                          Text("UID: ${currentUser!.uid}", style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 8),
                          Text("Email: ${currentUser!.email ?? 'Non disponible'}", style: const TextStyle(fontSize: 14)),
                        ],
                      )
                    else
                      const Text(
                        "Aucun utilisateur connecté.",
                        style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // TODO: Ajouter d'autres options de paramètres ici (Volume, Langue, etc.)

            // Bouton de déconnexion (Optionnel, si vous utilisez l'authentification)
            if (currentUser != null)
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    // TODO: Naviguer vers l'écran de connexion ou d'accueil après déconnexion
                    Navigator.popUntil(context, ModalRoute.withName('/')); // Exemple: Retour à la racine
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Déconnexion réussie."))
                    );
                    // TODO: Réinitialiser le GameState après déconnexion si nécessaire
                    // ref.read(gameStateProvider).resetState(); // Nécessite une méthode resetState dans GameState
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Déconnexion", style: TextStyle(fontSize: 16)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
