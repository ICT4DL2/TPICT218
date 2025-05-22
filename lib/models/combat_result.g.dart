// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'combat_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CombatResultAdapter extends TypeAdapter<CombatResult> {
  @override
  final int typeId = 20;

  @override
  CombatResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CombatResult(
      playerWon: fields[0] as bool,
      battleSummaryForGemini: fields[1] as String,
      rewards: (fields[2] as Map).cast<String, dynamic>(),
      defeatedPathogenTypes: (fields[3] as List).cast<String>().toSet(),
      opponentIdentifier: fields[4] as String,
      opponentType: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CombatResult obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.playerWon)
      ..writeByte(1)
      ..write(obj.battleSummaryForGemini)
      ..writeByte(2)
      ..write(obj.rewards)
      ..writeByte(3)
      ..write(obj.defeatedPathogenTypes.toList())
      ..writeByte(4)
      ..write(obj.opponentIdentifier)
      ..writeByte(5)
      ..write(obj.opponentType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CombatResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
