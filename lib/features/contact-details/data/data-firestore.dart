import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kontaku/core/models/number_model.dart';


Future<NumberModel?> getContactDetails(String number, String meUid) async {
  final db = FirebaseFirestore.instance;
  final numDetailsRef = db
      .collection('userDetails')
      .doc(meUid)
      .collection('contacts')
      .where('number', isEqualTo: number);

  final querySnapshot = await numDetailsRef.get();
  if (querySnapshot.docs.isEmpty) {
    return null;
  }

  final data = querySnapshot.docs.first.data();
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


Future<bool> deleteContactFirestore(String uid, String number) async {
  try{
  final db = FirebaseFirestore.instance;
    // UID di level atas: userDetails/{uid}/contacts/*
    final querySnapshot = await db
        .collection('userDetails')
        .doc(uid)
        .collection('contacts')
        .where('number', isEqualTo: number)
        .get();

    for (final doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
    return true;
  }catch(e){
    print('Error deleting contact: $e');
    return false;
  }
}