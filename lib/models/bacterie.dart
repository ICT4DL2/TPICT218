import 'package:hive/hive.dart';
import 'agent_pathogene.dart';
part 'bacterie.g.dart';

@HiveType(typeId: 2)
class Bacterie extends AgentPathogene {
  Bacterie({
    required int pv,
    required double armure,
    required int degats,
    required int initiative,
    // L'ID, le niveau et la mutation ne sont PAS passés ici.
    // String? customType, // Le customType peut être passé si nécessaire
  }) : super(
    nom: "Bactérie",
    pv: pv,
    armure: armure,
    typeAttaque: "perforante", // Défini ici pour Bacterie
    degats: degats,
    initiative: initiative,
    // customType: customType, // Passe le customType au parent si nécessaire
  );

  @override
  int specialAttack() {
    // TODO: Vérifier si l'attaque spéciale est débloquée (level >= 5).
    // Si level < 5, retourner les dégâts normaux ou 0.
    if (level < 5) {
      print("$nom (Niv $level) tente une attaque spéciale, mais elle n'est pas encore débloquée.");
      // Retourner les dégâts normaux ou une petite valeur
      return degats; // Ou une autre logique
    }
    // Logique de l'attaque spéciale si débloquée
    int specialDamage = (degats * 1.3).toInt();
    print("$nom (Niv $level) active BouclierBiofilm et inflige $specialDamage dégâts.");
    return specialDamage;
  }

// TODO: Implémenter applyLevelStats si nécessaire pour des bonus spécifiques à Bacterie
// @override
// void applyLevelStats() {
//   super.applyLevelStats(); // Appelle d'abord la logique de base
//   // Appliquer des bonus spécifiques à Bacterie si besoin
// }
}
