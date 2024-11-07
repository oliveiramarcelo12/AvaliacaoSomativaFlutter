import 'package:flutter/material.dart';

class CheckInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final String text; // Adicionando o texto dinâmico

  CheckInButton({required this.isLoading, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed, // Desabilita o botão se isLoading for true
      child: isLoading
          ? SizedBox(
              width: 24, // Tamanho fixo para o CircularProgressIndicator
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(text), // Mostra o texto com base na variável 'text'
    );
  }
}
