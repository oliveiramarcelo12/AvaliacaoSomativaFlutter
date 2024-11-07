import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
  final _googleSignIn = GoogleSignIn();
  final _storage = FlutterSecureStorage();
  bool _isEmailPasswordLogin = false; // Variável para controlar a visibilidade do formulário

  // Função para login com email e senha
  Future<void> _loginWithEmailAndPassword() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      // Armazena a flag de primeiro login bem-sucedido
      await _storage.write(key: 'hasLoggedIn', value: 'true');
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print('Erro ao fazer login: $e');
      _showErrorDialog('Erro ao fazer login com email e senha.');
    }
  }

  // Função para login com biometria
  Future<void> _loginWithBiometric() async {
    try {
      // Checa se o dispositivo suporta biometria e se o usuário já logou pela primeira vez
      bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      String? hasLoggedIn = await _storage.read(key: 'hasLoggedIn');
      
      if (hasLoggedIn != 'true') {
        _showErrorDialog('A biometria só é permitida após o primeiro login com email e senha.');
        return;
      }

      if (!canAuthenticateWithBiometrics) {
        _showErrorDialog('Biometria não está disponível neste dispositivo.');
        return;
      }

      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Por favor, autentique-se para entrar',
        options: const AuthenticationOptions(
          stickyAuth: true,
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );

      if (authenticated) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showErrorDialog('Falha na autenticação biométrica.');
      }
    } catch (e) {
      print('Erro na autenticação biométrica: $e');
      _showErrorDialog('Erro ao tentar autenticar com biometria.');
    }
  }

  // Função para login com Google
  Future<void> _loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Usuário cancelou o login');
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      
      // Salva o ID do usuário para uso com biometria
      await _storage.write(key: 'userId', value: googleUser.id);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print('Erro ao fazer login com Google: $e');
      _showErrorDialog('Erro ao fazer login com Google.');
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

  // Exibe os campos de login com email e senha
  Widget _emailPasswordLoginForm() {
    return Column(
      children: [
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
            // Se o usuário não logou antes, mostrar as opções de login por email/senha ou Google
            if (!_isEmailPasswordLogin) ...[
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isEmailPasswordLogin = true; // Ativa o formulário de email/senha
                  });
                },
                child: Text('Entrar com Email e Senha'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loginWithGoogle,
                child: Text('Entrar com Google'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loginWithBiometric,
                child: Text('Entrar com Biometria'),
              ),
            ],
            
            // Se o usuário já entrou com email e senha, pede para usar a biometria
            if (_isEmailPasswordLogin) ...[
              _emailPasswordLoginForm(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isEmailPasswordLogin = false; // Volta para as opções de login
                  });
                },
                child: Text('Voltar'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loginWithBiometric,
                child: Text('Entrar com Biometria'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
