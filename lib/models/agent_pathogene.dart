import 'package:hive/hive.dart';

// Assurez-vous que l'id 0 n'est pas déjà utilisé par une autre classe @HiveType
// et que les champs HiveField sont numérotés séquentiellement ou de manière unique.
// Les numéros de champ HiveField doivent être uniques au sein de cette classe.
// L'id 0 pour AgentPathogene et l'id 1 pour Anticorps sont des IDs de type @HiveType,
// pas des numéros de champ.
// Les numéros de champ (0, 1, 2, ...) sont pour les propriétés de la classe.

abstract class AgentPathogene {
  // --- NOUVEAU : Identifiant unique pour cette instance de pathogène ---
  @HiveField(0) // Assurez-vous que ce numéro de champ est unique dans cette classe
  late String id; // Sera assigné lors de la création dans GameState

  @HiveField(1) // Ancien champ 0
  final String nom;

  @HiveField(2) // Ancien champ 1
  int pv;

  @HiveField(3) // Ancien champ 2
  double armure;

  @HiveField(4) // Ancien champ 3
  late String typeAttaque; // Rendu modifiable si nécessaire pour la mutation ou spécialisation

  @HiveField(5) // Ancien champ 4
  int degats;

  @HiveField(6) // Ancien champ 5
  int initiative;

  // Nouveau champ "customType" (ou vous pouvez le nommer autrement selon vos besoins).
  @HiveField(7) // Ancien champ 8
  String? customType;

  // --- NOUVEAU : Niveau de l'agent pathogène ---
  // Ce niveau sera géré par le GameState et impactera les stats via CombatManager.
  @HiveField(8) // Nouveau numéro de champ
  int level = 1; // Niveau initial par défaut

  // --- NOUVEAU : Niveau de mutation de l'agent pathogène ---
  @HiveField(9) // Nouveau numéro de champ
  int mutationLevel = 0; // Niveau de mutation initial par défaut


  AgentPathogene({
    required this.nom,
    required this.pv,
    required this.armure,
    required String typeAttaque, // Le paramètre reste requis
    required this.degats,
    required this.initiative,
    this.customType,
    // L'ID et le niveau ne sont PAS passés dans le constructeur ici.
    // Ils seront assignés par le GameState lors de la création.
  }) : this.typeAttaque = typeAttaque; // Assigne la valeur du paramètre à la propriété


  /// Retourne la valeur de dégâts obtenue lors de l'attaque spéciale.
  /// Cette méthode devra utiliser le 'level' de l'agent pour savoir si l'attaque spéciale est débloquée.
  int specialAttack();

  // --- NOUVEAU : Méthode pour appliquer les stats basées sur le niveau ---
  /// Applique les bonus de statistiques basés sur le niveau de l'agent.
  /// Cette méthode sera appelée par le CombatManager ou lors du chargement/montée de niveau.
  void applyLevelStats() {
    // TODO: Implémenter la logique pour augmenter pv, armure, degats, initiative
    // en fonction du 'level'. Par exemple :
    // pv = basePv + (level - 1) * bonusPvParNiveau;
    // degats = baseDegats + (level - 1) * bonusDegatsParNiveau;
    // Vous aurez besoin de stocker les stats de base quelque part si elles ne sont pas fixes.
    // Pour l'instant, c'est une méthode placeholder.
    print("$nom (Niv $level) applique ses stats.");
    // Les calculs de stats réels devront être faits ici ou dans le CombatManager.
  }
}
