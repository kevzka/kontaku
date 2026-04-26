import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kontaku/core/models/account_model.dart';
import 'package:kontaku/core/utils/utils.dart';

/// Daftarkan user baru ke Firebase Auth + simpan detail ke Firestore.
/// Return: `{'success': true}` atau `{'success': false, 'error': String}`.
Future<Map<String, dynamic>> regisFunc({
  required String email,
  required String password,
  required String confirmPassword,
  required String username,
  required String phone,
}) async {
  if (password != confirmPassword) {
    return {
      'success': false,
      'error': 'Password dan Confirm Password tidak cocok',
    };
  }

  try {
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    await _addUserDetails(
      AccountModel(
        username: username,
        uid: credential.user!.uid,
        imageProfile: '',
        phoneNumber: Kontaku.normalizePhoneNumber(phone),
      ),
    );

    return {'success': true};
  } on FirebaseAuthException catch (e) {
    return {'success': false, 'error': e.code};
  }
}

Future<void> _addUserDetails(AccountModel account) async {
  await FirebaseFirestore.instance
      .collection('userDetails')
      .doc(account.uid)
      .set(account.toFirestoreMap());
}