// lib/screens/check_in_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

    // Checar a localização do usuário
    bool isWithinRange = await LocationService.checkUserLocation();

    if (isWithinRange) {
      setState(() {
        _statusMessage = 'Localização verificada. Registrando ponto...';
      });

      // Obtenha a referência do Firestore e do usuário atual
      User? user = FirebaseAuth.instance.currentUser;
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Registrar o ponto no Firestore
      await firestore.collection('check_ins').add({
        'userId': user?.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'location': 'Dentro da área permitida',
      });

      setState(() {
        _statusMessage = 'Ponto registrado com sucesso!';
      });
    } else {
      setState(() {
        _statusMessage = 'Você está fora da área permitida para registro de ponto.';
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
