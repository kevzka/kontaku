import '..//data/data-firestore.dart';
import '../data/data-local.dart';

Future<void> deleteContact(String uid, String number) async {
  try {
    deleteDummyContact(number);
    await deleteContactFirestore(uid, number);
  } catch (e) {
    print('Error deleting contact: $e');
  }

}
