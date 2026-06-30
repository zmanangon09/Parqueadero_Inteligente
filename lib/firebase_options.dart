// SCAFFOLD TEMPORAL — reemplazar ejecutando: flutterfire configure
// Este archivo es generado automáticamente por FlutterFire CLI.
// Referencia: https://firebase.flutter.dev/docs/cli
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no está configurado para esta plataforma. '
          'Ejecuta: flutterfire configure',
        );
    }
  }

  // Reemplazar con valores reales tras ejecutar: flutterfire configure
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_WITH_REAL_KEY',
    appId: 'REPLACE_WITH_REAL_APP_ID',
    messagingSenderId: 'REPLACE',
    projectId: 'REPLACE_WITH_PROJECT_ID',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_REAL_KEY',
    appId: 'REPLACE_WITH_REAL_APP_ID',
    messagingSenderId: 'REPLACE',
    projectId: 'REPLACE_WITH_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_REAL_KEY',
    appId: 'REPLACE_WITH_REAL_APP_ID',
    messagingSenderId: 'REPLACE',
    projectId: 'REPLACE_WITH_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.pryFinalParqueadero',
  );
}
