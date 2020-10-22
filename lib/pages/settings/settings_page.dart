import 'package:flutter/material.dart';
import 'package:the_yagi_project/models/settings/settings.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key, this.title, this.settings}) : super(key: key);

  final String title;
  final Settings settings;

  @override
  _MySettingsState createState() => _MySettingsState();
}

class _MySettingsState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    TextEditingController noThreatController = new TextEditingController(text: widget.settings.messageTemplate.getNoThreatMessage());
    TextEditingController cautionController = new TextEditingController(text: widget.settings.messageTemplate.getCautionMessage());
    TextEditingController highThreatController = new TextEditingController(text: widget.settings.messageTemplate.getHighThreatMessage());
    
    noThreatController.addListener(() { 
      widget.settings.messageTemplate.setNoThreatMessage(noThreatController.text);
    });

    cautionController.addListener(() {
      widget.settings.messageTemplate.setCautionMessage(cautionController.text);
    });

    highThreatController.addListener(() {
      widget.settings.messageTemplate.setHighThreatMessage(highThreatController.text);
    });

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text(widget.title),
        centerTitle: true,
        elevation: 0,
      ),
      body: new Column(
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
        ],
      ),
    );
  }
}
