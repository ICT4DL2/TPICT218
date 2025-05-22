// lib/models/ressources_defensives.dart
import 'package:hive/hive.dart';

part 'ressources_defensives.g.dart';

/// Représente les ressources défensives du joueur (Énergie, Bio-Matériaux).
@HiveType(typeId: 8) // Assurez-vous que ce Type ID est unique et cohérent
class RessourcesDefensives {
  @HiveField(0)
  int energie;

  @HiveField(1)
  int bioMateriaux;

  // TODO: Ajouter d'autres types de ressources si nécessaire (ex: Points de Recherche)
  // @HiveField(2)
  // int pointsRecherche;

  RessourcesDefensives({this.energie = 100, this.bioMateriaux = 100});

  /// Régénère passivement les ressources.
  void regenerer() {
    energie = (energie + 5).clamp(0, 100);
    bioMateriaux = (bioMateriaux + 5).clamp(0, 100);
    // TODO: Implémenter la régénération basée sur le temps ou d'autres facteurs.
    // TODO: Ajouter une limite maximale aux ressources (actuellement 100 avec clamp).
  }

  /// Consomme une quantité d'énergie donnée, si suffisante.
  bool consommerEnergie(int quantite) {
    if (energie >= quantite) {
      energie -= quantite;
      // TODO: Ajouter une notification ou un log ici si nécessaire
      return true;
    }
    // TODO: Ajouter une notification ou un log pour ressources insuffisantes
    return false;
  }

  /// Consomme une quantité de biomatériaux donnée, si suffisante.
  bool consommerBioMateriaux(int quantite) {
    if (bioMateriaux >= quantite) {
      bioMateriaux -= quantite;
      // TODO: Ajouter une notification ou un log ici si nécessaire
      return true;
    }
    // TODO: Ajouter une notification ou un log pour ressources insuffisantes
    return false;
  }

  /// Ajoute de l'énergie.
  void ajouterEnergie(int quantite) {
    if (quantite > 0) {
      energie += quantite;
      // TODO: Ajouter une limite maximale si nécessaire (actuellement 100 via clamp dans regenerer, mais pas ici)
      // if (energie > maxEnergie) energie = maxEnergie;
      // TODO: Ajouter une notification ou un log ici si nécessaire
    }
  }

  /// Ajoute des bio-matériaux.
  void ajouterBioMateriaux(int quantite) {
    if (quantite > 0) {
      bioMateriaux += quantite;
      // TODO: Ajouter une limite maximale si nécessaire (actuellement 100 via clamp dans regenerer, mais pas ici)
      // if (bioMateriaux > maxBioMateriaux) bioMateriaux = maxBioMateriaux;
      // TODO: Ajouter une notification ou un log ici si nécessaire
    }
  }

/// TODO: Ajouter une méthode pour consommer ou ajouter d'autres ressources.
// bool consommerPointsRecherche(int quantite) { ... }
// void ajouterPointsRecherche(int quantite) { ... }
}
