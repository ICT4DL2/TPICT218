import 'dart:math';
import 'package:hive/hive.dart';
part 'anticorps.g.dart';

@HiveType(typeId: 1)
class Anticorps {
  @HiveField(0)
  final String nom;

  @HiveField(1)
  int pv;

  @HiveField(2)
  final String typeAttaque;

  @HiveField(3)
  int degats;

  @HiveField(4)
  final int coutRessources;

  @HiveField(5)
  final int tempsProduction; // en secondes

  Anticorps({
    required this.nom,
    required this.pv,
    required this.typeAttaque,
    required this.degats,
    required this.coutRessources,
    required this.tempsProduction,
  });

  /// Méthode de l'attaque spéciale de l'anticorps.
  /// L'attaque spéciale est choisie aléatoirement entre :
  /// - SalvoToxique (1.5x les dégâts),
  /// - RéparationCellulaire (soin de 20 points, n'inflige aucun dégât),
  /// - MarquagePrioritaire (1.7x les dégâts).
  int specialAttack() {
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
}