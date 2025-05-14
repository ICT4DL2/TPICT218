// lib/combat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CombatScreen extends ConsumerStatefulWidget {
  const CombatScreen({Key? key}) : super(key: key);

  @override
  _CombatScreenState createState() => _CombatScreenState();
}

class _CombatScreenState extends ConsumerState<CombatScreen> {
  @override
  Widget build(BuildContext context) {
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
                margin: const EdgeInsets.all(32),
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
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Implémentez ici l'action de recherche d'un adversaire
                          },
                          icon: const Icon(Icons.search, size: 20),
                          label: const Text(
                            "Rechercher",
                            style: TextStyle(fontSize: 18, letterSpacing: 1.2),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Partie inférieure : Zone de commandes et d'informations complémentaires (30 % de la hauteur)
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
              child: Center(
                child: Text(
                  "Zone de Commande et Informations",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}