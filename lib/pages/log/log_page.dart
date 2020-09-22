import 'package:flutter/material.dart';

class LogPage extends StatefulWidget {
  LogPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: Colors.blue[900],
          title: Text(widget.title),
          centerTitle: true,
          elevation: 0,
        )
    );
  }
}
