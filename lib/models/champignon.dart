import 'package:hive/hive.dart';
import 'agent_pathogene.dart';
part 'champignon.g.dart';

@HiveType(typeId: 3)
class Champignon extends AgentPathogene {
  // --- CORRECTION : Numéro de champ HiveField mis à jour pour éviter le conflit ---
  // AgentPathogene utilise maintenant les champs 0 à 9. Ce champ doit commencer à 10.
  @HiveField(10)
  bool invisible = false;

  Champignon({
    required int pv,
    required double armure,
    required int degats,
    required int initiative,
    // L'ID, le niveau et la mutation sont dans AgentPathogene et assignés par GameState.
    // bool? invisible, // Le champ invisible peut être passé si nécessaire
    // String? customType, // Le customType peut être passé si nécessaire
  }) : super(
    nom: "Champignon",
    pv: pv,
    armure: armure,
    typeAttaque: "toxique", // Défini ici pour Champignon
    degats: degats,
    initiative: initiative,
    // customType: customType, // Passe le customType au parent si nécessaire
  )
  // : this.invisible = invisible ?? false; // Assigne la valeur du paramètre si passé
      ; // Constructeur mis à jour

  @override
  int specialAttack() {
    // TODO: Vérifier si l'attaque spéciale est débloquée (level >= 5).
    if (level < 5) {
      print("$nom (Niv $level) tente une attaque spéciale, mais elle n'est pas encore débloquée.");
      return degats; // Ou une autre logique
    }
    // Logique de l'attaque spéciale si débloquée
    invisible = true; // L'effet de l'attaque spéciale
    print("$nom (Niv $level) active InvisibilitySporadique et devient invisible.");
    return degats; // L'attaque spéciale inflige aussi des dégâts normaux ici
  }

// TODO: Implémenter applyLevelStats si nécessaire pour des bonus spécifiques à Champignon
}
