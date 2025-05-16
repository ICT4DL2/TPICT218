// lib/combat_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Importe les widgets ou modèles nécessaires
import 'gemini/briefing_widget.dart'; // Assurez-vous que le chemin est correct
import 'models/game_state.dart'; // Importe le GameStateProvider

// Importe les modèles pour créer la base ennemie de test (PNJ)
import 'models/bacterie.dart'; // Importe un type de pathogène concret
import 'models/champignon.dart'; // Importe Champignon si utilisé dans _createTestEnemyBase
import 'models/virus.dart'; // Importe Virus si utilisé dans _createTestEnemyBase
import 'models/base_virale.dart'; // Importe la classe BaseVirale


/// CustomPainter pour dessiner des carrés concentriques et des lignes radiales
/// en vert accentué, simulant un écran de radar sur un fond carré.
class RadarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Dessin de trois carrés concentriques
    final Paint squarePaint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    int numSquares = 3;
    for (int i = 1; i <= numSquares; i++) {
      double inset = (size.width / 2) * (i / (numSquares + 1));
      Rect rect = Rect.fromLTWH(
        inset,
        inset,
        size.width - 2 * inset,
        size.height - 2 * inset,
      );
      canvas.drawRect(rect, squarePaint);
    }

    // Dessin des lignes centrales et diagonales en vert accentué
    final Paint linePaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 2.0;
    // Ligne verticale
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), linePaint);
    // Ligne horizontale
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), linePaint);
    // Diagonale de gauche à droite
    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), linePaint);
    // Diagonale de droite à gauche
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


/// Écran de combat (Holo-Simulateur de Combat) où la simulation est lancée et le briefing affiché.
class CombatScreen extends ConsumerStatefulWidget {
  const CombatScreen({Key? key}) : super(key: key);

  @override
  _CombatScreenState createState() => _CombatScreenState();
}

/// L'état mutable de l'écran CombatScreen.
class _CombatScreenState extends ConsumerState<CombatScreen> {

  /// Méthode utilitaire pour créer une base ennemie de test simple (PNJ).
  /// Cette base sera utilisée pour les combats "contre la machine".
  BaseVirale _createTestEnemyBase() {
    BaseVirale testBase = BaseVirale(nom: "Base PNJ Facile");

    // Ajoute quelques pathogènes de test à la base PNJ.
    // --- CORRECTION : Retire typeAttaque du constructeur Bacterie ---
    // Le typeAttaque ("perforante") est défini dans le constructeur Bacterie lui-même.
    testBase.ajouterAgent(Bacterie(pv: 80, armure: 5.0, degats: 15, initiative: 6));
    testBase.ajouterAgent(Bacterie(pv: 70, armure: 4.0, degats: 18, initiative: 7));
    testBase.ajouterAgent(Bacterie(pv: 90, armure: 6.0, degats: 12, initiative: 5));

    // Exemple pour d'autres types si vous les ajoutez (ajustez selon leurs constructeurs) :
    // testBase.ajouterAgent(Champignon(pv: 60, armure: 3.0, degats: 25, initiative: 8)); // Si Champignon définit son typeAttaque
    // testBase.ajouterAgent(Virus(pv: 50, armure: 2.0, degats: 30, initiative: 9)); // Si Virus définit son typeAttaque

    return testBase;
  }

  @override
  Widget build(BuildContext context) {
    // ref.watch écoute les changements du GameState pour reconstruire le widget
    final gameState = ref.watch(gameStateProvider);
    final String battleData = gameState.battleData; // Le BriefingWidget lit cette donnée

    // ref.read est utilisé pour accéder à l'état (ou appeler des méthodes sur l'état)
    final gameStateActions = ref.read(gameStateProvider); // Obtenir une référence pour les actions

    return Scaffold(
      appBar: AppBar(
        title: const Text("Combat"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Partie supérieure : Arène de combat (écran radar) avec les boutons superposés.
          Expanded(
            flex: 7,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black45, width: 4),
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Colors.black87, Colors.black54],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  // Utilise un Stack pour superposer le radar et les boutons
                  child: Stack(
                    children: [
                      // 1. Le dessin du radar (en arrière-plan dans le Stack)
                      AspectRatio(
                        aspectRatio: 1,
                        child: CustomPaint(
                          painter: RadarPainter(),
                        ),
                      ),
                      // 2. Les boutons superposés (alignés en bas au centre du Stack)
                      Align(
                        alignment: Alignment.bottomCenter, // Aligne les boutons en bas au centre
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20.0), // Ajoute un peu de padding en bas
                          child: Column( // Utilise une colonne pour empiler les boutons
                            mainAxisSize: MainAxisSize.min, // Prend le minimum d'espace vertical
                            children: [
                              // Bouton pour lancer le combat PNJ (contre la machine).
                              ElevatedButton(
                                onPressed: () {
                                  // Créer une base ennemie de test (PNJ).
                                  BaseVirale enemy = _createTestEnemyBase();
                                  // Lancer le combat PNJ via GameState.
                                  gameStateActions.startBattle(enemy);
                                },
                                child: const Text("Jouer contre la Machine (PNJ)"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueGrey, // Couleur indicative PNJ
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  textStyle: const TextStyle(fontSize: 16),
                                ),
                              ),
                              const SizedBox(height: 12), // Espacement entre les boutons
                              // Bouton pour chercher un joueur en ligne (PvP).
                              ElevatedButton(
                                onPressed: () {
                                  // Navigue vers l'écran Scanner d'Adversaires.
                                  Navigator.pushNamed(context, '/scanner');
                                },
                                child: const Text("Chercher Joueur en Ligne (PvP)"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent, // Couleur indicative PvP
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  textStyle: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Partie inférieure : Zone de Briefing via Gemini
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              // BriefingWidget lit gameState.battleData qui est mis à jour par startBattle
              child: BriefingWidget(battleData: battleData),
            ),
          ),
        ],
      ),
    );
  }
}
