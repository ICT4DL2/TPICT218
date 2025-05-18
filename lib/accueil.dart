// lib/screens/accueil.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/game_state.dart'; // Assurez-vous que ce fichier exporte gameStateProvider

class Accueil extends ConsumerWidget {
  const Accueil({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On récupère l'état global grâce à Riverpod.
    final gameState = ref.watch(gameStateProvider);

    // Pour cet exemple, nous considérons que la valeur maximale des ressources est 100.
    // Assurez-vous que la valeur maximale est cohérente avec votre logique de jeu.
    const double maxResource = 100.0;
    final double energieValue =
    (gameState.ressources.energie / maxResource).clamp(0.0, 1.0).toDouble();
    final double biomatValue =
    (gameState.ressources.bioMateriaux / maxResource).clamp(0.0, 1.0).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ImmunoWarriors - Accueil'),
        backgroundColor: Colors.blueGrey[900], // Couleur plus sombre pour l'AppBar
        elevation: 0, // Pas d'ombre pour se fondre dans le dégradé
      ),
      // Container avec gradient couvrant toute la surface.
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade800, // Bleu plus profond
              Colors.teal.shade600, // Vert-bleu
              Colors.deepPurple.shade600, // Violet profond
              Colors.red.shade800, // Rouge profond
            ],
            stops: const [0.1, 0.4, 0.7, 0.9], // Points d'arrêt pour le dégradé
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0), // Augmenter le padding
            // SingleChildScrollView pour garantir la compatibilité sur petits écrans.
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre stylisé pour le système immunitaire
                  Center(
                    child: Text(
                      "Système Immunitaire (Niv ${gameState.immuneSystemLevel})",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Texte blanc pour contraste
                        shadows: [ // Ombre pour le texte
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24), // Espacement

                  // Affichage des ressources sous forme de barre de progression améliorée.
                  Card(
                    elevation: 8, // Ajouter de l'ombre à la carte
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Coins arrondis
                    color: Colors.white.withOpacity(0.9), // Fond blanc semi-transparent
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ressources Disponibles',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800]),
                          ),
                          const SizedBox(height: 12),
                          // Énergie
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Énergie',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              Text('${gameState.ressources.energie.toInt()}/${maxResource.toInt()}'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect( // Arrondir les coins de la barre de progression
                            borderRadius: BorderRadius.circular(5),
                            child: LinearProgressIndicator(
                              value: energieValue,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                              minHeight: 12, // Augmenter la hauteur
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Bio-Matériaux
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Bio-Matériaux',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              Text('${gameState.ressources.bioMateriaux.toInt()}/${maxResource.toInt()}'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect( // Arrondir les coins de la barre de progression
                            borderRadius: BorderRadius.circular(5),
                            child: LinearProgressIndicator(
                              value: biomatValue,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                              minHeight: 12, // Augmenter la hauteur
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24), // Espacement

                  // Section d'information ou de nouvelles (Optionnel)
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    color: Colors.white.withOpacity(0.9),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Dernier Combat:",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800]),
                          ),
                          const SizedBox(height: 8),
                          // Afficher un résumé du dernier combat si disponible
                          Text(
                            gameState.lastCombatResult != null
                                ? gameState.lastCombatResult!.playerWon
                                ? "Victoire !"
                                : "Défaite..."
                                : "Aucun combat récent.",
                            style: TextStyle(fontSize: 16, color: gameState.lastCombatResult != null ? (gameState.lastCombatResult!.playerWon ? Colors.green : Colors.red) : Colors.black54),
                          ),
                          // TODO: Afficher plus de détails du dernier combat si pertinent
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Vous pouvez ajouter d'autres sections ici si nécessaire (ex: Quêtes, Événements)

                ],
              ),
            ),
          ),
        ),
      ),
      // Boutons de navigation en bas.
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.blueGrey[700], // Couleur assortie
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/laboratoire');
                },
                icon: const Icon(Icons.science),
                label: const Text('Laboratoire'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.blueGrey[700], // Couleur assortie
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/recherche');
                },
                icon: const Icon(Icons.search),
                label: const Text('Recherche'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.blueGrey[700], // Couleur assortie
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/combat');
                },
                icon: const Icon(Icons.sports_martial_arts),
                label: const Text('Combat'),
              ),
            ),
          ],
        ),
      ),
      // Ajout de deux icônes empilées verticalement dans le coin inférieur droit.
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            mini: true,
            heroTag: "settingsBtn", // Ajout d'un heroTag unique
            onPressed: () {
              // Action pour ouvrir les paramètres
              Navigator.pushNamed(context, '/settings'); // Naviguer vers l'écran de paramètres
            },
            child: const Icon(Icons.settings),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            mini: true,
            heroTag: "journalBtn", // Ajout d'un heroTag unique
            onPressed: () {
              // Action pour ouvrir la section journal/carnet
              Navigator.pushNamed(context, '/journal'); // Naviguer vers l'écran de journal
            },
            child: const Icon(Icons.note),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
