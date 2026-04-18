import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationFailure implements Exception {
  final String message;

  const AuthenticationFailure(this.message);

  @override
  String toString() => message;
}

class AuthenticationRepository {
  final FirebaseAuth _firebaseAuth;

  AuthenticationRepository({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthenticationFailure('User tidak ditemukan');
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthenticationFailure(_mapFirebaseErrorCodeToMessage(e.code));
    }
  }

  Future<User?> getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthenticationFailure(_mapFirebaseErrorCodeToMessage(e.code));
    }
  }

  String _mapFirebaseErrorCodeToMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'user-disabled':
        return 'Akun ini dinonaktifkan';
      case 'user-not-found':
        return 'Email tidak terdaftar';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan, coba lagi nanti';
      default:
        return 'Terjadi kesalahan autentikasi';
    }
  }
}
