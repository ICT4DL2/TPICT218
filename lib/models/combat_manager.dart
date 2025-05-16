// lib/models/combat_manager.dart

import 'agent_pathogene.dart'; // Importe la classe de base des pathogènes
import 'anticorps.dart'; // Importe la classe des anticorps
import 'base_virale.dart'; // Importe la classe BaseVirale
import 'combat_result.dart'; // Importe notre nouvelle classe de résultat
import 'dart:math'; // Pour les calculs aléatoires (initiative, ciblage, capacité spéciale)

/// Gère la simulation d'un combat entre les anticorps du joueur et une base virale ennemie.
class CombatManager {

  /// Simule un combat et retourne le résultat.
  /// Prend en entrée l'équipe d'anticorps du joueur et la base virale ennemie.
  CombatResult simulateCombat(List<Anticorps> playerTeam, BaseVirale enemyBase) {
    // Création de listes modifiables pour le combat.
    // Nous travaillons sur des copies pour ne pas modifier les objets originaux directement avant la résolution.
    List<Anticorps> currentAnticorps = List.from(playerTeam);
    List<AgentPathogene> currentPathogens = List.from(enemyBase.agents);

    // Journal des événements du combat.
    List<String> combatLog = [];
    combatLog.add("--- Début du Combat ---"); // Ajoute un message de début au journal

    // Phase de préparation : Combiner toutes les unités et déterminer l'ordre d'action.
    // Chaque unité (Anticorps ou Pathogène) est un "combattant".
    List<dynamic> combatants = [...currentAnticorps, ...currentPathogens]; // Combine les deux listes
    // Trier les combattants par initiative (du plus élevé au plus bas).
    combatants.sort((a, b) => b.initiative.compareTo(a.initiative)); // La méthode compareTo est pratique pour trier

    int turn = 1; // Compteur de tours

    // Boucle principale du combat : Continue tant qu'il y a des unités des deux côtés.
    while (currentAnticorps.isNotEmpty && currentPathogens.isNotEmpty && turn <= 100) { // Ajout d'une limite de tours pour éviter les boucles infinies
      combatLog.add("\n--- Tour $turn ---"); // Message pour le début du tour

      // Chaque combattant agit dans l'ordre de l'initiative.
      for (var combatant in List.from(combatants)) { // Utilise une copie pour éviter les problèmes si des unités sont retirées pendant le tour
        // Vérifie si le combattant est toujours en vie.
        if ((combatant is Anticorps && currentAnticorps.contains(combatant)) ||
            (combatant is AgentPathogene && currentPathogens.contains(combatant))) {

          // --- Logique d'action pour l'Anticorps ---
          if (combatant is Anticorps) {
            // Choisir une cible pathogène aléatoire.
            if (currentPathogens.isEmpty) continue; // S'il n'y a plus d'ennemis, cet anticorps ne fait rien.
            AgentPathogene target = currentPathogens[Random().nextInt(currentPathogens.length)]; // Sélection aléatoire

            // Décider si l'attaque spéciale est utilisée (par exemple, 25% de chance).
            bool useSpecial = Random().nextDouble() < 0.25; // Génère un nombre entre 0.0 et 1.0

            int damageDealt = 0; // Dégâts infligés pendant cette action

            if (useSpecial) {
              damageDealt = combatant.specialAttack(); // Appelle la méthode specialAttack de l'anticorps
              // La méthode specialAttack de l'anticorps peut gérer les soins ou d'autres effets.
              // Pour les dégâts, elle retourne la valeur calculée.
              // Pour les soins, elle retourne 0.
              if (damageDealt > 0) {
                // Si l'attaque spéciale inflige des dégâts, l'appliquer à la cible.
                double effectiveDamage = damageDealt - target.armure; // Réduit les dégâts par l'armure de la cible
                effectiveDamage = effectiveDamage > 0 ? effectiveDamage : 1; // S'assure que les dégâts sont au moins 1
                target.pv -= effectiveDamage.toInt(); // Applique les dégâts à la cible
                combatLog.add("${combatant.nom} utilise sa capacité spéciale '${_getAnticorpsSpecialName(combatant)}' et inflige ${effectiveDamage.toInt()} dégâts à ${target.customType ?? target.nom}. ${target.customType ?? target.nom} a ${target.pv.toInt()} PV restants.");
              } else {
                // Si c'est une capacité spéciale sans dégâts (comme un soin), le log est géré dans la méthode specialAttack elle-même actuellement,
                // mais on pourrait vouloir un log ici pour plus de cohérence.
                // Exemple: combatLog.add("${combatant.nom} utilise sa capacité spéciale '${_getAnticorpsSpecialName(combatant)}'.");
              }

            } else {
              // Attaque normale.
              int normalDamage = combatant.degats;
              // TODO: Appliquer ici la logique de faiblesse/résistance (Type d'attaque vs Armure/Faiblesse du pathogène)
              double effectiveDamage = normalDamage - target.armure;
              effectiveDamage = effectiveDamage > 0 ? effectiveDamage : 1;
              target.pv -= effectiveDamage.toInt();
              combatLog.add("${combatant.nom} attaque ${target.customType ?? target.nom} et inflige ${effectiveDamage.toInt()} dégâts. ${target.customType ?? target.nom} a ${target.pv.toInt()} PV restants.");
            }

            // Vérifier si la cible est vaincue.
            if (target.pv <= 0) {
              combatLog.add("${target.customType ?? target.nom} a été vaincu !");
              currentPathogens.remove(target); // Retire le pathogène vaincu de la liste active
              combatants.remove(target); // Retire le pathogène vaincu de la liste des combattants
              // TODO: Ajouter la logique pour ajouter la signature à la mémoire immunitaire ici ou dans la résolution.
            }

          }
          // --- Logique d'action pour l'Agent Pathogène ---
          else if (combatant is AgentPathogene) {
            // TODO: Gérer la capacité spéciale du pathogène si elle est active et doit se déclencher ici.
            // Les capacités actuelles (MutationRapide, BouclierBiofilm, InvisibilitySporadique)
            // ne retournent pas directement les dégâts de l'attaque spéciale dans l'implémentation actuelle,
            // et leur effet (changer faiblesse, bouclier, invisibilité) devrait être géré ici
            // ou appliqué de manière passive/conditionnelle.
            // Pour l'instant, nous allons juste faire l'attaque normale.

            // Choisir une cible anticorps aléatoire.
            if (currentAnticorps.isEmpty) continue; // S'il n'y a plus d'ennemis, ce pathogène ne fait rien.
            Anticorps target = currentAnticorps[Random().nextInt(currentAnticorps.length)]; // Sélection aléatoire

            // Attaque normale.
            int normalDamage = combatant.degats;
            // TODO: Appliquer ici la logique de faiblesse/résistance (Type d'attaque du pathogène vs Armure/Faiblesse de l'anticorps)

            // Anticorps n'ont pas d'armure dans la modélisation actuelle, seulement des PV.
            // Si vous ajoutez une armure ou une résistance aux anticorps, ajoutez la déduction ici.
            double effectiveDamage = normalDamage.toDouble(); // Dégâts effectifs = dégâts de base pour l'instant
            effectiveDamage = effectiveDamage > 0 ? effectiveDamage : 1; // S'assure que les dégâts sont au moins 1
            target.pv -= effectiveDamage.toInt(); // Applique les dégâts à la cible
            combatLog.add("${combatant.customType ?? combatant.nom} attaque ${target.nom} et inflige ${effectiveDamage.toInt()} dégâts. ${target.nom} a ${target.pv.toInt()} PV restants.");


            // Vérifier si la cible est vaincue.
            if (target.pv <= 0) {
              combatLog.add("${target.nom} a été vaincu !");
              currentAnticorps.remove(target); // Retire l'anticorps vaincu de la liste active
              combatants.remove(target); // Retire l'anticorps vaincu de la liste des combattants
            }
          }
        }
      }

      // Incrémenter le tour.
      turn++;

      // Condition de fin de combat (au cas où la boucle while ne la détecte pas immédiatement après une élimination).
      if (currentAnticorps.isEmpty || currentPathogens.isEmpty) {
        break; // Sort de la boucle si un camp est éliminé
      }
    }

    // --- Fin du Combat : Phase de Résolution ---
    combatLog.add("\n--- Fin du Combat ---"); // Message de fin

    bool playerWon = currentPathogens.isEmpty; // Le joueur gagne si tous les pathogènes sont vaincus.

    if (playerWon) {
      combatLog.add("Victoire ! Tous les agents pathogènes ont été éliminés.");
      // TODO: Calculer et appliquer les récompenses.
      // TODO: Mettre à jour la mémoire immunitaire avec les types de pathogènes vaincus.
    } else {
      combatLog.add("Défaite. Vos anticorps ont été submergés.");
      // TODO: Gérer les conséquences de la défaite (par exemple, perdre des ressources, subir des dégâts à la base).
    }

    // Créer le résumé pour Gemini.
    // C'est ici que nous allons construire une chaîne qui décrit le combat
    // d'une manière utile pour l'IA. Pour l'instant, c'est simple.
    String battleSummaryForGemini = "Combat simulé terminé. Résultat : ${playerWon ? 'Victoire' : 'Défaite'}.\n";
    battleSummaryForGemini += "Journal de combat :\n" + combatLog.join("\n"); // Joint toutes les lignes du journal

    // Retourner le résultat du combat.
    return CombatResult(
      playerWon: playerWon,
      combatLog: combatLog,
      battleSummaryForGemini: battleSummaryForGemini,
      // rewards: {...}, // Ajouter les récompenses quand implémentées
      // defeatedPathogenTypes: [...], // Ajouter les types vaincus quand implémentés
    );
  }

  // Petite fonction utilitaire pour obtenir le nom de la capacité spéciale de l'anticorps
  // car l'implémentation actuelle choisit aléatoirement DANS la méthode specialAttack elle-même.
  // Idéalement, la décision de la capacité devrait être prise AVANT l'appel, et la méthode specialAttack
  // devrait juste exécuter l'effet de la capacité choisie.
  // Pour l'instant, on simule en donnant un nom générique ou en adaptant si possible.
  String _getAnticorpsSpecialName(Anticorps anti) {
    // Cette fonction est simplifiée et ne peut pas savoir exactement QUELLE capacité a été utilisée
    // si specialAttack décide aléatoirement. C'est une limitation de la conception actuelle.
    // Pour une meilleure implémentation, specialAttack devrait prendre un paramètre indiquant quelle capacité utiliser,
    // et la décision (aléatoire ou basée sur une IA simple) devrait se faire dans CombatManager.
    // Pour l'instant, on retourne un nom générique.
    return "Capacité Spéciale"; // Nom générique
    // Si specialAttack retournait une indication du type de capacité (ex: un enum), on pourrait utiliser ça.
  }

// TODO: Implémenter la logique de faiblesse/résistance (section 3.8 du TP).
// Cela nécessitera de définir les interactions entre les types d'attaque et les types/faiblesses des unités.
// Par exemple, une fonction comme :
/*
   double calculateEffectiveDamage(int baseDamage, String attackType, dynamic target) {
       double multiplier = 1.0;
       String targetDefenseType = ""; // Ex: le type du pathogène, ou la faiblesse de l'anticorps

       // Déterminer le type de défense/faiblesse de la cible
       if (target is AgentPathogene) {
           // Assumer que le typePathogene est la faiblesse ou le type de résistance
           targetDefenseType = target.typeAttaque; // Ou une propriété 'faiblesse' spécifique si ajoutée
           // TODO: Gérer les effets de la capacité spéciale du pathogène (ex: BouclierBiofilm, Invisibility) qui affectent la défense ici
       } else if (target is Anticorps) {
           // Assumer que le type d'attaque de l'anticorps est sa faiblesse ? Ou ajouter une propriété faiblesse ?
           // Le TP dit "Type d'Attaque (correspondant aux faiblesses pathogènes)" pour les anticorps,
           // ce qui suggère que l'anticorps d'un certain type EST le contre à la faiblesse du pathogène.
           // Donc, la faiblesse/résistance s'applique quand le pathogène attaque l'anticorps, basé sur le type d'attaque du pathogène.
           // Par exemple, un anticorps "Anti-Perforante" pourrait avoir une résistance aux attaques "perforante".
           // Ceci n'est pas encore modélisé dans Anticorps. Pour l'instant, pas de faiblesse/résistance pour Anticorps.
       }

       // Logique d'interaction (exemple simple)
       // if (attackType == "corrosive" && targetDefenseType == "Blindé") multiplier = 0.5;
       // if (attackType == "perforante" && targetDefenseType == "Mou") multiplier = 1.5;

       // L'idée serait de définir une map ou une table d'interactions :
       // Map<String, Map<String, double>> interactionTable = {
       //   "corrosive": {"Faible_Corrosion": 1.5, "Resistant_Corrosion": 0.5, ...},
       //   "perforante": {...},
       //   ...
       // };
       // multiplier = interactionTable[attackType]?[targetDefenseType] ?? 1.0;


       double effectiveDamage = baseDamage * multiplier - target.armure; // Soustraire l'armure APRES le multiplicateur

       return effectiveDamage > 0 ? effectiveDamage : 1;
   }
   */
}