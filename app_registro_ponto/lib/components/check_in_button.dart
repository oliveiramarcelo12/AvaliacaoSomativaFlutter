import 'package:flutter/material.dart';

/// Botão personalizado para o registro de ponto.
///
/// `CheckInButton` exibe um botão que muda para um indicador de carregamento 
/// quando uma operação assíncrona está em andamento. Recebe um texto dinâmico, 
/// uma função `onPressed`, e cores para customização.
class CheckInButton extends StatelessWidget {
  final bool isLoading;          // Indica se o botão está em estado de carregamento
  final VoidCallback onPressed;  // Função que é chamada quando o botão é pressionado
  final String text;             // Texto dinâmico exibido no botão

  // Construtor que inicializa as propriedades obrigatórias
  CheckInButton({
    required this.isLoading,
    required this.onPressed,
    required this.text,
    required Color buttonColor,
    required Color textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      // O botão é desabilitado se `isLoading` for true para evitar cliques múltiplos
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? SizedBox(
              width: 24, // Largura fixa do CircularProgressIndicator para uniformidade
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(text), // Exibe o texto dinâmico quando não está carregando
    );
  }
}
