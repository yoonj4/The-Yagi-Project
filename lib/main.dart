import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:the_yagi_project/models/settings/message_template.dart';
import 'package:the_yagi_project/models/settings/threat_meter_values.dart';
import 'package:the_yagi_project/pages/settings/settings_page.dart';
import 'package:the_yagi_project/pages/contacts/contacts_page.dart';
import 'package:the_yagi_project/pages/log/log_page.dart';
import 'package:the_yagi_project/pages/about/about_page.dart';
import 'package:the_yagi_project/pages/home_page//home_page.dart';
import 'package:the_yagi_project/models/settings/settings.dart';
import 'package:the_yagi_project/settings_bloc.dart';
import 'package:the_yagi_project/threat_meter/threat_level.dart';
import 'models/contacts.dart';
import 'models/event.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(EventAdapter());
  Hive.registerAdapter(ThreatLevelAdapter());
  Hive.registerAdapter(EmergencyContactAdapter());
  await Hive.openBox<Event>('events');
  await Hive.openBox<EmergencyContact>('emergency');

  // Hive.box<Event>('events').clear();

  MessageTemplate messageTemplate = new MessageTemplate();
  await messageTemplate.populateData();
  ThreatMeterValues threatMeterValues = new ThreatMeterValues();
  await threatMeterValues.initThreatMeterValues();
  Settings settings = new Settings(messageTemplate: messageTemplate, threatMeterValues: threatMeterValues);

  List<CameraDescription> cameras = await availableCameras();
  CameraController cameraController = CameraController(cameras[0], ResolutionPreset.max);
  await cameraController.initialize();

  runApp(MyApp(settings: settings, cameraController: cameraController,));
}

class MyApp extends StatefulWidget {
  MyApp({Key key, this.settings, this.cameraController}) : super(key: key);

  final Settings settings;
  final CameraController cameraController;

  @override
  _MyAppState createState() => _MyAppState(settings: settings, cameraController: cameraController);
}

class _MyAppState extends State<MyApp> {
  _MyAppState({this.settings, this.cameraController});

  final Settings settings;
  final CameraController cameraController;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc(SettingsInitial(settings: settings)),
      child: MaterialApp(
        title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.green,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => MyHomePage(title: 'Home Page', settings: settings, cameraController: cameraController,),
            '/contacts': (context) => ContactsPage(title: 'Contacts Page'),
            '/log': (context) => LogPage(title: 'Log Page'),
            '/settings': (context) => SettingsPage(title: 'Settings Page', settings: settings),
            '/about': (context) => AboutPage(title: 'About Page'),
          },
      )
    );
  }
}

