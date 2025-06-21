import 'package:dio/dio.dart';

class GeminiService {
  final Dio _dio = Dio();


  final String _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=AIzaSyCAv5j8Mm1NyVTqfdjxmGM3i9CIsp2LtnU'; // <-- Remplacez par votre VRAIE clé

  /// Appelle l'endpoint externe pour générer le briefing tactique.
  Future<String> fetchBriefing(String battleData) async {
    try {
      // Construire un corps de requête conforme aux spécifications de l'API Gemini.
      final Map<String, dynamic> requestBody = {
        "contents": [
          {
            "parts": [
              {
                "text":
                "Analyse cette bataille et génère un briefing tactique détaillé. Limite la réponse à environ 200 mots : $battleData" // J'ai ajouté une instruction de limite pour être sûr
              }
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.7,
          "maxOutputTokens": 200, // Cette limite peut être ignorée par le modèle s'il pense que la réponse est incomplète. L'instruction dans le prompt est souvent plus efficace.
          // Vous pouvez ajouter d'autres paramètres selon vos besoins, par exemple "topP", "topK", etc.
        },
        // Vous pouvez ajouter d'autres paramètres globaux ici comme "safetySettings"
      };

      final response = await _dio.post(
        _endpoint,
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        // La réponse de Gemini est dans 'candidates[0]['content']['parts'][0]['text']'
        final candidates = response.data['candidates'];
        if (candidates != null && candidates.isNotEmpty) {
          final firstCandidate = candidates[0];
          final content = firstCandidate['content'];
          if (content != null && content['parts'] != null && content['parts'].isNotEmpty) {
            final textPart = content['parts'][0];
            if (textPart != null && textPart['text'] != null) {
              return textPart['text'];
            }
          }
        }
        return 'Aucune chronique générée ou format de réponse inattendu.';
      } else {
        // Gérez les erreurs API, y compris les codes 400, 401, 403, 429, etc.
        // Inclure plus de détails de l'erreur si disponibles dans response.data
        String errorDetails = response.data != null ? " Détails: ${response.data.toString()}" : "";
        return "Erreur API: Code ${response.statusCode}$errorDetails";
      }
    } catch (e) {
      // Gérez les erreurs réseau ou autres exceptions avant la réponse HTTP
      print("Erreur lors de l'appel à l'API externe: $e"); // Pour le débogage
      return "Erreur lors de l'appel à l'API externe: $e";
    }
  }
}