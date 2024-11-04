import 'package:flutter/material.dart';

class CheckInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const CheckInButton({
    Key? key,
    required this.isLoading,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed, // Desabilita o botão se estiver carregando
      child: isLoading
          ? CircularProgressIndicator(color: Colors.white) // Exibe um indicador de carregamento
          : Text('Registrar Ponto'), // Texto do botão
    );
  }
}
