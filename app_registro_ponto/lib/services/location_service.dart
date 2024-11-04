import 'package:geolocator/geolocator.dart';

class LocationService {
  // Método para verificar a localização do usuário
  static Future<Position?> checkUserLocation() async {
    // Verifica se a permissão de localização foi concedida
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      // Retorna null se a permissão ainda for negada
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    // Configurações para obter a posição atual
    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best, // Configuração de precisão desejada
      distanceFilter: 10, // Atualiza a posição se o usuário se mover mais de 10 metros
    );

    // Obtém a posição atual do usuário
    Position position = await Geolocator.getCurrentPosition(locationSettings: locationSettings);
    return position;
  }

  // Método para verificar se o usuário está dentro do intervalo permitido
  static bool isWithinRange(Position userPosition, double targetLatitude, double targetLongitude, double allowedDistance) {
    double distance = Geolocator.distanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      targetLatitude,
      targetLongitude,
    );
    return distance <= allowedDistance;
  }
}
