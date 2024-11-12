import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart'; // Tela de destino após login
import 'register_screen.dart'; // Tela de registro (Criar conta)

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;
  final _localAuth = LocalAuthentication();
  bool _isBiometricAvailable = false;

  // Função para verificar suporte e disponibilidade de biometria
  Future<void> _checkBiometrics() async {
    try {
      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      bool isDeviceSupported = await _localAuth.isDeviceSupported();
      List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();

      setState(() {
        _isBiometricAvailable = canCheckBiometrics && isDeviceSupported && availableBiometrics.isNotEmpty;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao verificar biometria: $e';
      });
    }
  }

  // Função para login com email e senha
  Future<void> _login() async {
    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, preencha todos os campos.';
        _isLoading = false;
      });
      return;
    }

    if (!_emailController.text.contains('@')) {
      setState(() {
        _errorMessage = 'Por favor, insira um e-mail válido.';
        _isLoading = false;
      });
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (userCredential.user != null) {
        // Verificar se a biometria está vinculada
        bool isBiometricLinked = await _getBiometricPreference();

        // Se não estiver vinculada e a biometria for suportada
        if (!isBiometricLinked && _isBiometricAvailable) {
          // Perguntar ao usuário se ele quer vincular a biometria
          bool shouldLinkBiometrics = await _showBiometricLinkDialog();

          if (shouldLinkBiometrics) {
            await _linkBiometrics();
          }
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        setState(() {
          _errorMessage = 'Erro ao autenticar com Firebase';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao fazer login: $e';
        _isLoading = false;
      });
    }
  }

  // Função para verificar se a biometria está vinculada ao usuário
  Future<bool> _getBiometricPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometricLinked') ?? false;
  }

  // Função para mostrar o diálogo perguntando ao usuário se deseja vincular a biometria
  Future<bool> _showBiometricLinkDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Vincular Biometria'),
        content: Text('Você deseja vincular a biometria à sua conta?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Resposta 'Não'
            },
            child: Text('Não'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Resposta 'Sim'
            },
            child: Text('Sim'),
          ),
        ],
      ),
    ) ?? false;
  }

  // Função para vincular a biometria
  Future<void> _linkBiometrics() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometricLinked', true); // Marca a biometria como vinculada
  }

  // Função para autenticação biométrica
  Future<void> _authenticateWithBiometrics() async {
    bool isBiometricLinked = await _getBiometricPreference();
    
    if (isBiometricLinked) {
      try {
        bool isAuthenticated = await _localAuth.authenticate(
          localizedReason: 'Use sua biometria para fazer login.',
          options: const AuthenticationOptions(
            useErrorDialogs: true,
            stickyAuth: true,
          ),
        );

        if (isAuthenticated) {
          User? user = FirebaseAuth.instance.currentUser;

          if (user != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          } else {
            setState(() {
              _errorMessage = 'Falha na autenticação com biometria. Tente novamente.';
            });
          }
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Erro na autenticação biométrica: $e';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Biometria não vinculada. Faça login com senha primeiro.';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkBiometrics(); // Verificar a disponibilidade de biometria no dispositivo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white),
                errorText: _errorMessage.contains('e-mail') ? _errorMessage : null,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Senha',
                labelStyle: TextStyle(color: Colors.white),
                errorText: _errorMessage.contains('senha') ? _errorMessage : null,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              obscureText: true,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFFD4AF37),
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                    ),
                    child: Text('Login'),
                  ),
            SizedBox(height: 20),
            if (_isBiometricAvailable)
              ElevatedButton(
                onPressed: _authenticateWithBiometrics,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xFFD4AF37),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                ),
                child: Text('Usar biometria'),
              ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: Text(
                'Criar conta',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
