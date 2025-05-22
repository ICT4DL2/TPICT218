// lib/screens/journal_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/game_state.dart'; // Importe GameState pour accéder aux logs de combat et niveaux
import 'models/combat_result.dart'; // Importe CombatResult pour afficher les détails
import 'dart:math';


/// Écran du Journal/Carnet.
/// Contient des sections pour le journal d'attaque et les niveaux débloqués.
class JournalScreen extends ConsumerWidget {
  const JournalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider); // Écoute les changements dans GameState

    return DefaultTabController( // Utilise DefaultTabController pour gérer les onglets
      length: 2, // Nombre d'onglets réduit à 2 (Attaque, Progression)
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Journal"),
          backgroundColor: Colors.blueGrey[900], // Couleur assortie
          bottom: const TabBar( // Barre d'onglets sous l'AppBar
            tabs: [
              Tab(text: "Attaque"),
              // Retiré l'onglet "Défense"
              Tab(text: "Progression"), // Renommé pour refléter les niveaux débloqués
            ],
          ),
        ),
        body: TabBarView( // Contenu des onglets
          children: [
            // Contenu de l'onglet Journal d'Attaque
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Journal d'Attaque", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Divider(),
                  // Affiche l'historique des attaques ici.
                  Expanded( // Utilise Expanded pour que la ListView prenne l'espace restant
                    child: gameState.attackHistory.isEmpty
                        ? const Center(child: Text("Aucune attaque enregistrée."))
                        : ListView.builder(
                      itemCount: gameState.attackHistory.length,
                      itemBuilder: (context, index) {
                        // Affiche l'historique du plus récent au plus ancien
                        final combat = gameState.attackHistory[gameState.attackHistory.length - 1 - index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: Icon(
                              combat.playerWon ? Icons.check_circle_outline : Icons.cancel_outlined,
                              color: combat.playerWon ? Colors.green : Colors.red,
                            ),
                            title: Text(
                              combat.playerWon ? "Victoire" : "Défaite",
                              style: TextStyle(fontWeight: FontWeight.bold, color: combat.playerWon ? Colors.green : Colors.red),
                            ),
                            subtitle: Text(
                              combat.opponentType == "PvP"
                                  ? "Contre ${combat.opponentIdentifier}" // Affiche l'email pour PvP (si réactivé)
                                  : "Contre la Machine", // Affiche "Machine" pour PNJ
                            ),
                            // TODO: Afficher plus de détails du combat si nécessaire (date, résumé court, etc.)
                            // trailing: Text("Résumé: ${combat.battleSummaryForGemini.substring(0, min(50, combat.battleSummaryForGemini.length))}..."), // Exemple de résumé court
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Retiré le contenu de l'onglet Journal de Défense

            // Contenu de l'onglet Progression (Niveaux Débloqués)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  const Text("Progression", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Divider(),
                  Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.local_hospital),
                      title: const Text("Système Immunitaire"),
                      trailing: Text("Niveau ${gameState.immuneSystemLevel}"),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text("Niveaux des Unités", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Divider(),
                  // Affiche les agents pathogènes du joueur
                  ...gameState.playerBaseAgents.map((agent) => Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: const Icon(Icons.bug_report), // Icône d'agent
                      title: Text(agent.nom),
                      trailing: Text("Niveau ${agent.level}"),
                    ),
                  )).toList(),
                  const SizedBox(height: 16),

                  // Affiche les anticorps du joueur
                  ...gameState.playerAnticorps.map((anti) => Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: const Icon(Icons.verified_user), // Icône d'anticorps
                      title: Text(anti.nom),
                      subtitle: Text("Spécialisation: ${anti.specialization ?? 'Aucune'}"),
                      trailing: Text("Niveau ${anti.level}"),
                    ),
                  )).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
