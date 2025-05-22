// lib/combat_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:uuid/uuid.dart'; // Assurez-vous que uuid est bien importé

// Importe les widgets et modèles nécessaires
import 'gemini/briefing_widget.dart';
import 'models/game_state.dart';
import 'models/bacterie.dart';
import 'models/champignon.dart';
import 'models/virus.dart';
import 'models/base_virale.dart';
import 'models/agent_pathogene.dart'; // Importe AgentPathogene
import 'models/anticorps.dart'; // Importe Anticorps (toujours nécessaire pour la logique GameState actuelle)


// Peintre personnalisé pour le radar avec des améliorations visuelles
class RadarPainter extends CustomPainter {
  final double sweepAngle; // Angle de balayage pour l'animation
  final bool combatActive; // Indique si le combat est actif pour les effets visuels

  RadarPainter({required this.sweepAngle, required this.combatActive});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Peinture pour le fond du radar
    final Paint backgroundPaint = Paint()
      ..color = Colors.blueGrey[900]!; // Couleur de fond plus sombre

    canvas.drawCircle(center, radius, backgroundPaint);


    // Peinture pour les carrés du radar
    final Paint squarePaint = Paint()
      ..color = Colors.lightGreenAccent.withOpacity(0.5) // Couleur plus vive
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    int numSquares = 3;
    for (int i = 1; i <= numSquares; i++) {
      double inset = radius * (i / (numSquares + 1));
      Rect rect = Rect.fromCircle(center: center, radius: radius - inset); // Dessine des carrés concentriques
      canvas.drawRect(rect, squarePaint);
    }

    // Peinture pour les lignes du radar
    final Paint linePaint = Paint()
      ..color = Colors.lightGreenAccent.withOpacity(0.5) // Couleur plus vive
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), linePaint);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), linePaint);
    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), linePaint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), linePaint);

    // Animation du balayage radar
    final Paint sweepPaint = Paint()
      ..shader = SweepGradient(
          center: Alignment.center,
          startAngle: 0.0,
          endAngle: pi * 2,
          colors: [Colors.transparent, Colors.lightGreenAccent.withOpacity(0.4)], // Couleur plus vive
          stops: const [0.5, 1.0],
          transform: GradientRotation(sweepAngle) // Rotation basée sur l'angle animé
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, sweepPaint);

    // Effet visuel pendant le combat (pulsation/changement de couleur)
    if(combatActive) {
      final Paint combatEffectPaint = Paint()
        ..color = Colors.redAccent.withOpacity(0.4 + sin(DateTime.now().millisecondsSinceEpoch / 150) * 0.15); // Pulsation plus rapide et intense
      canvas.drawCircle(center, radius, combatEffectPaint);
    }
  }

  // Indique si le peintre doit être repeint (pour l'animation)
  @override
  bool shouldRepaint(covariant RadarPainter oldDelegate) {
    // Repeindre si l'angle de balayage ou l'état de combat change
    return oldDelegate.sweepAngle != sweepAngle || oldDelegate.combatActive != combatActive;
  }
}


class CombatScreen extends ConsumerStatefulWidget {
  const CombatScreen({Key? key}) : super(key: key);

  @override
  _CombatScreenState createState() => _CombatScreenState();
}

class _CombatScreenState extends ConsumerState<CombatScreen> with SingleTickerProviderStateMixin { // Ajoute SingleTickerProviderStateMixin pour l'animation

  // bool _isSearchingPvP = false; // Retiré car le bouton PvP est retiré
  BaseVirale? _currentEnemyBase; // Stocke la base ennemie actuelle
  String? _currentOpponentIdentifier; // Stocke l'identifiant de l'adversaire actuel
  String? _currentOpponentType; // Stocke le type de l'adversaire actuel ("PNJ" ou "PvP")

  String _pvpStatusMessage = "Prêt pour le combat.";

  // Liste des agents pathogènes sélectionnés par glisser-déposer
  List<AgentPathogene> _selectedUnits = [];
  bool _isDroppingUnits = false; // Indique si la phase de sélection d'unités est active

  int _countdown = 10; // Compteur pour le timer visuel
  Timer? _combatTimer; // Timer pour le décompte visuel
  bool _combatActive = false; // Indique si le combat visuel est en cours

  late AnimationController _sweepAnimationController; // Contrôleur pour l'animation du balayage radar
  late Animation<double> _sweepAnimation; // Animation de l'angle de balayage


  @override
  void initState() {
    super.initState();
    // Initialise le contrôleur d'animation pour le balayage radar
    _sweepAnimationController = AnimationController(
      duration: const Duration(seconds: 2), // Durée d'un cycle de balayage
      vsync: this, // Le TickerProvider
    )..repeat(); // Répète l'animation indéfiniment

    // Crée l'animation de l'angle de balayage (de 0 à 2*pi)
    _sweepAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(_sweepAnimationController);
  }


  // Crée une base ennemie de test (PNJ)
  BaseVirale _createTestEnemyBase() {
    BaseVirale testBase = BaseVirale(nom: "Base PNJ Facile");

    // Ajoute des agents pathogènes à la base ennemie
    testBase.ajouterAgent(Bacterie(pv: 80, armure: 5.0, degats: 15, initiative: 6));
    testBase.ajouterAgent(Bacterie(pv: 70, armure: 4.0, degats: 18, initiative: 7));
    testBase.ajouterAgent(Bacterie(pv: 90, armure: 6.0, degats: 12, initiative: 5));
    // TODO: Ajouter plus de variété et de complexité à la base ennemie PNJ

    final Uuid uuid = Uuid();
    for (var agent in testBase.agents) {
      agent.id = uuid.v4();
      agent.level = 1;
      agent.mutationLevel = 0;
    }

    return testBase;
  }

  // Prépare un combat contre la Machine (PNJ)
  void _preparePNJCombat() {
    // Retire la vérification _isSearchingPvP
    if (_combatActive || _isDroppingUnits) return; // Empêche si déjà en cours

    BaseVirale enemy = _createTestEnemyBase();

    setState(() {
      _currentEnemyBase = enemy;
      _currentOpponentIdentifier = "Machine";
      _currentOpponentType = "PNJ";
      _pvpStatusMessage = "Combat contre la Machine. Sélectionnez vos unités.";
      _selectedUnits.clear(); // Efface les unités sélectionnées
      _isDroppingUnits = true; // Active la phase de sélection d'unités
      _combatActive = false; // Assure que le timer est inactif
      _combatTimer?.cancel();
      _countdown = 10;
    });
  }


  // Lance le timer visuel et la simulation de combat après le décompte
  void _startCombatCountdown() {
    if (_combatActive || _selectedUnits.isEmpty || _currentEnemyBase == null) {
      // Ne rien faire si le combat est déjà actif, aucune unité sélectionnée, ou pas d'ennemi
      return;
    }

    setState(() {
      _isDroppingUnits = false; // Désactive la phase de drop pendant le combat
      _combatActive = true; // Active le mode combat
      _countdown = 10; // Réinitialise le décompte
      _pvpStatusMessage = "Combat en cours...";
    });

    _combatTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          timer.cancel(); // Arrête le timer
          _executeCombatSimulation(); // Exécute la simulation après le décompte
        }
      });
    });
  }

  // Exécute la simulation de combat réelle via GameState
  void _executeCombatSimulation() {
    if (_currentEnemyBase == null || _currentOpponentIdentifier == null || _currentOpponentType == null) {
      print("Erreur: Impossible d'exécuter la simulation, ennemi non défini.");
      setState(() {
        _pvpStatusMessage = "Erreur lors du combat.";
        _combatActive = false;
        _selectedUnits.clear(); // Réinitialise
      });
      return;
    }

    final gameStateActions = ref.read(gameStateProvider);

    // Appelle la logique de combat dans GameState.
    // TODO: Modifier GameState.startBattle et CombatManager pour utiliser List<AgentPathogene> _selectedUnits
    // et simuler les agents pathogènes attaquant la base ennemie.
    // Pour l'instant, la simulation utilise toujours les anticorps du joueur contre la base ennemie (logique inversée).
    gameStateActions.startBattle(
      _currentEnemyBase!, // Base ennemie attaquée
      opponentIdentifier: _currentOpponentIdentifier!,
      opponentType: _currentOpponentType!,
      // TODO: Passer _selectedUnits ici si la logique de combat est modifiée pour utiliser les agents sélectionnés
      // selectedAttackingAgents: _selectedUnits, // Exemple de comment passer les agents sélectionnés
    );


    setState(() {
      _combatActive = false; // Le combat visuel est terminé
      _pvpStatusMessage = "Combat terminé ! Consultez le journal.";
      _selectedUnits.clear(); // Efface les unités sélectionnées après le combat
      _currentEnemyBase = null; // Réinitialise l'ennemi
      _currentOpponentIdentifier = null;
      _currentOpponentType = null;
    });

    // Optionnel: Afficher un message ou naviguer vers le journal
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Combat terminé !")),
    );
  }


  @override
  void dispose() {
    _combatTimer?.cancel(); // Annule le timer lors de la suppression du widget
    _sweepAnimationController.dispose(); // Libère le contrôleur d'animation
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final String battleData = gameState.battleData;
    // Utilise playerBaseAgents (agents pathogènes) pour les unités disponibles
    final List<AgentPathogene> playerAvailableAgents = gameState.playerBaseAgents;

    return Scaffold(
      // --- NOUVEAU : Couleur d'arrière-plan du Scaffold ---
      backgroundColor: Colors.blueGrey[800], // Couleur de fond sombre pour l'écran
      appBar: AppBar(
        title: const Text("Combat"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Section Radar et Statut
          Expanded(
            flex: 4, // Réduit la taille pour laisser de la place aux unités
            child: Center(
              child: AspectRatio(
                aspectRatio: 1, // Maintient un ratio 1:1
                // Le radar est une cible de dépôt pour les AgentsPathogenes
                child: DragTarget<AgentPathogene>(
                  onAcceptWithDetails: (DragTargetDetails<AgentPathogene> details) {
                    // S'assure que la phase de drop est active et que l'unité n'est pas déjà sélectionnée
                    if (_isDroppingUnits && !_selectedUnits.contains(details.data)) {
                      setState(() {
                        _selectedUnits.add(details.data); // Ajoute l'agent à la liste des sélectionnés
                        print("Agent sélectionné ajouté: ${details.data.nom}"); // Log
                      });
                    }
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      margin: const EdgeInsets.all(16), // Marge réduite
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
                      child: Stack(
                        children: [
                          // Le peintre du radar (animé)
                          AnimatedBuilder( // Utilise AnimatedBuilder pour reconstruire quand l'animation change
                            animation: _sweepAnimation,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: RadarPainter(
                                  sweepAngle: _sweepAnimation.value, // Passe l'angle animé
                                  combatActive: _combatActive, // Passe l'état de combat
                                ),
                                child: Container(), // Un conteneur vide pour donner la taille
                              );
                            },
                          ),


                          // Affichage du statut et du timer
                          Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _pvpStatusMessage,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.greenAccent,
                                      shadows: [
                                        Shadow(blurRadius: 8.0, color: Colors.black, offset: Offset(1.0, 1.0)),
                                      ],
                                    ),
                                  ),
                                  if (_combatActive) // Affiche le timer si le combat est actif
                                    Text(
                                      "Temps restant: $_countdown s",
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.redAccent,
                                        shadows: [
                                          Shadow(blurRadius: 8.0, color: Colors.black, offset: Offset(1.0, 1.0)),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          // Affichage visuel des agents pathogènes sélectionnés sur le radar
                          ..._selectedUnits.map((agent) => Align(
                            alignment: Alignment(
                              // Position aléatoire simple sur le radar pour l'exemple
                              Random().nextDouble() * 1.6 - 0.8, // Entre -0.8 et 0.8
                              Random().nextDouble() * 1.6 - 0.8, // Entre -0.8 et 0.8
                            ),
                            child: Tooltip( // Affiche le nom de l'agent au survol/appui long
                              message: agent.nom,
                              child: Icon(
                                // Utilise une icône différente pour les agents pathogènes
                                Icons.bug_report, // Exemple d'icône
                                color: Colors.deepOrangeAccent, // Couleur différente
                                size: 35, // Taille légèrement augmentée
                              ),
                            ),
                          )).toList(),

                          // Bouton Lancer l'Attaque (visible si unités sélectionnées et pas en combat)
                          if (_selectedUnits.isNotEmpty && !_combatActive)
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: ElevatedButton(
                                  onPressed: _startCombatCountdown, // Lance le décompte
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  child: const Text("Lancer l'Attaque"),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Section des Unités Disponibles (Draggable) - Agents Pathogènes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Vos Agents Pathogènes Disponibles:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70)), // Texte en blanc pour contraste
                const SizedBox(height: 8),
                SizedBox(
                  height: 80, // Hauteur fixe pour la liste des unités
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal, // Défilement horizontal
                    itemCount: playerAvailableAgents.length, // Utilise les agents pathogènes
                    itemBuilder: (context, index) {
                      final agent = playerAvailableAgents[index];
                      // Une unité est draggable si la phase de drop est active
                      return Draggable<AgentPathogene>( // Draggable d'AgentPathogene
                        // Data transportée par le Draggable
                        data: agent,
                        // Widget affiché pendant le glisser
                        feedback: Material( // Utilisez Material pour l'élévation et l'ombre
                          elevation: 6.0,
                          child: CircleAvatar( // Icône de l'agent en cours de glissement
                            radius: 30,
                            backgroundColor: Colors.deepOrangeAccent.withOpacity(0.8), // Couleur assortie
                            child: Icon(Icons.bug_report, color: Colors.white, size: 40), // Icône d'agent
                          ),
                        ),
                        // Widget affiché à l'emplacement d'origine pendant le glisser (peut être vide ou une version transparente)
                        childWhenDragging: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.deepOrangeAccent.withOpacity(0.3), // Version transparente
                          child: Icon(Icons.bug_report, color: Colors.white.withOpacity(0.3), size: 40), // Icône d'agent
                        ),
                        // Widget affiché normalement
                        child: Opacity(
                          opacity: _isDroppingUnits && !_selectedUnits.contains(agent) ? 1.0 : 0.5, // Opacité si non sélectionnable ou déjà sélectionnée
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: _selectedUnits.contains(agent) ? Colors.grey : Colors.deepOrangeAccent, // Couleur différente si sélectionnée
                            child: Icon(Icons.bug_report, color: Colors.white, size: 40), // Icône d'agent
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Section Briefing et Boutons de Contrôle
          Expanded(
            flex: 3, // Taille réduite pour laisser de la place aux unités
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              // --- NOUVEAU : Amélioration du cadre du briefing ---
              decoration: BoxDecoration(
                color: Colors.blueGrey[100]!.withOpacity(0.9), // Fond plus clair et légèrement transparent
                borderRadius: BorderRadius.circular(16), // Bordures légèrement moins arrondies
                border: Border.all(color: Colors.blueGrey[400]!, width: 2), // Bordure subtile
                boxShadow: [ // Ombre plus présente
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded( // Le briefing prend l'espace restant
                    child: SingleChildScrollView( // Permet le défilement si le briefing est long
                      child: BriefingWidget(battleData: battleData),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Boutons de recherche/préparation combat (visibles si pas en phase de drop ou combat)
                  if (!_isDroppingUnits && !_combatActive)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: _preparePNJCombat, // Prépare le combat PNJ (bouton PvP retiré)
                          // Texte du bouton réduit
                          child: const Text("Lancer un Raid (PNJ)", textAlign: TextAlign.center),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Padding réduit
                            textStyle: const TextStyle(fontSize: 16),
                            minimumSize: const Size(200, 40), // Taille minimale ajustée
                          ),
                        ),
                        // Retiré le bouton PvP
                        // const SizedBox(height: 12),
                        // ElevatedButton(...)
                      ],
                    ),
                  // Bouton Annuler (visible pendant la phase de drop)
                  if (_isDroppingUnits && !_combatActive)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isDroppingUnits = false; // Désactive la phase de drop
                          _selectedUnits.clear(); // Efface les unités sélectionnées
                          _currentEnemyBase = null; // Réinitialise
                          _currentOpponentIdentifier = null;
                          _currentOpponentType = null;
                          _pvpStatusMessage = "Sélection annulée.";
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: const Text("Annuler Sélection"),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8),
        child: ElevatedButton.icon(
          // --- NOUVEAU : Couleur du bouton Accueil ---
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal, // Nouvelle couleur pour le bouton Accueil
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
