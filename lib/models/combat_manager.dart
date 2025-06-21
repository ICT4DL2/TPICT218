// lib/models/combat_manager.dart
import 'dart:math'; // Importe pour Random
import 'anticorps.dart';
import 'base_virale.dart';


class SimulationResult {
  final bool playerWon;
  final String battleSummaryForGemini;
  final Map<String, dynamic> rewards; // TODO: Définir une classe Rewards plus structurée
  final Set<String> defeatedPathogenTypes; // Types d'agents pathogènes vaincus

  SimulationResult({
    required this.playerWon,
    required this.battleSummaryForGemini,
    required this.rewards,
    required this.defeatedPathogenTypes,
  });
}


/// Gère la logique de simulation d'un combat entre les anticorps du joueur et une base virale ennemie.
class CombatManager {
  // Stocke les unités du joueur et la base ennemie dans l'instance
  final List<Anticorps> playerAnticorps;
  final BaseVirale enemyBase;

  // Constructeur qui reçoit les unités et la base
  CombatManager({
    required this.playerAnticorps,
    required this.enemyBase,
  });

  /// Simule le déroulement d'un combat.
  /// Retourne un SimulationResult contenant les données brutes du combat.
  SimulationResult simulateCombat() { // La méthode retourne SimulationResult


    // --- Logique de simulation PNJ basée sur les nombres ---
    final random = Random();
    int playerNumber = random.nextInt(5) + 1; // Génère un nombre entre 1 et 5

    int machineNumber;
    bool playerWon;
    String summary;
    Map<String, dynamic> rewards = {}; // Récompenses initiales vides
    Set<String> defeatedTypes = {}; // Types vaincus initiaux vides

    // Applique la règle spéciale si le joueur obtient 5
    if (playerNumber == 5) {
      machineNumber = 6; // La machine obtient la plus petite valeur possible
      playerWon = true; // Le joueur gagne
      summary = "Simulation PNJ: Votre nombre est $playerNumber, celui de la Machine est $machineNumber.\n";
      summary += "Victoire décisive ! Votre attaque et votre défense ont été couronnées de succès.\n";
      // TODO: Définir des récompenses généreuses pour une victoire décisive
      rewards = {'energie': 100, 'bioMateriaux': 80};
      // TODO: Déterminer les types vaincus (peut-être tous les types présents dans la base ennemie ?)
      defeatedTypes = enemyBase.agents.map((agent) => agent.runtimeType.toString()).toSet();


    } else {
      // Cas général pour les nombres joueur 1 à 4
      machineNumber = random.nextInt(5) + 6; // Génère un nombre entre 6 et 10
      summary = "Simulation PNJ: Votre nombre est $playerNumber, celui de la Machine est $machineNumber.\n";

      playerWon = (playerNumber * 2) >= machineNumber;


      if (playerWon) {
        summary += "Victoire ! Votre stratégie a porté ses fruits.\n";
        rewards = {'energie': 50, 'bioMateriaux': 30};
        defeatedTypes = {'Bacterie'}; // Exemple simple
        if (playerNumber >= 4) defeatedTypes.add('Virus');
        if (playerNumber >= 5) defeatedTypes.add('Champignon'); // Déjà géré par le cas spécial, mais pour l'exemple

      } else {
        summary += "Défaite. La défense de la Machine était trop forte.\n";
        rewards = {}; // Pas de récompenses en cas de défaite
        defeatedTypes = {}; // Pas de types vaincus en cas de défaite
      }
      summary += "Résultat final: ${playerWon ? 'Victoire' : 'Défaite'}.\n";
    }



    print("Simulation PNJ terminée. Joueur a gagné: $playerWon (Joueur:$playerNumber, Machine:$machineNumber)"); // Log

    // Retourne le résultat brut de la simulation
    return SimulationResult(
      playerWon: playerWon,
      battleSummaryForGemini: summary,
      rewards: rewards,
      defeatedPathogenTypes: defeatedTypes,
    );
  }
}
