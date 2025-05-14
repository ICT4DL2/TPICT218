// models/laboratoire_recherche.dart
import 'dart:math';
import 'agent_pathogene.dart';
import 'bacterie.dart';
import 'champignon.dart';
import 'virus.dart';
import 'anticorps.dart';
import 'ressources_defensives.dart';

class LaboratoireCreation {
  final RessourcesDefensives ressources;

  LaboratoireCreation(this.ressources);

  final int coutCreationAgent = 20;
  final int coutEvolution = 50;
  final int coutCreationAnticorps = 15;

  /// Crée un agent pathogène avec des statistiques fournies par l'utilisateur.
  /// L'agent retourné est une instance concrète (Bacterie, Champignon ou Virus).
  AgentPathogene creerAgentPathogeneManual({
    required String type,
    required int pv,
    required double armure,
    required int degats,
    required int initiative,
  }) {
    if (!ressources.consommerEnergie(coutCreationAgent)) {
      throw Exception("Pas assez d'énergie pour créer un agent.");
    }
    switch (type.toLowerCase()) {
      case "bacterie":
        return Bacterie(
          pv: pv,
          armure: armure,
          degats: degats,
          initiative: initiative,
        );
      case "champignon":
        return Champignon(
          pv: pv,
          armure: armure,
          degats: degats,
          initiative: initiative,
        );
      case "virus":
        return Virus(
          pv: pv,
          armure: armure,
          degats: degats,
          initiative: initiative,
        );
      default:
        throw Exception("Type d'agent pathogène inconnu.");
    }
  }

  /// Crée un agent pathogène avec des statistiques aléatoires.
  AgentPathogene creerAgentPathogene({ required String type }) {
    return creerAgentPathogeneManual(
      type: type,
      pv: (Random().nextInt(3) + 1) * 10,
      armure: (Random().nextInt(3) + 1) * 2.0,
      degats: (Random().nextInt(3) + 1) * 5,
      initiative: (Random().nextInt(3) + 1) * 3,
    );
  }

  /// Crée un anticorps en consommant des biomatériaux.
  Anticorps creerAnticorps({
    required String nom,
    int? pv,
    String? typeAttaque,
    int? degats,
    int? coutRessources,
    int? tempsProduction,
  }) {
    int cost = coutRessources ?? coutCreationAnticorps;
    if (!ressources.consommerBioMateriaux(cost)) {
      throw Exception("Pas assez de biomatériaux pour créer cet anticorps.");
    }
    return Anticorps(
      nom: nom,
      pv: pv ?? 80,
      typeAttaque: typeAttaque ?? "Généraliste",
      degats: degats ?? 20,
      coutRessources: cost,
      tempsProduction: tempsProduction ?? 10,
    );
  }

  /// Évolue un agent en améliorant ses caractéristiques.
  AgentPathogene evoluerAgent(AgentPathogene agent) {
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
}