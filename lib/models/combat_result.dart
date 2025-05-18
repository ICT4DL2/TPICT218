// lib/models/combat_result.dart
import 'package:hive/hive.dart'; // Importe Hive

part 'combat_result.g.dart'; // Nécessaire pour la génération Hive

/// Représente le résultat d'une simulation de combat.
@HiveType(typeId: 20) // --- NOUVEAU : Ajoute un Type ID unique pour CombatResult ---
class CombatResult {
  /// Indique si le joueur a gagné le combat.
  @HiveField(0)
  final bool playerWon;

  /// Résumé textuel du combat, potentiellement pour Gemini.
  @HiveField(1)
  final String battleSummaryForGemini;

  /// Récompenses obtenues après le combat.
  @HiveField(2)
  final Map<String, dynamic> rewards;

  /// Types de pathogènes vaincus (pour la mémoire immunitaire).
  @HiveField(3)
  final Set<String> defeatedPathogenTypes;

  // Informations sur l'adversaire
  @HiveField(4)
  final String opponentIdentifier; // Ex: "Machine", email de l'adversaire PvP
  @HiveField(5)
  final String opponentType; // Ex: "PNJ", "PvP"


  /// Constructeur pour créer un résultat de combat.
  CombatResult({
    required this.playerWon,
    required this.battleSummaryForGemini,
    required this.rewards,
    required this.defeatedPathogenTypes,
    required this.opponentIdentifier,
    required this.opponentType,
  });
}
