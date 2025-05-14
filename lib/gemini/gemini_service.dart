import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:dio/dio.dart';
import 'package:googleapis_auth/auth_io.dart';

class GeminiService {
  final Dio _dio = Dio();
  ServiceAccountCredentials? _credentials;
  static const String _endpoint =
      'https://generativelanguage.googleapis.com/v1/models/text-bison-001:generateText';
  static const List<String> _scopes =
  ['https://www.googleapis.com/auth/cloud-platform'];

  /// Initialise les credentials du compte de service à partir du fichier JSON.
  Future<void> _initCredentials() async {
    if (_credentials != null) return;
    final jsonStr = await rootBundle.loadString('assets/service_account.json');
    _credentials = ServiceAccountCredentials.fromJson(jsonDecode(jsonStr));
  }

  /// Envoie une requête à l'API Gemini/PaLM pour générer une chronique tactique.
  Future<String> fetchBriefing(String battleData) async {
    // Chargement des credentials si nécessaire
    await _initCredentials();

    // Obtention d'un client OAuth2 basé sur le compte de service
    final client = await clientViaServiceAccount(_credentials!, _scopes);
    final accessToken = client.credentials.accessToken.data;

    try {
      final response = await _dio.post(
        _endpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'prompt': {
            'text':
            'Analyse cette bataille et génère une chronique immersive : $battleData'
          },
          'temperature': 0.7,
          'maxOutputTokens': 200,
        },
      );

      if (response.statusCode == 200) {
        return response.data['candidates']?[0]?['output']
            ?? 'Aucune chronique générée.';
      } else {
        throw Exception('Erreur Gemini: Code ${response.statusCode}');
      }
    } catch (e) {
      return "Erreur lors de l'appel à Gemini: $e";
    } finally {
      client.close();
    }
  }
}
