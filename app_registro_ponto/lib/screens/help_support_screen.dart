import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  // Função para mostrar o manual na tela
  void _showManual(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Manual de Uso'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('1. Como usar o sistema de registro de ponto:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('  - Faça login utilizando seu email e senha.'),
                Text('  - Após o login, você pode vincular sua biometria.'),
                Text('  - Para registrar seu ponto, clique no botão "Registrar Ponto".'),
                SizedBox(height: 20),
                Text('2. Suporte:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('  - Para assistência, entre em contato com o suporte via email: suporte@empresa.com'),
                Text('  - Ou pelo telefone: (XX) XXXX-XXXX'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
              },
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajuda e Suporte'),
        backgroundColor: Colors.black, // Cor do AppBar
      ),
      backgroundColor: Colors.black, // Cor de fundo da tela
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.help_outline,
                size: 80,
                color: Colors.blue,
              ),
              SizedBox(height: 20),
              Text(
                'Para assistência, entre em contato com o suporte:',
                style: TextStyle(fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'Email: suporte@empresa.com',
                style: TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Telefone: (XX) XXXX-XXXX',
                style: TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => _showManual(context), // Exibe o manual
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xFFD4AF37), // Cor do botão
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                ),
                child: Text('Ver Manual'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
