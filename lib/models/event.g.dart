// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventAdapter extends TypeAdapter<Event> {
  @override
  final int typeId = 0;

  @override
  Event read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Event()
      ..eventDateTime = fields[0] as DateTime
      ..location = fields[1] as String
      ..threatLevel = fields[2] as ThreatLevel
      ..message = fields[3] as String
      ..emergencyContacts = (fields[4] as List)?.cast<EmergencyContact>();
  }

  @override
  void write(BinaryWriter writer, Event obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.eventDateTime)
      ..writeByte(1)
      ..write(obj.location)
      ..writeByte(2)
      ..write(obj.threatLevel)
      ..writeByte(3)
      ..write(obj.message)
      ..writeByte(4)
      ..write(obj.emergencyContacts);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
