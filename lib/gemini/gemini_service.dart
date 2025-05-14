// lib/gemini/gemini_service.dart
import 'package:cloud_functions/cloud_functions.dart';

class GeminiService {
  // Crée une référence à la fonction callable
  final HttpsCallable _generateBriefingCallable =
  FirebaseFunctions.instance.httpsCallable('generateGeminiBriefing');

  /// Appelle la fonction Firebase pour générer le briefing tactique.
  Future<String> fetchBriefing(String battleData) async {
    try {
      final result = await _generateBriefingCallable.call({
        'battleData': battleData,
      });
      // La fonction renvoie un objet avec "output" contenant le briefing.
      return result.data['output'] ?? 'Aucune chronique générée.';
    } catch (e) {
      return "Erreur lors de l'appel à Gemini via Firebase Functions: $e";
    }
  }
}