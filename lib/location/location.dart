import 'package:geolocator/geolocator.dart';
import 'package:maps_launcher/maps_launcher.dart';

Future<String> getMapsUrl() async {
  Position position = await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  return MapsLauncher.createCoordinatesUrl(position.latitude, position.longitude);
}