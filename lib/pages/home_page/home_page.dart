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
import 'package:the_yagi_project/threat_meter/threat_meter_new.dart';
import 'package:the_yagi_project/threat_meter/threat_meter_thumb_shape.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage(
      {Key key, this.settings, this.cameraController, this.videoDirectory})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final Settings settings;
  final CameraController cameraController;
  final Directory videoDirectory;

  @override
  _MyHomePageState createState() => _MyHomePageState(settings: settings);
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  _MyHomePageState({this.settings});

  final Settings settings;

  double _warningValue;
  double _alertValue;

  Box<EmergencyContact> emergencyContacts;

  List<bool> _selections = [false, true]; // this data might be saved locally
  bool _cameraOn = true;
  FToast fToast;
  CameraController cameraController;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (cameraController != null) {
        _onNewCameraSelected(cameraController.description);
      }
    }
  }

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
      body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Container(
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
                child: CameraPreview(widget.cameraController),
              ),
              Align(
                alignment: Alignment.center,
                child: BlocListener<SettingsBloc, SettingsState>(
                  listenWhen: (previous, current) {
                    Object previousSettings = previous.props.first;
                    Object currentSettings = current.props.first;

                    if (previousSettings is Settings &&
                        currentSettings is Settings) {
                      return previousSettings.threatMeterValues
                                  .getWarningValue() !=
                              currentSettings.threatMeterValues
                                  .getWarningValue() ||
                          previousSettings.threatMeterValues.getAlertValue() !=
                              currentSettings.threatMeterValues.getAlertValue();
                    }

                    return false;
                  },
                  listener: (context, state) {
                    print("listening");
                    Object settings = state.props.first;
                    if (settings is Settings) {
                      setState(() {
                        _warningValue =
                            settings.threatMeterValues.getWarningValue();
                        _alertValue =
                            settings.threatMeterValues.getAlertValue();
                      });
                    }
                  },
                  child: _buildThreatMeterNew(settings),
                ),
              ),
              Positioned(
                bottom: 50,
                left: 50,
                child: ToggleButtons(
                  children: <Widget>[
                    Icon(Icons.camera_alt_outlined),
                    Icon(Icons.cake_outlined),
                  ],
                  onPressed: (int index) {
                    setState(() {
                      for (int buttonIndex = 0;
                          buttonIndex < _selections.length;
                          buttonIndex++) {
                        _selections[buttonIndex] =
                            (buttonIndex == index) ? true : false;
                        _cameraOn = !_cameraOn;
                      }
                    });
                  },
                  isSelected: _selections,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                        child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/contacts');
                            },
                            child: Text('Contacts'))),
                    Expanded(
                        child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/settings');
                            },
                            child: Text(
                              'Settings',
                            ))),
                    Expanded(
                        child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/log');
                            },
                            child: Text('Log'))),
                    Expanded(
                        child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/about');
                            },
                            child: Text('About'))),
                  ],
                ),
              )
            ],
          )),
    );
  }

  Widget _buildThreatMeterNew(Settings settings) {
    if (settings != null) {
      _warningValue = settings.threatMeterValues.getWarningValue();
      _alertValue = settings.threatMeterValues.getAlertValue();
    }
    ThreatMeterValues threatMeterValues =
        new ThreatMeterValues.nonPermanent(_warningValue, _alertValue);

    return SliderWidget(
      key: ValueKey(threatMeterValues),
      cautionHeight: _warningValue,
      highThreatHeight: _alertValue,
      cameraController: widget.cameraController,
      settings: widget.settings,
      videoPath: widget.videoDirectory.path,
    );
  }

  void _onNewCameraSelected(CameraDescription cameraDescription) async {
    if (cameraController != null) {
      await cameraController.dispose();
    }
    cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.low,
    );

    await cameraController.initialize();
  }
}
