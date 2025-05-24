// lib/laboratoire_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/game_state.dart'; // Pour accéder à gameStateProvider
import 'models/agent_pathogene.dart';
import 'models/bacterie.dart';
import 'models/champignon.dart';
import 'models/virus.dart';
import 'models/anticorps.dart';


class LaboratoireScreen extends ConsumerStatefulWidget {
  const LaboratoireScreen({super.key});

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

  // --- SUPPRESSION : Retirer la map usedSubtypes locale. Elle est maintenant dans GameState. ---
  // final Map<String, Set<String>> usedSubtypes = { ... };

  // Coût fixe pour créer un anticorps de base (selon _getAnticorpsCost 'default').
  // Ce coût est maintenant géré dans LaboratoireCreation.
  // final int baseAnticorpsCost = 15; // Peut être supprimé si on utilise laboratoire.coutCreationAnticorps


  @override
  void initState() {
    super.initState();
    // L'initialisation du sous-type sélectionné sera gérée dans le build
    // en fonction de l'état chargé ou initial du GameState.
    // Retirer le postFrameCallback lié à usedSubtypes local.
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (agentSubtypes[selectedAgentType]!.isNotEmpty) {
    //     selectedAgentSubtype = agentSubtypes[selectedAgentType]!.first;
    //   }
    //    setState(() {});
    // });
  }

  // --- SUPPRESSION : Retirer la méthode _getAnticorpsCost si le coût est fixe ---
  // /// Renvoie le coût en bio-matériaux nécessaire pour créer un anticorps selon son orientation.
  // int _getAnticorpsCost(String orientation) { ... }


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


  /// Affiche une progressbar pour une ressource avec le nouveau style.
  Widget _buildResourceProgress(String label, int value) {
    Color color = (label == "Énergie") ? Colors.greenAccent : Colors.cyanAccent; // Couleurs vives
    final double percentage = (value / 100).clamp(0.0, 1.0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70)), // Texte blanc pour contraste
        const SizedBox(height: 4),
        SizedBox(
          width: 100,
          child: ClipRRect( // Arrondir les coins
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 10, // Hauteur augmentée
              backgroundColor: Colors.blueGrey[600], // Fond de barre plus sombre
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text("$value/100", style: const TextStyle(fontSize: 10, color: Colors.white70)), // Texte blanc pour contraste
      ],
    );
  }

  /// Affiche un AlertDialog présentant un récapitulatif textuel des statistiques de l'agent sélectionné.
  void _showAgentDetails(AgentPathogene agent) {
    final stats = _getAgentStats(
        agent is Bacterie ? "Bacterie" : agent is Champignon ? "Champignon" : agent is Virus ? "Virus" : "Inconnu");
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Text(agent.customType ?? agent.nom, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
              },
              children: [
                TableRow(children: [ const Text("Nom:", style: TextStyle(fontSize: 12)), Text(agent.customType ?? agent.nom, style: const TextStyle(fontSize: 12)) ]),
                TableRow(children: [ const Text("PV:", style: TextStyle(fontSize: 12)), Text(agent.pv.toString(), style: const TextStyle(fontSize: 12)) ]),
                TableRow(children: [ const Text("Armure:", style: TextStyle(fontSize: 12)), Text(agent.armure.toStringAsFixed(1), style: const TextStyle(fontSize: 12)) ]),
                TableRow(children: [ const Text("Dégâts:", style: TextStyle(fontSize: 12)), Text(agent.degats.toString(), style: const TextStyle(fontSize: 12)) ]),
                TableRow(children: [ const Text("Initiative:", style: TextStyle(fontSize: 12)), Text(agent.initiative.toString(), style: const TextStyle(fontSize: 12)) ]),
                TableRow(children: [ const Text("Type Attaque:", style: TextStyle(fontSize: 12)), Text(agent.typeAttaque, style: const TextStyle(fontSize: 12)) ]),
              ]
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Fermer'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  /// Affiche un AlertDialog présentant un récapitulatif textuel des statistiques de l'anticorps sélectionné.
  void _showAntibodyDetails(Anticorps anti) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Text(anti.nom, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: const {
              0: IntrinsicColumnWidth(),
              1: FlexColumnWidth(),
            },
            children: [
              TableRow(children: [
                const Text("Nom:", style: TextStyle(fontSize: 12)),
                Text(anti.nom, style: const TextStyle(fontSize: 12))
              ]),
              TableRow(children: [
                const Text("PV:", style: TextStyle(fontSize: 12)),
                Text(anti.pv.toString(), style: const TextStyle(fontSize: 12))
              ]),
              TableRow(children: [
                const Text("Type Attaque:", style: TextStyle(fontSize: 12)),
                Text(anti.typeAttaque, style: const TextStyle(fontSize: 12))
              ]),
              TableRow(children: [
                const Text("Dégâts:", style: TextStyle(fontSize: 12)),
                Text(anti.degats.toString(), style: const TextStyle(fontSize: 12))
              ]),
              TableRow(children: [
                const Text("Coût Ressources:", style: TextStyle(fontSize: 12)),
                Text(anti.coutRessources.toString(), style: const TextStyle(fontSize: 12))
              ]),
              TableRow(children: [
                const Text("Temps Production:", style: TextStyle(fontSize: 12)),
                Text("${anti.tempsProduction}s", style: const TextStyle(fontSize: 12))
              ]),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Fermer'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }


  /// Retourne l'icône représentant un agent, en fonction de son type et sous-type.
  Widget _getAgentIcon(AgentPathogene agent) {
    IconData icon = Icons.bug_report; // Icône par défaut pour agent
    Color color = Colors.deepOrangeAccent; // Couleur par défaut pour agent

    String? agentKey = agent.runtimeType.toString(); // Utilise le type d'exécution
    String? subKey = agent.customType; // Utilise le customType pour le sous-type

    if (agentSubtypes.containsKey(agentKey)) {
      if (subKey != null && subtypeDetails.containsKey(agentKey) && subtypeDetails[agentKey]!.containsKey(subKey)) {
        icon = subtypeDetails[agentKey]![subKey]!["icon"] ?? icon;
        color = subtypeDetails[agentKey]![subKey]!["color"] ?? color;
      }
    }
    // Si customType n'est pas trouvé dans subtypeDetails, utilise l'icône/couleur par défaut du type principal
    else {
      if (agent is Bacterie) { icon = Icons.biotech; color = Colors.purpleAccent; } // Couleur ajustée
      else if (agent is Champignon) { icon = Icons.eco; color = Colors.brown; }
      else if (agent is Virus) { icon = Icons.coronavirus; color = Colors.redAccent; } // Couleur ajustée
    }


    return Icon(icon, size: 24, color: color); // Taille de l'icône augmentée
  }


  /// Retourne l'icône représentant un anticorps.
  Widget _getAntibodyIcon(Anticorps anti) {
    // Utilise une icône générique pour l'anticorps basique avec une couleur assortie.
    return const Icon(Icons.verified_user, color: Colors.cyanAccent, size: 24); // Icône et couleur assorties, taille augmentée
  }


  @override
  Widget build(BuildContext context) {
    // ref.watch écoute les changements du GameState
    final gameState = ref.watch(gameStateProvider);
    final laboratoire = gameState.laboratoireCreation;
    final int energie = gameState.ressources.energie;
    final int bio = gameState.ressources.bioMateriaux;

    // Accéder à usedAgentSubtypes depuis le GameState.
    // Utilise la map persistante pour déterminer les sous-types disponibles.
    List<String> availableSubtypes = agentSubtypes[selectedAgentType]!
        .where((s) => !gameState.usedAgentSubtypes[selectedAgentType]!.contains(s)) // Utilise gameState.usedAgentSubtypes
        .toList();

    // S'assurer qu'un sous-type est sélectionné s'il y en a, ou null sinon.
    // Fait ceci ici dans build car initState n'a pas accès au GameState via ref.
    // Cela garantit que le dropdown est toujours synchronisé avec l'état actuel après un chargement Hive.
    if (availableSubtypes.isNotEmpty && (selectedAgentSubtype == null || !availableSubtypes.contains(selectedAgentSubtype))) {
      // Si le sous-type actuel n'est plus disponible ou n'est pas initialisé, sélectionner le premier disponible.
      selectedAgentSubtype = availableSubtypes.first;
    } else if (availableSubtypes.isEmpty) {
      // Si aucun sous-type disponible, sélectionner null.
      selectedAgentSubtype = null;
    }


    // Coût énergétique pour créer un agent.
    const int energyCostAgent = 20;
    // Coût en bio-matériaux pour créer un anticorps de base.
    final int bioCostAnticorps = laboratoire.coutCreationAnticorps;


    return Scaffold(
      // --- NOUVEAU : Couleur d'arrière-plan du Scaffold ---
      backgroundColor: Colors.blueGrey[800], // Couleur de fond sombre
      appBar: AppBar(
        title: const Text("Laboratoire & Création"),
        backgroundColor: Colors.blueGrey[900], // Couleur plus sombre pour l'AppBar
        elevation: 4, // Ombre
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16), // Padding augmenté
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Titre de la section Ressources
            Center(
                child: Text(
                  "Ressources",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent, // Couleur vive
                      shadows: [
                        Shadow(blurRadius: 8.0, color: Colors.black.withOpacity(0.5), offset: const Offset(1.0, 1.0)),
                      ]
                  ),
                )
            ),
            const SizedBox(height: 16),

            // Ressources affichées avec progress bars améliorées.
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.blueGrey[100]!.withOpacity(0.9), // Fond clair et transparent
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildResourceProgress("Énergie", energie),
                    _buildResourceProgress("Bio-Mat.", bio),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24), // Espacement augmenté

            // Formulaire de création d'un agent pathogène.
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8), // Marge ajustée
              elevation: 8, // Ombre
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Coins arrondis
              color: Colors.blueGrey[100]!.withOpacity(0.9), // Fond clair et transparent
              child: Padding(
                padding: const EdgeInsets.all(16), // Padding augmenté
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("Créer un Agent Pathogène",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blueGrey[800])), // Style de texte
                    const SizedBox(height: 16), // Espacement
                    // Dropdown pour sélectionner le Type principal
                    DropdownButtonFormField<String>(
                      value: selectedAgentType,
                      dropdownColor: Colors.blueGrey[50], // Fond du dropdown
                      style: TextStyle(color: Colors.blueGrey[800], fontSize: 14), // Style du texte
                      items: agentSubtypes.keys
                          .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            selectedAgentType = v;
                            // Réinitialise le sous-type sélectionné lorsque le type principal change
                            final avail = agentSubtypes[selectedAgentType]!
                                .where((s) => !gameState.usedAgentSubtypes[selectedAgentType]!.contains(s)) // Utilise gameState.usedAgentSubtypes
                                .toList();
                            selectedAgentSubtype = avail.isNotEmpty ? avail.first : null;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "Type d'agent",
                        labelStyle: TextStyle(color: Colors.blueGrey[700]), // Style du label
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), // Bordures arrondies
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Padding ajusté
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8), // Fond du champ
                      ),
                    ),
                    const SizedBox(height: 12), // Espacement
                    // Liste déroulante pour le sous-type spécifique
                    DropdownButtonFormField<String?>(
                      value: selectedAgentSubtype,
                      dropdownColor: Colors.blueGrey[50], // Fond du dropdown
                      style: TextStyle(color: Colors.blueGrey[800], fontSize: 14), // Style du texte
                      items: availableSubtypes
                          .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s),
                      ))
                          .toList(),
                      onChanged: availableSubtypes.isEmpty ? null : (v) {
                        if (v != null) {
                          setState(() {
                            selectedAgentSubtype = v;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "Sous-type",
                        labelStyle: TextStyle(color: Colors.blueGrey[700]), // Style du label
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), // Bordures arrondies
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Padding ajusté
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8), // Fond du champ
                      ),
                      hint: availableSubtypes.isEmpty ? Text("Aucun sous-type dispo", style: TextStyle(color: Colors.blueGrey[500])) : null, // Style du hint
                    ),
                    const SizedBox(height: 16), // Espacement
                    // Bouton pour déclencher la création de l'agent.
                    ElevatedButton.icon(
                      onPressed: selectedAgentSubtype == null
                          ? null
                          : () {
                        if (energie < energyCostAgent) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Pas assez d'énergie pour créer un agent ($energyCostAgent requis).")),
                          );
                          return;
                        }
                        try {
                          gameState.consommerEnergie(energyCostAgent);
                          final stats = _getAgentStats(selectedAgentType);
                          final newAgent = laboratoire.creerAgentPathogeneManual(
                            type: selectedAgentType,
                            pv: stats["PV"],
                            armure: stats["Armure"],
                            degats: stats["Dégâts"],
                            initiative: stats["Initiative"],
                          );
                          newAgent.customType = selectedAgentSubtype!;

                          gameState.addAgentToBase(newAgent);

                          // Marquer le sous-type comme utilisé via GameState.
                          gameState.markAgentSubtypeAsUsed(selectedAgentType, selectedAgentSubtype!);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Agent Pathogène créé !")),
                          );
                          // setState est nécessaire ici pour que le dropdown des sous-types se mette à jour
                          // immédiatement après la création, recalculant les availableSubtypes.
                          setState(() {
                            // La logique de sélection du premier sous-type disponible est déjà gérée en haut du build.
                            // On force juste la reconstruction pour que la liste availableSubtypes soit recalculée.
                          });
                        } catch (e) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      },
                      icon: const Icon(Icons.add, size: 18), // Taille de l'icône augmentée
                      label: Text("Créer Agent ($energyCostAgent Énergie)", style: const TextStyle(fontSize: 14)), // Taille du texte augmentée
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrangeAccent, // Couleur vive pour l'action de création d'agent
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Padding ajusté
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)) // Coins arrondis
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16), // Espacement

            // Formulaire de création d'un anticorps.
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8), // Marge ajustée
              elevation: 8, // Ombre
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Coins arrondis
              color: Colors.blueGrey[100]!.withOpacity(0.9), // Fond clair et transparent
              child: Padding(
                padding: const EdgeInsets.all(16), // Padding augmenté
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("Créer un Anticorps Basique",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blueGrey[800])), // Style de texte
                    const SizedBox(height: 16), // Espacement

                    // Bouton pour déclencher la création de l'anticorps.
                    ElevatedButton.icon(
                      onPressed: () {
                        final cost = bioCostAnticorps;
                        if (bio < cost) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Pas assez de bio-matériaux pour créer un anticorps basique ($cost requis).")),
                          );
                          return;
                        }
                        try {
                          gameState.consommerBioMateriaux(cost);
                          final autoName = "Anticorps Basique-${gameState.anticorps.length + 1}";

                          final newAnti = laboratoire.creerAnticorps(
                            nom: autoName,
                            coutRessources: cost,
                            typeAttaque: "Généraliste",
                            pv: 80,
                            degats: 20,
                            tempsProduction: 10,
                          );

                          gameState.addAnticorps(newAnti);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Anticorps Basique créé !")),
                          );
                          // Pas de setState nécessaire ici car gameState.addAnticorps(newAnti) appelle notifyListeners()
                        } catch (e) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      },
                      icon: const Icon(Icons.add, size: 18), // Taille de l'icône augmentée
                      label: Text("Créer Anticorps Basique ($bioCostAnticorps Bio-Mat.)", style: const TextStyle(fontSize: 14)), // Taille du texte augmentée
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent, // Couleur vive pour l'action de création d'anticorps
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Padding ajusté
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)) // Coins arrondis
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24), // Espacement augmenté

            // Liste des agents existants (dans la base virale du joueur) affichée en grille.
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8), // Marge ajustée
              elevation: 8, // Ombre
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Coins arrondis
              color: Colors.blueGrey[100]!.withOpacity(0.9), // Fond clair et transparent
              child: Padding(
                padding: const EdgeInsets.all(16), // Padding augmenté
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("Mes Agents Pathogènes",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blueGrey[800])), // Style de texte
                    const Divider(color: Colors.blueGrey), // Couleur de la diviseur
                    // Accéder aux agents via baseVirale.agents
                    gameState.baseVirale.agents.isEmpty
                        ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(child: Text("Aucun agent créé.", style: TextStyle(color: Colors.black54))), // Style de texte
                    )
                        : GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.0,
                      mainAxisSpacing: 8.0, // Espacement augmenté
                      crossAxisSpacing: 8.0, // Espacement augmenté
                      // Boucler sur gameState.baseVirale.agents
                      children: gameState.baseVirale.agents.map((agent) {
                        final displayName = agent.customType ?? agent.nom;
                        return GestureDetector(
                          onTap: () => _showAgentDetails(agent),
                          child: Card(
                            elevation: 4.0, // Ombre légère
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Coins arrondis
                            color: Colors.white.withOpacity(0.9), // Fond blanc semi-transparent
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _getAgentIcon(agent),
                                const SizedBox(height: 4),
                                Text(
                                  displayName,
                                  style: const TextStyle(fontSize: 10, color: Colors.black87), // Style de texte
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16), // Espacement

            // Liste des anticorps existants affichée en grille.
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8), // Marge ajustée
              elevation: 8, // Ombre
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Coins arrondis
              color: Colors.blueGrey[100]!.withOpacity(0.9), // Fond clair et transparent
              child: Padding(
                padding: const EdgeInsets.all(16), // Padding augmenté
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("Mes Anticorps",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blueGrey[800])), // Style de texte
                    const Divider(color: Colors.blueGrey), // Couleur de la diviseur
                    gameState.anticorps.isEmpty
                        ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(child: Text("Aucun anticorps créé.", style: TextStyle(color: Colors.black54))), // Style de texte
                    )
                        : GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.0,
                      mainAxisSpacing: 8.0, // Espacement augmenté
                      crossAxisSpacing: 8.0, // Espacement augmenté
                      children: gameState.anticorps.map((anti) {
                        return GestureDetector(
                          onTap: () => _showAntibodyDetails(anti),
                          child: Card(
                            elevation: 4.0, // Ombre légère
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Coins arrondis
                            color: Colors.white.withOpacity(0.9), // Fond blanc semi-transparent
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _getAntibodyIcon(anti),
                                const SizedBox(height: 4),
                                Text(
                                  anti.nom,
                                  style: const TextStyle(fontSize: 10, color: Colors.black87), // Style de texte
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal, // Couleur assortie au bouton Accueil
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
