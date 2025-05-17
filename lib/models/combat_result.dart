// lib/models/combat_result.dart

/// Représente le résultat d'une simulation de combat.
class CombatResult {
  /// Indique si le joueur a gagné le combat.
  final bool playerWon;

  /// Résumé textuel du combat, potentiellement pour Gemini.
  final String battleSummaryForGemini;

  // --- NOUVEAU : Récompenses obtenues après le combat ---
  final Map<String, dynamic> rewards;

  // --- NOUVEAU : Types de pathogènes vaincus (pour la mémoire immunitaire) ---
  final Set<String> defeatedPathogenTypes;


  /// Constructeur pour créer un résultat de combat.
  CombatResult({
    required this.playerWon,
    required this.battleSummaryForGemini,
    // --- NOUVEAU : Ajoute les paramètres rewards et defeatedPathogenTypes ---
    required this.rewards,
    required this.defeatedPathogenTypes,
  });
}
