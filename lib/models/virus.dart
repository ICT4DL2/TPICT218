import 'package:hive/hive.dart';
import 'agent_pathogene.dart';
part 'virus.g.dart';

@HiveType(typeId: 5)
class Virus extends AgentPathogene {
  Virus({
    required int pv,
    required double armure,
    required int degats,
    required int initiative,
  }) : super(
    nom: "Virus",
    pv: pv,
    armure: armure,
    typeAttaque: "corrosive",
    degats: degats,
    initiative: initiative,
  );

  @override
  int specialAttack() {
    int specialDamage = (degats * 1.5).toInt();
    print("$nom utilise MutationRapide et inflige $specialDamage dégâts.");
    return specialDamage;
  }
}