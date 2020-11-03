import 'package:geolocator/geolocator.dart';

Future<String> getMapsUrl() async {
  Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  return "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";
}