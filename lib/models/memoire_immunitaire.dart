import 'package:hive/hive.dart';
part 'memoire_immunitaire.g.dart';

@HiveType(typeId: 7)
class MemoireImmunitaire {
  @HiveField(0)
  final Map<String, int> signatures = {};

  void ajouterSignature(String typePathogene) {
    if (signatures.containsKey(typePathogene)) {
      signatures[typePathogene] = signatures[typePathogene]! + 1;
    } else {
      signatures[typePathogene] = 1;
    }
  }

  int getBonus(String typePathogene) {
    return signatures[typePathogene] ?? 0;
  }
}