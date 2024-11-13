import 'package:firebase_auth/firebase_auth.dart';

/// Serviço de autenticação utilizando Firebase Authentication.
/// Contém métodos para login, logout e obtenção do ID do usuário atual.
class AuthService {
  // Instância do FirebaseAuth para gerenciar a autenticação.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Método para autenticar o usuário com email e senha.
  ///
  /// [email] - Email do usuário.
  /// [password] - Senha do usuário.
  /// Retorna o objeto `User` se a autenticação for bem-sucedida, ou `null` em caso de falha.
  Future<User?> signIn(String email, String password) async {
    try {
      // Tenta fazer o login com o email e senha fornecidos
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user; // Retorna o usuário autenticado
    } catch (e) {
      // Em caso de erro, exibe a mensagem de erro e retorna null
      print(e);
      return null;
    }
  }

  /// Método para desconectar o usuário atual.
  Future<void> signOut() async {
    await _auth.signOut(); // Encerra a sessão do usuário atual
  }

  /// Método para obter o ID do usuário atualmente autenticado.
  ///
  /// Retorna uma string vazia caso não haja um usuário logado.
  String getCurrentUserId() {
    return _auth.currentUser?.uid ?? ''; // Retorna o UID ou uma string vazia
  }
}
