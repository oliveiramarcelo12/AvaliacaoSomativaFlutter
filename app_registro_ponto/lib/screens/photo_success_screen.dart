import 'package:flutter/material.dart';
import 'home_screen.dart';
class PhotoSuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Foto Registrada")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Texto de confirmação
            Text(
              "Foto registrada com sucesso!",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            // Botão para navegar para a tela inicial (Home)
            ElevatedButton(
              onPressed: () {
                // Navega para a HomeScreen após o sucesso
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              child: Text("Ir para a Home"),
            ),
          ],
        ),
      ),
    );
  }
}
