import 'package:hive/hive.dart';
import 'agent_pathogene.dart';
part 'champignon.g.dart';

@HiveType(typeId: 3)
class Champignon extends AgentPathogene {
  @HiveField(6)
  bool invisible = false;

  Champignon({
    required int pv,
    required double armure,
    required int degats,
    required int initiative,
  }) : super(
    nom: "Champignon",
    pv: pv,
    armure: armure,
    typeAttaque: "toxique",
    degats: degats,
    initiative: initiative,
  );

  @override
  int specialAttack() {
    invisible = true;
    print("$nom active InvisibilitySporadique et devient invisible.");
    return degats;
  }
}