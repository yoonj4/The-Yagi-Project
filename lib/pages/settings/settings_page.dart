import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_yagi_project/models/settings/settings.dart';
import 'package:the_yagi_project/settings_bloc.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key, this.title, this.settings}) : super(key: key);

  final String title;
  final Settings settings;

  @override
  _MySettingsState createState() => _MySettingsState(settings: settings);
}

class _MySettingsState extends State<SettingsPage> {
  _MySettingsState({this.settings});

  final Settings settings;

  @override
  Widget build(BuildContext context) {
    TextEditingController noThreatController = new TextEditingController(text: settings.messageTemplate.getNoThreatMessage());
    TextEditingController cautionController = new TextEditingController(text: settings.messageTemplate.getCautionMessage());
    TextEditingController highThreatController = new TextEditingController(text: settings.messageTemplate.getHighThreatMessage());
    TextEditingController warningValueController = new TextEditingController(text: settings.threatMeterValues.getWarningValue().toString());
    TextEditingController alertValueController = new TextEditingController(text: settings.threatMeterValues.getAlertValue().toString());
    
    noThreatController.addListener(() { 
      settings.messageTemplate.setNoThreatMessage(noThreatController.text);
    });

    cautionController.addListener(() {
      settings.messageTemplate.setCautionMessage(cautionController.text);
    });

    highThreatController.addListener(() {
      settings.messageTemplate.setHighThreatMessage(highThreatController.text);
    });
    
    warningValueController.addListener(() {
      double value = double.parse(warningValueController.text);
      settings.threatMeterValues.setWarningValue(value);
      final bloc = BlocProvider.of<SettingsBloc>(context);
      bloc.add(SetSettings(settings));
    });

    alertValueController.addListener(() {
      double value = double.parse(alertValueController.text);
      settings.threatMeterValues.setAlertValue(value);
      final bloc = BlocProvider.of<SettingsBloc>(context);
      bloc.add(SetSettings(settings));
    });

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text(widget.title),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return Column(
            children: [
              new Text("Message to send when you're safe."),
              new TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                controller: noThreatController,
              ),
              new Text("Message to send when you feel in danger."),
              new TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                controller: cautionController,
              ),
              new Text("Message to send when you're in danger."),
              new TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                controller: highThreatController,
              ),
              new Text("Yellow tick height setter."),
              new TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                controller: warningValueController,
              ),
              new Text("Red tick height setter."),
              new TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                controller: alertValueController,
              ),
            ],
          );
        },
      )
    );
  }
}
