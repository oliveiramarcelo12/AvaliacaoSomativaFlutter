import 'package:flutter/material.dart';

class SimplePhotoTipsScreen extends StatelessWidget {
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
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true); // Retorna à tela anterior
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
