import 'package:hive/hive.dart';
part 'ressources_defensives.g.dart';

@HiveType(typeId: 8)
class RessourcesDefensives {
  @HiveField(0)
  int energie;

  @HiveField(1)
  int bioMateriaux;

  RessourcesDefensives({this.energie = 100, this.bioMateriaux = 100});

  /// Régénère passivement les ressources.
  void regenerer() {
    energie = (energie + 5).clamp(0, 100);
    bioMateriaux = (bioMateriaux + 5).clamp(0, 100);
  }

  /// Consomme une quantité d'énergie donnée, si suffisante.
  bool consommerEnergie(int quantite) {
    if (energie >= quantite) {
      energie -= quantite;
      return true;
    }
    return false;
  }

  /// Consomme une quantité de biomatériaux donnée, si suffisante.
  bool consommerBioMateriaux(int quantite) {
    if (bioMateriaux >= quantite) {
      bioMateriaux -= quantite;
      return true;
    }
    return false;
  }
}