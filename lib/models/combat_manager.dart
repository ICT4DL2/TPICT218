import 'dart:math';
import 'package:immunowariors/gemini/gemini_service.dart';
import 'anticorps.dart';
import 'agent_pathogene.dart';
import 'champignon.dart';

/// Classe qui orchestre les combats entre les anticorps du joueur et les agents pathogènes ennemis.
class CombatManager {
  final List<Anticorps> playerUnits;
  final List<AgentPathogene> enemyUnits;

  CombatManager({required this.playerUnits, required this.enemyUnits});

  /// Simule le combat et génère automatiquement un briefing via l'API Gemini.
  Future<String> simulateCombat() async {
    List<_CombatUnit> units = [];

    for (var unit in playerUnits) {
      units.add(_CombatUnit(
        name: unit.nom,
        hp: unit.pv,
        initiative: 100, // Fixe pour les anticorps
        isPlayer: true,
        attackDamage: unit.degats,
        owner: unit,
      ));
    }
    for (var enemy in enemyUnits) {
      units.add(_CombatUnit(
        name: enemy.nom,
        hp: enemy.pv,
        initiative: enemy.initiative,
        isPlayer: false,
        attackDamage: enemy.degats,
        owner: enemy,
      ));
    }

    units.sort((a, b) => b.initiative.compareTo(a.initiative));
    String combatLog = "Début du combat\n";
    int turn = 1;
    Random rand = Random();

    while (units.where((u) => u.isPlayer).isNotEmpty &&
        units.where((u) => !u.isPlayer).isNotEmpty) {
      combatLog += "\n-- Tour $turn --\n";

      for (var attacker in List<_CombatUnit>.from(units)) {
        if (attacker.hp <= 0) continue;

        bool useSpecial = rand.nextDouble() < 0.3;
        int damage = attacker.attackDamage;

        if (useSpecial) {
          if (attacker.isPlayer) {
            Anticorps a = attacker.owner as Anticorps;
            int specialDmg = a.specialAttack();
            damage = specialDmg > 0 ? specialDmg : a.degats;
            combatLog += "${attacker.name} utilise son attaque spéciale ! Dégâts : $damage.\n";
          } else {
            AgentPathogene p = attacker.owner as AgentPathogene;
            int specialDmg = p.specialAttack();
            damage = specialDmg > 0 ? specialDmg : p.degats;
            combatLog += "${attacker.name} utilise sa capacité spéciale ! Dégâts : $damage.\n";
          }
        } else {
          combatLog += "${attacker.name} attaque normalement : $damage dégâts.\n";
        }

        List<_CombatUnit> targets =
        units.where((u) => u.isPlayer != attacker.isPlayer && u.hp > 0).toList();
        if (targets.isEmpty) break;
        targets.sort((a, b) => a.hp.compareTo(b.hp));
        _CombatUnit target = targets.first;

        // Gestion de l'invisibilité des Champignons
        if (target.owner is Champignon && (target.owner as Champignon).invisible) {
          combatLog += "Mais ${target.name} est invisible, attaque échouée.\n";
          (target.owner as Champignon).invisible = false; // Perte d'invisibilité après esquive
          continue;
        }

        target.hp -= damage;
        combatLog += "Cible : ${target.name}, HP restants : ${target.hp > 0 ? target.hp : 0}\n";
        if (target.hp <= 0) {
          combatLog += "${target.name} est éliminé.\n";
        }
      }

      units = units.where((u) => u.hp > 0).toList();
      turn++;
      if (turn > 50) {
        combatLog += "\nCombat arrêté après 50 tours.\n";
        break;
      }
    }

    bool playerWon = units.any((u) => u.isPlayer);
    combatLog += "\nCombat terminé. " + (playerWon ? "Victoire !" : "Défaite !");

    // 🔥 Appel automatique à Gemini pour générer le briefing post-combat
    GeminiService gemini = GeminiService();
    String briefing = await gemini.fetchBriefing(combatLog);

    return "$combatLog\n\n🔎 **Briefing Gemini**\n$briefing";
  }
}

/// Classe interne pour gérer les unités durant le combat.
class _CombatUnit {
  String name;
  int hp;
  int initiative;
  bool isPlayer;
  int attackDamage;
  dynamic owner;

  _CombatUnit({
    required this.name,
    required this.hp,
    required this.initiative,
    required this.isPlayer,
    required this.attackDamage,
    required this.owner,
  });
}