import 'package:flutter/material.dart';
import 'package:the_yagi_project/services/location.dart';
import 'package:the_yagi_project/services/phone.dart';
import 'custom_slider_thumb_circle.dart';
import 'package:camera/camera.dart';
import 'package:the_yagi_project/threat_meter/threat_level.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:the_yagi_project/models/settings/settings.dart';
import 'package:hive/hive.dart';
import 'package:the_yagi_project/services/sms.dart';
import 'package:the_yagi_project/models/event.dart';
import 'package:mms/mms.dart';
import 'package:the_yagi_project/models/contacts.dart';

class SliderWidget extends StatefulWidget {
  final double sliderHeight;
  final int min;
  final int max;
  final fullWidth;

  final double cautionHeight;
  final double highThreatHeight;

  final Settings settings;

  final videoPath;
  final CameraController cameraController;


  SliderWidget({
    Key key,
    this.settings,
    this.videoPath,
    this.cameraController,
    this.cautionHeight,
    this.highThreatHeight,
    this.sliderHeight = 48,
    this.max = 10,
    this.min = 0,
    this.fullWidth = false,
    }) : super(key: key);

  @override
  _SliderWidgetState createState() => _SliderWidgetState(warningValue: cautionHeight, alertValue: highThreatHeight);
}

class _SliderWidgetState extends State<SliderWidget> {

  _SliderWidgetState({
    this.warningValue,
    this.alertValue,
  }) : super();

  double _value = 0;

  double warningValue;
  double alertValue;
  ThreatLevel _currentThreatLevel = ThreatLevel.noThreat;
  DateTime _lastThreatLevelModifiedTime = DateTime.fromMillisecondsSinceEpoch(0);  // represented in milliseconds since epoch. -1 is the value to represent it's never been set.

  Box<EmergencyContact> emergencyContacts;

  FToast fToast;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  @override
  Widget build(BuildContext context) {
    double paddingFactor = .2;

    if (this.widget.fullWidth) paddingFactor = .3;
    if (warningValue == null) {
      warningValue = widget.settings.threatMeterValues.getWarningValue();
    }

    if (alertValue == null) {
      alertValue = widget.settings.threatMeterValues.getAlertValue();
    }
    emergencyContacts = Hive.box<EmergencyContact>('emergency');


    return Container(
      width: this.widget.fullWidth
          ? double.infinity
          : (this.widget.sliderHeight) * 5.5,
      height: (this.widget.sliderHeight),
      decoration: new BoxDecoration(
        borderRadius: new BorderRadius.all(
          Radius.circular((this.widget.sliderHeight * .3)),
        ),
        gradient: new LinearGradient(
            colors: [
              const Color(0xFF00c6ff),
              const Color(0xFF0072ff),
            ],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(1.0, 1.00),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(this.widget.sliderHeight * paddingFactor,
            2, this.widget.sliderHeight * paddingFactor, 2),
        child: Row(
          children: <Widget>[
            Text(
              '${this.widget.min}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: this.widget.sliderHeight * .3,
                fontWeight: FontWeight.w700,
                color: Colors.white,

              ),
            ),
            SizedBox(
              width: this.widget.sliderHeight * .1,
            ),
            Expanded(
              child: Center(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.white.withOpacity(1),
                    inactiveTrackColor: Colors.white.withOpacity(.5),

                    trackHeight: 4.0,
                    thumbShape: CustomSliderThumbCircle(
                      thumbRadius: this.widget.sliderHeight * .4,
                      min: this.widget.min,
                      max: this.widget.max,
                    ),
                    overlayColor: Colors.white.withOpacity(.4),
                    //valueIndicatorColor: Colors.white,
                    activeTickMarkColor: Colors.white,
                    inactiveTickMarkColor: Colors.red.withOpacity(.7),
                  ),
                  child: Slider(
                    value: _value,
                    onChanged: (value) {
                      setState(() {
                        _value = value;
                      });
                    },
                    onChangeStart: (double value) {
                      /*setState(() {
                          _thumbShape = DraggingThreatMeterThumbShape();
                        });*/
                      print(widget.videoPath);
                      // widget.cameraController.startVideoRecording(widget.videoPath);
                    },
                    onChangeEnd: (double value) {
                      // widget.cameraController.stopVideoRecording();
                      DateTime now = DateTime.now();
                      setState(() {
                        _handleThumbRelease(value, now, context);
                      });
                    },),
                ),
              ),
            ),
            SizedBox(
              width: this.widget.sliderHeight * .1,
            ),
            Text(
              '${this.widget.max}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: this.widget.sliderHeight * .3,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleThumbRelease(double value, DateTime now, BuildContext context) {

    if (value >= warningValue && value < alertValue) {
      if (_currentThreatLevel != ThreatLevel.caution) {
        // first time
        _sendMessage(widget.settings.messageTemplate.getCautionMessage(), now, _convertToThreatLevel(value), context);
      } else if (_canSendMessage(now)) {
        // if we did this action repeatedly
        _sendMessage(widget.settings.messageTemplate.getCautionMessage(), now, _convertToThreatLevel(value), context);
      }
    } else if (value >= alertValue) {
      if (_currentThreatLevel != ThreatLevel.highThreat) {
        _sendMessage(widget.settings.messageTemplate.getHighThreatMessage(), now, _convertToThreatLevel(value), context);
        makePhoneCall('2063269710', false);
      } else if (_canSendMessage(now)) {
        _sendMessage(widget.settings.messageTemplate.getHighThreatMessage(), now, _convertToThreatLevel(value), context);
        makePhoneCall('2063269710', false);
      }
    } else if(_currentThreatLevel != ThreatLevel.noThreat) {
      _sendMessage(widget.settings.messageTemplate.getNoThreatMessage(), now, _convertToThreatLevel(value), context);
    }

    // _thumbShape = ThreatMeterThumbShape();
    _currentThreatLevel = _convertToThreatLevel(value);

    if (_canSendMessage(now)) {
      _lastThreatLevelModifiedTime = now;
    }
  }

  bool _canSendMessage(DateTime now) {
    // We can send a message if it's been 10 seconds since the previous message
    return now.isAfter(_lastThreatLevelModifiedTime.add(const Duration(seconds: 10)));
  }

  void _sendMessage(String message, DateTime now, ThreatLevel threatLevel, BuildContext context) async {
    Iterable currentEmergencyContacts = emergencyContacts.values;
    String mapsUrl = await getMapsUrl();
    currentEmergencyContacts.forEach((emergencyContact) {
      sendSMS(emergencyContact.number, message + " " + mapsUrl);
    });

    List<String> recipientNumbers = List<String>.from(currentEmergencyContacts.map((e) => e.number).map((e) => e.replaceAll(RegExp('[^0-9]'), '')));
    print(recipientNumbers);
    // Mms().sendVideo(widget.videoPath, recipientNumbers);

    _showToast(context);

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
    if (value >= this.warningValue && value < this.alertValue) {
      return ThreatLevel.caution;
    } else if (value >= alertValue) {
      return ThreatLevel.highThreat;
    } else {
      return ThreatLevel.noThreat;
    }
  }

  void _showToast(BuildContext context) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.greenAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check),
          SizedBox(
            width: 12.0,
          ),
          Text("This is a Custom Toast"),
        ],
      ),
    );

    // Custom Toast Position
    fToast.showToast(
        child: toast,
        toastDuration: Duration(seconds: 2),
        positionedToastBuilder: (context, child) {
          return Positioned(
            child: child,
            top: 100.0,
            left: 100.0,
          );
        }
    );
  }
}


