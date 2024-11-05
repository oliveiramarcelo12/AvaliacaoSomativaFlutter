// lib/components/check_in_button.dart
import 'package:flutter/material.dart';

class CheckInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  CheckInButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed, // Desabilita o botão se isLoading for true
      child: isLoading ? CircularProgressIndicator() : Text('Registrar Ponto'),
    );
  }
}
