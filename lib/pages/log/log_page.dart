import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:the_yagi_project/models/event.dart';
import 'package:the_yagi_project/threat_meter/threat_level.dart';


class LogPage extends StatefulWidget {
  LogPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  Box<Event> eventsBox = Hive.box<Event>('events');

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
        body: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
            Text(
              widget.title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: eventsBox.length,
                itemBuilder: (context, index) {
                  if (eventsBox.length == 0) {
                    return null;
                  }
                  else {
                    var event = eventsBox.get(eventsBox.length - index - 1);
                    Color color;
                    if (event.threatLevel == ThreatLevel.highThreat) {
                      color = Colors.red;
                    } else if (event.threatLevel == ThreatLevel.caution) {
                      color = Colors.yellow;
                    }
// TODO add expandable window for more event information. list of emergency contacts, message, etc.
                    return ListTile(
                      title: Text(event.eventDateTime.toString()),
                      subtitle: Text(event.location.toString()),
                      tileColor: color,
                    );
                  }
                },
                separatorBuilder: (context, index) => const Divider(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}