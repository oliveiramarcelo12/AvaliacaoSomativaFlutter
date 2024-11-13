import 'package:flutter/material.dart';

/// Widget personalizado que exibe um indicador de carregamento centralizado.
///
/// `LoadingSpinner` é usado para mostrar ao usuário que uma operação assíncrona
/// está em andamento, como uma requisição de rede ou carregamento de dados.
class LoadingSpinner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      // O CircularProgressIndicator é um widget nativo do Flutter que exibe um spinner animado.
      child: CircularProgressIndicator(),
    );
  }
}
