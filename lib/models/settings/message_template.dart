import 'package:shared_preferences/shared_preferences.dart';

class MessageTemplate {

  String _noThreatMessage;
  String _cautionMessage;
  String _highThreatMessage;

  String getNoThreatMessage() {
    return _noThreatMessage;
  }

  String getCautionMessage() {
    return _cautionMessage;
  }

  String getHighThreatMessage() {
    return _highThreatMessage;
  }

  void setNoThreatMessage(String msg) async {
    _noThreatMessage = msg;

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('noThreatMessage', msg);
  }

  Future<void> setCautionMessage(String msg) async {
    _cautionMessage = msg;

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('cautionMessage', msg);
  }

  void setHighThreatMessage(String msg) async {
    _highThreatMessage = msg;

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('highThreatMessage', msg);
  }

  Future<void> populateData() async {
    final prefs = await SharedPreferences.getInstance();

    _noThreatMessage = prefs.getString('noThreatMessage');
    if (_noThreatMessage == null || _noThreatMessage.isEmpty) {
      _noThreatMessage = 'THIS WOULD BE THE DEFAULT MESSAGE';
    }

    _cautionMessage = prefs.getString('cautionMessage');
    if (_cautionMessage == null ||_cautionMessage.isEmpty) {
      _cautionMessage = 'THIS WOULD BE THE DEFAULT MESSAGE';
    }

    _highThreatMessage = prefs.getString('highThreatMessage');
    if (_highThreatMessage == null || _highThreatMessage.isEmpty) {
      _highThreatMessage = 'THIS WOULD BE THE DEFAULT MESSAGE';
    }
  }
}