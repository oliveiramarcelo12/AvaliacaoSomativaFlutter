// Importações necessárias para inicializar o Firebase no aplicativo Flutter
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Classe que armazena as configurações padrão do Firebase para o projeto.
///
/// Contém as informações necessárias para conectar o aplicativo ao projeto Firebase,
/// como `apiKey`, `appId`, e outras credenciais que identificam o projeto.
class DefaultFirebaseOptions {
  
  /// Método estático que retorna as configurações de Firebase para a plataforma atual.
  ///
  /// Aqui são definidas as credenciais do projeto Firebase, necessárias para autenticação,
  /// armazenamento e outras integrações com o Firebase.
  static FirebaseOptions get currentPlatform {
    // Configurações específicas do projeto Firebase
    return const FirebaseOptions(
      apiKey: "AIzaSyDhcqrkLeDPOtZzxqSwOsl9EsWm7xRH6pc",           // Chave de API do Firebase
      appId: "1:197911325551:android:06d24774ec7d85c196569a",     // ID do aplicativo
      messagingSenderId: "197911325551",                          // ID do remetente do Firebase Cloud Messaging
      projectId: "testefirebasenoite",                            // ID do projeto no Firebase
      storageBucket: "testefirebasenoite.appspot.com",            // URL do bucket de armazenamento do Firebase
      authDomain: "testefirebasenoite.firebaseapp.com",           // Domínio de autenticação do Firebase
    );
  }
}
