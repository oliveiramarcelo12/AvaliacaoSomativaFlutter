// lib/services/location_service.dart

import 'package:geolocator/geolocator.dart';
import '../utils/constants.dart';

class LocationService {
  // Função para verificar a localização do usuário
  static Future<bool> checkUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // Se o usuário negar permanentemente a permissão
      return false;
    }

    // Obter a posição atual do usuário
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    // Calcular a distância entre a localização do usuário e a localização do escritório
    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      Constants.officeLocation.latitude,
      Constants.officeLocation.longitude,
    );

    // Retorna true se o usuário estiver dentro do raio definido
    return distance <= Constants.officeRadius;
  }
}
