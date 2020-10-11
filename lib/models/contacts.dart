import 'package:hive/hive.dart';
part 'contacts.g.dart';

@HiveType(typeId: 2)
class EmergencyContact extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String number;

  //constructor
  EmergencyContact({String name, String number}) {
    this.name = name;
    this.number = number;
  }
}