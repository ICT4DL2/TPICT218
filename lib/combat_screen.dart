// lib/combat_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';


import 'gemini/briefing_widget.dart';
import 'models/game_state.dart';
import 'package:uuid/uuid.dart';

import 'models/bacterie.dart';
import 'models/champignon.dart';
import 'models/virus.dart';
import 'models/base_virale.dart';
import 'models/agent_pathogene.dart';


class RadarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

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

    final Paint linePaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), linePaint);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), linePaint);
    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), linePaint);
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

  bool _isSearchingPvP = false;
  BaseVirale? _foundEnemyBase;
  String? _foundEnemyEmail;
  String _pvpStatusMessage = "Prêt pour le combat.";


  BaseVirale _createTestEnemyBase() {
    BaseVirale testBase = BaseVirale(nom: "Base PNJ Facile");

    testBase.ajouterAgent(Bacterie(pv: 80, armure: 5.0, degats: 15, initiative: 6));
    testBase.ajouterAgent(Bacterie(pv: 70, armure: 4.0, degats: 18, initiative: 7));
    testBase.ajouterAgent(Bacterie(pv: 90, armure: 6.0, degats: 12, initiative: 5));

    final Uuid uuid = Uuid();
    for (var agent in testBase.agents) {
      agent.id = uuid.v4();
      agent.level = 1;
      agent.mutationLevel = 0;
    }

    return testBase;
  }

  void _startPvPSearch() {
    if (_isSearchingPvP) return;

    setState(() {
      _isSearchingPvP = true;
      _foundEnemyBase = null;
      _foundEnemyEmail = null;
      _pvpStatusMessage = "Recherche d'adversaire en cours...";
    });

    Timer(const Duration(seconds: 3), () {
      BaseVirale foundOpponentBase = _createTestEnemyBase();
      String opponentEmail = "adversaire_simule@example.com";

      setState(() {
        _isSearchingPvP = false;
        _foundEnemyBase = foundOpponentBase;
        _foundEnemyEmail = opponentEmail;
        _pvpStatusMessage = "Adversaire trouvé : ${foundOpponentBase.nom}";
      });

      _startCombat(_foundEnemyBase!, opponentIdentifier: _foundEnemyEmail!, opponentType: "PvP");
    });
  }

  void _startCombat(BaseVirale enemyBase, {String opponentIdentifier = "Machine", String opponentType = "PNJ"}) {
    final gameStateActions = ref.read(gameStateProvider);

    if (gameStateActions.playerAnticorps.isEmpty) {
      setState(() {
        _pvpStatusMessage = "Impossible de lancer le combat : Vous n'avez pas d'anticorps !";
        _foundEnemyEmail = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible de lancer le combat : Vous n'avez pas d'anticorps !")),
      );
      return;
    }

    gameStateActions.startBattle(
      enemyBase,
      opponentIdentifier: opponentIdentifier,
      opponentType: opponentType,
    );

    setState(() {
      _pvpStatusMessage = opponentType == "PvP"
          ? "Combat contre $opponentIdentifier en cours..."
          : "Combat contre la Machine en cours...";
      _foundEnemyBase = null;
    });
  }


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
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: CustomPaint(
                          painter: RadarPainter(),
                        ),
                      ),

                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Text(
                            _pvpStatusMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.greenAccent,
                              shadows: [
                                Shadow(
                                  blurRadius: 8.0,
                                  color: Colors.black,
                                  offset: Offset(1.0, 1.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: _isSearchingPvP ? null : () {
                                  BaseVirale enemy = _createTestEnemyBase();
                                  _startCombat(enemy);
                                },
                                child: const Text("Jouer contre la Machine (PNJ)"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueGrey,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  textStyle: const TextStyle(fontSize: 16),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _isSearchingPvP ? null : _startPvPSearch,
                                child: Text(_isSearchingPvP ? "Recherche..." : "Chercher Joueur en Ligne (PvP)"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(vertical: 12)),
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.home),
          label: const Text("Accueil"),
        ),
      ),
    );
  }
}
