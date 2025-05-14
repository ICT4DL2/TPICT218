// lib/gemini/gemini_service.dart
import 'package:dio/dio.dart';

class GeminiService {
  final Dio _dio = Dio();

  // Remplacez cette URL par l'URL publique de votre fonction Netlify.
  // Par exemple, si votre site Netlify s'appelle "immunowariors", utilisez :
  // https://immunowariors.netlify.app/.netlify/functions/generateGeminiBriefing
  final String _endpoint =
      'https://immunowariors.netlify.app/.netlify/functions/generateGeminiBriefing';

  /// Appelle l'endpoint Netlify pour générer le briefing tactique.
  Future<String> fetchBriefing(String battleData) async {
    try {
      final response = await _dio.post(
        _endpoint,
        data: {'battleData': battleData},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      if (response.statusCode == 200) {
        return response.data['output'] ?? 'Aucune chronique générée.';
      } else {
        return "Erreur Gemini: Code ${response.statusCode}";
      }
    } catch (e) {
      return "Erreur lors de l'appel à Gemini via l'endpoint: $e";
    }
  }
}