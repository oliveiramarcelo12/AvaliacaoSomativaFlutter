import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'photo_success_screen.dart'; // Importe a tela de sucesso

class RegisterPhotoScreen extends StatefulWidget {
  @override
  _RegisterPhotoScreenState createState() => _RegisterPhotoScreenState();
}

class _RegisterPhotoScreenState extends State<RegisterPhotoScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isUploading = false; 
  String _uploadStatus = '';

  Future<void> _captureAndUploadPhoto() async {
    if (_isUploading) return;

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

        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          if (snapshot.state == TaskState.running) {
            setState(() {
              _uploadStatus = 'Fazendo upload... ${(snapshot.bytesTransferred / snapshot.totalBytes * 100).toStringAsFixed(0)}%';
            });
          }
        });

        await uploadTask.whenComplete(() async {
          String downloadURL = await storageRef.getDownloadURL();
          await _detectFace(downloadURL);  // Detecta o rosto

          setState(() {
            _isUploading = false;
            _uploadStatus = 'Foto registrada com sucesso!';
          });
        });
      } catch (e) {
        setState(() {
          _isUploading = false;
          _uploadStatus = 'Erro ao fazer upload: $e';
        });
      }
    }
  }

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
          // Rosto detectado, navegue para a tela de sucesso
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PhotoSuccessScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Nenhum rosto detectado.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao detectar rosto. Verifique a imagem e tente novamente.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro na comunicação com a API: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrar Foto Inicial')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _imageFile != null
                ? Image.file(_imageFile!, width: 200, height: 200)
                : Text("Nenhuma foto capturada."),
            SizedBox(height: 20),
            if (_isUploading) CircularProgressIndicator(),
            Text(
              _uploadStatus,
              style: TextStyle(fontSize: 16, color: Colors.green),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUploading ? null : _captureAndUploadPhoto,
              child: Text("Capturar Foto"),
            ),
          ],
        ),
      ),
    );
  }
}
