// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Função para login com email e senha
  Future<void> _loginWithEmailAndPassword() async {
    try {
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

  // Função para login com biometria
  Future<void> _loginWithBiometric() async {
    try {
      // Verifique se o dispositivo suporta biometria
      bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      if (!canAuthenticateWithBiometrics) {
        _showErrorDialog('Biometria não está disponível neste dispositivo.');
        return;
      }

      // Solicitar autenticação biométrica
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Por favor, autentique-se para entrar',
        options: const AuthenticationOptions(
          stickyAuth: true, // Permite que a autenticação continue após mudança de foco
          useErrorDialogs: true, // Exibe a caixa de erro de autenticação
          sensitiveTransaction: true, // Caso sensível
        ),
      );

      if (authenticated) {
        // Sucesso na autenticação, prosseguir para a tela principal
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showErrorDialog('Falha na autenticação biométrica.');
      }
    } catch (e) {
      print('Erro na autenticação biométrica: $e');
      _showErrorDialog('Erro ao tentar autenticar com biometria.');
    }
  }

  // Função para exibir um diálogo de erro
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erro'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
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
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Campo de login com email e senha
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loginWithEmailAndPassword,
              child: Text('Entrar com Email e Senha'),
            ),
            SizedBox(height: 20),
            // Botão de login com biometria
            ElevatedButton(
              onPressed: _loginWithBiometric,
              child: Text('Entrar com Biometria'),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: Text(
                'Não tem uma conta? Registre-se aqui',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
