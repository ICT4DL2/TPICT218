// lib/combat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'gemini/briefing_widget.dart'; // Assurez-vous que le chemin est correct
import 'models/game_state.dart';

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
          // Partie supérieure : Arène de combat (70 % de la hauteur)
          Expanded(
            flex: 7,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black45, width: 4),
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [Colors.grey.shade300, Colors.grey.shade500],
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
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.0),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.sports_martial_arts,
                          size: 80,
                          color: Colors.black38,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Partie inférieure : Zone de Briefing via Gemini (30 % de la hauteur)
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