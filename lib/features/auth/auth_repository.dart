import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/api_client.dart';
import '../../shared/models/app_error.dart';

class AuthRepository {
  Future<void>? _initialization;

  Future<void> _ensureInitialized() {
    if (kIsWeb) {
      return Future.value();
    }

    return _initialization ??= GoogleSignIn.instance.initialize();
  }

  Future<UserCredential> signInWithGoogle() async {
    await _ensureInitialized();

    final userCredential =
        kIsWeb ? await _signInWithFirebasePopup() : await _signInOnAndroid();

    final user = userCredential.user;
    if (user == null) {
      throw const AppError(
        code: 'AUTH_FAILED',
        message: 'Firebase authentication did not return a user.',
      );
    }

    await apiClient.post<Map<String, dynamic>>(
      '/v1/auth/profile',
      data: {
        'displayName': user.displayName ?? 'Family user',
        'photoURL': user.photoURL ?? '',
      },
    );

    return userCredential;
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      await _ensureInitialized();
      await GoogleSignIn.instance.signOut();
    }

    await FirebaseAuth.instance.signOut();
  }

  Future<UserCredential> _signInWithFirebasePopup() async {
    final provider = GoogleAuthProvider()..setCustomParameters({
        'prompt': 'select_account',
      });

    try {
      return await FirebaseAuth.instance.signInWithPopup(provider);
    } on FirebaseAuthException catch (error) {
      throw AppError(
        code: error.code,
        message: error.message ??
            'Google Sign-In popup failed. Check your Firebase authorized domains and browser blocking settings.',
      );
    }
  }

  Future<UserCredential> _signInOnAndroid() async {
    final account = await GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw const AppError(
        code: 'GOOGLE_SIGN_IN_FAILED',
        message: 'Google Sign-In did not return an ID token.',
      );
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    return FirebaseAuth.instance.signInWithCredential(credential);
  }
}
