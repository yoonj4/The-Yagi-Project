import 'package:hive/hive.dart';
part 'contacts.g.dart';

@HiveType(typeId: 0)
class EmergencyContact extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String number;
}