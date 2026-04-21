import 'package:cloud_firestore/cloud_firestore.dart';
import '../../authentication/logic/bloc/authentication.dart';
import 'package:kontaku/core/models/number_model.dart';
import 'package:kontaku/core/utils/utils.dart';
import 'package:kontaku/core/utils/auth-check.dart';

Future<bool> addContactToFirestore({
  required NumberModel number,
  required AuthenticationBloc authenticationBloc,
}) async {
  final currentUserUid = checkAuthenticationStatus(authenticationBloc);
  if (currentUserUid == "unauthenticated") {
    return false;
  }
  final db = FirebaseFirestore.instance;
  try {
    final contactExists = await checkIfContactExistsInFirestore(
      number.number,
      currentUserUid,
    );
    if (!contactExists) {
      await db
          .collection("userDetails")
          .doc(currentUserUid)
          .collection("contacts")
          .doc(number.number)
          .set(number.toFirestoreMap());

      return true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}

Future<bool> checkIfContactExistsInFirestore(
  String phone,
  String currentUserUid,
) async {
  final db = FirebaseFirestore.instance;
  try {
    print(phone);
    final querySnapshot = await db
        .collection("userDetails")
        .doc(currentUserUid)
        .collection("contacts")
        .where("number", isEqualTo: phone)
        .get();
    print(querySnapshot.docs.isNotEmpty);
    return querySnapshot.docs.isNotEmpty;
  } catch (e) {
    return false;
  }
}
