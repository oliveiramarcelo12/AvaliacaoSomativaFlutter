import 'package:flutter/material.dart';
import '../components/check_in_button.dart';
import '../services/location_service.dart';
import '../services/auth_service.dart';
import '../models/check_in_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class CheckInScreen extends StatefulWidget {
  @override
  _CheckInScreenState createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  bool _isCheckingIn = false;
  String _statusMessage = 'Aguardando ação do usuário...';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _handleCheckIn() async {
    setState(() {
      _isCheckingIn = true;
      _statusMessage = 'Verificando localização...';
    });

    // Checar localização
    Position? userPosition = await LocationService.checkUserLocation();

    if (userPosition != null) {
      // Coordenadas da empresa (posição de destino)
      const double targetLatitude = -23.5505;
      const double targetLongitude = -46.6333;

      // Verifica se o usuário está dentro da área permitida
      bool isWithinRange = LocationService.isWithinRange(userPosition, targetLatitude, targetLongitude, 100.0);

      if (isWithinRange) {
        setState(() {
          _statusMessage = 'Localização verificada. Registrando ponto...';
        });

        // Criar modelo de check-in
        CheckInModel checkIn = CheckInModel(
          userId: AuthService().getCurrentUserId(),
          latitude: userPosition.latitude,
          longitude: userPosition.longitude,
          timestamp: DateTime.now(),
        );

        // Salvar no Firestore
        await _firestore.collection('check_ins').add(checkIn.toJson());

        setState(() {
          _statusMessage = 'Ponto registrado com sucesso!';
        });
      } else {
        setState(() {
          _statusMessage = 'Você está fora da área permitida para registro de ponto.';
        });
      }
    } else {
      setState(() {
        _statusMessage = 'Não foi possível obter a localização.';
      });
    }

    setState(() {
      _isCheckingIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Ponto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _statusMessage,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            CheckInButton(
              isLoading: _isCheckingIn,
              onPressed: _handleCheckIn,
            ),
          ],
        ),
      ),
    );
  }
}
