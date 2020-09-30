import 'package:the_yagi_project/models/contacts.dart';
import 'package:the_yagi_project/threat_meter/threat_level.dart';

class Event {
  DateTime eventDateTime; //log time when released
  String location; //map url
  ThreatLevel threatLevel;
  String message;
  List<EmergencyContact> emergencyContacts;

  //constructor
  Event(DateTime eventDateTime,
        String location,
        ThreatLevel threatLevel,
        String message,
        List<EmergencyContact> emergencyContacts){
    this.eventDateTime = eventDateTime;
    this.location = location;
    this.threatLevel = threatLevel;
    this.message = message;
    this.emergencyContacts = emergencyContacts;
  }
}
