import 'package:hive/hive.dart';
import 'dart:typed_data';
part 'contacts.g.dart';

@HiveType(typeId: 2)
class EmergencyContact extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String number;

  @HiveField(2)
  Uint8List avatar;

  @HiveField(3)
  String initials;

  //constructor
  EmergencyContact({String name, String number, Uint8List avatar, String initials}) {
    this.name = name;
    this.number = number;
    this.avatar = avatar;
    this.initials = initials;
  }
}