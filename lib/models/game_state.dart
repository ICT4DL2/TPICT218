// lib/models/game_state.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'dart:async'; // Importe pour utiliser Timer

// Importe les modèles de données
import 'agent_pathogene.dart';
import 'bacterie.dart';
import 'champignon.dart';
import 'virus.dart';
import 'anticorps.dart';
import 'base_virale.dart';
import 'memoire_immunitaire.dart';
import 'ressources_defensives.dart';
import 'laboratoire_recherche.dart';
// Assurez-vous que ce fichier existe si vous utilisez DefaultAgentPathogene
// import '../default_agent_pathogene.dart';


// Importe les classes de logique de combat
import 'combat_manager.dart';
import 'combat_result.dart';


/// GameState centralisé pour gérer l’état global de l’application.
/// Gère l'état du joueur, la persistance Hive, la sauvegarde/chargement Firestore,
/// et le système de progression (niveau immunitaire, niveaux d'unités).
class GameState extends ChangeNotifier {
  RessourcesDefensives ressources = RessourcesDefensives(energie: 100, bioMateriaux: 100);

  MemoireImmunitaire memoire = MemoireImmunitaire();

  List<Anticorps> anticorps = [];

  BaseVirale baseVirale = BaseVirale(nom: "Base Principale");

  late LaboratoireCreation laboratoireCreation;

  String battleData = "En attente de combat...";

  CombatResult? lastCombatResult;

  Map<String, Set<String>> usedAgentSubtypes = {
    "Bacterie": {},
    "Champignon": {},
    "Virus": {},
  };

  int immuneSystemLevel = 1;

  // --- NOUVEAU : Propriétés pour l'amélioration du Système Immunitaire avec timer ---
  @HiveField(10) // Assurez-vous que ce numéro de champ est unique
  bool isImmuneSystemUpgrading = false;
  @HiveField(11) // Assurez-vous que ce numéro de champ est unique
  DateTime? immuneSystemUpgradeEndTime; // Moment où l'amélioration sera terminée
  Timer? _immuneSystemUpgradeTimer; // Timer local (non persistant)

  // Getter pour calculer le temps restant
  Duration get immuneSystemUpgradeTimeLeft {
    if (!isImmuneSystemUpgrading || immuneSystemUpgradeEndTime == null) {
      return Duration.zero;
    }
    final timeLeft = immuneSystemUpgradeEndTime!.difference(DateTime.now());
    return timeLeft.isNegative ? Duration.zero : timeLeft;
  }


  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid();


  GameState() {
    laboratoireCreation = LaboratoireCreation(ressources, this);
    loadState();
    // Le timer doit être redémarré après le chargement si une amélioration était en cours.
    _resumeImmuneSystemUpgradeTimer();
  }

  /// Redémarre le timer de l'amélioration du système immunitaire si elle était en cours.
  void _resumeImmuneSystemUpgradeTimer() {
    if (isImmuneSystemUpgrading && immuneSystemUpgradeEndTime != null) {
      final timeLeft = immuneSystemUpgradeEndTime!.difference(DateTime.now());
      if (!timeLeft.isNegative) {
        print("Reprise du timer d'amélioration du Système Immunitaire. Temps restant: $timeLeft");
        _startImmuneSystemTimer(timeLeft);
      } else {
        // L'amélioration est déjà terminée, finaliser immédiatement.
        _finalizeImmuneSystemUpgrade();
      }
    }
  }

  /// Démarre le timer pour l'amélioration du système immunitaire.
  void _startImmuneSystemTimer(Duration duration) {
    _immuneSystemUpgradeTimer?.cancel(); // Annule tout timer précédent
    _immuneSystemUpgradeTimer = Timer(duration, () {
      _finalizeImmuneSystemUpgrade();
    });
    notifyListeners(); // Notifie l'UI que le timer a démarré
  }

  /// Finalise l'amélioration du système immunitaire une fois le timer terminé.
  void _finalizeImmuneSystemUpgrade() {
    isImmuneSystemUpgrading = false;
    immuneSystemUpgradeEndTime = null;
    immuneSystemLevel++; // Monte le niveau du système immunitaire
    print("Amélioration du Système Immunitaire terminée. Nouveau niveau: $immuneSystemLevel"); // Log

    // TODO: Déclencher des effets de montée de niveau ici si nécessaire (ex: débloquer de nouvelles recherches).

    saveState(); // Sauvegarde après la finalisation
    notifyListeners(); // Notifie l'UI que le niveau a changé et l'amélioration est terminée
  }


  /// Initialise les unités de base si elles n'existent pas déjà au chargement.
  /// Cette méthode devrait idéalement être appelée APRES loadState
  /// pour ne pas écraser des unités sauvegardées.
  /// Assigne un ID et initialise le niveau pour les unités de base.
  void _initBaseUnits() {
    if (anticorps.isEmpty || !anticorps.any((a) => a.nom == "GLOB-B")) {
      print("Ajout de l'anticorps de base GLOB-B.");
      Anticorps basicAnti = Anticorps(
        nom: "GLOB-B",
        pv: 80,
        typeAttaque: "Généraliste",
        degats: 20,
        coutRessources: 20,
        tempsProduction: 10,
      );
      basicAnti.id = _uuid.v4();
      basicAnti.level = 1;
      basicAnti.memory = {};

      anticorps.add(basicAnti);
      saveState();
    }
    // TODO: Ajouter d'autres unités de base ou logique d'initialisation si nécessaire, avec génération d'ID et initialisation du niveau.
  }


  /// Ajoute un nouvel agent pathogène à la base virale du joueur et notifie les écouteurs.
  /// Génère un ID pour l'agent, initialise son niveau et sauvegarde la base sur Firestore.
  void addAgentToBase(AgentPathogene agent) {
    agent.id = _uuid.v4();
    agent.level = 1;
    agent.mutationLevel = 0;

    baseVirale.ajouterAgent(agent);

    notifyListeners();
    savePlayerBaseToFirestore();
    saveState();
  }

  /// Ajoute une nouvelle unité d'anticorps à la liste du joueur et notifie les écouteurs.
  /// Génère un ID pour l'anticorps et initialise son niveau.
  void addAnticorps(Anticorps newAnti) {
    newAnti.id = _uuid.v4();
    newAnti.level = 1;
    newAnti.memory = {};

    anticorps.add(newAnti);

    notifyListeners();
    saveState();
  }

  /// Marque un sous-type spécifique d'agent pathogène comme ayant été créé.
  /// Appeler après la création réussie d'un agent.
  /// Notifie les écouteurs car cela affecte la liste des sous-types disponibles dans l'UI.
  void markAgentSubtypeAsUsed(String agentType, String subtype) {
    if (usedAgentSubtypes.containsKey(agentType)) {
      usedAgentSubtypes[agentType]!.add(subtype);
      notifyListeners();
      print("Marqué sous-type $subtype pour type $agentType comme utilisé.");
      saveState();
    } else {
      print("Erreur: Type d'agent $agentType inconnu dans usedAgentSubtypes map.");
    }
  }

  // --- Méthode pour démarrer l'amélioration du système immunitaire ---
  /// Démarre le processus de montée de niveau du système immunitaire avec un timer.
  void startImmuneSystemUpgrade() {
    // Vérification des coûts et des conditions déjà faites dans RechercheScreen,
    // mais on peut les refaire ici pour plus de sécurité.
    int costBio = immuneSystemLevel * 30;
    int costEnergie = immuneSystemLevel * 20;

    if (isImmuneSystemUpgrading || ressources.bioMateriaux < costBio || ressources.energie < costEnergie) {
      print("Impossible de démarrer l'amélioration du Système Immunitaire.");
      return; // Conditions non remplies
    }

    ressources.consommerBioMateriaux(costBio);
    ressources.consommerEnergie(costEnergie);

    isImmuneSystemUpgrading = true;
    final upgradeDuration = Duration(seconds: 10 * immuneSystemLevel); // 10s par niveau à atteindre
    immuneSystemUpgradeEndTime = DateTime.now().add(upgradeDuration);
    print("Démarrage de l'amélioration du Système Immunitaire vers le niveau ${immuneSystemLevel + 1}. Durée: $upgradeDuration"); // Log

    _startImmuneSystemTimer(upgradeDuration); // Démarre le timer local
    saveState(); // Sauvegarde l'état de début d'amélioration
    notifyListeners(); // Notifie l'UI
  }


  // --- NOUVEAU : Méthode pour faire évoluer une unité (Agent ou Anticorps) ---
  /// Tente de faire évoluer une unité spécifique.
  void levelUpUnit(dynamic unit) { // unit peut être AgentPathogene ou Anticorps
    // TODO: Définir les coûts d'évolution par niveau et par type d'unité.
    int costBio = 0;
    int costEnergie = 0;
    int maxLevel = 10; // Exemple de niveau max

    if (unit is AgentPathogene) {
      costBio = unit.level * 10;
      costEnergie = unit.level * 8;
      maxLevel = 15; // Exemple de niveau max différent pour les agents
    } else if (unit is Anticorps) {
      costBio = unit.level * 8;
      costEnergie = unit.level * 6;
      maxLevel = 10; // Exemple de niveau max différent pour les anticorps
    } else {
      print("Erreur: Type d'unité non supporté pour l'évolution.");
      return;
    }

    // Vérifie si le niveau max est atteint
    if (unit.level >= maxLevel) {
      print("${unit.nom} a déjà atteint le niveau maximum ($maxLevel).");
      // TODO: Afficher un message à l'utilisateur.
      return;
    }

    // Vérifie si le joueur a assez de ressources.
    if (ressources.bioMateriaux < costBio || ressources.energie < costEnergie) {
      print("Ressources insuffisantes pour faire évoluer ${unit.nom} au niveau ${unit.level + 1} (requis: $costBio Bio-Mat., $costEnergie Énergie).");
      // TODO: Afficher un message à l'utilisateur.
      return;
    }

    // Consomme les ressources
    ressources.consommerBioMateriaux(costBio);
    ressources.consommerEnergie(costEnergie);

    // Incrémente le niveau de l'unité
    unit.level++;
    print("${unit.nom} a évolué au niveau ${unit.level}."); // Log

    // Applique les bonus de stats du nouveau niveau
    // unit.applyLevelStats(); // TODO: Appeler cette méthode une fois implémentée

    saveState(); // Sauvegarde l'état après l'évolution
    notifyListeners(); // Notifie l'UI
  }

  // TODO: Ajouter une méthode specializeAnticorps(Anticorps anti, String specializationType)
  // Cette méthode vérifiera le niveau du système immunitaire (>= 4), les coûts,
  // définira anti.specialization, et sauvegardera l'état.


  /// Consomme une quantité d'énergie donnée, si suffisante.
  void consommerEnergie(int quantite) {
    if (ressources.consommerEnergie(quantite)) {
      notifyListeners();
      saveState();
    }
  }

  /// Consomme une quantité de biomatériaux donnée, si suffisante.
  void consommerBioMateriaux(int quantite) {
    if (ressources.consommerBioMateriaux(quantite)) {
      notifyListeners();
      saveState();
    }
  }

  /// Régénère passivement les ressources et notifie l'interface.
  void regenererRessources() {
    ressources.regenerer();
    notifyListeners();
    // La régénération peut être fréquente, sauvegarder à chaque fois pourrait être excessif.
    // Vous pourriez vouloir sauvegarder moins souvent pour la régénération.
    // saveState(); // Optionnel : sauvegarder après régénération
  }

  /// Sauvegarde l'état actuel dans Hive.
  /// Inclut toutes les propriétés persistantes.
  Future<void> saveState() async {
    try {
      var box = await Hive.openBox('gameStateBox');
      await box.put('ressources', ressources);
      await box.put('memoire', memoire);
      await box.put('anticorps', anticorps);
      await box.put('baseVirale', baseVirale);
      await box.put('battleData', battleData);
      await box.put('usedAgentSubtypes', usedAgentSubtypes.map((k, v) => MapEntry(k, v.toList())));
      await box.put('immuneSystemLevel', immuneSystemLevel);
      // --- NOUVEAU : Sauvegarde les propriétés de l'amélioration du Système Immunitaire ---
      await box.put('isImmuneSystemUpgrading', isImmuneSystemUpgrading);
      await box.put('immuneSystemUpgradeEndTime', immuneSystemUpgradeEndTime);


      print("GameState sauvegardé avec succès dans Hive.");
    } catch (e) {
      print("Erreur lors de la sauvegarde GameState: $e");
    }
  }

  /// Charge l'état sauvegardé depuis Hive.
  /// Charge toutes les propriétés persistantes.
  Future<void> loadState() async {
    try {
      var box = await Hive.openBox('gameStateBox');

      ressources = box.get('ressources', defaultValue: RessourcesDefensives(energie: 100, bioMateriaux: 100)) as RessourcesDefensives;
      memoire = box.get('memoire', defaultValue: MemoireImmunitaire()) as MemoireImmunitaire;
      anticorps = List<Anticorps>.from(box.get('anticorps', defaultValue: []));
      baseVirale = box.get('baseVirale', defaultValue: BaseVirale(nom: "Base Principale")) as BaseVirale;
      battleData = box.get('battleData', defaultValue: "En attente de combat...") as String;

      var loadedUsedSubtypes = box.get('usedAgentSubtypes');
      if (loadedUsedSubtypes != null) {
        usedAgentSubtypes = (loadedUsedSubtypes as Map<dynamic, dynamic>).map(
                (k, v) => MapEntry(k.toString(), (v as List<dynamic>).map((item) => item.toString()).toSet()));
      } else {
        usedAgentSubtypes = {
          "Bacterie": {},
          "Champignon": {},
          "Virus": {},
        };
      }
      print("usedAgentSubtypes chargé: $usedAgentSubtypes");

      immuneSystemLevel = box.get('immuneSystemLevel', defaultValue: 1) as int;
      // --- NOUVEAU : Charge les propriétés de l'amélioration du Système Immunitaire ---
      isImmuneSystemUpgrading = box.get('isImmuneSystemUpgrading', defaultValue: false) as bool;
      immuneSystemUpgradeEndTime = box.get('immuneSystemUpgradeEndTime') as DateTime?;


      print("GameState chargé avec succès depuis Hive.");
      print("Niveau Système Immunitaire: $immuneSystemLevel");
      print("Amélioration Système Immunitaire en cours: $isImmuneSystemUpgrading"); // Log

      // --- NOUVEAU : Appliquer les stats basées sur le niveau après chargement ---
      // Il est important d'appliquer les bonus de niveau après avoir chargé les unités
      // car les stats de base pourraient ne pas être celles sauvegardées.
      // Assurez-vous que applyLevelStats existe et met à jour les propriétés pv, degats, etc.
      // dans AgentPathogene et Anticorps.
      for (var agent in baseVirale.agents) {
        // agent.applyLevelStats(); // TODO: Implémenter/appeler cette méthode si elle n'est pas déjà fonctionnelle
      }
      for (var anti in anticorps) {
        // anti.applyLevelStats(); // TODO: Implémenter/appeler cette méthode si elle n'est pas déjà fonctionnelle
      }

      // Redémarre le timer si nécessaire après le chargement
      _resumeImmuneSystemUpgradeTimer();


      _initBaseUnits();

      notifyListeners();
    } catch (e) {
      print("Erreur lors du chargement GameState: $e");
      ressources = RessourcesDefensives(energie: 100, bioMateriaux: 100);
      memoire = MemoireImmunitaire();
      anticorps = [];
      baseVirale = BaseVirale(nom: "Base Principale");
      battleData = "En attente de combat...";
      usedAgentSubtypes = {
        "Bacterie": {},
        "Champignon": {},
        "Virus": {},
      };
      immuneSystemLevel = 1;
      // Initialise les propriétés de l'amélioration du Système Immunitaire en cas d'erreur
      isImmuneSystemUpgrading = false;
      immuneSystemUpgradeEndTime = null;


      print("GameState réinitialisé après erreur de chargement.");
      _initBaseUnits();
      notifyListeners();
    }
  }

  void startBattle(BaseVirale enemyBase) {
    if (anticorps.isEmpty) {
      battleData = "Impossible de lancer le combat : Vous n'avez pas d'anticorps !";
      lastCombatResult = null;
      notifyListeners();
      return;
    }

    CombatManager combatManager = CombatManager(
      playerAnticorps: anticorps,
      enemyBase: enemyBase,
    );

    CombatResult result = combatManager.simulateCombat();

    battleData = result.battleSummaryForGemini;
    lastCombatResult = result;

    saveState();

    notifyListeners();
  }

  Map<String, dynamic> _agentPathogeneToMap(AgentPathogene agent) {
    final map = {
      'id': agent.id,
      'nom': agent.nom,
      'pv': agent.pv,
      'armure': agent.armure,
      'typeAttaque': agent.typeAttaque,
      'degats': agent.degats,
      'initiative': agent.initiative,
      'customType': agent.customType,
      'level': agent.level,
      'mutationLevel': agent.mutationLevel,
    };

    if (agent is Bacterie) {
      map['_type'] = 'Bacterie';
    } else if (agent is Champignon) {
      map['_type'] = 'Champignon';
      map['invisible'] = agent.invisible;
    } else if (agent is Virus) {
      map['_type'] = 'Virus';
    }

    return map;
  }

  AgentPathogene? _agentPathogeneFromMap(Map<String, dynamic> map) {
    final type = map['_type'];
    if (type == null) {
      print("Erreur: Type d'agent pathogène manquant dans la map Firestore.");
      return null;
    }

    final id = map['id'] as String?;
    if (id == null) {
      print("Erreur: ID d'agent pathogène manquant dans la map Firestore.");
      return null;
    }
    final nom = map['nom'] as String? ?? "Agent Inconnu";
    final pv = (map['pv'] as num?)?.toInt() ?? 0;
    final armure = (map['armure'] as num?)?.toDouble() ?? 0.0;
    final typeAttaque = map['typeAttaque'] as String? ?? "Généraliste";
    final degats = (map['degats'] as num?)?.toInt() ?? 0;
    final initiative = (map['initiative'] as num?)?.toInt() ?? 0;
    final customType = map['customType'] as String?;
    final level = (map['level'] as num?)?.toInt() ?? 1;
    final mutationLevel = (map['mutationLevel'] as num?)?.toInt() ?? 0;


    AgentPathogene? agent;
    switch (type) {
      case 'Bacterie':
        agent = Bacterie(pv: pv, armure: armure, degats: degats, initiative: initiative);
        agent.customType = customType;
        break;
      case 'Champignon':
        final invisible = map['invisible'] as bool? ?? false;
        agent = Champignon(pv: pv, armure: armure, degats: degats, initiative: initiative);
        agent.customType = customType;
        if (agent is Champignon) {
          agent.invisible = invisible;
        }
        break;
      case 'Virus':
        agent = Virus(pv: pv, armure: armure, degats: degats, initiative: initiative);
        agent.customType = customType;
        break;
      default:
        print("Erreur: Type d'agent pathogène inconnu lors de la désérialisation: $type");
        return null;
    }

    if (agent != null) {
      agent.id = id;
      agent.level = level;
      agent.mutationLevel = mutationLevel;
    }
    return agent;
  }

  Map<String, dynamic> _playerBaseToMap() {
    return {
      'nom': baseVirale.nom,
      'agents': baseVirale.agents.map((agent) => _agentPathogeneToMap(agent)).toList(),
    };
  }

  BaseVirale _baseFromMap(Map<String, dynamic> map) {
    final nom = map['nom'] as String? ?? "Base Chargée";
    final agentsData = map['agents'] as List<dynamic>? ?? [];

    final agents = agentsData
        .map((agentMap) => _agentPathogeneFromMap(agentMap as Map<String, dynamic>))
        .whereType<AgentPathogene>()
        .toList();

    return BaseVirale(
      nom: nom,
      agents: agents,
    );
  }


  Future<void> savePlayerBaseToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("Erreur: Aucun utilisateur connecté pour sauvegarder la base sur Firestore.");
      return;
    }

    final userDocRef = _firestore.collection('playerSystems').doc(user.uid);

    try {
      final baseData = _playerBaseToMap();

      final userData = {
        'uid': user.uid,
        'lastUpdated': FieldValue.serverTimestamp(),
        'baseVirale': baseData,
        'immuneSystemLevel': immuneSystemLevel,
      };


      await userDocRef.set(userData, SetOptions(merge: true));

      print("Base virale du joueur (${user.uid}) et niveau immunitaire sauvegardés sur Firestore.");

    } catch (e) {
      print("Erreur lors de la sauvegarde de la base sur Firestore: $e");
    }
  }

  Future<Map<String, dynamic>?> loadPlayerPublicDataFromFirestore(String uid) async {
    try {
      final userDocRef = _firestore.collection('playerSystems').doc(uid);
      final docSnapshot = await userDocRef.get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        final baseData = data['baseVirale'] as Map<String, dynamic>?;
        final loadedImmuneSystemLevel = (data['immuneSystemLevel'] as num?)?.toInt() ?? 1;

        BaseVirale? loadedBase;
        if (baseData != null) {
          loadedBase = _baseFromMap(baseData);
          print("Base virale pour UID $uid chargée depuis Firestore.");
        } else {
          print("Champ 'baseVirale' manquant dans le document Firestore pour UID $uid.");
        }

        return {
          'baseVirale': loadedBase,
          'immuneSystemLevel': loadedImmuneSystemLevel,
        };

      } else {
        print("Document Firestore non trouvé pour UID $uid.");
        return null;
      }
    } catch (e) {
      print("Erreur lors du chargement des données publiques depuis Firestore pour UID $uid: $e");
      return null;
    }
  }


  List<AgentPathogene> get playerBaseAgents => baseVirale.agents;

  List<Anticorps> get playerAnticorps => anticorps;
}

final gameStateProvider = ChangeNotifierProvider<GameState>((ref) => GameState());
