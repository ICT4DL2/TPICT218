import 'dart:math';
import 'package:hive/hive.dart';
part 'anticorps.g.dart';

@HiveType(typeId: 1)
class Anticorps {
  // --- NOUVEAU : Identifiant unique pour cette instance d'anticorps ---
  @HiveField(0) // Assurez-vous que ce numéro de champ est unique dans cette classe
  late String id; // Sera assigné lors de la création dans GameState

  @HiveField(1) // Ancien champ 0
  final String nom;

  @HiveField(2) // Ancien champ 1
  int pv;

  @HiveField(3) // Ancien champ 2
  late String typeAttaque; // Rendu modifiable si nécessaire pour la spécialisation

  @HiveField(4) // Ancien champ 3
  int degats;

  @HiveField(5) // Ancien champ 4
  final int coutRessources;

  @HiveField(6) // Ancien champ 5
  final int tempsProduction; // en secondes

  // --- NOUVEAU : Niveau de l'anticorps ---
  @HiveField(7) // Nouveau numéro de champ
  int level = 1; // Niveau initial par défaut

  // --- NOUVEAU : Spécialisation de l'anticorps ---
  // Ex: "Corona", "E. coli", ou null si non spécialisé.
  @HiveField(8) // Nouveau numéro de champ
  String? specialization;

  // --- NOUVEAU : Mémoire immunitaire de l'anticorps ---
  // Ensemble des types de pathogènes (sous-types) dont cet anticorps se souvient.
  @HiveField(9) // Nouveau numéro de champ
  Set<String> memory = {};


  Anticorps({
    required this.nom,
    required this.pv,
    required String typeAttaque, // Le paramètre reste requis
    required this.degats,
    required this.coutRessources,
    required this.tempsProduction,
    // L'ID, le niveau, la spécialisation et la mémoire ne sont PAS passés dans le constructeur ici.
    // Ils seront assignés par le GameState lors de la création ou de la progression.
  }) : typeAttaque = typeAttaque; // Assigne la valeur du paramètre à la propriété


  /// Méthode de l'attaque spéciale de l'anticorps.
  /// Cette méthode devra utiliser le 'level' de l'anticorps pour savoir si l'attaque spéciale est débloquée.
  int specialAttack() {
    // TODO: Utiliser 'level' pour débloquer l'attaque spéciale (niveau 5).
    // Pour l'instant, la logique est la même.
    int choice = Random().nextInt(3);
    if (choice == 0) {
      int specialDamage = (degats * 1.5).toInt();
      print("$nom active Salvo Toxique et inflige $specialDamage dégâts.");
      return specialDamage;
    } else if (choice == 1) {
      pv += 20;
      print("$nom active RéparationCellulaire et se soigne de 20 points.");
      return 0; // Ne lance pas d'attaque
    } else {
      int specialDamage = (degats * 1.7).toInt();
      print("$nom active MarquagePrioritaire et inflige $specialDamage dégâts.");
      return specialDamage;
    }
  }

  // --- NOUVEAU : Méthode pour appliquer les stats basées sur le niveau ---
  /// Applique les bonus de statistiques basés sur le niveau de l'anticorps.
  /// Cette méthode sera appelée par le CombatManager ou lors du chargement/montée de niveau.
  void applyLevelStats() {
    // TODO: Implémenter la logique pour augmenter pv, degats
    // en fonction du 'level'.
    print("$nom (Niv $level) applique ses stats.");
    // Les calculs de stats réels devront être faits ici ou dans le CombatManager.
  }

  // --- NOUVEAU : Méthode pour vérifier si l'anticorps a de la mémoire pour un type ---
  /// Vérifie si cet anticorps a de la mémoire pour un sous-type de pathogène donné.
  bool hasMemoryFor(String pathogenSubtype) {
    // TODO: Utiliser 'level' pour débloquer la capacité de mémoire (niveau 5).
    // Pour l'instant, on vérifie juste si le sous-type est dans le set 'memory'.
    if (level < 5) return false; // La mémoire n'est active qu'à partir du niveau 5
    return memory.contains(pathogenSubtype);
  }
}
