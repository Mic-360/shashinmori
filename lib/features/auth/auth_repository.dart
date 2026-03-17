import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/api_client.dart';
import '../../shared/models/app_error.dart';

class AuthRepository {
  Future<void>? _initialization;

  Future<void> _ensureInitialized() {
    return _initialization ??= GoogleSignIn.instance.initialize();
  }

  Future<UserCredential> signInWithGoogle() async {
    await _ensureInitialized();

    final account = await GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw const AppError(
        code: 'GOOGLE_SIGN_IN_FAILED',
        message: 'Google Sign-In did not return an ID token.',
      );
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final userCredential = await FirebaseAuth.instance.signInWithCredential(
      credential,
    );

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
        'displayName': user.displayName ?? account.displayName ?? 'Family user',
        'photoURL': user.photoURL ?? account.photoUrl ?? '',
      },
    );

    return userCredential;
  }

  Future<void> signOut() async {
    await _ensureInitialized();
    await GoogleSignIn.instance.signOut();
    await FirebaseAuth.instance.signOut();
  }
}
