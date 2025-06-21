// lib/models/anticorps.dart
import 'dart:math';
import 'package:hive/hive.dart';
import 'agent_pathogene.dart';

part 'anticorps.g.dart';

@HiveType(typeId: 8) // ID de type Hive unique pour la classe Anticorps.
class Anticorps extends AgentPathogene {
  // --- Propriétés spécifiques à l'Anticorps ---

  @HiveField(10) // Les ID de champ doivent être uniques et suivre ceux de la classe mère.
  final int coutRessources;

  /// Temps nécessaire en secondes pour produire cet anticorps.
  @HiveField(11)
  final int tempsProduction;

  @HiveField(12)
  String? specialization;

  @HiveField(13)
  Set<String> memory = {};

  Anticorps({
    // Paramètres hérités de AgentPathogene
    required String nom,
    required int pv,
    required String typeAttaque,
    required int degats,
    double armure = 0.0, // Valeur par défaut si non fournie
    int initiative = 5,  // Valeur par défaut si non fournie

    // Paramètres spécifiques à Anticorps
    required this.coutRessources,
    required this.tempsProduction,
  }) : super(
    nom: nom,
    pv: pv,
    armure: armure,
    degats: degats,
    initiative: initiative,
    typeAttaque: typeAttaque,
  ) {

  }

  /// Implémentation de l'attaque spéciale pour l'anticorps.
  /// Le comportement peut varier en fonction du niveau ou de la spécialisation.
  @override
  int specialAttack() {
    int choice = Random().nextInt(3);
    if (choice == 0) {
      int specialDamage = (degats * 1.5).round();
      return specialDamage;
    } else if (choice == 1) {
      pv += 20;
      return 0; // Pas de dégâts infligés
    } else {
      int specialDamage = (degats * 1.7).round();
      return specialDamage;
    }
  }


  @override
  void applyLevelStats() {
    super.applyLevelStats(); // Appelle la méthode de base pour l'affichage du log

    this.pv += (this.level * 10);
    this.degats += (this.level * 2);
  }

  /// Vérifie si l'anticorps a développé une mémoire pour un sous-type de pathogène.
  /// Conditionné par le niveau (par exemple, niveau 5 minimum).
  bool hasMemoryFor(String pathogenSubtype) {
    if (level < 5) return false;
    return memory.contains(pathogenSubtype);
  }
}