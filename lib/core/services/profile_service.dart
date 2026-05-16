import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:kontaku/core/models/account_model.dart';
import 'package:kontaku/core/utils/auth-check.dart';
import 'package:kontaku/features/authentication/logic/bloc/authentication.dart';

/// Shared service untuk operasi profil pengguna.
/// Menggantikan duplikasi getMyProfile() di profile-screen dan profile-edit-screen.
class ProfileService {
  static Future<AccountModel> getMyProfile({
    required AuthenticationBloc authenticationBloc,
  }) async {
    try {
      final db = FirebaseFirestore.instance;
      final currentUserUid = checkAuthenticationStatus(authenticationBloc);
      final snapshot = await db
          .collection('userDetails')
          .doc(currentUserUid)
          .get();

      final email = FirebaseAuth.instance.currentUser!.email!;

      final myProfile = AccountModel(
        username: snapshot['username'] as String? ?? 'Unknown',
        email: email,
        uid: currentUserUid,
        profilePath: snapshot['profilePath'] as String? ?? '',
        phoneNumber: snapshot['phoneNumber'] as String? ?? '',
      );

      debugPrint('[ProfileService] Profile loaded: ${myProfile.username}');
      return myProfile;
    } catch (e) {
      debugPrint('[ProfileService] Error fetching profile: $e');
      rethrow;
    }
  }

  static Future<void> saveProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    await FirebaseFirestore.instance
        .collection('userDetails')
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }
}
