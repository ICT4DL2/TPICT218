import 'package:hive/hive.dart';
import 'agent_pathogene.dart';
part 'base_virale.g.dart';

@HiveType(typeId: 4)
class BaseVirale {
  @HiveField(0)
  final String nom;

  @HiveField(1)
  List<AgentPathogene> agents;

  BaseVirale({
    required this.nom,
    List<AgentPathogene>? agents,
  }) : agents = agents ?? [];

  void ajouterAgent(AgentPathogene agent) {
    agents.add(agent);
  }

  void retirerAgent(AgentPathogene agent) {
    agents.remove(agent);
  }
}