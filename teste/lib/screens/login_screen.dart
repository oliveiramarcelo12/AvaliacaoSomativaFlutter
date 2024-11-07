import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  bool _isBiometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    _isBiometricAvailable = await _localAuth.canCheckBiometrics;
    setState(() {});
  }

  // Função de login com email e senha e armazenamento do UID
  Future<void> _loginWithEmailAndPassword() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Armazena o UID de forma segura para futuras autenticações com biometria
      await _secureStorage.write(key: 'userUID', value: userCredential.user?.uid);

      // Navega para a tela principal
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print('Erro ao fazer login: $e');
      _showErrorDialog('Erro ao fazer login com email e senha.');
    }
  }

  // Função para login com biometria, usando UID salvo
  Future<void> _loginWithBiometric() async {
    try {
      if (!_isBiometricAvailable) {
        _showErrorDialog('Biometria não está disponível neste dispositivo.');
        return;
      }

      // Autenticação biométrica
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Por favor, autentique-se para entrar',
        options: const AuthenticationOptions(
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (authenticated) {
        // Recupera o UID armazenado
        String? storedUID = await _secureStorage.read(key: 'userUID');

        if (storedUID != null) {
          // Autentica o usuário usando o UID salvo
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          _showErrorDialog('Nenhuma sessão encontrada. Faça login com e-mail e senha primeiro.');
        }
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
            // Campos de email e senha que só aparecem no primeiro login
            if (!_isBiometricAvailable || _secureStorage.read(key: 'userUID') == null) ...[
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
            ],

            // Botão de login com biometria
            SizedBox(height: 20),
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
