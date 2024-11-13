import 'package:flutter/material.dart';

/// `CustomTextField` é um widget personalizado para campos de texto com suporte a validação,
/// ocultação de texto (ex: para senhas), e entrada de diferentes tipos de dados.
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;      // Controlador para gerenciar o valor do campo
  final String label;                          // Rótulo exibido acima do campo de texto
  final bool obscureText;                      // Indica se o texto deve ser ocultado (usado para senhas)
  final TextInputType keyboardType;            // Tipo de teclado, define o tipo de entrada (texto, email, número, etc.)
  final String? Function(String?)? validator;  // Função de validação opcional

  // Construtor que permite definir os parâmetros do campo, com valores padrão para `obscureText` e `keyboardType`
  CustomTextField({
    required this.controller,
    required this.label,
    this.obscureText = false,                  // Por padrão, o texto não é oculto
    this.keyboardType = TextInputType.text,    // Por padrão, aceita texto simples
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,                  // Define o controlador para gerenciar o estado do campo
      decoration: InputDecoration(
        labelText: label,                      // Exibe o rótulo passado no parâmetro `label`
        border: OutlineInputBorder(),          // Define a borda do campo como contornada
      ),
      obscureText: obscureText,                // Oculta o texto se `obscureText` for true
      keyboardType: keyboardType,              // Define o tipo de entrada de acordo com `keyboardType`
      validator: validator,                    // Aplica a função de validação, se fornecida
    );
  }
}
