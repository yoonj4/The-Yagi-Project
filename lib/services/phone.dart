import 'package:url_launcher/url_launcher.dart'; // call with dial pad
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';


Future<void> makePhoneCall(String contact, bool direct) async {
  if (direct == true) {
    bool res = await FlutterPhoneDirectCaller.callNumber(contact);
    print(res);
  } else {
    String telScheme = 'tel:$contact';

    if (await canLaunch(telScheme)) {
      await launch(telScheme);
    } else {
      throw 'Could not launch $telScheme';
    }
  }
}