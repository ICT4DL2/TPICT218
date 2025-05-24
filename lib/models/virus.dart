import 'package:hive/hive.dart';
import 'agent_pathogene.dart';
part 'virus.g.dart';

@HiveType(typeId: 5)
class Virus extends AgentPathogene {
  Virus({
    required super.pv,
    required super.armure,
    required super.degats,
    required super.initiative,
    // L'ID, le niveau et la mutation ne sont PAS passés ici.
    // String? customType, // Le customType peut être passé si nécessaire
  }) : super(
    nom: "Virus",
    typeAttaque: "corrosive",
    // customType: customType, // Passe le customType au parent si nécessaire
  );

  @override
  int specialAttack() {
    // TODO: Vérifier si l'attaque spéciale est débloquée (level >= 5).
    if (level < 5) {
      print("$nom (Niv $level) tente une attaque spéciale, mais elle n'est pas encore débloquée.");
      return degats; // Ou une autre logique
    }
    // Logique de l'attaque spéciale si débloquée
    int specialDamage = (degats * 1.5).toInt();
    print("$nom (Niv $level) utilise MutationRapide et inflige $specialDamage dégâts.");
    return specialDamage;
  }

// TODO: Implémenter applyLevelStats si nécessaire pour des bonus spécifiques à Virus
}
