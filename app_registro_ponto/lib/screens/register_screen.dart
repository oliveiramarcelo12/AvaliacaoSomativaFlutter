import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register_photo_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;

  // Função para verificar se o e-mail já está registrado
  Future<bool> _isEmailRegistered(String email) async {
    try {
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao verificar e-mail: $e';
      });
      return false;
    }
  }

  // Função para registrar o usuário
  Future<void> _register() async {
    setState(() {
      _errorMessage = '';
    });

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, preencha todos os campos.';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'As senhas não coincidem.';
      });
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _isLoading = true;
    });

    bool emailExists = await _isEmailRegistered(email);
    if (emailExists) {
      setState(() {
        _errorMessage = 'Este e-mail já está cadastrado.';
        _isLoading = false;
      });
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Redireciona para a tela de foto
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RegisterPhotoScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao registrar: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registrar"),
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
              keyboardType: TextInputType.emailAddress,
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
            SizedBox(height: 10),
            // Campo de Confirmar Senha
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirmar Senha',
                labelStyle: TextStyle(color: Colors.white), // Texto do label branco
                errorText: _errorMessage.contains('senhas') ? _errorMessage : null,
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
            // Botão de Registrar
            _isLoading
                ? CircularProgressIndicator() // Se estiver carregando, mostra o indicador de progresso
                : ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Color(0xFFD4AF37), // Cor do texto (branco)
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                    ),
                    child: Text('Registrar'),
                  ),
          ],
        ),
      ),
    );
  }
}
