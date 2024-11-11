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
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Função para login com email e senha
  Future<void> _login() async {
    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (userCredential.user != null) {
        // Após o login bem-sucedido, pergunte se o usuário deseja vincular a biometria
        bool userWantsBiometrics = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Habilitar Biometria'),
            content: Text('Deseja vincular a biometria à sua conta?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false); // Não habilitar biometria
                },
                child: Text('Não'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true); // Habilitar biometria
                },
                child: Text('Sim'),
              ),
            ],
          ),
        );

        if (userWantsBiometrics) {
          // Salva que a biometria foi habilitada
          await _saveBiometricPreference(true);
        }

        // Verifique se a biometria foi habilitada
        bool isBiometricEnabled = await _getBiometricPreference();

        if (isBiometricEnabled) {
          // Tente autenticar com a biometria
          bool isAuthenticated = await _localAuth.authenticate(
            localizedReason: 'Por favor, autentique-se para continuar',
            options: AuthenticationOptions(
              stickyAuth: true,
              biometricOnly: true,
            ),
          );

          if (isAuthenticated) {
            // Redireciona para a tela inicial após autenticação bem-sucedida com biometria
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          } else {
            // Se a biometria falhar, peça para fazer login novamente com e-mail e senha
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          }
        } else {
          // Caso a biometria não tenha sido habilitada, redireciona para a tela inicial
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao fazer login: $e';
        _isLoading = false;
      });
    }
  }

  // Função para salvar a preferência de biometria no SharedPreferences
  Future<void> _saveBiometricPreference(bool isBiometricEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isBiometricEnabled', isBiometricEnabled); // Salva se a biometria foi habilitada
  }

  // Função para obter a preferência de biometria do SharedPreferences
  Future<bool> _getBiometricPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isBiometricEnabled') ?? false; // Retorna se a biometria foi habilitada
  }

  // Função para verificar e autenticar com biometria ao iniciar
  Future<void> _authenticateWithBiometrics() async {
    bool isBiometricEnabled = await _getBiometricPreference();
    
    if (isBiometricEnabled) {
      bool isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Por favor, autentique-se para continuar',
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (isAuthenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        // Se a biometria falhar, peça para fazer login novamente com email e senha
        setState(() {
          _errorMessage = 'Falha na autenticação biométrica!';
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _authenticateWithBiometrics(); // Tente autenticar com biometria ao iniciar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
        backgroundColor: Colors.black, // Cor do AppBar (preto)
      ),
      backgroundColor: Colors.black, // Cor de fundo da tela (preto)
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Campo de E-mail
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white), // Texto do label branco
                errorText: _errorMessage.contains('e-mail') ? _errorMessage : null,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white), // Borda branca
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white), // Borda branca ao focar
                ),
              ),
              style: TextStyle(color: Colors.white), // Cor do texto no campo
            ),
            SizedBox(height: 10),
            // Campo de Senha
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Senha',
                labelStyle: TextStyle(color: Colors.white), // Texto do label branco
                errorText: _errorMessage.contains('senha') ? _errorMessage : null,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white), // Borda branca
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white), // Borda branca ao focar
                ),
              ),
              obscureText: true,
              style: TextStyle(color: Colors.white), // Cor do texto no campo
            ),
            SizedBox(height: 20),
            // Exibição da mensagem de erro
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            // Botão de Login
            _isLoading
                ? CircularProgressIndicator() // Se estiver carregando, mostra o indicador de progresso
                : ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Color(0xFFD4AF37), // Cor do texto (branco)
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                    ),
                    child: Text('Login'),
                  ),
            SizedBox(height: 20),
            // Botão de criar conta
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: Text('Criar conta', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
