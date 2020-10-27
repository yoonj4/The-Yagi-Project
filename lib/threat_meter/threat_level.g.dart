// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'threat_level.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ThreatLevelAdapter extends TypeAdapter<ThreatLevel> {
  @override
  final int typeId = 1;

  @override
  ThreatLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ThreatLevel.noThreat;
      case 1:
        return ThreatLevel.caution;
      case 2:
        return ThreatLevel.highThreat;
      default:
        return null;
    }
  }

  @override
  void write(BinaryWriter writer, ThreatLevel obj) {
    switch (obj) {
      case ThreatLevel.noThreat:
        writer.writeByte(0);
        break;
      case ThreatLevel.caution:
        writer.writeByte(1);
        break;
      case ThreatLevel.highThreat:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThreatLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
