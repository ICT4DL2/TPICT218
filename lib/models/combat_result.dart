// lib/models/combat_result.dart

/// Représente le résultat d'un combat simulé.
class CombatResult {
  // Indique si le joueur a gagné le combat.
  final bool playerWon;

  // Liste des actions ou événements survenus pendant le combat, pour le journal.
  final List<String> combatLog;

  // Un résumé structuré du combat, destiné à être envoyé à l'IA Gemini.
  final String battleSummaryForGemini;

  // Placeholders pour les récompenses (ressources, points de recherche, etc.)
  // Nous pourrons les ajouter plus tard selon les mécaniques exactes.
  // final Map<String, dynamic> rewards;

  // Placeholders pour les mises à jour de la mémoire immunitaire.
  // final List<String> defeatedPathogenTypes;


  CombatResult({
    required this.playerWon, // Le joueur a-t-il gagné ?
    required this.combatLog, // Le journal complet du combat
    required this.battleSummaryForGemini, // Le résumé pour Gemini
    // this.rewards = const {}, // Les récompenses gagnées
    // this.defeatedPathogenTypes = const [], // Types de pathogènes vaincus
  });
}