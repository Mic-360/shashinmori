import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static const String _firebaseApiKey =
      'AIzaSyD3vKKsPI9sBD2By5XZtzI_WLW7kkkRgJg';
  static const String _firebaseAppId =
      '1:753164470775:web:95ad35d463d02cdbdfc6f2';
  static const String _firebaseMessagingSenderId = '753164470775';
  static const String _firebaseProjectId = 'shashinmori-c82a1';
  static const String _firebaseAuthDomain = 'shashinmori-c82a1.firebaseapp.com';
  static const String _firebaseStorageBucket =
      'shashinmori-c82a1.firebasestorage.app';

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: _firebaseApiKey,
        appId: _firebaseAppId,
        messagingSenderId: _firebaseMessagingSenderId,
        projectId: _firebaseProjectId,
        storageBucket: _firebaseStorageBucket,
      );

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
        apiKey: _firebaseApiKey,
        appId: _firebaseAppId,
        messagingSenderId: _firebaseMessagingSenderId,
        projectId: _firebaseProjectId,
        authDomain: _firebaseAuthDomain,
        storageBucket: _firebaseStorageBucket,
      );
}
