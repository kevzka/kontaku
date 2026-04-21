import 'package:cloud_firestore/cloud_firestore.dart';
import '../../authentication/logic/bloc/authentication.dart';
import '../../authentication/logic/event-state/authentication-event-state.dart';
import 'package:kontaku/core/models/number_model.dart';
import 'package:kontaku/core/utils/utils.dart';
import '../data/func.dart';

Future<bool> addContact({
  required String name,
  required String email,
  required String phone,
  required String notes,
  required AuthenticationBloc authenticationBloc,
}) async {
  final authenticationState = authenticationBloc.state;
  final currentUserUid = (authenticationState is Authenticated)
      ? authenticationState.user.uid
      : null;
  if (currentUserUid == null || currentUserUid.isEmpty) {
    return false;
  }
  final db = FirebaseFirestore.instance;
  try {
    final normalizedPhone = Kontaku.normalizePhoneNumber(phone);

    final NumberModel number = NumberModel(
      name: name,
      number: normalizedPhone,
      profilePath: null,
      email: email,
      notes: notes,
      uid: currentUserUid,
    );

    final contactExists = await checkIfContactExistsInFirestore(
      number.number,
      currentUserUid,
    );
    if (!contactExists) {
      await addContactToFirestore(number: number, authenticationBloc: authenticationBloc);

      return true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}