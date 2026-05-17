import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../data/data-firestore.dart';
import '../data/data-local.dart';

Future<void> deleteContact({required String uid, required String number, String? uidContact}) async {
  try {
    deleteDummyContact(number);
    await deleteContactFirestore(uid, number);
    await deleteCOntactInGroupFirestore(uid, number);
    if(uidContact != null) {
    await deleteUserChatsRDB(uid, uidContact);
    }
  } catch (e) {
    debugPrint('Error deleting contact: $e');
  }

}

Future<void> deleteCOntactInGroupFirestore(String uid, String number) async {
  try {
    print('Deleting contact from group in Firestore with uid: $uid and number: $number');
    FirebaseFirestore db = FirebaseFirestore.instance;
    CollectionReference categoriesRef = db.collection('userDetails').doc(uid).collection('categories');
    QuerySnapshot querySnapshot = await categoriesRef.get();
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      DocumentReference categoryRef = categoriesRef.doc(doc.id);
      QuerySnapshot contactsSnapshot = await categoryRef.collection('contacts').where('number', isEqualTo: number).get();
      for (QueryDocumentSnapshot contactDoc in contactsSnapshot.docs) {
        await categoryRef.collection('contacts').doc(contactDoc.id).delete();
        print('Successfully deleted contact from group in Firestore for category: ${doc.id}');
        //hapus jika group kosong
        QuerySnapshot remainingContacts = await categoryRef.collection('contacts').get();
        if (remainingContacts.docs.isEmpty) {
          await categoryRef.delete();
          print('Deleted empty group: ${doc.id}');
        }
      }
    }
  } catch (e) {
    debugPrint('Error deleting contact from group in Firestore: $e');
  }
}

Future<void> deleteUserChatsRDB(String uid, String uidChats) async {
  try {
    debugPrint('Deleting contact from RDB with uid: $uid and uidContact: $uidChats');
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference userChatsRef = database.ref('userChats/$uid');
    await userChatsRef.child(uidChats).remove();
    debugPrint('Successfully deleted contact from RDB');
  } catch (e) {
    debugPrint('Error deleting contact from RDB: $e');
  }
}
