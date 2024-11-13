// Importa bibliotecas necessárias
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import '../utils/constants.dart';

/// Serviço de localização para verificar a posição do usuário em relação a um local designado.
class LocationService {
  
  /// Verifica se o usuário está dentro de uma determinada distância do local alvo.
  ///
  /// [userLatitude] - Latitude do usuário.
  /// [userLongitude] - Longitude do usuário.
  /// Retorna `true` se o usuário estiver dentro do raio permitido ou `false` caso contrário.
  static Future<bool> checkUserLocation(double userLatitude, double userLongitude) async {
    // Verifica a permissão de localização do usuário
    LocationPermission permission = await Geolocator.checkPermission();

    // Solicita permissão se ela ainda não foi concedida
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Se a permissão for negada permanentemente, o usuário não pode usar a funcionalidade
    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    // Obtém a posição atual do usuário com alta precisão
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    // Calcula a distância entre a posição do usuário e a posição alvo usando a Fórmula de Haversine
    double distance = _calculateHaversineDistance(
      position.latitude,
      position.longitude,
      Constants.officeLocation.latitude,
      Constants.officeLocation.longitude,
    );

    // Retorna `true` se a distância estiver dentro do raio permitido, `false` caso contrário
    return distance <= Constants.officeRadius;
  }

  /// Calcula a distância entre duas coordenadas geográficas usando a Fórmula de Haversine.
  ///
  /// [lat1] - Latitude do ponto de partida.
  /// [lon1] - Longitude do ponto de partida.
  /// [lat2] - Latitude do ponto de destino.
  /// [lon2] - Longitude do ponto de destino.
  /// Retorna a distância em metros.
  static double _calculateHaversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371000; // Raio da Terra em metros
    final double dLat = _degreesToRadians(lat2 - lat1); // Diferença de latitude em radianos
    final double dLon = _degreesToRadians(lon2 - lon1); // Diferença de longitude em radianos
    
    // Cálculo da fórmula de Haversine
    final double a = sin(dLat / 2) * sin(dLat / 2) +
                     cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
                     sin(dLon / 2) * sin(dLon / 2);
                     
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // Retorna a distância em metros
  }

  /// Função auxiliar para converter graus para radianos.
  ///
  /// [degrees] - Valor em graus a ser convertido.
  /// Retorna o valor em radianos.
  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}
