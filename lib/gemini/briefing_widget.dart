import 'package:flutter/material.dart';
import 'gemini_service.dart';

class BriefingWidget extends StatelessWidget {
  final String battleData; // Ajout du paramètre obligatoire

  const BriefingWidget({Key? key, required this.battleData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GeminiService geminiService = GeminiService();
    return FutureBuilder<String>(
      future: geminiService.fetchBriefing(battleData), // Ajout du paramètre battleData
      builder: (context, snapshot) {
        // Affichage d'une barre de chargement pendant l'attente de la réponse
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // Gestion des erreurs lors de l'appel à Gemini
        if (snapshot.hasError) {
          return Center(child: Text("Erreur: ${snapshot.error}"));
        }
        // En l'absence de données ou données nulles
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("Aucun briefing disponible."));
        }
        // Affichage du briefing tactique une fois la donnée reçue
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Briefing Tactique",
                style: Theme.of(context).textTheme.titleLarge, // Utilisation de titleLarge à la place de headline6
              ),
              const SizedBox(height: 8.0),
              Text(
                snapshot.data!,
                style: Theme.of(context).textTheme.bodyLarge, // Utilisation de bodyLarge à la place de bodyText1
              ),
            ],
          ),
        );
      },
    );
  }
}