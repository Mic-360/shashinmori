import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static FirebaseOptions get web => FirebaseOptions(
        apiKey: _required('FIREBASE_API_KEY'),
        appId: _required('FIREBASE_APP_ID'),
        messagingSenderId: _required('FIREBASE_MESSAGING_SENDER_ID'),
        projectId: _required('FIREBASE_PROJECT_ID'),
        authDomain: _required('FIREBASE_AUTH_DOMAIN'),
        storageBucket: _required('FIREBASE_STORAGE_BUCKET'),
      );

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: _required('FIREBASE_API_KEY'),
        appId: _required('FIREBASE_APP_ID'),
        messagingSenderId: _required('FIREBASE_MESSAGING_SENDER_ID'),
        projectId: _required('FIREBASE_PROJECT_ID'),
        storageBucket: _required('FIREBASE_STORAGE_BUCKET'),
      );

  static String _required(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty || value.startsWith('replace-with-')) {
      throw StateError(
        'Missing Firebase env value for $key. Update shashinmori-app/.env before running the app.',
      );
    }
    return value;
  }
}
