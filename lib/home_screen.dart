import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Pas d'AppBar pour obtenir un rendu en plein écran.
      body: Container(
        constraints: const BoxConstraints.expand(), // Le container occupe tout l'espace de l'écran
        decoration: const BoxDecoration(
          // Définition de l'image de fond.
          image: DecorationImage(
            image: AssetImage("assets/images/fond.png"), // Chemin vers votre image. Assurez-vous qu'il est déclaré dans pubspec.yaml.
            fit: BoxFit.fill, // L'image couvre intégralement l'écran.
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }
}