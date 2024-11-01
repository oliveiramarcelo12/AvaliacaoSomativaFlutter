import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position?> checkUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return position;
  }

  static bool isWithinRange(Position userPosition, Position targetPosition, double allowedDistance) {
    double distance = Geolocator.distanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      targetPosition.latitude,
      targetPosition.longitude,
    );
    return distance <= allowedDistance;
  }
}
