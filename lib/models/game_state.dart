// lib/models/game_state.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importe Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Importe Cloud Firestore

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
// Assurez-vous que ce fichier existe si vous utilisez DefaultAgentPathogene dans votre état ou vos listes Hive
// import '../default_agent_pathogene.dart'; // Pour la classe utilisée dans le laboratoire


// Importe les classes de logique de combat
import 'combat_manager.dart';
import 'combat_result.dart';


/// GameState centralisé pour gérer l’état global de l’application.
/// Utilise ChangeNotifier de Flutter pour notifier les écouteurs (widgets Riverpod)
/// des changements d'état. Gère également la persistance Hive et la sauvegarde/chargement
/// de certaines données vers Firestore.
class GameState extends ChangeNotifier {
  /// Les ressources défensives du joueur (énergie et biomatériaux).
  RessourcesDefensives ressources = RessourcesDefensives(energie: 100, bioMateriaux: 100);

  /// La mémoire immunitaire qui garde la trace des types d’agents vaincus.
  MemoireImmunitaire memoire = MemoireImmunitaire();

  /// Liste des unités anticorps disponibles pour le joueur.
  List<Anticorps> anticorps = [];

  /// Base virale du joueur. Contient les agents pathogènes que le joueur déploie/crée.
  BaseVirale baseVirale = BaseVirale(nom: "Base Principale"); // La base du joueur

  /// Instance de la logique de création et d’évolution des agents.
  late LaboratoireCreation laboratoireCreation;

  /// Stocke le résumé textuel de la dernière bataille pour affichage ou envoi à Gemini.
  String battleData = "En attente de combat...";

  /// Propriété pour stocker le résultat complet du dernier combat.
  CombatResult? lastCombatResult;

  /// Map pour suivre les sous-types d'agents pathogènes qui ont déjà été créés.
  /// Map<Type Agent Principal (Bactérie/Champignon/Virus), Set<Sous-type Spécifique (E. coli/Corona etc.)>>
  Map<String, Set<String>> usedAgentSubtypes = {
    "Bacterie": {},
    "Champignon": {},
    "Virus": {},
  };

  // --- NOUVEAU : Instance de Firestore ---
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  /// Constructeur de GameState.
  /// Initialise le laboratoire et charge l'état depuis Hive.
  GameState() {
    laboratoireCreation = LaboratoireCreation(ressources);
    loadState(); // Charge l'état depuis Hive au démarrage
    // _initBaseUnits(); // Peut être appelé ici si initBaseUnits doit toujours s'exécuter, même après un chargement Hive
  }

  /// Initialise les unités de base si elles n'existent pas déjà au chargement.
  /// Cette méthode devrait idéalement être appelée APRES loadState
  /// pour ne pas écraser des unités sauvegardées.
  void _initBaseUnits() {
    // Exemple: Ajouter un anticorps de base si la liste d'anticorps est vide après chargement.
    if (!anticorps.any((a) => a.nom == "GLOB-B")) { // any() est plus efficace que every()
      // Vérifier si un GLOB-B existant a été chargé avant d'en ajouter un nouveau.
      print("Ajout de l'anticorps de base GLOB-B."); // Log
      anticorps.add(Anticorps(
        nom: "GLOB-B",
        pv: 80,
        typeAttaque: "Généraliste", // Correspondance avec faiblesse/résistance à définir
        degats: 20,
        coutRessources: 20,
        tempsProduction: 10,
      ));
      // Pas de notifyListeners ici car initBaseUnits est appelé dans le constructeur ou loadState
      // qui sera suivi d'un notifyListeners.
    }
    // TODO: Ajouter d'autres unités de base ou logique d'initialisation si nécessaire.
  }


  /// Ajoute un nouvel agent pathogène à la base virale du joueur et notifie les écouteurs.
  /// Appelle également la sauvegarde Firestore de la base.
  void addAgentToBase(AgentPathogene agent) {
    baseVirale.ajouterAgent(agent);
    notifyListeners();
    // --- NOUVEAU : Sauvegarde la base sur Firestore après ajout d'un agent ---
    // Cette sauvegarde est déclenchée à chaque ajout d'agent.
    savePlayerBaseToFirestore();
  }

  /// Ajoute une nouvelle unité d'anticorps à la liste du joueur et notifie les écouteurs.
  void addAnticorps(Anticorps newAnti) {
    anticorps.add(newAnti);
    notifyListeners();
    // TODO: Décider si l'ajout d'anticorps doit aussi déclencher une sauvegarde Firestore de la base (probablement pas, car les anticorps ne sont pas dans la base attaquable).
  }

  /// Marque un sous-type spécifique d'agent pathogène comme ayant été créé.
  /// Appeler après la création réussie d'un agent.
  /// Notifie les écouteurs car cela affecte la liste des sous-types disponibles dans l'UI.
  void markAgentSubtypeAsUsed(String agentType, String subtype) {
    if (usedAgentSubtypes.containsKey(agentType)) {
      usedAgentSubtypes[agentType]!.add(subtype);
      notifyListeners();
      print("Marqué sous-type $subtype pour type $agentType comme utilisé.");
    } else {
      print("Erreur: Type d'agent $agentType inconnu dans usedAgentSubtypes map.");
    }
  }


  /// Consomme une quantité d'énergie et notifie les écouteurs si la consommation est réussie.
  void consommerEnergie(int quantite) {
    if (ressources.consommerEnergie(quantite)) {
      notifyListeners();
    }
  }

  /// Consomme une quantité de biomatériaux et notifie les écouteurs si la consommation est réussie.
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
  /// Utilise Hive.openBox pour accéder à la boîte de sauvegarde.
  /// Sauvegarde les propriétés pertinentes marquées avec @HiveField.
  Future<void> saveState() async {
    try {
      var box = await Hive.openBox('gameStateBox');
      await box.put('ressources', ressources);
      await box.put('memoire', memoire);
      await box.put('anticorps', anticorps);
      await box.put('baseVirale', baseVirale);
      await box.put('battleData', battleData);
      await box.put('usedAgentSubtypes', usedAgentSubtypes.map((k, v) => MapEntry(k, v.toList())));
      print("GameState sauvegardé avec succès dans Hive.");
    } catch (e) {
      print("Erreur lors de la sauvegarde GameState: $e");
    }
  }

  /// Charge l'état sauvegardé depuis Hive.
  /// Tente de récupérer les données de la boîte de sauvegarde.
  Future<void> loadState() async {
    try {
      var box = await Hive.openBox('gameStateBox');

      ressources = box.get('ressources', defaultValue: RessourcesDefensives(energie: 100, bioMateriaux: 100));
      memoire = box.get('memoire', defaultValue: MemoireImmunitaire());
      anticorps = List<Anticorps>.from(box.get('anticorps', defaultValue: []));
      baseVirale = box.get('baseVirale', defaultValue: BaseVirale(nom: "Base Principale"));
      battleData = box.get('battleData', defaultValue: "En attente de combat...");

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

      _initBaseUnits(); // Appeler ici pour ajouter les unités de base si le chargement n'en a pas trouvé

      notifyListeners(); // Notifie les widgets que l'état a été chargé
      print("GameState chargé avec succès depuis Hive.");
    } catch (e) {
      print("Erreur lors du chargement GameState: $e");
      if (usedAgentSubtypes.isEmpty || !usedAgentSubtypes.containsKey("Bacterie")) {
        usedAgentSubtypes = {
          "Bacterie": {},
          "Champignon": {},
          "Virus": {},
        };
        print("usedAgentSubtypes réinitialisé après erreur de chargement.");
      }
      _initBaseUnits();
      notifyListeners();
    }
  }

  /// Lance une simulation de combat contre une base ennemie.
  /// Utilise le CombatManager pour simuler et met à jour l'état du jeu avec les résultats.
  void startBattle(BaseVirale enemyBase) {
    if (anticorps.isEmpty) {
      battleData = "Impossible de lancer le combat : Vous n'avez pas d'anticorps !";
      lastCombatResult = null;
      notifyListeners();
      return;
    }

    CombatManager combatManager = CombatManager();
    CombatResult result = combatManager.simulateCombat(anticorps, enemyBase);

    battleData = result.battleSummaryForGemini;
    lastCombatResult = result;

    // TODO: Appliquer les récompenses (ressources, points de recherche) basées sur `result.rewards` quand implémenté.
    // TODO: Mettre à jour la mémoire immunitaire basée sur `result.defeatedPathogenTypes` quand implémenté.
    // TODO: Gérer les conséquences de la défaite si `!result.playerWon` (ex: perte de PV pour la base du joueur, perte d'anticorps si c'est une mécanique).

    notifyListeners();
  }

  // --- Méthodes de conversion vers/depuis Map pour Firestore ---

  /// Convertit un AgentPathogene en Map pour la sauvegarde Firestore.
  /// Inclut un champ '_type' pour identifier la sous-classe lors de la lecture.
  Map<String, dynamic> _agentPathogeneToMap(AgentPathogene agent) {
    final map = {
      'nom': agent.nom,
      'pv': agent.pv,
      'armure': agent.armure,
      'typeAttaque': agent.typeAttaque,
      'degats': agent.degats,
      'initiative': agent.initiative,
      'customType': agent.customType, // Peut être null
    };

    // Ajoute des champs spécifiques à la sous-classe si nécessaire
    if (agent is Bacterie) {
      map['_type'] = 'Bacterie';
      // Aucune propriété spécifique à ajouter pour Bacterie dans votre modèle actuel
    } else if (agent is Champignon) {
      map['_type'] = 'Champignon';
      map['invisible'] = agent.invisible; // Ajoute la propriété spécifique
    } else if (agent is Virus) {
      map['_type'] = 'Virus';
      // Aucune propriété spécifique à ajouter pour Virus dans votre modèle actuel
    }
    // TODO: Ajouter d'autres types d'agents pathogènes ici si vous en créez (comme DefaultAgentPathogene si utilisé).

    return map;
  }

  /// Convertit une Map (lue depuis Firestore) en instance d'AgentPathogene.
  /// Utilise le champ '_type' pour déterminer la sous-classe correcte.
  AgentPathogene? _agentPathogeneFromMap(Map<String, dynamic> map) {
    final type = map['_type'];
    if (type == null) {
      print("Erreur: Type d'agent pathogène manquant dans la map Firestore.");
      return null; // Ne peut pas désérialiser sans le type
    }

    // Assurez-vous que les champs existent et ont le bon type, en gérant les cas null ou types incorrects.
    final nom = map['nom'] as String? ?? "Agent Inconnu"; // Fournir une valeur par défaut
    final pv = (map['pv'] as num?)?.toInt() ?? 0; // Convertir num en int, gérer null
    final armure = (map['armure'] as num?)?.toDouble() ?? 0.0; // Convertir num en double, gérer null
    final typeAttaque = map['typeAttaque'] as String? ?? "Généraliste"; // Gérer null
    final degats = (map['degats'] as num?)?.toInt() ?? 0; // Convertir num en int, gérer null
    final initiative = (map['initiative'] as num?)?.toInt() ?? 0; // Convertir num en int, gérer null
    final customType = map['customType'] as String?; // Peut être null

    switch (type) {
      case 'Bacterie':
        return Bacterie(
          pv: pv,
          armure: armure,
          degats: degats,
          initiative: initiative,
        )..customType = customType; // Applique le customType après création
      case 'Champignon':
        final invisible = map['invisible'] as bool? ?? false; // Gère la valeur manquante ou null
        return Champignon(
          pv: pv,
          armure: armure,
          degats: degats,
          initiative: initiative,
        )..customType = customType
          ..invisible = invisible; // Applique la propriété spécifique
      case 'Virus':
        return Virus(
          pv: pv,
          armure: armure,
          degats: degats,
          initiative: initiative,
        )..customType = customType; // Applique le customType
    // TODO: Ajouter d'autres types d'agents pathogènes ici (comme DefaultAgentPathogene si utilisé).
    /*
      case 'DefaultAgentPathogene':
         final agentType = map['agentType'] as String? ?? "Default";
         final level = (map['level'] as num?)?.toInt() ?? 1;
         return DefaultAgentPathogene(
            nom: nom, // Utilise le nom lu de la map
            agentType: agentType,
            level: level,
            pv: pv,
            armure: armure,
            degats: degats,
            initiative: initiative,
         )..customType = customType;
      */
      default:
        print("Erreur: Type d'agent pathogène inconnu lors de la désérialisation: $type");
        return null;
    }
  }

  /// Convertit la BaseVirale du joueur en Map pour la sauvegarde Firestore.
  Map<String, dynamic> _playerBaseToMap() {
    return {
      'nom': baseVirale.nom,
      // Convertit chaque agent de la liste en Map
      'agents': baseVirale.agents.map((agent) => _agentPathogeneToMap(agent)).toList(),
    };
  }

  /// Convertit une Map (lue depuis Firestore) en instance de BaseVirale.
  BaseVirale _baseFromMap(Map<String, dynamic> map) {
    final nom = map['nom'] as String? ?? "Base Chargée"; // Nom par défaut si manquant
    final agentsData = map['agents'] as List<dynamic>? ?? []; // Liste vide si agents manquent

    // Convertit chaque Map d'agent dans la liste en instance d'AgentPathogene
    final agents = agentsData
        .map((agentMap) => _agentPathogeneFromMap(agentMap as Map<String, dynamic>))
        .whereType<AgentPathogene>() // Filtre les valeurs nulles si la désérialisation échoue
        .toList();

    return BaseVirale(
      nom: nom,
      agents: agents,
    );
  }


  // --- Méthode pour sauvegarder la base du joueur sur Firestore ---

  /// Sauvegarde la BaseVirale actuelle du joueur sur Firestore.
  /// Les données sont stockées dans une collection 'playerSystems'
  /// avec le UID de l'utilisateur comme ID de document.
  Future<void> savePlayerBaseToFirestore() async {
    // Obtient l'utilisateur actuellement connecté.
    final user = FirebaseAuth.instance.currentUser;

    // Vérifie si un utilisateur est connecté. On ne peut sauvegarder que pour un utilisateur connecté.
    if (user == null) {
      print("Erreur: Aucun utilisateur connecté pour sauvegarder la base sur Firestore.");
      return; // Sort de la fonction si pas d'utilisateur
    }

    // Référence au document Firestore pour cet utilisateur.
    final userDocRef = _firestore.collection('playerSystems').doc(user.uid);

    try {
      // Prépare les données de la base virale du joueur en format Map.
      final baseData = _playerBaseToMap();

      // Crée la structure complète du document utilisateur à sauvegarder.
      final userData = {
        'uid': user.uid, // Stocke l'UID pour référence
        // 'playerName': 'Nom du Joueur', // TODO: Ajouter un champ pour le nom du joueur si vous en avez un
        'lastUpdated': FieldValue.serverTimestamp(), // Horodatage de la dernière mise à jour
        'baseVirale': baseData, // Les données de la base virale
        // TODO: Ajouter d'autres données publiques du joueur si nécessaire (ex: niveau, score)
      };


      // Sauvegarde les données sur Firestore.
      // set() écrase le document s'il existe, ou le crée s'il n'existe pas.
      await userDocRef.set(userData, SetOptions(merge: true)); // merge: true permet de fusionner avec un document existant si vous ne voulez pas tout écraser

      print("Base virale du joueur (${user.uid}) sauvegardée sur Firestore."); // Log de succès

    } catch (e) {
      print("Erreur lors de la sauvegarde de la base sur Firestore: $e"); // Log l'erreur
      // TODO: Gérer l'erreur (ex: afficher un message à l'utilisateur, réessayer).
    }
  }

  // --- Méthode pour charger la base du joueur depuis Firestore (pour tester ou afficher sa propre base publique) ---

  /// Charge la BaseVirale du joueur depuis Firestore.
  /// Cette méthode charge la version "publique" de la base du joueur telle qu'elle est sauvegardée pour les autres.
  /// Elle n'écrase pas l'état complet du GameState (ressources, anticorps, etc.).
  /// Elle est utile pour afficher la base d'un autre joueur ou la propre base publique du joueur.
  Future<BaseVirale?> loadPlayerBaseFromFirestore(String uid) async {
    try {
      final userDocRef = _firestore.collection('playerSystems').doc(uid);
      final docSnapshot = await userDocRef.get(); // Récupère le document

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        final baseData = data['baseVirale'] as Map<String, dynamic>?;

        if (baseData != null) {
          print("Base virale pour UID $uid chargée depuis Firestore."); // Log
          return _baseFromMap(baseData); // Convertit la Map en BaseVirale
        } else {
          print("Champ 'baseVirale' manquant dans le document Firestore pour UID $uid."); // Log
          return null;
        }
      } else {
        print("Document Firestore non trouvé pour UID $uid."); // Log
        return null; // Document non trouvé
      }
    } catch (e) {
      print("Erreur lors du chargement de la base depuis Firestore pour UID $uid: $e"); // Log
      return null; // Erreur de chargement
    }
  }


  // Méthode pour accéder à la liste des agents de la base du joueur
  List<AgentPathogene> get playerBaseAgents => baseVirale.agents;

  // Méthode pour accéder à la liste des anticorps du joueur
  List<Anticorps> get playerAnticorps => anticorps;
}

/// Déclaration du provider Riverpod pour le GameState.
/// Utilise ChangeNotifierProvider pour fournir une instance de GameState
/// qui peut notifier ses écouteurs des changements.
final gameStateProvider = ChangeNotifierProvider<GameState>((ref) => GameState());
