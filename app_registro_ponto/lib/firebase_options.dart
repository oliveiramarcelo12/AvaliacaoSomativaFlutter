// firebase_options.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: "AIzaSyDhcqrkLeDPOtZzxqSwOsl9EsWm7xRH6pc",
      appId: "1:197911325551:android:06d24774ec7d85c196569a",
      messagingSenderId: "197911325551",
      projectId: "testefirebasenoite",
      storageBucket: "testefirebasenoite.appspot.com",
      authDomain: "testefirebasenoite.firebaseapp.com",
    );
  }
}
