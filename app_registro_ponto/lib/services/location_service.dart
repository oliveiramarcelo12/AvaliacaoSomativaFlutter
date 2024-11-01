// lib/services/location_service.dart
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Serviço de localização desativado.");
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Permissão de localização negada.");
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Permissão de localização permanentemente negada.");
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  bool isWithinDistance(Position position, Position targetPosition, double radiusMeters) {
    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      targetPosition.latitude,
      targetPosition.longitude,
    );
    return distance <= radiusMeters;
  }
}
