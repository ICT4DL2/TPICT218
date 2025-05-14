import 'dart:math';
import 'package:hive/hive.dart';
import 'models/agent_pathogene.dart';
part 'default_agent_pathogene.g.dart';

@HiveType(typeId: 6)
class DefaultAgentPathogene extends AgentPathogene {
  @HiveField(6)
  final String agentType; // "A", "B", "O", "AB", ou type personnalisé.

  @HiveField(7)
  int level; // Niveau d'évolution de l'agent (pertinent pour A et pour son évolution vers AB).

  DefaultAgentPathogene({
    required String nom, // Nom personnalisé de l'antigène
    required this.agentType,
    this.level = 1,
    required int pv,
    required double armure,
    required int degats,
    required int initiative,
  }) : super(
    nom: nom,
    pv: pv,
    armure: armure,
    typeAttaque: agentType,
    degats: degats,
    initiative: initiative,
  );

  /// Bonus offensif de A contre B, proportionnel au niveau.
  int bonusAttackAgainstB() => level * 5;

  /// Bonus défensif de A contre B, proportionnel au niveau.
  int bonusDefenseAgainstB() => level * 3;

  @override
  int specialAttack() {
    int finalDamage = degats;
    if (agentType == "A") {
      print("$nom (Niveau $level) exécute son attaque spéciale contre B.");
      finalDamage += bonusAttackAgainstB();
    } else if (agentType == "B") {
      print("$nom active son attaque spéciale et génère une récupération de biomatériaux.");
    } else if (agentType == "O") {
      print("$nom se concentre sur sa défense grâce à son aptitude spéciale.");
    } else if (agentType == "AB") {
      print("$nom (évolué en AB) active ses capacités décuplées !");
      finalDamage = (degats * 2);
    } else {
      print("$nom attaque avec son aptitude spéciale personnalisée.");
    }
    return max(finalDamage, degats);
  }
}