import 'package:flutter/material.dart';

class CheckInButton extends StatelessWidget {
  final Function onPress;

  CheckInButton({required this.onPress});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onPress(),
      child: Text('Registrar Ponto'),
    );
  }
}
