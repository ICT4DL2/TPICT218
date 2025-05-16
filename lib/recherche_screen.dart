// lib/recherche_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Importe le GameState pour accéder aux ressources et potentiellement déclencher des recherches
import 'models/game_state.dart';
// Importe le LaboratoireCreation si la logique de recherche y est gérée
import 'models/laboratoire_recherche.dart'; // Assurez-vous que ce fichier existe

/// Écran de Recherche & Développement.
/// Permet au joueur d'investir des ressources pour débloquer des améliorations
/// ou des spécialisations (comme pour les anticorps).
class RechercheScreen extends ConsumerStatefulWidget {
  const RechercheScreen({Key? key}) : super(key: key);

  @override
  _RechercheScreenState createState() => _RechercheScreenState();
}

class _RechercheScreenState extends ConsumerState<RechercheScreen> {

  // TODO: Définir ici les différentes options de recherche disponibles.
  // Cela pourrait être une liste d'objets "Recherche" ou une simple map.
  // Pour l'instant, utilisons des exemples statiques.
  final List<Map<String, dynamic>> researchOptions = [
    {
      'name': 'Spécialisation Anticorps (Niveau 1)',
      'description': 'Permet de spécialiser les anticorps basiques contre un type de pathogène.',
      'cost_bio': 50,
      'cost_energie': 30,
      'unlocked': false, // TODO: Gérer l'état de débloqué via GameState/Hive
      'level': 1, // Niveau de la recherche
      'type': 'AnticorpsSpecialization', // Type de recherche pour la logique
    },
    {
      'name': 'Amélioration Production Énergie',
      'description': 'Augmente la vitesse de régénération de l\'énergie.',
      'cost_bio': 75,
      'cost_energie': 40,
      'unlocked': false, // TODO: Gérer l'état de débloqué via GameState/Hive
      'level': 1,
      'type': 'EnergyProduction',
    },
    // TODO: Ajouter d'autres options de recherche (nouvelles unités, améliorations de stats, etc.)
  ];

  /// Tente de réaliser une recherche.
  /// Vérifie les coûts, consomme les ressources et déclenche la logique de déblocage.
  void _performResearch(Map<String, dynamic> research) {
    final gameState = ref.read(gameStateProvider); // Accède au GameState pour les actions
    final laboratoire = gameState.laboratoireCreation; // Accède au Laboratoire (si la logique de recherche y est)

    final int costBio = research['cost_bio'];
    final int costEnergie = research['cost_energie'];
    final String researchName = research['name'];

    // Vérifie si la recherche est déjà débloquée (si vous ajoutez cette logique)
    // if (research['unlocked']) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text("$researchName est déjà débloquée.")),
    //   );
    //   return;
    // }

    // Vérifie si le joueur a assez de ressources.
    if (gameState.ressources.bioMateriaux < costBio || gameState.ressources.energie < costEnergie) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ressources insuffisantes pour débloquer $researchName (requis: $costBio Bio-Mat., $costEnergie Énergie).")),
      );
      return;
    }

    try {
      // Consomme les ressources via le GameState.
      gameState.consommerBioMateriaux(costBio);
      gameState.consommerEnergie(costEnergie);

      // TODO: Déclencher la logique réelle de déblocage de la recherche.
      // Cela pourrait impliquer :
      // - Marquer la recherche comme débloquée dans le GameState (qui devrait être persisté par Hive).
      // - Débloquer de nouvelles recettes dans le LaboratoireCreation.
      // - Appliquer des bonus permanents (ex: augmenter la régénération de ressources).
      // - Débloquer de nouvelles options de recherche de niveau supérieur.

      // Exemple simple: Marquer comme débloqué dans la liste locale (non persistant).
      // Vous devrez lier ceci à l'état persistant du GameState.
      // setState(() {
      //   research['unlocked'] = true; // Ceci ne fonctionne que localement
      // });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$researchName débloquée avec succès !")),
      );

      // TODO: Potentiellement, naviguer vers un autre écran ou mettre à jour l'UI
      // pour montrer les nouvelles possibilités débloquées.

      // Notifie les écouteurs pour mettre à jour l'affichage des ressources.
      // gameState.notifyListeners(); // consommerBioMateriaux/Energie le font déjà

    } catch (e) {
      // Gère les erreurs potentielles lors de la consommation de ressources.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la recherche : ${e.toString()}")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    // ref.watch pour écouter les changements de ressources et reconstruire l'UI.
    final gameState = ref.watch(gameStateProvider);
    final int energie = gameState.ressources.energie;
    final int bio = gameState.ressources.bioMateriaux;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Recherche & Développement"),
        backgroundColor: Colors.green[700], // Couleur indicative pour la recherche
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Affichage des ressources pertinentes pour la recherche.
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Ressources Disponibles", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Affichage de l'énergie
                        Column(
                          children: [
                            const Icon(Icons.flash_on, color: Colors.green),
                            Text("$energie Énergie", style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                        // Affichage des bio-matériaux
                        Column(
                          children: [
                            const Icon(Icons.biotech, color: Colors.blue),
                            Text("$bio Bio-Mat.", style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                        // TODO: Ajouter d'autres ressources de recherche si nécessaire (ex: Points de Recherche)
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Liste des options de recherche disponibles.
            const Text("Options de Recherche", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded( // Utilise Expanded pour que la liste prenne l'espace restant
              child: ListView.builder(
                itemCount: researchOptions.length,
                itemBuilder: (context, index) {
                  final research = researchOptions[index];
                  // TODO: Ajouter une logique pour vérifier si la recherche est déjà débloquée
                  final bool isUnlocked = research['unlocked']; // Actuellement basé sur la liste locale

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Icon(Icons.science, color: isUnlocked ? Colors.grey : Colors.green[700]), // Icône grise si débloquée
                      title: Text(research['name'], style: TextStyle(decoration: isUnlocked ? TextDecoration.lineThrough : null)), // Barré si débloquée
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(research['description']),
                          const SizedBox(height: 4),
                          // Affichage des coûts
                          Text("Coût: ${research['cost_bio']} Bio-Mat., ${research['cost_energie']} Énergie",
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      trailing: ElevatedButton(
                        // Désactiver le bouton si la recherche est débloquée ou si ressources insuffisantes
                        onPressed: isUnlocked ? null : () {
                          _performResearch(research);
                        },
                        child: Text(isUnlocked ? "Débloqué" : "Rechercher"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isUnlocked ? Colors.grey : Colors.green,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Bouton de retour à l'accueil
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(vertical: 12)),
          onPressed: () {
            Navigator.pop(context); // Retourne à l'écran précédent (Accueil)
          },
          icon: const Icon(Icons.home),
          label: const Text("Accueil"),
        ),
      ),
    );
  }
}
