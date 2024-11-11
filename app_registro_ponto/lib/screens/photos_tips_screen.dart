import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'register_photo_screen.dart';

class PhotoTipsScreen extends StatefulWidget {
  @override
  _PhotoTipsScreenState createState() => _PhotoTipsScreenState();
}

class _PhotoTipsScreenState extends State<PhotoTipsScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();

    // Busca pela câmera frontal
    CameraDescription? frontCamera;
    for (var camera in _cameras!) {
      if (camera.lensDirection == CameraLensDirection.front) {
        frontCamera = camera;
        break;
      }
    }

    // Inicializa a câmera frontal, ou usa a primeira câmera se a frontal não estiver disponível
    _cameraController = CameraController(
      frontCamera ?? _cameras![0],
      ResolutionPreset.medium,
    );

    try {
      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print("Erro ao inicializar a câmera: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dicas para Captura de Foto'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Para garantir uma boa captura de foto:",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            _buildTip("1. Posicione o rosto centralizado e com boa iluminação."),
            _buildTip("2. Evite acessórios que cubram o rosto, como óculos de sol."),
            _buildTip("3. Olhe diretamente para a câmera e mantenha uma expressão neutra."),
            SizedBox(height: 20),
            _isCameraInitialized
                ? Container(
                    width: 200,
                    height: 200,
                    child: CameraPreview(_cameraController!),
                  )
                : CircularProgressIndicator(), // Indicador de carregamento enquanto a câmera é inicializada
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPhotoScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFFD4AF37),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
              ),
              child: Text("Estou Pronto"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.lightbulb, color: Colors.yellow),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
