import 'package:hive/hive.dart';

abstract class AgentPathogene {
  @HiveField(0)
  final String nom;

  @HiveField(1)
  int pv;

  @HiveField(2)
  double armure;

  @HiveField(3)
  final String typeAttaque;

  @HiveField(4)
  int degats;

  @HiveField(5)
  int initiative;

  // Nouveau champ "customType" (ou vous pouvez le nommer autrement selon vos besoins).
  @HiveField(8)
  String? customType;

  AgentPathogene({
    required this.nom,
    required this.pv,
    required this.armure,
    required this.typeAttaque,
    required this.degats,
    required this.initiative,
    this.customType, // Paramètre optionnel qui permet de stocker un type personnalisé.
  });

  /// Retourne la valeur de dégâts obtenue lors de l'attaque spéciale.
  int specialAttack();
}