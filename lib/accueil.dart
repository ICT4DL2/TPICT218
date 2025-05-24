// lib/screens/accueil.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Assurez-vous que ce fichier exporte gameStateProvider
import 'models/game_state.dart';


class Accueil extends ConsumerWidget {
  const Accueil({super.key});

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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Augmenter le padding
          // SingleChildScrollView pour garantir la compatibilité sur petits écrans.
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre stylisé pour le système immunitaire (style similaire au combat screen)
                Center(
                  child: Text(
                    "Système Immunitaire (Niv ${gameState.immuneSystemLevel})",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 32), // Espacement augmenté

                // Affichage des ressources sous forme de barre de progression améliorée.
                Card(
                  elevation: 8, // Ajouter de l'ombre à la carte
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Coins arrondis
                  child: Padding(
                    padding: const EdgeInsets.all(20.0), // Padding augmenté
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ressources Disponibles',
                          style: TextStyle(
                            fontSize: 20, // Taille du texte augmentée
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16), // Espacement augmenté

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
                        const SizedBox(height: 8), // Espacement augmenté
                        ClipRRect( // Arrondir les coins de la barre de progression
                          borderRadius: BorderRadius.circular(8), // Coins plus arrondis
                          child: LinearProgressIndicator(
                            value: energieValue,
                            minHeight: 16, // Augmenter la hauteur
                          ),
                        ),
                        const SizedBox(height: 20), // Espacement augmenté

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
                        const SizedBox(height: 8), // Espacement augmenté
                        ClipRRect( // Arrondir les coins de la barre de progression
                          borderRadius: BorderRadius.circular(8), // Coins plus arrondis
                          child: LinearProgressIndicator(
                            value: biomatValue,
                            minHeight: 16, // Augmenter la hauteur
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24), // Espacement


              ],
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