// lib/laboratoire_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/game_state.dart'; // Pour accéder à gameStateProvider
import 'models/laboratoire_recherche.dart';
import 'models/agent_pathogene.dart';
import 'models/bacterie.dart';
import 'models/champignon.dart';
import 'models/virus.dart';

class LaboratoireScreen extends ConsumerStatefulWidget {
  const LaboratoireScreen({Key? key}) : super(key: key);

  @override
  _LaboratoireScreenState createState() => _LaboratoireScreenState();
}

class _LaboratoireScreenState extends ConsumerState<LaboratoireScreen> {
  // Variables de création d'agents
  String selectedAgentType = "Bacterie";
  String? selectedAgentSubtype;

  // Liste limitée à 4 sous-types par type.
  final Map<String, List<String>> agentSubtypes = {
    "Bacterie": ["E. coli", "Salmonella", "Staphylococcus", "Streptococcus"],
    "Champignon": ["Candida", "Aspergillus", "Cryptococcus", "Histoplasma"],
    "Virus": ["Corona", "Influenza", "HIV", "SARS"],
  };

  // Détails de chaque sous-type (pour information, pas utilisé dans la sélection ici)
  final Map<String, Map<String, dynamic>> subtypeDetails = {
    "Bacterie": {
      "E. coli": {"icon": Icons.scatter_plot, "color": Colors.lightGreen},
      "Salmonella": {"icon": Icons.bug_report, "color": Colors.orange},
      "Staphylococcus": {"icon": Icons.biotech, "color": Colors.purple},
      "Streptococcus": {"icon": Icons.healing, "color": Colors.blue},
    },
    "Champignon": {
      "Candida": {"icon": Icons.emoji_nature, "color": Colors.brown},
      "Aspergillus": {"icon": Icons.eco, "color": Colors.green},
      "Cryptococcus": {"icon": Icons.spa, "color": Colors.indigo},
      "Histoplasma": {"icon": Icons.local_florist, "color": Colors.amber},
    },
    "Virus": {
      "Corona": {"icon": Icons.coronavirus, "color": Colors.red},
      "Influenza": {"icon": Icons.ac_unit, "color": Colors.cyan},
      "HIV": {"icon": Icons.healing, "color": Colors.pink},
      "SARS": {"icon": Icons.dangerous, "color": Colors.deepOrange},
    },
  };

  // Variables de création d'anticorps.
  String selectedAnticorpsOrientation = "Contre Champignon";

  // Pour empêcher la duplication d'un sous-type pour un type donné.
  final Map<String, Set<String>> usedSubtypes = {
    "Bacterie": {},
    "Champignon": {},
    "Virus": {},
  };

  @override
  void initState() {
    super.initState();
    selectedAgentSubtype = agentSubtypes[selectedAgentType]!.first;
  }

  /// Renvoie les statistiques de base pour un agent selon son type.
  Map<String, dynamic> _getAgentStats(String type) {
    switch (type) {
      case "Bacterie":
        return {"PV": 110, "Armure": 12.0, "Dégâts": 30, "Initiative": 5};
      case "Champignon":
        return {"PV": 95, "Armure": 9.0, "Dégâts": 25, "Initiative": 6};
      case "Virus":
        return {"PV": 80, "Armure": 5.0, "Dégâts": 40, "Initiative": 7};
      default:
        return {"PV": 100, "Armure": 10.0, "Dégâts": 20, "Initiative": 5};
    }
  }

  /// Renvoie le coût en bio-matériaux nécessaire pour créer un anticorps selon son orientation.
  int _getAnticorpsCost(String orientation) {
    switch (orientation) {
      case "Contre Virus":
        return 25;
      case "Contre Bacterie":
        return 20;
      case "Contre Champignon":
        return 15;
      default:
        return 15;
    }
  }

  /// Affiche une progressbar pour une ressource.
  /// L'énergie est affichée en vert, les bio-matériaux en bleu.
  Widget _buildResourceProgress(String label, int value) {
    Color color = (label == "Énergie") ? Colors.green : Colors.blue;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        SizedBox(
          width: 100,
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 6,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        Text("$value/100", style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  /// Affiche un AlertDialog présentant un récapitulatif textuel des statistiques de l'agent sélectionné.
  void _showAgentDetails(AgentPathogene agent) {
    final stats = _getAgentStats(
        agent is Bacterie ? "Bacterie" : agent is Champignon ? "Champignon" : "Virus");
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Text(agent.customType ?? agent.nom, style: const TextStyle(fontSize: 14)),
        content: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
          children: stats.entries.map((entry) {
            return TableRow(children: [
              Text("${entry.key}:", style: const TextStyle(fontSize: 12)),
              Text(entry.value.toString(), style: const TextStyle(fontSize: 12))
            ]);
          }).toList(),
        ),
      ),
    );
  }

  /// Affiche un AlertDialog présentant un récapitulatif textuel des statistiques de l'anticorps sélectionné.
  void _showAntibodyDetails(dynamic anti) {
    // Pour l'anticorps, nous affichons PV et Dégâts en résumé.
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Text(anti.nom, style: const TextStyle(fontSize: 14)),
        content: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
          children: [
            TableRow(children: [
              const Text("PV:", style: TextStyle(fontSize: 12)),
              Text(anti.pv.toString(), style: const TextStyle(fontSize: 12))
            ]),
            TableRow(children: [
              const Text("Dégâts:", style: TextStyle(fontSize: 12)),
              Text(anti.degats.toString(), style: const TextStyle(fontSize: 12))
            ]),
          ],
        ),
      ),
    );
  }

  /// Retourne l'icône représentant un agent, en fonction de son type.
  Widget _getAgentIcon(AgentPathogene agent) {
    if (agent is Bacterie) {
      return const Icon(Icons.biotech, size: 20, color: Colors.purple);
    } else if (agent is Champignon) {
      return const Icon(Icons.eco, size: 20, color: Colors.brown);
    } else if (agent is Virus) {
      return const Icon(Icons.coronavirus, size: 20, color: Colors.red);
    }
    return const Icon(Icons.person, size: 20, color: Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final laboratoire = gameState.laboratoireCreation;
    final int energie = gameState.ressources.energie;
    final int bio = gameState.ressources.bioMateriaux;

    // Mise à jour de la liste des sous-types disponibles.
    List<String> availableSubtypes = agentSubtypes[selectedAgentType]!
        .where((s) => !usedSubtypes[selectedAgentType]!.contains(s))
        .toList();
    if (availableSubtypes.isNotEmpty) {
      selectedAgentSubtype ??= availableSubtypes.first;
    } else {
      selectedAgentSubtype = null;
    }

    // Coût énergétique pour créer un agent.
    const int energyCost = 20;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Laboratoire & Recherche"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ressources affichées avec progress bars.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildResourceProgress("Énergie", energie),
                _buildResourceProgress("Bio-Mat.", bio),
              ],
            ),
            const SizedBox(height: 12),
            // Formulaire de création d'un agent pathogène.
            Card(
              margin: const EdgeInsets.all(4),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    const Text("Créer un Agent Pathogène",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedAgentType,
                      items: agentSubtypes.keys
                          .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type, style: const TextStyle(fontSize: 12)),
                      ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            selectedAgentType = v;
                            selectedAgentSubtype = agentSubtypes[selectedAgentType]!.first;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: "Type d'agent",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Liste déroulante pour le sous-type.
                    DropdownButtonFormField<String>(
                      value: selectedAgentSubtype,
                      items: availableSubtypes
                          .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s, style: const TextStyle(fontSize: 12)),
                      ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            selectedAgentSubtype = v;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: "Sous-type",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (selectedAgentSubtype == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Aucun sous-type disponible.")),
                          );
                          return;
                        }
                        if (energie < energyCost) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Pas assez d'énergie pour créer un agent.")),
                          );
                          return;
                        }
                        try {
                          // Consommer l'énergie.
                          gameState.consommerEnergie(energyCost);
                          final stats = _getAgentStats(selectedAgentType);
                          final newAgent = laboratoire.creerAgentPathogeneManual(
                            type: selectedAgentType,
                            pv: stats["PV"],
                            armure: stats["Armure"],
                            degats: stats["Dégâts"],
                            initiative: stats["Initiative"],
                          );
                          // Stocker le sous-type dans customType pour servir de nom.
                          newAgent.customType = selectedAgentSubtype!;
                          usedSubtypes[selectedAgentType]!.add(selectedAgentSubtype!);
                          gameState.addAgent(newAgent);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Agent Pathogène créé !")),
                          );
                          setState(() {
                            final avail = agentSubtypes[selectedAgentType]!
                                .where((s) => !usedSubtypes[selectedAgentType]!.contains(s))
                                .toList();
                            selectedAgentSubtype = avail.isNotEmpty ? avail.first : null;
                          });
                        } catch (e) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text("Créer Agent", style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Formulaire de création d'un anticorps.
            Card(
              margin: const EdgeInsets.all(4),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    const Text("Créer un Anticorps",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedAnticorpsOrientation,
                      items: const [
                        DropdownMenuItem(child: Text("Contre Virus", style: TextStyle(fontSize: 12)), value: "Contre Virus"),
                        DropdownMenuItem(child: Text("Contre Bacterie", style: TextStyle(fontSize: 12)), value: "Contre Bacterie"),
                        DropdownMenuItem(child: Text("Contre Champignon", style: TextStyle(fontSize: 12)), value: "Contre Champignon"),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            selectedAnticorpsOrientation = v;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: "Orientation",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        final cost = _getAnticorpsCost(selectedAnticorpsOrientation);
                        if (bio < cost) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Pas assez de bio-matériaux pour créer un anticorps.")),
                          );
                          return;
                        }
                        try {
                          gameState.consommerBioMateriaux(cost);
                          final autoName = "Anticorps-${gameState.anticorps.length + 1}";
                          final newAnti = laboratoire.creerAnticorps(nom: autoName, coutRessources: cost);
                          gameState.addAnticorps(newAnti);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Anticorps créé !")),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text("Créer Anticorps", style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Liste des agents existants affichée en grille.
            Card(
              margin: const EdgeInsets.all(4),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    const Text("Agents Existants", style: TextStyle(fontWeight: FontWeight.bold)),
                    const Divider(),
                    gameState.agents.isEmpty
                        ? const Text("Aucun agent créé.")
                        : GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: gameState.agents.map((agent) {
                        final displayName = agent.customType ?? agent.nom;
                        return GestureDetector(
                          onTap: () => _showAgentDetails(agent),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _getAgentIcon(agent),
                              const SizedBox(height: 4),
                              Text(displayName, style: const TextStyle(fontSize: 10)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Liste des anticorps existants affichée en grille.
            Card(
              margin: const EdgeInsets.all(4),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    const Text("Anticorps Existants", style: TextStyle(fontWeight: FontWeight.bold)),
                    const Divider(),
                    gameState.anticorps.isEmpty
                        ? const Text("Aucun anticorps créé.")
                        : GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: gameState.anticorps.map((anti) {
                        return GestureDetector(
                          onTap: () => _showAntibodyDetails(anti),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.shield, color: Colors.blueGrey, size: 16),
                              const SizedBox(height: 4),
                              Text(anti.nom, style: const TextStyle(fontSize: 10)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(vertical: 12)),
          onPressed: () {
            Navigator.pushNamed(context, '/accueil');
          },
          icon: const Icon(Icons.home),
          label: const Text("Accueil"),
        ),
      ),
    );
  }
}