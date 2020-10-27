import 'package:hive/hive.dart';
import 'package:the_yagi_project/models/contacts.dart';
import 'package:the_yagi_project/threat_meter/threat_level.dart';
part 'event.g.dart';

@HiveType(typeId: 0)
class Event extends HiveObject {
  @HiveField(0)
  DateTime eventDateTime; //log time when released

  @HiveField(1)
  String location; //map url

  @HiveField(2)
  ThreatLevel threatLevel;

  @HiveField(3)
  String message;

  @HiveField(4)
  List<EmergencyContact> emergencyContacts;

  //constructor
  Event({DateTime eventDateTime,
        String location,
        ThreatLevel threatLevel,
        String message,
        List<EmergencyContact> emergencyContacts}){
    this.eventDateTime = eventDateTime;
    this.location = location;
    this.threatLevel = threatLevel;
    this.message = message;
    this.emergencyContacts = emergencyContacts;
  }
}



