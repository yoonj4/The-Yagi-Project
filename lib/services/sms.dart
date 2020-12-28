import 'package:mms/mms.dart';

void sendMMS(List<String> address, String message, String videoFilePath) {
  Mms().sendVideoWithDefaultApp(message, videoFilePath, address);
}