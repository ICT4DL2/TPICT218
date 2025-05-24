import 'package:flutter/material.dart';
import 'gemini_service.dart';

class BriefingWidget extends StatelessWidget {
  final String battleData; // Paramètre obligatoire pour la bataille

  const BriefingWidget({super.key, required this.battleData});

  @override
  Widget build(BuildContext context) {
    GeminiService geminiService = GeminiService();
    return FutureBuilder<String>(
      future: geminiService.fetchBriefing(battleData),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Erreur: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("Aucun briefing disponible."));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Briefing Tactique",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8.0),
              Text(
                snapshot.data!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        );
      },
    );
  }
}