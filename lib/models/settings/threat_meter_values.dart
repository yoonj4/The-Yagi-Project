import 'package:shared_preferences/shared_preferences.dart';

class ThreatMeterValues {
  static const String WARNING_VALUE = "warningValue";
  static const String ALERT_VALUE = "alertValue";

  double _warningValue;
  double _alertValue;

  ThreatMeterValues();

  ThreatMeterValues.nonPermanent(double warningValue, double alertValue) {
    _warningValue = warningValue;
    _alertValue = alertValue;
  }

  double getWarningValue() {
    return _warningValue;
  }

  double getAlertValue() {
    return _alertValue;
  }

  Future<void> setWarningValue(double value) async {
    _warningValue = value;
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble(WARNING_VALUE, _warningValue);
  }

  Future<void> setAlertValue(double value) async {
    _alertValue = value;
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble(ALERT_VALUE, _alertValue);
  }

  Future<void> initThreatMeterValues() async {
    final prefs = await SharedPreferences.getInstance();

    _warningValue = prefs.getDouble(WARNING_VALUE);
    if (_warningValue == null) {
      _warningValue = 0.33;
      prefs.setDouble(WARNING_VALUE, _warningValue);
    }

    _alertValue = prefs.getDouble(ALERT_VALUE);
    if (_alertValue == null) {
      _alertValue = 0.66;
      prefs.setDouble(ALERT_VALUE, _alertValue);
    }
  }

  @override
  bool operator ==(Object other) {
    if (other is ThreatMeterValues) {
      return _warningValue == other._warningValue
          && _alertValue == other._alertValue;
    }

    return false;
  }
}