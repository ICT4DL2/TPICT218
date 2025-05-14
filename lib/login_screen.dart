// laboratoire_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/game_state.dart'; // Pour accéder à gameStateProvider
import 'models/laboratoire_recherche.dart';
import 'models/agent_pathogene.dart';

class LaboratoireScreen extends ConsumerStatefulWidget {
  const LaboratoireScreen({Key? key}) : super(key: key);

  @override
  _LaboratoireScreenState createState() => _LaboratoireScreenState();
}

class _LaboratoireScreenState extends ConsumerState<LaboratoireScreen> {
  // Variables pour la création d'agents pathogènes
  String selectedAgentType = "Bacterie";
  final TextEditingController agentPvController = TextEditingController();
  final TextEditingController agentArmureController = TextEditingController();
  final TextEditingController agentDegatsController = TextEditingController();
  final TextEditingController agentInitiativeController = TextEditingController();

  // Variable pour la création d'anticorps
  final TextEditingController anticorpsNomController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final laboratoire = gameState.laboratoireCreation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laboratoire & Recherche'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade300,
              Colors.green.shade300,
              Colors.red.shade300,
              Colors.purple.shade300,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Laboratoire & Recherche',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Section de création d'un agent pathogène
                  const Text(
                    'Créer un Agent Pathogène',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedAgentType,
                    items: const [
                      DropdownMenuItem(child: Text("Bacterie"), value: "Bacterie"),
                      DropdownMenuItem(child: Text("Champignon"), value: "Champignon"),
                      DropdownMenuItem(child: Text("Virus"), value: "Virus"),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedAgentType = value;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Type d\'agent',
                      filled: true,
                      fillColor: Colors.white70,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(agentPvController, 'Valeur de base de PV (optionnel)'),
                  _buildTextField(agentArmureController, 'Valeur de base d\'armure (optionnel)'),
                  _buildTextField(agentDegatsController, 'Valeur de base de dégâts (optionnel)'),
                  _buildTextField(agentInitiativeController, 'Valeur de base d\'initiative (optionnel)'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      try {
                        AgentPathogene newAgent;
                        if (_areAgentFieldsFilled()) {
                          int pv = int.parse(agentPvController.text);
                          double armure = double.parse(agentArmureController.text);
                          int degats = int.parse(agentDegatsController.text);
                          int initiative = int.parse(agentInitiativeController.text);
                          newAgent = laboratoire.creerAgentPathogeneManual(
                            type: selectedAgentType,
                            pv: pv,
                            armure: armure,
                            degats: degats,
                            initiative: initiative,
                          );
                        } else {
                          newAgent = laboratoire.creerAgentPathogene(type: selectedAgentType);
                        }
                        gameState.addAgent(newAgent);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Agent Pathogène créé !')),
                        );
                        _clearAgentFields();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Créer Agent'),
                  ),
                  const SizedBox(height: 24),
                  // Section de création d'un anticorps
                  const Text(
                    'Créer un Anticorps',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(anticorpsNomController, 'Nom de l\'anticorps'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      try {
                        if (anticorpsNomController.text.isEmpty) {
                          throw Exception("Veuillez saisir le nom de l'anticorps.");
                        }
                        final newAnticorps = laboratoire.creerAnticorps(nom: anticorpsNomController.text);
                        gameState.addAnticorps(newAnticorps);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Anticorps créé !')),
                        );
                        anticorpsNomController.clear();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Créer Anticorps'),
                  ),
                  const SizedBox(height: 24),
                  // Affichage des agents existants
                  const Text(
                    'Agents Existants',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    itemCount: gameState.agents.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final agent = gameState.agents[index];
                      return Card(
                        color: Colors.white70,
                        child: ListTile(
                          title: Text(agent.nom),
                          subtitle: Text('PV: ${agent.pv}, Dégâts: ${agent.degats}'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Affichage des anticorps existants
                  const Text(
                    'Anticorps Existants',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    itemCount: gameState.anticorps.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final anti = gameState.anticorps[index];
                      return Card(
                        color: Colors.white70,
                        child: ListTile(
                          title: Text(anti.nom),
                          subtitle: Text('PV: ${anti.pv}, Dégâts: ${anti.degats}'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/accueil');
          },
          icon: const Icon(Icons.home),
          label: const Text('Accueil'),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: (label.contains("armure"))
            ? TextInputType.numberWithOptions(decimal: true)
            : TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white70,
        ),
      ),
    );
  }

  bool _areAgentFieldsFilled() {
    return agentPvController.text.isNotEmpty &&
        agentArmureController.text.isNotEmpty &&
        agentDegatsController.text.isNotEmpty &&
        agentInitiativeController.text.isNotEmpty;
  }

  void _clearAgentFields() {
    agentPvController.clear();
    agentArmureController.clear();
    agentDegatsController.clear();
    agentInitiativeController.clear();
  }
}