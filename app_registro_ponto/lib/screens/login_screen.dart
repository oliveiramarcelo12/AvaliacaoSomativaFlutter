import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final _storage = FlutterSecureStorage();

  // Função para login com email e senha
  Future<void> _loginWithEmailAndPassword() async {
    try {
      // Autenticação com Firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Solicita ao usuário se deseja vincular a biometria
      bool shouldLinkBiometrics = await _showBiometricLinkDialog();

      if (shouldLinkBiometrics) {
        await _storage.write(key: 'biometricLinkedUser', value: _emailController.text);
      }

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print('Erro ao fazer login: $e');
      _showErrorDialog('Erro ao fazer login com email e senha.');
    }
  }

  // Função para mostrar o diálogo de vínculo biométrico
  Future<bool> _showBiometricLinkDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Vincular Biometria'),
        content: Text('Deseja vincular a biometria para logins futuros?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sim'),
          ),
        ],
      ),
    ) ?? false;
  }

  // Função para login com biometria
  Future<void> _loginWithBiometric() async {
    try {
      String? savedEmail = await _storage.read(key: 'biometricLinkedUser');

      if (savedEmail == null) {
        _showErrorDialog('Biometria não vinculada. Faça login com email e senha primeiro.');
        return;
      }

      bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      bool authenticated = false;

      if (canAuthenticateWithBiometrics) {
        authenticated = await _localAuth.authenticate(
          localizedReason: 'Autentique-se para entrar',
        );
      }

      if (authenticated) {
        // Acesso autorizado
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showErrorDialog('Falha na autenticação biométrica.');
      }
    } catch (e) {
      print('Erro na autenticação biométrica: $e');
      _showErrorDialog('Erro ao tentar autenticar com biometria.');
    }
  }

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
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Senha'), obscureText: true),
            ElevatedButton(onPressed: _loginWithEmailAndPassword, child: Text('Entrar com Email e Senha')),
            ElevatedButton(onPressed: _loginWithBiometric, child: Text('Entrar com Biometria')),
          ],
        ),
      ),
    );
  }
}
