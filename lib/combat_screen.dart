// lib/combat_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'gemini/briefing_widget.dart'; // Assurez-vous que le chemin est correct
import 'models/game_state.dart';

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

class CombatScreen extends ConsumerStatefulWidget {
  const CombatScreen({Key? key}) : super(key: key);

  @override
  _CombatScreenState createState() => _CombatScreenState();
}

class _CombatScreenState extends ConsumerState<CombatScreen> {
  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final String battleData = gameState.battleData;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Combat"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Partie supérieure : Arène de combat réinventée en écran radar
          Expanded(
            flex: 7,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                decoration: BoxDecoration(
                  // L'arène reste carrée avec des coins arrondis
                  border: Border.all(color: Colors.black45, width: 4),
                  borderRadius: BorderRadius.circular(16),
                  // Gradient pour un fond "noir clair"
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
                  child: AspectRatio(
                    aspectRatio: 1,
                    // CustomPaint qui dessine les éléments du radar
                    child: CustomPaint(
                      painter: RadarPainter(),
                    ),
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
              child: BriefingWidget(battleData: battleData),
            ),
          ),
        ],
      ),
    );
  }
}