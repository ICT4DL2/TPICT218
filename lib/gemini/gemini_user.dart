// lib/gemini/gemini_user.dart
class GeminiUser {
  final String userId;
  final String preferredLanguage;
  final String tone; // Par exemple, 'tactique', 'décontracté', etc.

  GeminiUser({
    required this.userId,
    this.preferredLanguage = 'fr',
    this.tone = 'tactique',
  });

  // Conversion en JSON pour l'envoi dans l'appel API.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'preferredLanguage': preferredLanguage,
      'tone': tone,
    };
  }
}