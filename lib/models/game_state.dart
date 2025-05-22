// lib/models/game_state.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

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

// Importe les classes de logique de combat
import 'combat_manager.dart'; // Importe CombatManager et SimulationResult
import 'combat_result.dart'; // Importe CombatResult
part 'game_state.g.dart';

/// GameState centralisé pour gérer l’état global de l’application.
/// Gère l'état du joueur, la persistance Hive, la sauvegarde/chargement Firestore,
/// et le système de progression (niveau immunitaire, niveaux d'unités).
@HiveType(typeId: 6) // Assurez-vous que ce Type ID est unique et cohérent
class GameState extends ChangeNotifier {
  @HiveField(14)
  String playerName = "Nouveau Joueur";

  @HiveField(0)
  RessourcesDefensives ressources = RessourcesDefensives(energie: 100, bioMateriaux: 100);

  @HiveField(1)
  MemoireImmunitaire memoire = MemoireImmunitaire();

  @HiveField(2)
  List<Anticorps> anticorps = [];

  @HiveField(3)
  BaseVirale baseVirale = BaseVirale(nom: "Base Principale");

  late LaboratoireCreation laboratoireCreation;

  @HiveField(4)
  String battleData = "En attente de combat...";

  CombatResult? lastCombatResult; // lastCombatResult n'a pas besoin d'être persisté si l'historique est stocké

  @HiveField(5)
  Map<String, Set<String>> usedAgentSubtypes = {
    "Bacterie": {},
    "Champignon": {},
    "Virus": {},
  };

  @HiveField(7)
  int immuneSystemLevel = 1;

  // --- Propriétés pour l'amélioration du Système Immunitaire avec timer ---
  @HiveField(10)
  bool isImmuneSystemUpgrading = false;
  @HiveField(11)
  DateTime? immuneSystemUpgradeEndTime;
  Timer? _immuneSystemUpgradeTimer;

  // --- Liste pour l'historique des combats (attaques seulement) ---
  @HiveField(12)
  List<CombatResult> attackHistory = [];


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
    loadState(); // Charge l'état sauvegardé
    _resumeImmuneSystemUpgradeTimer();
  }

  void setPlayerName(String name) {
    if (playerName != name) {
      playerName = name;
      notifyListeners();
    }
  }


  void _resumeImmuneSystemUpgradeTimer() {
    if (isImmuneSystemUpgrading && immuneSystemUpgradeEndTime != null) {
      final timeLeft = immuneSystemUpgradeEndTime!.difference(DateTime.now());
      if (!timeLeft.isNegative) {
        print("Reprise du timer d'amélioration du Système Immunitaire. Temps restant: $timeLeft");
        _startImmuneSystemTimer(timeLeft);
      } else {
        _finalizeImmuneSystemUpgrade();
      }
    }
  }

  void _startImmuneSystemTimer(Duration duration) {
    _immuneSystemUpgradeTimer?.cancel();
    _immuneSystemUpgradeTimer = Timer(duration, () {
      _finalizeImmuneSystemUpgrade();
    });
    notifyListeners();
  }

  void _finalizeImmuneSystemUpgrade() {
    isImmuneSystemUpgrading = false;
    immuneSystemUpgradeEndTime = null;
    immuneSystemLevel++;
    print("Amélioration du Système Immunitaire terminée. Nouveau niveau: $immuneSystemLevel");

    saveState();
    notifyListeners();
  }


  void _initBaseUnits() {
    // TODO: Revoir cette logique d'initialisation si les agents pathogènes sont les unités de base
    // et si les anticorps sont créés différemment.
    // Pour l'instant, garde l'ajout d'un anticorps de base si la liste est vide.
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
      // Ne pas sauvegarder ici, saveState est appelé après loadState.
    }
    // TODO: Ajouter une logique pour initialiser des agents pathogènes de base si nécessaire.
  }


  /// Ajoute un nouvel agent pathogène à la base virale du joueur et notifie les écouteurs.
  /// Appelle également la sauvegarde Firestore de la base.
  void addAgentToBase(AgentPathogene agent) {
    agent.id = _uuid.v4(); // Assigne un ID unique
    agent.level = 1; // Niveau initial
    agent.mutationLevel = 0; // Niveau de mutation initial

    baseVirale.ajouterAgent(agent);

    notifyListeners();
    savePlayerPublicDataToFirestore(); // Sauvegarde sur Firestore (mise à jour du nom)
    saveState(); // Sauvegarde locale via Hive
  }

  /// Ajoute une nouvelle unité d'anticorps à la liste du joueur et notifie les écouteurs.
  void addAnticorps(Anticorps newAnti) {
    newAnti.id = _uuid.v4(); // Assigne un ID unique
    newAnti.level = 1; // Niveau initial
    newAnti.memory = {}; // Mémoire initiale vide

    anticorps.add(newAnti);

    notifyListeners();
    saveState(); // Sauvegarde locale via Hive
    // L'ajout d'anticorps seuls ne déclenche pas de sauvegarde Firestore de la base attaquable.
    // Cela sera géré lors de savePlayerPublicDataToFirestore qui inclut les anticorps pour les combats.
  }

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

  void startImmuneSystemUpgrade() {
    int costBio = immuneSystemLevel * 30;
    int costEnergie = immuneSystemLevel * 20;

    if (isImmuneSystemUpgrading || ressources.bioMateriaux < costBio || ressources.energie < costEnergie) {
      print("Impossible de démarrer l'amélioration du Système Immunitaire.");
      return;
    }

    ressources.consommerBioMateriaux(costBio);
    ressources.consommerEnergie(costEnergie);

    isImmuneSystemUpgrading = true;
    final upgradeDuration = Duration(seconds: 10 * immuneSystemLevel);
    immuneSystemUpgradeEndTime = DateTime.now().add(upgradeDuration);
    print("Démarrage de l'amélioration du Système Immunitaire vers le niveau ${immuneSystemLevel + 1}. Durée: $upgradeDuration");

    _startImmuneSystemTimer(upgradeDuration);
    savePlayerPublicDataToFirestore(); // Sauvegarde le niveau du système immunitaire
    saveState();
    notifyListeners();
  }

  void levelUpUnit(dynamic unit) {
    int costBio = 0;
    int costEnergie = 0;
    int maxLevel = 10; // Niveau max par défaut

    if (unit is AgentPathogene) {
      costBio = unit.level * 10;
      costEnergie = unit.level * 8;
      maxLevel = 15; // Niveau max pour les agents
    } else if (unit is Anticorps) {
      costBio = unit.level * 8;
      costEnergie = unit.level * 6;
      maxLevel = 10; // Niveau max pour les anticorps
    } else {
      print("Erreur: Type d'unité non supporté pour l'évolution.");
      return;
    }

    if (unit.level >= maxLevel) {
      print("${unit.nom} a déjà atteint le niveau maximum ($maxLevel).");
      return;
    }

    if (ressources.bioMateriaux < costBio || ressources.energie < costEnergie) {
      print("Ressources insuffisantes pour faire évoluer ${unit.nom} au niveau ${unit.level + 1} (requis: $costBio Bio-Mat., $costEnergie Énergie).");
      return;
    }

    ressources.consommerBioMateriaux(costBio);
    ressources.consommerEnergie(costEnergie);

    unit.level++;
    print("${unit.nom} a évolué au niveau ${unit.level}.");

    // TODO: Appliquer les statistiques d'évolution (PV, dégâts, etc.) basées sur le nouveau niveau.
    // unit.applyLevelStats(); // Nécessite l'implémentation de cette méthode dans les classes d'unité.

    savePlayerPublicDataToFirestore(); // Sauvegarde les unités mises à jour
    saveState();
    notifyListeners();
  }


  void consommerEnergie(int quantite) {
    // Cette méthode est déjà implémentée dans RessourcesDefensives,
    // mais elle est ici pour être appelée par d'autres parties de GameState si nécessaire.
    if (ressources.consommerEnergie(quantite)) {
      notifyListeners();
      saveState();
    }
  }

  void consommerBioMateriaux(int quantite) {
    // Cette méthode est déjà implémentée dans RessourcesDefensives.
    if (ressources.consommerBioMateriaux(quantite)) {
      notifyListeners();
      saveState();
    }
  }

  void regenererRessources() {
    ressources.regenerer();
    notifyListeners();
    saveState(); // Sauvegarde après régénération
  }

  /// Lance une simulation de combat contre une base ennemie.
  /// Inclut les informations sur l'adversaire pour l'historique.
  /// TODO: Modifier cette méthode pour accepter List<AgentPathogene> selectedAttackingAgents
  /// et ajuster la logique pour simuler les agents attaquant la base ennemie.
  void startBattle(BaseVirale enemyBase, {required String opponentIdentifier, required String opponentType}) {

    CombatManager combatManager = CombatManager(
      playerAnticorps: anticorps, // Actuellement utilise les anticorps
      enemyBase: enemyBase, // Base attaquée ou attaquant (selon le contexte)

    );

    // Appelle simulateCombat et obtient un SimulationResult
    SimulationResult simulationResult = combatManager.simulateCombat();

    // Crée un CombatResult FINAL en utilisant le SimulationResult et les infos adversaire
    final finalCombatResult = CombatResult(
      playerWon: simulationResult.playerWon,
      battleSummaryForGemini: simulationResult.battleSummaryForGemini,
      rewards: simulationResult.rewards, // Conserve les récompenses potentielles du simulateur (pour info/futur usage)
      defeatedPathogenTypes: simulationResult.defeatedPathogenTypes,
      opponentIdentifier: opponentIdentifier, // Utilise l'identifiant passé
      opponentType: opponentType, // Utilise le type passé
    );

    battleData = finalCombatResult.battleSummaryForGemini; // Met à jour battleData avec le résumé final
    lastCombatResult = finalCombatResult; // Stocke le résultat complet

    // Ajoute le résultat final à l'historique des attaques
    attackHistory.add(finalCombatResult);
    // Limiter la taille de l'historique
    if (attackHistory.length > 50) { // Exemple: garder les 50 derniers combats
      attackHistory.removeAt(0);
    }


    // --- NOUVEAU : Appliquer les récompenses fixes de +10 si le joueur a gagné ---
    if (finalCombatResult.playerWon) {
      const int rewardAmount = 10; // Montant fixe de la récompense
      ressources.ajouterEnergie(rewardAmount);
      ressources.ajouterBioMateriaux(rewardAmount);
      print("Victoire ! Récompense reçue : +$rewardAmount Énergie, +$rewardAmount Bio-Matériaux.");

    } else {
    }


    // TODO: Mettre à jour la mémoire immunitaire des anticorps du joueur basée sur `simulationResult.defeatedPathogenTypes`


    saveState();
    notifyListeners();
  }


  /// Sauvegarde l'état actuel dans Hive.
  /// Inclut toutes les propriétés persistantes, y compris le nom du joueur et l'historique.
  Future<void> saveState() async {
    try {
      var box = await Hive.openBox('gameStateBox');
      // Sauvegarde le nom du joueur
      await box.put('playerName', playerName);
      await box.put('ressources', ressources);
      await box.put('memoire', memoire);
      await box.put('anticorps', anticorps);
      await box.put('baseVirale', baseVirale);
      await box.put('battleData', battleData);
      await box.put('usedAgentSubtypes', usedAgentSubtypes.map((k, v) => MapEntry(k, v.toList())));
      await box.put('immuneSystemLevel', immuneSystemLevel);
      await box.put('isImmuneSystemUpgrading', isImmuneSystemUpgrading);
      await box.put('immuneSystemUpgradeEndTime', immuneSystemUpgradeEndTime);
      // Sauvegarde l'historique des combats (uniquement les attaques)
      await box.put('attackHistory', attackHistory);


      print("GameState sauvegardé avec succès dans Hive."); // --- DEBUG PRINT ---
    } catch (e) {
      print("Erreur lors de la sauvegarde GameState: $e");
    }
  }

  /// Charge l'état sauvegardé depuis Hive.
  /// Charge toutes les propriétés persistantes, y compris le nom du joueur et l'historique.
  Future<void> loadState() async {
    try {
      var box = await Hive.openBox('gameStateBox');

      playerName = box.get('playerName', defaultValue: "Nouveau Joueur") as String;
      print("GameState: Nom du joueur chargé depuis Hive: $playerName"); // --- DEBUG PRINT ---


      ressources = box.get('ressources', defaultValue: RessourcesDefensives(energie: 100, bioMateriaux: 100)) as RessourcesDefensives;
      memoire = box.get('memoire', defaultValue: MemoireImmunitaire()) as MemoireImmunitaire;
      // Assurez-vous que les listes sont correctement typées lors du chargement
      anticorps = (box.get('anticorps', defaultValue: <Anticorps>[]) as List).cast<Anticorps>();
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
      isImmuneSystemUpgrading = box.get('isImmuneSystemUpgrading', defaultValue: false) as bool;
      immuneSystemUpgradeEndTime = box.get('immuneSystemUpgradeEndTime') as DateTime?;

      // Assurez-vous que les listes d'historique sont correctement typées lors du chargement
      attackHistory = (box.get('attackHistory', defaultValue: <CombatResult>[]) as List).cast<CombatResult>();


      print("GameState chargé avec succès depuis Hive.");
      print("Niveau Système Immunitaire: $immuneSystemLevel");
      print("Amélioration Système Immunitaire en cours: $isImmuneSystemUpgrading");
      print("Historique d'attaque chargé: ${attackHistory.length} combats.");


      for (var agent in baseVirale.agents) {
        // agent.applyLevelStats(); // TODO: Appeler cette méthode une fois implémentée
      }
      for (var anti in anticorps) {
        // anti.applyLevelStats(); // TODO: Appeler cette méthode une méthode si elle n'est pas déjà fonctionnelle
      }

      _resumeImmuneSystemUpgradeTimer();

      _initBaseUnits(); // Appeler ici pour ajouter les unités de base si le chargement n'en a pas trouvé

      notifyListeners();
    } catch (e) {
      print("Erreur lors du chargement GameState: $e");
      // Initialise les propriétés essentielles avec des valeurs par défaut en cas d'erreur
      playerName = "Nouveau Joueur"; // Initialise le nom par défaut
      print("GameState: Nom du joueur initialisé par défaut après erreur de chargement."); // --- DEBUG PRINT ---
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
      isImmuneSystemUpgrading = false;
      immuneSystemUpgradeEndTime = null;
      attackHistory = [];


      print("GameState réinitialisé après erreur de chargement.");
      _initBaseUnits();
      notifyListeners();
    }
  }

  // --- Sérialisation/Désérialisation des Anticorps pour Firestore ---
  Map<String, dynamic> _anticorpsToMap(Anticorps anti) {
    final map = {
      'id': anti.id,
      'nom': anti.nom,
      'pv': anti.pv,
      'typeAttaque': anti.typeAttaque,
      'degats': anti.degats,
      'coutRessources': anti.coutRessources, // <<--- CORRIGÉ ICI
      'tempsProduction': anti.tempsProduction,
      'level': anti.level,
      // 'memory': anti.memory.map((k, v) => MapEntry(k, v)), // Si la mémoire doit être stockée
    };
    return map;
  }

  Anticorps? _anticorpsFromMap(Map<String, dynamic> map) {
    final id = map['id'] as String?;
    if (id == null) return null;

    final nom = map['nom'] as String? ?? "Anticorps Inconnu";
    final pv = (map['pv'] as num?)?.toInt() ?? 0;
    final typeAttaque = map['typeAttaque'] as String? ?? "Généraliste";
    final degats = (map['degats'] as num?)?.toInt() ?? 0;
    final coutRessources = (map['coutRessources'] as num?)?.toInt() ?? 0;
    final tempsProduction = (map['tempsProduction'] as num?)?.toInt() ?? 0;
    final level = (map['level'] as num?)?.toInt() ?? 1;

    Anticorps anti = Anticorps(
      nom: nom,
      pv: pv,
      typeAttaque: typeAttaque,
      degats: degats,
      coutRessources: coutRessources,
      tempsProduction: tempsProduction,
    );
    anti.id = id;
    anti.level = level;
    // if (map.containsKey('memory')) {
    //   anti.memory = (map['memory'] as Map<String, dynamic>).cast<String, int>();
    // }
    return anti;
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


  /// Sauvegarde les données publiques du joueur (base virale, anticorps, ressources, niveau du système immunitaire)
  /// sur Firestore pour qu'elles soient disponibles pour les combats JcJ.
  Future<void> savePlayerPublicDataToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("Erreur: Aucun utilisateur connecté pour sauvegarder la base sur Firestore.");
      return;
    }

    final userDocRef = _firestore.collection('playerSystems').doc(user.uid);

    try {
      final baseData = _playerBaseToMap();
      final anticorpsData = anticorps.map((anti) => _anticorpsToMap(anti)).toList();

      final userData = {
        'uid': user.uid,
        'playerName': playerName,
        'lastUpdated': FieldValue.serverTimestamp(),
        'baseVirale': baseData,
        'playerAnticorps': anticorpsData, // Sauvegarde les anticorps
        'playerRessources': { // Sauvegarde les ressources
          'energie': ressources.energie,
          'bioMateriaux': ressources.bioMateriaux,
        },
        'immuneSystemLevel': immuneSystemLevel, // Sauvegarde le niveau du système immunitaire
      };

      await userDocRef.set(userData, SetOptions(merge: true));

      print("Données publiques du joueur (${user.uid}) sauvegardées sur Firestore.");

    } catch (e) {
      print("Erreur lors de la sauvegarde des données publiques sur Firestore: $e");
    }
  }

  /// Charge les données publiques d'un joueur (base virale, anticorps, ressources, niveau du système immunitaire)
  /// depuis Firestore pour les combats JcJ ou l'affichage d'adversaires.
  Future<Map<String, dynamic>?> loadPlayerPublicDataFromFirestore(String uid) async {
    try {
      final userDocRef = _firestore.collection('playerSystems').doc(uid);
      final docSnapshot = await userDocRef.get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        final loadedPlayerName = data['playerName'] as String?;
        final baseData = data['baseVirale'] as Map<String, dynamic>?;
        final anticorpsData = data['playerAnticorps'] as List<dynamic>?;
        final ressourcesData = data['playerRessources'] as Map<String, dynamic>?;
        final loadedImmuneSystemLevel = (data['immuneSystemLevel'] as num?)?.toInt() ?? 1;

        BaseVirale? loadedBase;
        if (baseData != null) {
          loadedBase = _baseFromMap(baseData);
          print("Base virale pour UID $uid chargée depuis Firestore.");
        } else {
          print("Champ 'baseVirale' manquant dans le document Firestore pour UID $uid.");
        }

        List<Anticorps> loadedAnticorps = [];
        if (anticorpsData != null) {
          loadedAnticorps = anticorpsData
              .map((antiMap) => _anticorpsFromMap(antiMap as Map<String, dynamic>))
              .whereType<Anticorps>()
              .toList();
          print("Anticorps pour UID $uid chargés depuis Firestore.");
        } else {
          print("Champ 'playerAnticorps' manquant dans le document Firestore pour UID $uid.");
        }

        RessourcesDefensives? loadedRessources;
        if (ressourcesData != null) {
          loadedRessources = RessourcesDefensives(
            energie: (ressourcesData['energie'] as num?)?.toInt() ?? 0,
            bioMateriaux: (ressourcesData['bioMateriaux'] as num?)?.toInt() ?? 0,
          );
          print("Ressources pour UID $uid chargées depuis Firestore.");
        } else {
          print("Champ 'playerRessources' manquant dans le document Firestore pour UID $uid.");
        }


        return {
          'playerName': loadedPlayerName,
          'baseVirale': loadedBase,
          'playerAnticorps': loadedAnticorps,
          'playerRessources': loadedRessources,
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