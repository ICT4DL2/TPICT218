// models/laboratoire_recherche.dart
import 'dart:math';
import 'agent_pathogene.dart';
import 'bacterie.dart';
import 'champignon.dart';
import 'virus.dart';
import 'anticorps.dart';
import 'ressources_defensives.dart';
import 'game_state.dart'; // Importe GameState pour accéder au niveau immunitaire et aux limites

class LaboratoireCreation {
  final RessourcesDefensives ressources;
  // --- NOUVEAU : Référence au GameState pour accéder au niveau immunitaire ---
  final GameState gameState; // Le Laboratoire a besoin de connaître l'état global

  LaboratoireCreation(this.ressources, this.gameState); // Passe le GameState au constructeur

  final int coutCreationAgent = 20;
  final int coutEvolution = 50; // Coût de l'évolution (montée de niveau) d'une unité
  final int coutCreationAnticorps = 15;

  // TODO: Définir les coûts pour les recherches spécifiques (spécialisation, etc.)

  /// Crée un agent pathogène avec des statistiques fournies par l'utilisateur.
  /// Vérifie les limites de création basées sur le niveau immunitaire.
  /// L'ID et le niveau seront assignés dans GameState.addAgentToBase.
  AgentPathogene creerAgentPathogeneManual({
    required String type,
    required int pv,
    required double armure,
    required int degats,
    required int initiative,
    String? customType, // Permet de passer un customType
  }) {
    // --- NOUVEAU : Vérifie la limite de création d'agents si niveau < 4 ---
    if (gameState.immuneSystemLevel < 4 && gameState.baseVirale.agents.length >= 2) {
      throw Exception("Limite de création d'agents atteinte pour le niveau ${gameState.immuneSystemLevel} du Système Immunitaire (max 2).");
    }

    if (!ressources.consommerEnergie(coutCreationAgent)) {
      throw Exception("Pas assez d'énergie pour créer un agent.");
    }

    // La génération de l'ID et l'initialisation du niveau seront faites dans GameState.addAgentToBase.
    AgentPathogene newAgent;
    switch (type.toLowerCase()) {
      case "bacterie":
        newAgent = Bacterie(
          pv: pv,
          armure: armure,
          degats: degats,
          initiative: initiative,
          // customType: customType, // Passer le customType si le constructeur l'accepte
        );
        break;
      case "champignon":
        newAgent = Champignon(
          pv: pv,
          armure: armure,
          degats: degats,
          initiative: initiative,
          // customType: customType,
          // invisible: false, // Gérer les propriétés spécifiques si nécessaire
        );
        break;
      case "virus":
        newAgent = Virus(
          pv: pv,
          armure: armure,
          degats: degats,
          initiative: initiative,
          // customType: customType,
        );
        break;
      default:
        throw Exception("Type d'agent pathogène inconnu.");
    }
    // Assigner le customType après la création si le constructeur ne l'accepte pas directement
    if (customType != null && newAgent is AgentPathogene) { // Vérification de type pour être sûr
      newAgent.customType = customType;
    }

    return newAgent; // L'ID et le niveau seront assignés dans GameState
  }

  /// Crée un agent pathogène avec des statistiques aléatoires.
  /// Vérifie les limites de création basées sur le niveau immunitaire.
  /// L'ID et le niveau seront assignés dans GameState.addAgentToBase.
  AgentPathogene creerAgentPathogene({ required String type, String? customType }) {
    // --- NOUVEAU : Vérifie la limite de création d'agents si niveau < 4 ---
    if (gameState.immuneSystemLevel < 4 && gameState.baseVirale.agents.length >= 2) {
      throw Exception("Limite de création d'agents atteinte pour le niveau ${gameState.immuneSystemLevel} du Système Immunitaire (max 2).");
    }

    if (!ressources.consommerEnergie(coutCreationAgent)) {
      throw Exception("Pas assez d'énergie pour créer un agent.");
    }

    // La génération de l'ID et l'initialisation du niveau seront faites dans GameState.addAgentToBase.
    AgentPathogene newAgent = creerAgentPathogeneManual(
      type: type,
      pv: (Random().nextInt(3) + 1) * 10,
      armure: (Random().nextInt(3) + 1) * 2.0,
      degats: (Random().nextInt(3) + 1) * 5,
      initiative: (Random().nextInt(3) + 1) * 3,
      customType: customType,
    );

    return newAgent; // L'ID et le niveau seront assignés dans GameState
  }


  /// Crée un anticorps en consommant des biomatériaux.
  /// Vérifie les limites de création basées sur le niveau immunitaire.
  /// L'ID et le niveau seront assignés dans GameState.addAnticorps.
  Anticorps creerAnticorps({
    required String nom,
    int? pv,
    String? typeAttaque,
    int? degats,
    int? coutRessources,
    int? tempsProduction,
  }) {
    // --- NOUVEAU : Vérifie la limite de création d'anticorps si niveau < 4 ---
    if (gameState.immuneSystemLevel < 4 && gameState.anticorps.length >= 1) {
      throw Exception("Limite de création d'anticorps atteinte pour le niveau ${gameState.immuneSystemLevel} du Système Immunitaire (max 1).");
    }

    int cost = coutRessources ?? coutCreationAnticorps;
    if (!ressources.consommerBioMateriaux(cost)) {
      throw Exception("Pas assez de biomatériaux pour créer cet anticorps.");
    }

    // La génération de l'ID et l'initialisation du niveau seront faites dans GameState.addAnticorps.
    return Anticorps(
      nom: nom,
      pv: pv ?? 80,
      typeAttaque: typeAttaque ?? "Généraliste",
      degats: degats ?? 20,
      coutRessources: cost,
      tempsProduction: tempsProduction ?? 10,
    ); // L'ID et le niveau seront assignés dans GameState
  }

  /// Évolue un agent en améliorant ses caractéristiques.
  /// Cette méthode ne devrait plus être utilisée directement pour la montée de niveau.
  /// La montée de niveau sera gérée par une méthode dans GameState.
  /// Laisse la méthode pour référence si elle est utilisée ailleurs.
  AgentPathogene evoluerAgent(AgentPathogene agent) {
    print("Attention: evoluerAgent dans LaboratoireCreation est obsolète pour la montée de niveau.");
    // Cette logique devrait être dans une méthode levelUpUnit dans GameState.
    // Pour l'instant, on la laisse mais elle ne gère pas les niveaux externes.
    if (!ressources.consommerEnergie(coutEvolution)) {
      throw Exception("Pas assez d'énergie pour faire évoluer l'agent.");
    }
    int pvAmeliore = agent.pv * 2;
    double armureAmelioree = agent.armure * 1.5;
    int degatsAmeliores = agent.degats * 2;
    int initiativeAmelioree = agent.initiative + 10;

    if (agent is Bacterie) {
      return Bacterie(
        pv: pvAmeliore,
        armure: armureAmelioree,
        degats: degatsAmeliores,
        initiative: initiativeAmelioree,
      );
    } else if (agent is Champignon) {
      return Champignon(
        pv: pvAmeliore,
        armure: armureAmelioree,
        degats: degatsAmeliores,
        initiative: initiativeAmelioree,
      );
    } else if (agent is Virus) {
      return Virus(
        pv: pvAmeliore,
        armure: armureAmelioree,
        degats: degatsAmeliores,
        initiative: initiativeAmelioree,
      );
    } else {
      throw Exception("Type d'agent non supporté pour l'évolution.");
    }
  }

// TODO: Ajouter des méthodes pour gérer les recherches spécifiques (spécialisation, etc.)
// ou déplacer cette logique dans GameState.
}
