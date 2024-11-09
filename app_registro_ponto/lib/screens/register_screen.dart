// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_photo_screen.dart';  // Certifique-se de ter importado a tela de captura de foto.

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;  // Adicionado para controlar o estado de carregamento

  // Função para verificar se o e-mail já está registrado
  Future<bool> _isEmailRegistered(String email) async {
    try {
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'As senhas não coincidem.';
      });
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _isLoading = true;  // Define o estado de carregamento para true
      _errorMessage = '';
    });

    // Verifica se o e-mail já está registrado
    bool emailExists = await _isEmailRegistered(email);
    if (emailExists) {
      setState(() {
        _errorMessage = 'Este e-mail já está cadastrado.';
        _isLoading = false;  // Define o estado de carregamento para false
      });
      return;
    }

    try {
      // Criação da conta
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Redireciona para a tela de captura de foto
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RegisterPhotoScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao registrar: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;  // Define o estado de carregamento para false
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registrar"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            SizedBox(height: 10),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirmar Senha'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 20),
            _isLoading
              ? CircularProgressIndicator()  // Exibe um indicador de carregamento enquanto registra
              : ElevatedButton(
                  onPressed: _register,
                  child: Text('Registrar'),
                ),
          ],
        ),
      ),
    );
  }
}
