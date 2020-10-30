import 'package:equatable/equatable.dart';
import 'package:the_yagi_project/models/settings/message_template.dart';
import 'package:the_yagi_project/models/settings/threat_meter_values.dart';

class Settings extends Equatable {
  Settings({this.messageTemplate, this.threatMeterValues});

  final MessageTemplate messageTemplate;
  final ThreatMeterValues threatMeterValues;

   @override
  List<Object> get props => [
    messageTemplate,
    threatMeterValues,
  ];

   @override
  bool operator ==(Object other) {
     if (other is Settings) {
       return threatMeterValues.getWarningValue() == other.threatMeterValues.getWarningValue()
           && threatMeterValues.getAlertValue() == other.threatMeterValues.getAlertValue();
     }
     return false;
  }
}

