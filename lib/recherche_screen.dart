// lib/recherche_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async'; // Importe pour utiliser Timer

// Importe le GameState pour accéder aux ressources, niveau immunitaire et déclencher des actions
import 'models/game_state.dart';
// Importe les modèles d'unités pour les afficher
import 'models/agent_pathogene.dart';
import 'models/anticorps.dart';


/// Écran de Recherche & Développement.
/// Permet au joueur d'investir des ressources pour débloquer des améliorations
/// ou des spécialisations (comme pour les anticorps) et monter le niveau
/// du système immunitaire ou des unités individuelles.
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
      'level_required': 4, // Nécessite niveau 4 du système immunitaire
      'type': 'AnticorpsSpecialization', // Type de recherche pour la logique
    },
    {
      'name': 'Amélioration Production Énergie',
      'description': 'Augmente la vitesse de régénération de l\'énergie.',
      'cost_bio': 75,
      'cost_energie': 40,
      'unlocked': false, // TODO: Gérer l'état de débloqué via GameState/Hive
      'level_required': 1, // Disponible dès le début
      'type': 'EnergyProduction',
    },
    // TODO: Ajouter d'autres options de recherche (nouvelles unités, améliorations de stats, etc.)
  ];

  Timer? _immuneSystemUpgradeTimer;

  @override
  void initState() {
    super.initState();
    // TODO: Initialiser le timer si une amélioration du système immunitaire était en cours lors du chargement
    // Cela nécessite de stocker le temps restant dans GameState.
  }

  @override
  void dispose() {
    _immuneSystemUpgradeTimer?.cancel();
    super.dispose();
  }


  /// Tente de réaliser une recherche spécifique (pas la montée de niveau du système immunitaire).
  /// Vérifie les coûts, consomme les ressources et déclenche la logique de déblocage.
  void _performResearch(Map<String, dynamic> research) {
    final gameState = ref.read(gameStateProvider); // Accède au GameState pour les actions

    final int costBio = research['cost_bio'];
    final int costEnergie = research['cost_energie'];
    final String researchName = research['name'];
    final int levelRequired = research['level_required'];

    // Vérifie si le niveau du système immunitaire est suffisant.
    if (gameState.immuneSystemLevel < levelRequired) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Niveau Système Immunitaire insuffisant pour $researchName (requis: $levelRequired).")),
      );
      return;
    }

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

  /// Tente de monter le niveau du système immunitaire.
  void _levelUpImmuneSystem() {
    final gameState = ref.read(gameStateProvider); // Accède au GameState pour l'action

    // TODO: Vérifier si une amélioration est déjà en cours.
    if (gameState.isImmuneSystemUpgrading) { // Nécessite une propriété isImmuneSystemUpgrading dans GameState
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Amélioration du Système Immunitaire déjà en cours.")),
      );
      return;
    }

    // TODO: Définir le coût pour le prochain niveau du système immunitaire.
    // Doit correspondre à la logique dans GameState.levelUpImmuneSystem.
    int costBioNextLevel = gameState.immuneSystemLevel * 30;
    int costEnergieNextLevel = gameState.immuneSystemLevel * 20;

    // Vérifie si le joueur a les ressources pour le prochain niveau
    if (gameState.ressources.bioMateriaux < costBioNextLevel || gameState.ressources.energie < costEnergieNextLevel) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ressources insuffisantes pour monter le niveau du Système Immunitaire (requis: $costBioNextLevel Bio-Mat., $costEnergieNextLevel Énergie).")),
      );
      return;
    }


    // Appelle la méthode de montée de niveau dans GameState.
    // Cette méthode dans GameState devra consommer les ressources et démarrer le timer/état d'amélioration.
    gameState.startImmuneSystemUpgrade(); // Nécessite une nouvelle méthode startImmuneSystemUpgrade dans GameState

    // TODO: Démarrer un timer local pour mettre à jour l'UI si GameState ne gère pas l'état du timer lui-même
    // (GameState devrait idéalement stocker le temps restant et l'état d'amélioration).
    // Si GameState gère le temps restant, l'UI se mettra à jour via ref.watch.
  }

  /// Tente de faire évoluer une unité (Agent ou Anticorps).
  void _levelUpUnit(dynamic unit) { // unit peut être AgentPathogene ou Anticorps
    final gameState = ref.read(gameStateProvider); // Accède au GameState pour l'action

    // TODO: Vérifier le type de l'unité et ses coûts d'évolution.
    // TODO: Vérifier si le niveau max est atteint.
    // TODO: Afficher une confirmation ou un message si nécessaire.

    // Appelle la méthode de montée de niveau dans GameState.
    // Cette méthode dans GameState devra vérifier les coûts, consommer les ressources,
    // incrémenter le niveau de l'unité, appeler unit.applyLevelStats(), et sauvegarder.
    gameState.levelUpUnit(unit); // Nécessite une nouvelle méthode levelUpUnit dans GameState

    // TODO: Afficher un SnackBar de succès ou d'échec basé sur le résultat de gameState.levelUpUnit
  }


  @override
  Widget build(BuildContext context) {
    // ref.watch pour écouter les changements de ressources, niveau immunitaire et liste d'agents.
    final gameState = ref.watch(gameStateProvider);
    final int energie = gameState.ressources.energie;
    final int bio = gameState.ressources.bioMateriaux;
    final int immuneLevel = gameState.immuneSystemLevel; // Obtient le niveau immunitaire
    final List<AgentPathogene> playerAgents = gameState.playerBaseAgents; // Obtient la liste des agents
    final List<Anticorps> playerAnticorps = gameState.playerAnticorps; // Obtient la liste des anticorps

    // TODO: Définir le coût pour le prochain niveau du système immunitaire.
    // Doit correspondre à la logique dans GameState.levelUpImmuneSystem.
    int costBioNextImmuneLevel = immuneLevel * 30;
    int costEnergieNextImmuneLevel = immuneLevel * 20;
    // Vérifie si le joueur a les ressources pour le prochain niveau immunitaire
    bool canLevelUpImmuneSystem = gameState.ressources.bioMateriaux >= costBioNextImmuneLevel &&
        gameState.ressources.energie >= costEnergieNextImmuneLevel;
    // TODO: Vérifier si une amélioration est déjà en cours pour désactiver le bouton
    bool isImmuneSystemUpgrading = gameState.isImmuneSystemUpgrading; // Nécessite une propriété isImmuneSystemUpgrading dans GameState
    // TODO: Afficher le temps restant si une amélioration est en cours
    String immuneUpgradeStatus = isImmuneSystemUpgrading
        ? "Amélioration en cours... (${gameState.immuneSystemUpgradeTimeLeft.inSeconds}s restants)" // Nécessite immuneSystemUpgradeTimeLeft
        : "Prêt pour le niveau ${immuneLevel + 1}";


    return Scaffold(
      appBar: AppBar(
        title: const Text("Recherche & Développement"),
        backgroundColor: Colors.green[700], // Couleur indicative pour la recherche
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView( // Utilise ListView pour permettre le défilement si le contenu est long
          children: [
            // Affichage du niveau du système immunitaire et bouton de montée de niveau.
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Système Immunitaire", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Niveau Actuel: $immuneLevel", style: const TextStyle(fontSize: 16)),
                        // Bouton pour monter le niveau du système immunitaire
                        ElevatedButton(
                          // Désactivé si ressources insuffisantes OU si une amélioration est déjà en cours
                          onPressed: (canLevelUpImmuneSystem && !isImmuneSystemUpgrading) ? _levelUpImmuneSystem : null,
                          child: Text(isImmuneSystemUpgrading ? "En cours..." : "Monter Niveau"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Affichage du coût pour le prochain niveau ou le statut d'amélioration
                    Text(
                      isImmuneSystemUpgrading
                          ? immuneUpgradeStatus
                          : "Coût prochain niveau: $costBioNextImmuneLevel Bio-Mat., $costEnergieNextImmuneLevel Énergie",
                      style: TextStyle(fontSize: 14, color: (canLevelUpImmuneSystem || isImmuneSystemUpgrading) ? Colors.black54 : Colors.redAccent),
                    ),
                    // TODO: Afficher une barre de progression pour l'amélioration du système immunitaire
                  ],
                ),
              ),
            ),

            // Affichage des ressources pertinentes pour la recherche avec barres de progression.
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
                        // Affichage de l'énergie avec barre de progression
                        Expanded(
                          child: Column(
                            children: [
                              const Icon(Icons.flash_on, color: Colors.green),
                              Text("$energie Énergie", style: const TextStyle(fontSize: 14)),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: energie / 100.0, // Assuming max energy is 100
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                                backgroundColor: Colors.green.shade100,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16), // Espacement entre les barres
                        // Affichage des bio-matériaux avec barre de progression
                        Expanded(
                          child: Column(
                            children: [
                              const Icon(Icons.biotech, color: Colors.blue),
                              Text("$bio Bio-Mat.", style: const TextStyle(fontSize: 14)),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: bio / 100.0, // Assuming max biomaterials is 100
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                                backgroundColor: Colors.blue.shade100,
                              ),
                            ],
                          ),
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
            // Utilise Column pour afficher la liste des options de recherche
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: researchOptions.map((research) {
                final bool isUnlocked = research['unlocked']; // TODO: Gérer l'état débloqué via GameState
                final int levelRequired = research['level_required'];
                final bool canAfford = gameState.ressources.bioMateriaux >= research['cost_bio'] &&
                    gameState.ressources.energie >= research['cost_energie'];
                final bool levelSufficient = immuneLevel >= levelRequired;
                final bool canResearch = !isUnlocked && canAfford && levelSufficient;

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
                        // Affichage des coûts et niveau requis
                        Text(
                            "Coût: ${research['cost_bio']} Bio-Mat., ${research['cost_energie']} Énergie",
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(
                          "Niveau Système Immunitaire requis: $levelRequired",
                          style: TextStyle(fontSize: 12, color: levelSufficient ? Colors.black54 : Colors.redAccent),
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      // Désactiver le bouton si la recherche est débloquée, ressources insuffisantes ou niveau insuffisant
                      onPressed: canResearch ? () {
                        _performResearch(research);
                      } : null,
                      child: Text(isUnlocked ? "Débloqué" : "Rechercher"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canResearch ? Colors.green : Colors.grey,
                      ),
                    ),
                  ),
                );
              }).toList(), // Convertit le Map en List de Widgets
            ),

            const SizedBox(height: 24), // Espacement

            // Liste des agents du laboratoire avec option d'évolution.
            const Text("Agents du Laboratoire", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            // Utilise Column pour afficher la liste des agents
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: playerAgents.map((agent) {
                // TODO: Définir le coût d'évolution pour chaque niveau d'unité.
                // Exemple simple : coût fixe par niveau.
                int costBioLevelUp = agent.level * 10;
                int costEnergieLevelUp = agent.level * 8;
                // TODO: Définir le niveau maximum pour les unités.
                int maxLevel = 10; // Exemple
                bool canAffordLevelUp = gameState.ressources.bioMateriaux >= costBioLevelUp &&
                    gameState.ressources.energie >= costEnergieLevelUp;
                bool isMaxLevel = agent.level >= maxLevel;
                bool canLevelUp = canAffordLevelUp && !isMaxLevel;


                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: Icon(Icons.bug_report, color: isMaxLevel ? Colors.grey : Colors.red), // Icône grise si niveau max
                    title: Text("${agent.nom} (Niv ${agent.level})", style: TextStyle(decoration: isMaxLevel ? TextDecoration.lineThrough : null)), // Barré si niveau max
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("PV: ${agent.pv}, Dégâts: ${agent.degats}, Armure: ${agent.armure.toStringAsFixed(1)}"),
                        const SizedBox(height: 4),
                        // Affichage des coûts d'évolution
                        Text(
                            isMaxLevel
                                ? "Niveau Maximum atteint"
                                : "Coût évolution: $costBioLevelUp Bio-Mat., $costEnergieLevelUp Énergie",
                            style: TextStyle(fontSize: 12, color: (canAffordLevelUp || isMaxLevel) ? Colors.grey : Colors.redAccent)),
                      ],
                    ),
                    trailing: ElevatedButton(
                      // Désactiver le bouton si niveau max ou ressources insuffisantes
                      onPressed: canLevelUp ? () {
                        _levelUpUnit(agent);
                      } : null,
                      child: Text(isMaxLevel ? "Max" : "Évoluer"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canLevelUp ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                );
              }).toList(), // Convertit le Map en List de Widgets
            ),

            const SizedBox(height: 24), // Espacement

            // Liste des anticorps du joueur avec option d'évolution.
            const Text("Anticorps", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            // Utilise Column pour afficher la liste des anticorps
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: playerAnticorps.map((anti) {
                // TODO: Définir le coût d'évolution pour chaque niveau d'unité.
                // Exemple simple : coût fixe par niveau.
                int costBioLevelUp = anti.level * 8;
                int costEnergieLevelUp = anti.level * 6;
                // TODO: Définir le niveau maximum pour les unités.
                int maxLevel = 10; // Exemple
                bool canAffordLevelUp = gameState.ressources.bioMateriaux >= costBioLevelUp &&
                    gameState.ressources.energie >= costEnergieLevelUp;
                bool isMaxLevel = anti.level >= maxLevel;
                bool canLevelUp = canAffordLevelUp && !isMaxLevel;

                // TODO: Logique pour la spécialisation (niveau 4 du système immunitaire requis)
                bool canSpecialize = gameState.immuneSystemLevel >= 4 && anti.specialization == null;
                // TODO: Définir le coût de spécialisation
                int costBioSpec = 100;
                int costEnergieSpec = 80;
                bool canAffordSpec = gameState.ressources.bioMateriaux >= costBioSpec &&
                    gameState.ressources.energie >= costEnergieSpec;


                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: Icon(Icons.verified_user, color: isMaxLevel ? Colors.grey : Colors.blue), // Icône grise si niveau max
                    title: Text("${anti.nom} (Niv ${anti.level})", style: TextStyle(decoration: isMaxLevel ? TextDecoration.lineThrough : null)), // Barré si niveau max
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("PV: ${anti.pv}, Dégâts: ${anti.degats}"),
                        Text("Spécialisation: ${anti.specialization ?? 'Aucune'}"),
                        const SizedBox(height: 4),
                        // Affichage des coûts d'évolution
                        Text(
                            isMaxLevel
                                ? "Niveau Maximum atteint"
                                : "Coût évolution: $costBioLevelUp Bio-Mat., $costEnergieLevelUp Énergie",
                            style: TextStyle(fontSize: 12, color: (canAffordLevelUp || isMaxLevel) ? Colors.grey : Colors.redAccent)),
                        // Affichage des coûts de spécialisation si possible
                        if (canSpecialize)
                          Text(
                            "Coût spécialisation: $costBioSpec Bio-Mat., $costEnergieSpec Énergie",
                            style: TextStyle(fontSize: 12, color: canAffordSpec ? Colors.grey : Colors.redAccent),
                          ),
                      ],
                    ),
                    trailing: Column( // Utilise une colonne pour aligner les boutons verticalement
                      mainAxisSize: MainAxisSize.min, // Prend le minimum d'espace vertical
                      children: [
                        // Bouton d'évolution
                        ElevatedButton(
                          // Désactiver le bouton si niveau max ou ressources insuffisantes
                          onPressed: canLevelUp ? () {
                            _levelUpUnit(anti); // Appelle la même méthode pour les anticorps
                          } : null,
                          child: Text(isMaxLevel ? "Max" : "Évoluer"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canLevelUp ? Colors.blue : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4), // Espacement entre les boutons
                        // Bouton de spécialisation (si possible)
                        if (canSpecialize)
                          ElevatedButton(
                            onPressed: canAffordSpec ? () {
                              // TODO: Implémenter la logique de spécialisation dans GameState
                              // gameState.specializeAnticorps(anti);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Logique de spécialisation à implémenter.")),
                              );
                            } : null,
                            child: const Text("Spécialiser"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: canAffordSpec ? Colors.orange : Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(), // Convertit le Map en List de Widgets
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
