import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_yagi_project/models/settings/message_template.dart';

class Settings {
  MessageTemplate messageTemplate;
  double warningValue;
  double alertValue;

  Settings() {
    messageTemplate = new MessageTemplate();
    _initThresholdValues();
  }

  void _initThresholdValues() async {
    final prefs = await SharedPreferences.getInstance();

    warningValue = prefs.getDouble("warningValue");
    if (warningValue == null) {
      warningValue = 0.33;
      prefs.setDouble("warningValue", warningValue);
    }

    alertValue = prefs.getDouble("alertValue");
    if (alertValue == null) {
      alertValue = 0.66;
      prefs.setDouble("alertValue", alertValue);
    }
  }
}

