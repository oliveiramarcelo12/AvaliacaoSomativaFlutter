import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

// Importe a sua tela principal (HomeScreen) 
import 'home_screen.dart'; // Substitua com o caminho correto do arquivo da HomeScreen

class RegisterPhotoScreen extends StatefulWidget {
  @override
  _RegisterPhotoScreenState createState() => _RegisterPhotoScreenState();
}

class _RegisterPhotoScreenState extends State<RegisterPhotoScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isUploading = false;
  String? _uploadStatus;

  // Função para capturar e fazer o upload da foto
  Future<void> _captureAndUploadPhoto() async {
    if (_isUploading) return;

    // Captura a imagem usando a câmera
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isUploading = true;
        _uploadStatus = 'Fazendo upload...';
      });

      try {
        User? user = FirebaseAuth.instance.currentUser;
        final storageRef = FirebaseStorage.instance.ref().child('user_photos/${user!.uid}.jpg');
        UploadTask uploadTask = storageRef.putFile(_imageFile!);

        // Monitora o progresso do upload
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          if (snapshot.state == TaskState.running) {
            setState(() {
              _uploadStatus = 'Fazendo upload... ${(snapshot.bytesTransferred / snapshot.totalBytes * 100).toStringAsFixed(0)}%';
            });
          }
        });

        await uploadTask.whenComplete(() async {
          String downloadURL = await storageRef.getDownloadURL();
          await _detectFace(downloadURL); // Chama a função de detecção de rosto
        });
      } catch (e) {
        setState(() {
          _isUploading = false;
          _uploadStatus = 'Erro ao fazer upload: $e';
        });
      }
    }
  }

  // Função para detectar o rosto na foto usando a API de reconhecimento facial
  Future<void> _detectFace(String imageUrl) async {
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
          // Rosto detectado, navega para a tela inicial
          setState(() {
            _isUploading = false;
            _uploadStatus = 'Foto registrada com sucesso!';
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()), // Garante a navegação para a HomeScreen
          );
        } else {
          // Se não houver rosto detectado, exibe a mensagem de erro
          setState(() {
            _isUploading = false;
            _uploadStatus = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Nenhum rosto detectado. Para garantir uma boa captura:\n"
                "1. Posicione o rosto centralizado e com boa iluminação.\n"
                "2. Evite acessórios que cubram o rosto, como óculos de sol.\n"
                "3. Olhe diretamente para a câmera e mantenha uma expressão neutra.",
              ),
              duration: Duration(seconds: 10),
            ),
          );
        }
      } else {
        // Mensagem de erro caso a API retorne erro
        setState(() {
          _isUploading = false;
          _uploadStatus = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao detectar rosto. Verifique a imagem e tente novamente.")),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadStatus = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro na comunicação com a API: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Foto Inicial'),
        backgroundColor: Colors.black, // Cor do AppBar (preto)
      ),
      backgroundColor: Colors.black, // Cor de fundo da tela (preto)
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Exibe a imagem capturada, se houver
            _imageFile != null
                ? Image.file(_imageFile!, width: 200, height: 200)
                : Text(
                    "Nenhuma foto capturada.",
                    style: TextStyle(color: Colors.white), // Texto branco
                  ),
            SizedBox(height: 20),
            // Exibe o status de upload, se necessário
            if (_isUploading) CircularProgressIndicator(),
            if (_uploadStatus != null)
              Text(
                _uploadStatus!,
                style: TextStyle(fontSize: 16, color: Colors.green), // Texto verde para sucesso
              ),
            SizedBox(height: 20),
            // Botão para capturar foto
            ElevatedButton(
              onPressed: _isUploading ? null : _captureAndUploadPhoto,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Color(0xFFD4AF37), // Cor do texto (branco)
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
              ),
              child: Text("Capturar Foto"),
            ),
          ],
        ),
      ),
    );
  }
}
