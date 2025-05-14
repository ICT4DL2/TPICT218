// lib/gemini/gemini_user.dart (ou dans le fichier où se trouve GameState)
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'agent_pathogene.dart';
import 'bacterie.dart';
import 'champignon.dart';
import 'virus.dart';
import 'anticorps.dart';
import 'base_virale.dart';
import 'memoire_immunitaire.dart';
import 'ressources_defensives.dart';
import 'laboratoire_recherche.dart';
import '../default_agent_pathogene.dart'; // Pour la classe utilisée dans le laboratoire

/// GameState centralisé pour gérer l’état global de l’application.
class GameState extends ChangeNotifier {
  /// Les ressources défensives du joueur (énergie et biomatériaux).
  RessourcesDefensives ressources = RessourcesDefensives(energie: 100, bioMateriaux: 100);

  /// La mémoire immunitaire qui garde la trace des types d’agents vaincus.
  MemoireImmunitaire memoire = MemoireImmunitaire();

  /// Liste des agents pathogènes.
  List<AgentPathogene> agents = [];

  /// Liste des unités anticorps.
  List<Anticorps> anticorps = [];

  /// Base virale.
  BaseVirale baseVirale = BaseVirale(nom: "Base Principale");

  /// Instance de la logique de création et d’évolution des agents.
  late LaboratoireCreation laboratoireCreation;

  /// Nouvelle propriété battleData qui contiendra les informations de la bataille.
  String battleData = "Bataille simulée en cours";

  GameState() {
    laboratoireCreation = LaboratoireCreation(ressources);
    _initBaseUnits();
    loadState(); // Chargement de l'état dès l'initialisation
  }

  /// Initialise les unités de base si elles n'existent pas déjà.
  void _initBaseUnits() {
    if (agents.isEmpty) {
      agents.add(Bacterie(
        pv: 100,
        armure: 10.0,
        degats: 20,
        initiative: 5,
      ));
    }

    if (anticorps.every((a) => a.nom != "GLOB-B")) {
      anticorps.add(Anticorps(
        nom: "GLOB-B",
        pv: 80,
        typeAttaque: "Généraliste",
        degats: 20,
        coutRessources: 20,
        tempsProduction: 10,
      ));
    }
  }

  /// Ajoute un nouvel agent et notifie les écouteurs.
  void addAgent(AgentPathogene agent) {
    agents.add(agent);
    baseVirale.ajouterAgent(agent);
    notifyListeners();
  }

  /// Ajoute une nouvelle unité d'anticorps.
  void addAnticorps(Anticorps newAnti) {
    anticorps.add(newAnti);
    notifyListeners();
  }

  /// Consomme une quantité d'énergie et notifie les écouteurs.
  void consommerEnergie(int quantite) {
    if (ressources.consommerEnergie(quantite)) {
      notifyListeners();
    }
  }

  /// Consomme une quantité de biomatériaux et notifie les écouteurs.
  void consommerBioMateriaux(int quantite) {
    if (ressources.consommerBioMateriaux(quantite)) {
      notifyListeners();
    }
  }

  /// Régénère passivement les ressources et notifie l'interface.
  void regenererRessources() {
    ressources.regenerer();
    notifyListeners();
  }

  /// Sauvegarde l'état actuel dans Hive.
  Future<void> saveState() async {
    var box = await Hive.openBox('gameStateBox');
    await box.put('ressources', ressources);
    await box.put('memoire', memoire);
    await box.put('agents', agents);
    await box.put('anticorps', anticorps);
    await box.put('baseVirale', baseVirale);
    // Sauvegarde du battleData.
    await box.put('battleData', battleData);
  }

  /// Charge l'état sauvegardé depuis Hive et notifie l'interface.
  Future<void> loadState() async {
    var box = await Hive.openBox('gameStateBox');

    if (box.containsKey('ressources')) {
      ressources = box.get('ressources');
    } else {
      ressources = RessourcesDefensives(energie: 100, bioMateriaux: 100);
    }

    if (box.containsKey('memoire')) {
      memoire = box.get('memoire');
    } else {
      memoire = MemoireImmunitaire();
    }

    if (box.containsKey('agents')) {
      agents = List<AgentPathogene>.from(box.get('agents'));
    }
    if (box.containsKey('anticorps')) {
      anticorps = List<Anticorps>.from(box.get('anticorps'));
    }
    if (box.containsKey('baseVirale')) {
      baseVirale = box.get('baseVirale');
    }
    // Chargement du battleData.
    if (box.containsKey('battleData')) {
      battleData = box.get('battleData');
    } else {
      battleData = "Bataille simulée en cours";
    }

    notifyListeners();
  }
}

/// Déclaration du provider Riverpod pour le GameState.
final gameStateProvider = ChangeNotifierProvider<GameState>((ref) => GameState());