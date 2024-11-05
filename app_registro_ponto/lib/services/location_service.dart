// lib/services/location_service.dart

import 'dart:math';
import 'package:geolocator/geolocator.dart';
import '../utils/constants.dart';

class LocationService {
  // Função para verificar a localização do usuário
  static Future<bool> checkUserLocation(double userLatitude, double userLongitude) async {
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

    // Calcular a distância entre a localização do usuário e a localização do escritório usando a Fórmula de Haversine
    double distance = _calculateHaversineDistance(
      position.latitude,
      position.longitude,
      Constants.officeLocation.latitude,
      Constants.officeLocation.longitude,
    );

    // Retorna true se o usuário estiver dentro do raio definido
    return distance <= Constants.officeRadius;
  }

  // Método para calcular a distância usando a Fórmula de Haversine
  static double _calculateHaversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371000; // Raio da Terra em metros
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = sin(dLat / 2) * sin(dLat / 2) +
                     cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
                     sin(dLon / 2) * sin(dLon / 2);
                     
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // Resultado em metros
  }

  // Função auxiliar para converter graus para radianos
  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}