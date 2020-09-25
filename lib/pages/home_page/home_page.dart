import 'package:flutter/material.dart';

import 'package:the_yagi_project/services/location.dart';
import 'package:the_yagi_project/threat_meter/threat_level.dart';
import 'package:the_yagi_project/threat_meter/threat_meter.dart';
import 'package:the_yagi_project/threat_meter/threat_meter_thumb_shape.dart';
import 'package:the_yagi_project/models/settings/settings.dart';
import 'package:the_yagi_project/services/sms.dart';

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
  int _lastThreatLevelModifiedTime = -1;  // represented in milliseconds since epoch. -1 is the value to represent it's never been set.
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
                  int now = DateTime.now().millisecondsSinceEpoch;
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

  void _handleThumbRelease(double value, int now) async {
    String mapsUrl = 'await getMapsUrl()';
    if (value >= _warningValue && value < _alertValue) {
      if (_currentThreatLevel != ThreatLevel.caution) {
        print('asdfasdf' + widget.settings.messageTemplate.getCautionMessage());
        // first time
        sendSMS('2063269710', widget.settings.messageTemplate.getCautionMessage());
        print(mapsUrl);
      } else if (_canSendMessage(now)) {
        // if we did this action repeatedly
        print("YELLOW2");
        print(mapsUrl);
      }
    } else if (value >= _alertValue) {
      if (_currentThreatLevel != ThreatLevel.highThreat) {
        print("RED1");
        print(mapsUrl);
      } else if (_canSendMessage(now)) {
        print("RED2");
        print(mapsUrl);
      }
    } else if(_currentThreatLevel != ThreatLevel.noThreat) {
      print("BACK TO SAFETY");
      print(mapsUrl);
    }

    _thumbShape = ThreatMeterThumbShape();
    if (value >= _warningValue && value < _alertValue) {
      _currentThreatLevel = ThreatLevel.caution;
    } else if (value >= _alertValue) {
      _currentThreatLevel = ThreatLevel.highThreat;
    } else if (value < _warningValue) {
      _currentThreatLevel = ThreatLevel.noThreat;
    }

    if (_canSendMessage(now)) {
      _lastThreatLevelModifiedTime = now;
    }
  }

  bool _canSendMessage(int now) {
    // We can send a message if it's been 10 seconds since the previous message
    return now - _lastThreatLevelModifiedTime >= 10 * 1000;
  }
}