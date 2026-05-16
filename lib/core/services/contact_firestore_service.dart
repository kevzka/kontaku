import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kontaku/core/models/number_model.dart';
import 'package:flutter/foundation.dart';

/// Shared Firestore service untuk operasi kontak.
/// Menggantikan duplikasi di contact-details dan contact-edit-screen.
class ContactFirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<NumberModel?> getContactDetails(
    String number,
    String meUid,
  ) async {
    final query = _db
        .collection('userDetails')
        .doc(meUid)
        .collection('contacts')
        .where('number', isEqualTo: number);

    final snapshot = await query.get();
    if (snapshot.docs.isEmpty) return null;

    final data = snapshot.docs.first.data();
    final model = NumberModel.fromFirestoreMap(data, fallbackUid: meUid);
    return NumberModel(
      name: model.name,
      number: model.number.isEmpty ? number : model.number,
      profilePath: model.profilePath,
      uid: model.uid,
      uidNumber: model.uidNumber,
      email: model.email,
      notes: model.notes,
    );
  }

  static Future<bool> deleteContact(String uid, String number) async {
    try {
      final contactsRef = _db
          .collection('userDetails')
          .doc(uid)
          .collection('contacts');

      final snapshot = await contactsRef
          .where('number', isEqualTo: number)
          .get();

      if (snapshot.docs.isEmpty) {
        debugLog('Contact with number $number not found for user $uid');
        return false;
      }

      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      debugLog('Contact with number $number deleted for user $uid');
      return true;
    } catch (e) {
      debugLog('Error deleting contact: $e');
      return false;
    }
  }

  static Future<String> updateContact({
    required String uid,
    required String number,
    required String numberOri,
    String? name,
    String? email,
    String? notes,
  }) async {
    debugLog(
      'Updating contact uid:$uid number:$number name:$name email:$email notes:$notes',
    );
    try {
      if (number != numberOri) {
        final oldDocRef = _db
            .collection('userDetails')
            .doc(uid)
            .collection('contacts')
            .doc(numberOri);

        final oldDocSnap = await oldDocRef.get();

        if (oldDocSnap.exists) {
          final oldData = Map<String, dynamic>.from(oldDocSnap.data()!);
          oldData['name'] = name;
          oldData['email'] = email;
          oldData['notes'] = notes;
          oldData['number'] = number;

          final newDocRef = _db
              .collection('userDetails')
              .doc(uid)
              .collection('contacts')
              .doc(number);

          final batch = _db.batch();
          batch.set(newDocRef, oldData);
          batch.delete(oldDocRef);
          await batch.commit();
          debugLog('Contact moved from $numberOri to $number');
        }
        return 'number_changed';
      } else {
        await _db
            .collection('userDetails')
            .doc(uid)
            .collection('contacts')
            .doc(numberOri)
            .update({'name': name, 'email': email, 'notes': notes});
        return 'true';
      }
    } catch (e) {
      debugLog('Error updating contact: $e');
      return 'false';
    }
  }

  // ignore: avoid_print
  static void debugLog(String msg) {
    if (kDebugMode) {
      print('[ContactFirestoreService] $msg');
    }
  }
}
