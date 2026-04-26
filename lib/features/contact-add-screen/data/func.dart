import 'package:cloud_firestore/cloud_firestore.dart';
import '../../authentication/logic/bloc/authentication.dart';
import 'package:kontaku/core/models/number_model.dart';
import 'package:kontaku/core/utils/auth-check.dart';

Future<bool> addContactToFirestore({
  required NumberModel number,
  required AuthenticationBloc authenticationBloc,
}) async {
  final currentUserUid = checkAuthenticationStatus(authenticationBloc);
  if (currentUserUid.isEmpty || currentUserUid == "unauthenticated") {
    return false;
  }
  try {
    final contactRef = FirebaseFirestore.instance
        .collection("userDetails")
        .doc(currentUserUid)
        .collection("contacts")
        .doc(number.number);

    final contactSnapshot = await contactRef.get();
    if (contactSnapshot.exists) {
      return false;
    }

    await contactRef.set(number.toFirestoreMap());
    return true;
  } catch (e) {
    return false;
  }
}
