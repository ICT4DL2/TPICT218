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
  }) : super(
    nom: "Bactérie",
    pv: pv,
    armure: armure,
    typeAttaque: "perforante",
    degats: degats,
    initiative: initiative,
  );

  @override
  int specialAttack() {
    int specialDamage = (degats * 1.3).toInt();
    print("$nom active BouclierBiofilm et inflige $specialDamage dégâts.");
    return specialDamage;
  }
}
