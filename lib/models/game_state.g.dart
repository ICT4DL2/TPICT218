// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameStateAdapter extends TypeAdapter<GameState> {
  @override
  final int typeId = 99;

  @override
  GameState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameState()
      ..playerName = fields[14] as String
      ..ressources = fields[0] as RessourcesDefensives
      ..memoire = fields[1] as MemoireImmunitaire
      ..anticorps = (fields[2] as List).cast<Anticorps>()
      ..baseVirale = fields[3] as BaseVirale
      ..battleData = fields[4] as String
      ..usedAgentSubtypes = (fields[5] as Map).map((dynamic k, dynamic v) =>
        MapEntry(k as String, (v as List<String>).toSet()))
      ..immuneSystemLevel = fields[7] as int
      ..isImmuneSystemUpgrading = fields[10] as bool
      ..immuneSystemUpgradeEndTime = fields[11] as DateTime?
      ..attackHistory = (fields[12] as List).cast<CombatResult>()
      ..defenseHistory = (fields[13] as List).cast<CombatResult>();
  }

  @override
  void write(BinaryWriter writer, GameState obj) {
    writer
      ..writeByte(12)
      ..writeByte(14)
      ..write(obj.playerName)
      ..writeByte(0)
      ..write(obj.ressources)
      ..writeByte(1)
      ..write(obj.memoire)
      ..writeByte(2)
      ..write(obj.anticorps)
      ..writeByte(3)
      ..write(obj.baseVirale)
      ..writeByte(4)
      ..write(obj.battleData)
      ..writeByte(5)
      ..write(obj.usedAgentSubtypes)
      ..writeByte(7)
      ..write(obj.immuneSystemLevel)
      ..writeByte(10)
      ..write(obj.isImmuneSystemUpgrading)
      ..writeByte(11)
      ..write(obj.immuneSystemUpgradeEndTime)
      ..writeByte(12)
      ..write(obj.attackHistory)
      ..writeByte(13)
      ..write(obj.defenseHistory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
