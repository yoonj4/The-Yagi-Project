import 'package:hive/hive.dart';
part 'threat_level.g.dart';


@HiveType(typeId: 1)
enum ThreatLevel {
  @HiveField(0)
  noThreat,

  @HiveField(1)
  caution,

  @HiveField(2)
  highThreat
}