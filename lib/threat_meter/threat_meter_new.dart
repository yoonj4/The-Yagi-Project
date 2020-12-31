import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:the_yagi_project/services/location.dart';
import 'package:the_yagi_project/services/phone.dart';
import 'package:the_yagi_project/threat_meter/threat_meter_tick_mark_shape.dart';
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
import 'dart:math' as math;

class SliderWidget extends StatefulWidget {
  final double sliderHeight;
  final int min;
  final int max;

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
  }) : super(key: key);

  @override
  _SliderWidgetState createState() => _SliderWidgetState(
      warningValue: cautionHeight, alertValue: highThreatHeight,);
}

class _SliderWidgetState extends State<SliderWidget> {
  _SliderWidgetState({
    this.warningValue,
    this.alertValue,
  }) : super();

  double _value = 0;
  String _videoFilePath;

  double warningValue;
  double alertValue;
  ThreatLevel _currentThreatLevel = ThreatLevel.noThreat;
  DateTime _lastThreatLevelModifiedTime = DateTime.fromMillisecondsSinceEpoch(
      0); // represented in milliseconds since epoch. -1 is the value to represent it's never been set.

  Box<EmergencyContact> emergencyContacts;
  Color test = Colors.white;

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

    if (warningValue == null)
      warningValue = widget.settings.threatMeterValues.getWarningValue();
    if (alertValue == null)
      alertValue = widget.settings.threatMeterValues.getAlertValue();

    emergencyContacts = Hive.box<EmergencyContact>('emergency');

    double width = widget.sliderHeight * 5.5;
    double height = widget.sliderHeight;

    // everything is rotated, so use these values post rotation
    double rotatedHeight = width;
    double rotatedWidth = height;

    var warningPixelValue = rotatedHeight * warningValue;
    var alertPixelValue = rotatedHeight * alertValue;

    Color warningColor = Colors.yellow;
    Color alertColor = Colors.yellow;
    Color okayColor = Colors.green;

    Color thumbOverlayColor = okayColor;

    return Container(
        transform: Matrix4.identity()
          ..translate(width / 2, height / 2)
          ..rotateZ(-math.pi / 2)
          ..translate(-width / 2, -height / 2),
        alignment: Alignment.center,
        width:  widget.sliderHeight * 5.5,
        height: widget.sliderHeight,
        decoration: new BoxDecoration(
          borderRadius: new BorderRadius.all(
            Radius.circular((this.widget.sliderHeight * 1)),
          ),
          gradient: new LinearGradient(
              colors: [
                test,
                const Color(0xFF0072ff),
              ],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 1.00),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp),
        ),
        child: Stack(children: [
          Center(
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
                overlayColor: thumbOverlayColor.withOpacity(.5),
                valueIndicatorColor: Colors.red,
                activeTickMarkColor: Colors.red,
                inactiveTickMarkColor: Colors.red.withOpacity(.7),
              ),
              child: Slider(
                value: _value,
                onChanged: (value) {
                  setState(() {
                    _value = value;
                    if(_value > warningValue)
                      thumbOverlayColor = warningColor;
                    else if (_value > alertValue)
                      thumbOverlayColor = alertColor;
                    else
                      thumbOverlayColor = okayColor;
                  });
                },
                onChangeStart: (double value) {
                  setState(() {
                    // _thumbShape = DraggingThreatMeterThumbShape();
                    test = Colors.transparent;
                    _videoFilePath = widget.videoPath +
                        '/' +
                        DateTime.now().millisecondsSinceEpoch.toString() +
                        '.mp4';
                  });
                  print(_videoFilePath);
                  widget.cameraController.startVideoRecording(_videoFilePath);
                },
                onChangeEnd: (double value) {
                  widget.cameraController.stopVideoRecording();
                  DateTime now = DateTime.now();
                  setState(() {
                    _handleThumbRelease(value, now, context);
                    test = Colors.white;
                  });
                },
              ),
            ),
          ),
          Container(
            transform: Matrix4.identity()
              ..translate(warningPixelValue)
              ..scale(.1, .1)
              ..rotateZ(math.pi / 2),
            decoration: new BoxDecoration(
              borderRadius: new BorderRadius.all(
                Radius.circular((this.widget.sliderHeight * 1)),
                ),
              gradient: new LinearGradient(
              colors: [
                Colors.yellow,
                Colors.yellow,
              ],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 1.00),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp),
            ),
          ), // warning marker
          Container(
            transform: Matrix4.identity()
              ..translate(warningPixelValue, -25)
              ..scale(.5, .5)
              ..rotateZ(math.pi / 2),
            child: Icon(Icons.warning, color: Colors.yellow)
          ), // warning Icon
          Container(
            transform: Matrix4.identity()
              ..translate(alertPixelValue)
              ..scale(.1, .1)
              ..rotateZ(math.pi / 2),
            decoration: new BoxDecoration(
              borderRadius: new BorderRadius.all(
                Radius.circular((this.widget.sliderHeight * 1)),
              ),
              gradient: new LinearGradient(
                  colors: [
                    Colors.red,
                    Colors.red,
                  ],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(1.0, 1.00),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp),
            ),
          ), // alert marker
          Container(
              transform: Matrix4.identity()
                ..translate(alertPixelValue, -25)
                ..scale(.5, .5)
                ..rotateZ(math.pi / 2),
              child: Icon(Icons.whatshot, color: Colors.red)
          ), // alert Icon
        ]
      )

    );
  }

  void _handleThumbRelease(double value, DateTime now, BuildContext context) {
    if (value >= warningValue && value < alertValue) {
      if (_currentThreatLevel != ThreatLevel.caution) {
        // first time
        _sendMessage(widget.settings.messageTemplate.getCautionMessage(), now,
            _convertToThreatLevel(value), context);
      } else if (_canSendMessage(now)) {
        // if we did this action repeatedly
        _sendMessage(widget.settings.messageTemplate.getCautionMessage(), now,
            _convertToThreatLevel(value), context);
      }
    } else if (value >= alertValue) {
      if (_currentThreatLevel != ThreatLevel.highThreat) {
        _sendMessage(widget.settings.messageTemplate.getHighThreatMessage(),
            now, _convertToThreatLevel(value), context);
        makePhoneCall('2063269710', false);
      } else if (_canSendMessage(now)) {
        _sendMessage(widget.settings.messageTemplate.getHighThreatMessage(),
            now, _convertToThreatLevel(value), context);
        makePhoneCall('2063269710', false);
      }
    } else if (_currentThreatLevel != ThreatLevel.noThreat) {
      _sendMessage(widget.settings.messageTemplate.getNoThreatMessage(), now,
          _convertToThreatLevel(value), context);
    }

    // _thumbShape = ThreatMeterThumbShape();
    _currentThreatLevel = _convertToThreatLevel(value);

    if (_canSendMessage(now)) {
      _lastThreatLevelModifiedTime = now;
    }
  }

  bool _canSendMessage(DateTime now) {
    // We can send a message if it's been 10 seconds since the previous message
    return now
        .isAfter(_lastThreatLevelModifiedTime.add(const Duration(seconds: 10)));
  }

  void _sendMessage(String message, DateTime now, ThreatLevel threatLevel,
      BuildContext context) async {
    Iterable currentEmergencyContacts = emergencyContacts.values;
    String mapsUrl = await getMapsUrl();
    Iterable<String> recipientNumbers = currentEmergencyContacts.map((e) => e.number);
    sendMMS(recipientNumbers.toList(), message + " " + mapsUrl, _videoFilePath);

    _showToast(context);

    var events = Hive.box<Event>('events');
    await events.add(Event(
      eventDateTime: now,
      location: mapsUrl,
      threatLevel: threatLevel,
      message: message,
      emergencyContacts: currentEmergencyContacts.toList(),
    ));
  }

  ThreatLevel _convertToThreatLevel(double value) {
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
        });
  }
}
