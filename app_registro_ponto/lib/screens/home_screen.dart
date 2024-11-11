import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'check_in_screen.dart'; // Importa a tela de verificação de ponto (caso exista)

class HomeScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  // Função para sair da conta
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Verifica se o usuário está autenticado, caso contrário, exibe um fallback
    final String userEmail = user?.email ?? 'usuário não autenticado';

    return Scaffold(
      appBar: AppBar(
        title: Text('Tela Inicial'),
        backgroundColor: Colors.black, // Cor do AppBar (preto)
        actions: [
          // Ícone de logout
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
            color: Colors.white, // Cor do ícone de logout (branco)
          ),
        ],
      ),
      backgroundColor: Colors.black, // Cor de fundo da tela (preto)
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mensagem de boas-vindas com o email do usuário
            Text(
              'Bem-vindo, $userEmail!',
              style: TextStyle(fontSize: 20, color: Colors.white), // Texto branco
            ),
            SizedBox(height: 20),
            // Mensagem informativa
            Text(
              'Você está logado no sistema de registro de ponto.',
              style: TextStyle(fontSize: 16, color: Colors.white), // Texto branco
            ),
            SizedBox(height: 20),
            // Botão de registrar ponto
            ElevatedButton(
              onPressed: () {
                // Redireciona para a tela de check-in (registro de ponto)
                Navigator.pushNamed(context, '/check_in');
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Color(0xFFD4AF37), // Cor do texto (branco)
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
              ),
              child: Text('Registrar Ponto'),
            ),
          ],
        ),
      ),
    );
  }
}
