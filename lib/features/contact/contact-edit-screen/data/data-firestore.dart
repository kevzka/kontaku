// Re-export dari shared service untuk backward compatibility.
export 'package:kontaku/core/services/contact_firestore_service.dart'
    show ContactFirestoreService;

import 'package:kontaku/core/models/number_model.dart';
import 'package:kontaku/core/services/contact_firestore_service.dart';

Future<NumberModel?> getContactDetails(String number, String meUid) =>
    ContactFirestoreService.getContactDetails(number, meUid);

Future<bool> deleteContactFirestore(String uid, String number) =>
    ContactFirestoreService.deleteContact(uid, number);
