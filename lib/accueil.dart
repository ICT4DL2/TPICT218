import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/game_state.dart'; // Assurez-vous que ce fichier exporte gameStateProvider

class Accueil extends ConsumerWidget {
  const Accueil({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On récupère l'état global grâce à Riverpod.
    final gameState = ref.watch(gameStateProvider);

    // Pour cet exemple, nous considérons que la valeur maximale des ressources est 100.
    final double energieValue = (gameState.ressources.energie / 100).clamp(0.0, 1.0).toDouble();
    final double biomatValue = (gameState.ressources.bioMateriaux / 100).clamp(0.0, 1.0).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ImmunoWarriors - Accueil'),
      ),
      // Container avec gradient couvrant toute la surface.
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
            // SingleChildScrollView pour garantir la compatibilité sur petits écrans.
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Affichage des ressources sous forme de barre de progression.
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Énergie',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text('${gameState.ressources.energie}/100'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: energieValue,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                        minHeight: 10,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Bio-Matériaux',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text('${gameState.ressources.bioMateriaux}/100'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: biomatValue,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                        minHeight: 10,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Section Agents Pathogènes
                  const Text(
                    'Agents Pathogènes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: gameState.agents.length,
                    itemBuilder: (context, index) {
                      final agent = gameState.agents[index];
                      return ListTile(
                        leading: const Icon(Icons.bug_report, color: Colors.black87),
                        title: Text(agent.nom),
                        subtitle: Text('PV : ${agent.pv}, Dégâts : ${agent.degats}'),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Section Anticorps
                  const Text(
                    'Anticorps',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: gameState.anticorps.length,
                    itemBuilder: (context, index) {
                      final anticorpsUnit = gameState.anticorps[index];
                      return ListTile(
                        leading: const Icon(Icons.shield, color: Colors.blueGrey),
                        title: Text(anticorpsUnit.nom),
                        subtitle: Text('PV : ${anticorpsUnit.pv}, Dégâts : ${anticorpsUnit.degats}'),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
      // Boutons de navigation placés en bas de l'écran.
      // Le bouton 'Accueil' n'est pas affiché quand on est sur la page d'accueil.
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/laboratoire');
                },
                icon: const Icon(Icons.science),
                label: const Text('Laboratoire'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/recherche');
                },
                icon: const Icon(Icons.search),
                label: const Text('Recherche'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/combat');
                },
                icon: const Icon(Icons.sports_martial_arts),
                label: const Text('Combat'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}