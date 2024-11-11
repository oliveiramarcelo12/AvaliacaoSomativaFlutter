import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../components/check_in_button.dart';
import '../services/location_service.dart';
import 'check_in_history_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'photos_tips_screen.dart';

class CheckInScreen extends StatefulWidget {
  @override
  _CheckInScreenState createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  bool _isLoading = false;
  String _statusMessage = 'Aguardando ação do usuário...';
  bool _isCheckingIn = true; // Flag para indicar se é registro de entrada
  bool _hasCheckedIn = false; // Flag para indicar se o usuário já registrou entrada
Future<void> _handleCheckInOut() async {
  // Mostra a tela de dicas e espera até que o usuário confirme
  bool isReady = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => PhotoTipsScreen()),
  );

  // Se o usuário não estiver pronto, interrompe o processo
  if (isReady != true) {
    return;
  }

  setState(() {
    _isLoading = true;
    _statusMessage = _isCheckingIn
        ? 'Verificando localização para entrada...'
        : 'Verificando localização para saída...';
  });
    try {
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
          _statusMessage = 'Localização confirmada. Tirando foto para ${_isCheckingIn ? 'entrada' : 'saída'}...';
        });

        // Verifique se o usuário está autenticado
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          print("Usuário não autenticado");
          setState(() {
            _statusMessage = 'Usuário não autenticado. Redirecionando para login...';
          });
          Navigator.pushReplacementNamed(context, '/login');
          return;
        } else {
          print("Usuário autenticado");
        }

        // Capture a foto usando a câmera
        final ImagePicker _picker = ImagePicker();
        final XFile? image = await _picker.pickImage(source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,  );
        if (image == null) {
          setState(() {
            _statusMessage = 'Captura de foto cancelada.';
            _isLoading = false;
          });
          return;
        }

        // Envie a imagem para o Firebase Storage
        String fileName = '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        Reference storageRef = FirebaseStorage.instance.ref().child('check_in_photos/$fileName');
        UploadTask uploadTask = storageRef.putFile(File(image.path));
        TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() => null);
        String photoUrl = await storageSnapshot.ref.getDownloadURL();

        // Verificar se a imagem é de um rosto (com a mesma API de detecção facial)
        bool isFaceDetected = await _detectFace(photoUrl);
        if (!isFaceDetected) {
          setState(() {
            _isLoading = false;
            _statusMessage = 'Foto não reconhecida como rosto. Tente novamente.';
          });
          return;
        }

        // Obtenha a data e hora atuais
        DateTime now = DateTime.now();
        String formattedDate = DateFormat('dd/MM/yyyy').format(now);
        String formattedTime = DateFormat('HH:mm:ss').format(now);

        // Salve o registro no Firestore
        FirebaseFirestore.instance.collection('check_ins').add({
          'userId': user.uid,
          'date': formattedDate,
          'time': formattedTime,
          'type': _isCheckingIn ? 'entrada' : 'saida', // Tipo de registro
          'location': 'Dentro da área permitida',
          'photoUrl': photoUrl, // URL da foto
        });

        setState(() {
          _statusMessage = '${_isCheckingIn ? 'Entrada' : 'Saída'} registrada com sucesso em $formattedDate às $formattedTime!';
          _hasCheckedIn = _isCheckingIn; // Atualiza o status de check-in
          _isCheckingIn = !_isCheckingIn; // Alterna o estado para a próxima ação
        });
      } else {
        setState(() {
          _statusMessage = 'Fora da área permitida para registro de ${_isCheckingIn ? 'entrada' : 'saída'}.'; 
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Erro ao registrar ponto: $e';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Função para verificar se a foto contém um rosto
  Future<bool> _detectFace(String imageUrl) async {
    final endpoint = "https://registroponto2024.cognitiveservices.azure.com/"; 
    final apiKey = "6O87mZZUNPbsFe5hQoQeIexuZWzDvPIRVwgg6vKaS6XiOyuIP3WQJQQJ99AKACYeBjFXJ3w3AAAKACOGH6Px";

    final url = Uri.parse('${endpoint}face/v1.0/detect');
    final headers = {
      "Content-Type": "application/json",
      "Ocp-Apim-Subscription-Key": apiKey,
    };
    final body = jsonEncode({"url": imageUrl});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData.isNotEmpty) {
          return true; // Rosto detectado
        } else {
          return false; // Nenhum rosto detectado
        }
      } else {
        return false; // Se a resposta for inválida
      }
    } catch (e) {
      return false; // Caso ocorra um erro na comunicação com a API
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Ponto'),
        backgroundColor: Colors.black, // Cor do AppBar (preto)
        iconTheme: IconThemeData(color: Colors.white), // Ícone da AppBar (branco)
      ),
      backgroundColor: Colors.black, // Cor de fundo da tela (preto)
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _statusMessage,
              style: TextStyle(fontSize: 18, color: Colors.white), // Texto branco
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            CheckInButton(
              isLoading: _isLoading,
              onPressed: _handleCheckInOut,
              text: _isCheckingIn ? 'Registrar Entrada' : 'Registrar Saída',
              buttonColor: Color(0xFFD4AF37), // Cor do botão (dourado)
              textColor: Colors.white, // Cor do texto do botão (branco)
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CheckInHistoryScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Color(0xFFD4AF37), // Cor do texto (branco)
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
              ),
              child: Text('Ver Histórico'),
            ),
          ],
        ),
      ),
    );
  }
}
