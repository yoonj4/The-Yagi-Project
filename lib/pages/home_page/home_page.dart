import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:the_yagi_project/models/event.dart';

import 'package:the_yagi_project/models/settings/settings.dart';
import 'package:the_yagi_project/services/location.dart';
import 'package:the_yagi_project/services/sms.dart';
import 'package:the_yagi_project/threat_meter/threat_level.dart';
import 'package:the_yagi_project/threat_meter/threat_meter.dart';
import 'package:the_yagi_project/threat_meter/threat_meter_thumb_shape.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.settings}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final Settings settings;
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _warningValue = 0.5;
  double _alertValue = 1;

  double _value = 0.0;
  ThreatLevel _currentThreatLevel = ThreatLevel.noThreat;
  DateTime _lastThreatLevelModifiedTime = DateTime.fromMillisecondsSinceEpoch(0);  // represented in milliseconds since epoch. -1 is the value to represent it's never been set.
  SliderComponentShape _thumbShape = ThreatMeterThumbShape();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
          children: [
            RotatedBox(
              quarterTurns: 3,
              child: ThreatMeter(
                value: _value,
                thumbShape: _thumbShape,
                onChanged: (double value) {
                  setState(() {
                    _value = value;
                  });
                },
                onChangeStart: (double value) {
                  setState(() {
                    _thumbShape = DraggingThreatMeterThumbShape();
                  });
                },
                onChangeEnd: (double value) {
                  DateTime now = DateTime.now();
                  setState(() {
                    _handleThumbRelease(value, now);
                  });
                },
              ),
            ),
            Row(
              children: [
                Expanded( child: FlatButton(
                    onPressed: (){ Navigator.pushNamed(context, '/contacts'); },
                    color: Colors.amber,
                    child: Text('Contacts')
                )),
                Expanded( child: FlatButton(
                    onPressed: (){ Navigator.pushNamed(context, '/settings'); },
                    color: Colors.amber,
                    child: Text('Settings')
                )),
                Expanded( child: FlatButton(
                    onPressed: (){ Navigator.pushNamed(context, '/log'); },
                    color: Colors.amber,
                    child: Text('Log')
                )),
                Expanded( child: FlatButton(
                    onPressed: (){ Navigator.pushNamed(context, '/about'); },
                    color: Colors.amber,
                    child: Text('About')
                )),
              ],
            )
          ]
      ),
    );
  }

  void _handleThumbRelease(double value, DateTime now) {
    if (value >= _warningValue && value < _alertValue) {
      if (_currentThreatLevel != ThreatLevel.caution) {
        // first time
        _sendMessage('2063269710', widget.settings.messageTemplate.getCautionMessage(), now, _convertToThreatLevel(value));
      } else if (_canSendMessage(now)) {
        // if we did this action repeatedly
        _sendMessage('2063269710', widget.settings.messageTemplate.getCautionMessage(), now, _convertToThreatLevel(value));
      }
    } else if (value >= _alertValue) {
      if (_currentThreatLevel != ThreatLevel.highThreat) {
        _sendMessage('2063269710', widget.settings.messageTemplate.getHighThreatMessage(), now, _convertToThreatLevel(value));
      } else if (_canSendMessage(now)) {
        _sendMessage('2063269710', widget.settings.messageTemplate.getHighThreatMessage(), now, _convertToThreatLevel(value));
      }
    } else if(_currentThreatLevel != ThreatLevel.noThreat) {
      _sendMessage('2063269710', widget.settings.messageTemplate.getNoThreatMessage(), now, _convertToThreatLevel(value));
    }

    _thumbShape = ThreatMeterThumbShape();
   _currentThreatLevel = _convertToThreatLevel(value);

    if (_canSendMessage(now)) {
      _lastThreatLevelModifiedTime = now;
    }
  }

  bool _canSendMessage(DateTime now) {
    // We can send a message if it's been 10 seconds since the previous message
    return now.isAfter(_lastThreatLevelModifiedTime.add(const Duration(seconds: 10)));
  }

  void _sendMessage(String number, String message, DateTime now, ThreatLevel threatLevel) async {
    sendSMS(number, message);
    String mapsUrl = await getMapsUrl();
    print(mapsUrl);
    Fluttertoast.showToast(
        msg: "You sent an alert.",
    );
    Event(
      now, mapsUrl, threatLevel, message, null
    );
  }

  ThreatLevel _convertToThreatLevel(double value){
    if (value >= _warningValue && value < _alertValue) {
      return ThreatLevel.caution;
    } else if (value >= _alertValue) {
      return ThreatLevel.highThreat;
    } else if (value < _warningValue) {
      return ThreatLevel.noThreat;
    }
  }
}

