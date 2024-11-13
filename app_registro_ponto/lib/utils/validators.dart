/// Classe Validators que contém métodos de validação de dados, como email e senha.
class Validators {

  /// Método para validar o campo de email.
  ///
  /// [value] - O valor do email a ser validado.
  /// Retorna uma mensagem de erro se o campo estiver vazio, ou `null` se for válido.
  static String? validateEmail(String? value) {
    // Verifica se o email é nulo ou está vazio
    if (value == null || value.isEmpty) {
      return 'O email é obrigatório.'; // Retorna mensagem de erro se vazio
    }
    return null; // Retorna null se o email for válido
  }

  /// Método para validar o campo de senha.
  ///
  /// [value] - O valor da senha a ser validada.
  /// Retorna uma mensagem de erro se o campo estiver vazio, ou `null` se for válido.
  static String? validatePassword(String? value) {
    // Verifica se a senha é nula ou está vazia
    if (value == null || value.isEmpty) {
      return 'A senha é obrigatória.'; // Retorna mensagem de erro se vazio
    }
    return null; // Retorna null se a senha for válida
  }
}
