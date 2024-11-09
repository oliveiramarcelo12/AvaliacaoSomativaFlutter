import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_screen.dart';  // Importa a tela de registro de conta
import 'home_screen.dart';     // Importa a tela inicial (home)

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Função para login com email e senha
  Future<void> _loginWithEmailAndPassword() async {
    try {
      // Autenticação com Firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print('Erro ao fazer login: $e');
      _showErrorDialog('Erro ao fazer login com email e senha.');
    }
  }

  // Função para mostrar um erro de login
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Erro'),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Campo de email
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
            // Campo de senha
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Senha'), obscureText: true),
            // Botão de login
            ElevatedButton(onPressed: _loginWithEmailAndPassword, child: Text('Entrar com Email e Senha')),
            
            // Link para criar uma conta (vai para a tela de registro)
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: Text('Criar Conta'),
            ),
          ],
        ),
      ),
    );
  }
}
