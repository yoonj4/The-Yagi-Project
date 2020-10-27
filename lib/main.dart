import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:the_yagi_project/pages/settings/settings_page.dart';
import 'package:the_yagi_project/pages/contacts/contacts_page.dart';
import 'package:the_yagi_project/pages/log/log_page.dart';
import 'package:the_yagi_project/pages/about/about_page.dart';
import 'package:the_yagi_project/pages/home_page//home_page.dart';
import 'package:the_yagi_project/models/settings/settings.dart';
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

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Settings _settings;

  @override
  void initState() {
    super.initState();

    setState(() {
      _settings = new Settings();
      _settings.messageTemplate.populateData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.green,
          // This makes the visual density adapt to the platform that you run
          // the app on. For desktop platforms, the controls will be smaller and
          // closer together (more dense) than on mobile platforms.
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => MyHomePage(title: 'Home Page', settings: _settings),
          '/contacts': (context) => ContactsPage(title: 'Contacts Page'),
          '/log': (context) => LogPage(title: 'Log Page'),
          '/settings': (context) => SettingsPage(title: 'Settings Page', settings: _settings),
          '/about': (context) => AboutPage(title: 'About Page'),
        }
    );
  }
}

