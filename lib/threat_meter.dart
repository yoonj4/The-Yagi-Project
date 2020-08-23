import 'package:flutter/material.dart';

class ThreatMeter extends StatefulWidget {
  @override
  _ThreatMeterState createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }

}

class _ThreatMeterState extends State<ThreatMeter> {
  ThreatLevel threatLevel = ThreatLevel.noThreat;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

}

enum ThreatLevel { noThreat, mediumThreat, highThreat }