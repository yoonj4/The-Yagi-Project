import 'package:sms/sms.dart';

void sendSMS(String address, String message) {
  SmsSender sender = new SmsSender();
  sender.sendSms(new SmsMessage(address, message));
}