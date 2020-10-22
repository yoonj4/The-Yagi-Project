import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MySettingsState createState() => _MySettingsState();
}

class _MySettingsState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
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
          ),
          new Text("Message to send when you feel in danger."),
          new TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          new Text("Message to send when you're in danger."),
          new TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
