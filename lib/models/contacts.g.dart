// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contacts.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmergencyContactAdapter extends TypeAdapter<EmergencyContact> {
  @override
  final int typeId = 2;

  @override
  EmergencyContact read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmergencyContact()
      ..name = fields[0] as String
      ..number = fields[1] as String;
  }

  @override
  void write(BinaryWriter writer, EmergencyContact obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.number);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmergencyContactAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
