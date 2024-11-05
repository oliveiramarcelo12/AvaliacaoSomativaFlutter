import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../components/check_in_button.dart';
import '../services/location_service.dart';

class CheckInScreen extends StatefulWidget {
  @override
  _CheckInScreenState createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  bool _isCheckingIn = false;
  String _statusMessage = 'Aguardando ação do usuário...';

  Future<void> _handleCheckIn() async {
    setState(() {
      _isCheckingIn = true;
      _statusMessage = 'Verificando localização...';
    });

    try {
      // Solicitar permissão de localização ao usuário
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() {
          _statusMessage = 'Permissão de localização negada.';
          _isCheckingIn = false;
        });
        return;
      }

      // Obter a localização do usuário
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      double userLatitude = position.latitude;
      double userLongitude = position.longitude;

      // Checar se está dentro do raio permitido (definido no LocationService)
      bool isWithinRange = await LocationService.checkUserLocation(userLatitude, userLongitude);

      if (isWithinRange) {
        setState(() {
          _statusMessage = 'Localização confirmada. Registrando ponto...';
        });

        // Obtenha a referência do Firestore e o usuário atual
        User? user = FirebaseAuth.instance.currentUser;
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        // Obtenha a data e hora atuais
        DateTime now = DateTime.now();
        String formattedDate = DateFormat('dd/MM/yyyy').format(now);
        String formattedTime = DateFormat('HH:mm:ss').format(now);

        // Salve o registro no Firestore
        await firestore.collection('check_ins').add({
          'userId': user?.uid,
          'date': formattedDate,
          'time': formattedTime,
          'location': 'Dentro da área permitida',
        });

        // Mensagem de sucesso com data e hora
        setState(() {
          _statusMessage = 'Ponto registrado com sucesso em $formattedDate às $formattedTime!';
        });
      } else {
        setState(() {
          _statusMessage = 'Fora da área permitida para registro de ponto.';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Erro ao registrar o ponto: $e';
      });
    } finally {
      setState(() {
        _isCheckingIn = false;
      });
    }
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
