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
  bool _isLoading = false;
  String _statusMessage = 'Aguardando ação do usuário...';
  bool _isCheckingIn = true; // Flag para indicar se é registro de entrada

  Future<void> _handleCheckInOut() async {
    setState(() {
      _isLoading = true;
      _statusMessage = _isCheckingIn ? 'Verificando localização para entrada...' : 'Verificando localização para saída...';
    });

    // Solicitar permissão de localização ao usuário
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      setState(() {
        _statusMessage = 'Permissão de localização negada.';
        _isLoading = false;
      });
      return;
    }

    // Obter a localização do usuário
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    double userLatitude = position.latitude;
    double userLongitude = position.longitude;

    // Checar se está dentro do raio permitido
    bool isWithinRange = await LocationService.checkUserLocation(userLatitude, userLongitude);

    if (isWithinRange) {
      setState(() {
        _statusMessage = 'Localização confirmada. Registrando ${_isCheckingIn ? 'entrada' : 'saída'}...';
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
        'type': _isCheckingIn ? 'entrada' : 'saida', // Tipo de registro
        'location': 'Dentro da área permitida',
      });

      setState(() {
        _statusMessage = '${_isCheckingIn ? 'Entrada' : 'Saída'} registrada com sucesso em $formattedDate às $formattedTime!';
      });
    } else {
      setState(() {
        _statusMessage = 'Fora da área permitida para registro de ${_isCheckingIn ? 'entrada' : 'saída'}.';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _toggleCheckInOut() {
    setState(() {
      _isCheckingIn = !_isCheckingIn; // Alterna entre entrada e saída
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
              isLoading: _isLoading,
              onPressed: _handleCheckInOut,
              text: _isCheckingIn ? 'Registrar Entrada' : 'Registrar Saída', // Texto do botão
            ),
            SizedBox(height: 20),
            // Mostra o botão de saída somente quando for registrar saída
            if (!_isCheckingIn) 
              CheckInButton(
                isLoading: _isLoading,
                onPressed: _handleCheckInOut,
                text: 'Registrar Saída', // Texto do botão de saída
              ),
            // Mostra o botão para alternar entre entrada e saída
            SizedBox(height: 20),
            TextButton(
              onPressed: _toggleCheckInOut,
              child: Text(
                _isCheckingIn ? 'Mudar para Saída' : 'Mudar para Entrada',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
