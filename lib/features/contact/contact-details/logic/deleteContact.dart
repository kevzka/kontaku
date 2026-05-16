import 'package:firebase_database/firebase_database.dart';

import '../data/data-firestore.dart';
import '../data/data-local.dart';

Future<void> deleteContact({required String uid, required String number, String? uidContact}) async {
  // debugPrint('Deleting contact with uid: $uid, number: $number, uidContact: $uidContact');
  try {
    deleteDummyContact(number);
    await deleteContactFirestore(uid, number);
    if(uidContact != null) {
    await deleteUserChatsRDB(uid, uidContact);
    }
  } catch (e) {
    // debugPrint('Error deleting contact: $e');
  }

}

Future<void> deleteUserChatsRDB(String uid, String uidChats) async {
  try {
    // debugPrint('Deleting contact from RDB with uid: $uid and uidContact: $uidChats');
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference userChatsRef = database.ref('userChats/$uid');
    await userChatsRef.child(uidChats).remove();
    // debugPrint('Successfully deleted contact from RDB');
  } catch (e) {
    // debugPrint('Error deleting contact from RDB: $e');
  }
}
