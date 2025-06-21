// lib/combat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:math';

import 'models/game_state.dart';
import 'models/agent_pathogene.dart';
import 'models/bacterie.dart';
import 'models/base_virale.dart';
import 'models/anticorps.dart';
import 'gemini/briefing_widget.dart';

/// Écran de combat où les agents pathogènes attaquent une base virale défendue par des anticorps.
class CombatScreen extends ConsumerStatefulWidget {
  const CombatScreen({super.key});

  @override
  _CombatScreenState createState() => _CombatScreenState();
}

class _CombatScreenState extends ConsumerState<CombatScreen>
    with SingleTickerProviderStateMixin {
  BaseVirale? _enemyBase;
  List<AgentPathogene> _selectedUnits = [];
  bool _showBriefing = false;
  String _battleSummary = '';

  late AnimationController _animController;
  Timer? _combatTimer;
  bool _showEffect = false;

  late List<double> _attackerHealth;
  late List<double> _defenderHealth;
  late List<double> _attackerMax;
  late List<double> _defenderMax;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _combatTimer?.cancel();
    super.dispose();
  }

  void _prepareCombat() {
    final base = BaseVirale(nom: 'Base Défensive');
    base.ajouterAgent(Anticorps(
      nom: 'GLOB-B',
      pv: 90,
      typeAttaque: 'directe',
      degats: 10,
      coutRessources: 2,
      tempsProduction: 3,
    ));
    base.ajouterAgent(Anticorps(
      nom: 'GLOB-C',
      pv: 100,
      typeAttaque: 'directe',
      degats: 12,
      coutRessources: 3,
      tempsProduction: 4,
    ));

    _selectedUnits = [
      Bacterie(pv: 70, armure: 2.0, degats: 13, initiative: 5),
      Bacterie(pv: 80, armure: 3.5, degats: 14, initiative: 6),
    ];

    _attackerMax = _selectedUnits.map((u) => u.pv.toDouble()).toList();
    _defenderMax = base.agents.map((a) => a.pv.toDouble()).toList();
    _attackerHealth = List.from(_attackerMax);
    _defenderHealth = List.from(_defenderMax);
    _showEffect = false;

    setState(() {
      _enemyBase = base;
      _showBriefing = false;
    });
  }

  void _startCombat() {
    if (_enemyBase == null || _selectedUnits.isEmpty) return;

    setState(() {
      _battleSummary = '';
      _showBriefing = false;
    });

    _combatTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _performCombatStep();
      if (_isCombatOver()) {
        timer.cancel();
        _endCombat();
      }
    });
  }

  void _performCombatStep() {
    for (int i = 0; i < _selectedUnits.length && i < _enemyBase!.agents.length; i++) {
      final attacker = _selectedUnits[i];
      final defender = _enemyBase!.agents[i];
      _defenderHealth[i] = max(0, _defenderHealth[i] - attacker.degats);
      _attackerHealth[i] = max(0, _attackerHealth[i] - defender.degats);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _showEffect = true;
      });
    });

    Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _showEffect = false;
        });
      }
    });
  }

  bool _isCombatOver() {
    return _attackerHealth.every((h) => h <= 0) || _defenderHealth.every((h) => h <= 0);
  }

  void _endCombat() {
    final gameState = ref.read(gameStateProvider);
    gameState.startBattle(
      _enemyBase!,
      opponentIdentifier: 'Base Défensive',
      opponentType: 'Anticorps',
    );
    setState(() {
      _battleSummary = gameState.battleData +
          '\nUnits utilisées: ' + _selectedUnits.map((u) => u.nom).join(', ');
      _showBriefing = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[800],
      appBar: AppBar(
        title: const Text('Combat'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;
                return Stack(
                  children: [
                    for (int i = 0; i < _selectedUnits.length; i++)
                      Positioned(
                        left: 60 + i * 40,
                        top: h * 0.3 + i * 40,
                        child: _buildUnitIcon(
                          Icons.bug_report,
                          Colors.greenAccent,
                          _attackerHealth[i] / _attackerMax[i],
                          _showEffect,
                          isUser: true,
                        ),
                      ),
                    if (_enemyBase != null)
                      for (int j = 0; j < _enemyBase!.agents.length; j++)
                        Positioned(
                          left: w - 60 - j * 40,
                          top: h * 0.6 + j * 40,
                          child: _buildUnitIcon(
                            Icons.shield,
                            Colors.blueAccent,
                            _defenderHealth[j] / _defenderMax[j],
                            _showEffect,
                            isUser: false,
                          ),
                        ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          if (!_showBriefing) ...[
            ElevatedButton(
              onPressed: _prepareCombat,
              child: const Text('Préparer Combat'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _startCombat,
              child: const Text('Lancer Combat'),
            ),
          ],
          if (_showBriefing)
            Expanded(
              flex: 5,
              child: BriefingWidget(battleData: _battleSummary),
            ),
        ],
      ),
    );
  }

  Widget _buildUnitIcon(IconData icon, Color color, double ratio, bool effect, {bool isUser = true}) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: effect ? Colors.yellow : color, size: 40),
            if (effect)
              Icon(
                isUser ? Icons.flash_on : Icons.shield_moon,
                color: Colors.orangeAccent,
                size: 18,
              ),
          ],
        ),
        SizedBox(
          width: 40,
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: Colors.red[900],
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
