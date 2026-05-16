import 'package:kontaku/core/services/contact_firestore_service.dart';
import '../data/data-local.dart';

Future<void> deleteContact(String uid, String number) async {
  try {
    deleteDummyContact(number);
    await ContactFirestoreService.deleteContact(uid, number);
  } catch (e) {
    assert(() { print('Error deleting contact: $e'); return true; }());
  }
}
