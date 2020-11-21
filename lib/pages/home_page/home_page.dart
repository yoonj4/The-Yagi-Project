import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:mms/mms.dart';
import 'package:the_yagi_project/models/contacts.dart';
import 'package:the_yagi_project/models/event.dart';
import 'package:the_yagi_project/models/settings/settings.dart';
import 'package:the_yagi_project/models/settings/threat_meter_values.dart';
import 'package:the_yagi_project/services/location.dart';
import 'package:the_yagi_project/services/phone.dart';
import 'package:the_yagi_project/services/sms.dart';
import 'package:the_yagi_project/settings_bloc.dart';
import 'package:the_yagi_project/threat_meter/threat_level.dart';
import 'package:the_yagi_project/threat_meter/threat_meter.dart';
import 'package:the_yagi_project/threat_meter/threat_meter_thumb_shape.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.settings, this.cameraController, this.videoDirectory}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final Settings settings;
  final CameraController cameraController;
  final String title;
  final Directory videoDirectory;

  @override
  _MyHomePageState createState() => _MyHomePageState(settings: settings);
}


class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState({this.settings});

  final Settings settings;

  double _value = 0.0;
  double _warningValue;
  double _alertValue;
  ThreatLevel _currentThreatLevel = ThreatLevel.noThreat;
  DateTime _lastThreatLevelModifiedTime = DateTime.fromMillisecondsSinceEpoch(0);  // represented in milliseconds since epoch. -1 is the value to represent it's never been set.
  SliderComponentShape _thumbShape = ThreatMeterThumbShape();
  Box<EmergencyContact> emergencyContacts;
  String _videoPath;

  @override
  Widget build(BuildContext context) {
    if (_warningValue == null) {
      _warningValue = settings.threatMeterValues.getWarningValue();
    }

    if (_alertValue == null) {
      _alertValue = settings.threatMeterValues.getAlertValue();
    }
    emergencyContacts = Hive.box<EmergencyContact>('emergency');

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
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(5.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Colors.black.withAlpha(0),
                  Colors.black12,
                  Colors.cyan
                ],
              ),
            ),
            child: AspectRatio(
              aspectRatio: widget.cameraController.value.aspectRatio,
              child: CameraPreview(widget.cameraController),
            ),
          ),
          Container(
            // this container may be unnecessary
            // width: 300,
            // height: 200,
            // color: Colors.cyan,
            // transform: Matrix4.rotationZ(.1),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..translate(50.0, 50)
                ..scale(1.0, 1.0)
                ..rotateZ(-math.pi / 2),
              child: BlocListener<SettingsBloc, SettingsState>(
                listenWhen: (previous, current) {
                  Object previousSettings = previous.props.first;
                  Object currentSettings = current.props.first;

                  if (previousSettings is Settings && currentSettings is Settings) {
                    return previousSettings.threatMeterValues.getWarningValue() != currentSettings.threatMeterValues.getWarningValue()
                        || previousSettings.threatMeterValues.getAlertValue() != currentSettings.threatMeterValues.getAlertValue();
                  }

                  return false;
                },
                listener: (context, state) {
                  print("listening");
                  Object settings = state.props.first;
                  if (settings is Settings) {
                    setState(() {
                      _warningValue = settings.threatMeterValues.getWarningValue();
                      _alertValue = settings.threatMeterValues.getAlertValue();
                    });
                  }
                },
                child: _buildThreatMeter(settings),
              ),
            ),
          ),
          Positioned(
            bottom: 15,
            left: 15,
            child:
              Text(
              "THIS IS A BATMAN",
              style: TextStyle(color: Colors.black87, fontSize: 20.0),
              ),
          ),
        ],
      ),
      bottomNavigationBar: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
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
      ),
    );
  }

  Widget _buildThreatMeter(Settings settings) {
    if (settings != null) {
      _warningValue = settings.threatMeterValues.getWarningValue();
      _alertValue = settings.threatMeterValues.getAlertValue();
    }
    ThreatMeterValues threatMeterValues = new ThreatMeterValues.nonPermanent(_warningValue, _alertValue);
    return ThreatMeter(
      key: ValueKey(threatMeterValues),
      value: _value,
      cautionHeight: _warningValue,
      highThreatHeight: _alertValue,
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
        _videoPath = widget.videoDirectory.path + '/'
            + DateTime.now().millisecondsSinceEpoch.toString()
            + '.mp4';
        print(_videoPath);
        widget.cameraController.startVideoRecording(_videoPath);
      },
      onChangeEnd: (double value) {
        widget.cameraController.stopVideoRecording();
        DateTime now = DateTime.now();
        setState(() {
          _handleThumbRelease(value, now);
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    widget.cameraController.dispose();
  }

  void _handleThumbRelease(double value, DateTime now) {
    if (value >= _warningValue && value < _alertValue) {
      if (_currentThreatLevel != ThreatLevel.caution) {
        // first time
        _sendMessage(widget.settings.messageTemplate.getCautionMessage(), now, _convertToThreatLevel(value));
      } else if (_canSendMessage(now)) {
        // if we did this action repeatedly
        _sendMessage(widget.settings.messageTemplate.getCautionMessage(), now, _convertToThreatLevel(value));
      }
    } else if (value >= _alertValue) {
      if (_currentThreatLevel != ThreatLevel.highThreat) {
        _sendMessage(widget.settings.messageTemplate.getHighThreatMessage(), now, _convertToThreatLevel(value));
        makePhoneCall('2063269710', false);
      } else if (_canSendMessage(now)) {
        _sendMessage(widget.settings.messageTemplate.getHighThreatMessage(), now, _convertToThreatLevel(value));
        makePhoneCall('2063269710', false);
      }
    } else if(_currentThreatLevel != ThreatLevel.noThreat) {
      _sendMessage(widget.settings.messageTemplate.getNoThreatMessage(), now, _convertToThreatLevel(value));
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

  void _sendMessage(String message, DateTime now, ThreatLevel threatLevel) async {
    Iterable currentEmergencyContacts = emergencyContacts.values;
    String mapsUrl = await getMapsUrl();
    currentEmergencyContacts.forEach((emergencyContact) {
      sendSMS(emergencyContact.number, message + " " + mapsUrl);
    });
    List<String> recipientNumbers = List<String>.from(currentEmergencyContacts.map((e) => e.number));
    print(recipientNumbers);
    Mms().sendVideo(_videoPath, recipientNumbers);
    Fluttertoast.showToast(
      msg: "You sent an alert.",
    );

    var events = Hive.box<Event>('events');
    await events.add(
      Event(
        eventDateTime: now,
        location: mapsUrl,
        threatLevel: threatLevel,
        message: message,
        emergencyContacts: currentEmergencyContacts.toList(),
      )
    );
  }

  ThreatLevel _convertToThreatLevel(double value){
    if (value >= _warningValue && value < _alertValue) {
      return ThreatLevel.caution;
    } else if (value >= _alertValue) {
      return ThreatLevel.highThreat;
    } else {
      return ThreatLevel.noThreat;
    }
  }
}

