import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kontaku/core/models/number_model.dart';
import 'package:kontaku/features/authentication/bloc/authentication.dart';
import 'package:kontaku/features/authentication/event-state/authentication-event-state.dart';

Future<List<NumberModel>> fetchCurrentUserContactNumbers(
  AuthenticationBloc authenticationBloc,
) async {
  final authenticationState = authenticationBloc.state;
  if (authenticationState is Authenticated) {
    final currentUserUid = authenticationState.user.uid;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('numberDetails')
        .where('uid', isEqualTo: currentUserUid)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return NumberModel(
        name: data['name'] as String? ?? '',
        number: data['number'] as String? ?? '',
        profilePath: null,
        uid: data['uid'] as String?,
        uidNumber: data['uidNumber'] as String?,
      );
    }).toList();
  }
  return [];
}

Future<void> addContactNumberForCurrentUser({
  required AuthenticationBloc authenticationBloc,
  required String name,
  required String number,
}) async {
  final linkedUserUid = await findUserUidByPhoneNumber(number: number);
  final authenticationState = authenticationBloc.state;
  if (authenticationState is Authenticated) {
    final currentUserUid = authenticationState.user.uid;
    await FirebaseFirestore.instance.collection('numberDetails').add({
      'name': name,
      'number': number,
      'uid': currentUserUid,
      'uidNumber': linkedUserUid,
    });
  }
}

Future<String?> findUserUidByPhoneNumber({required String number}) async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('userDetails')
      .where('phoneNumber', isEqualTo: number)
      .get();
  final firstUserUid = querySnapshot.docs
      .map((doc) => doc['uid'] as String?)
      .firstWhere((uid) => uid != null, orElse: () => null);

  if (querySnapshot.docs.isNotEmpty) {
    return firstUserUid;
  } else {
    return null;
  }
}

List<NumberModel> mergeContactsWithCloudNumbers(
  List<NumberModel> existingContacts,
  List<NumberModel> cloudNumbers,
) {
  final knownNumbers = existingContacts
      .map((contact) => _normalizePhoneNumber(contact.number))
      .where((number) => number.isNotEmpty)
      .toSet();
  final mergedContacts = [...existingContacts];

  for (final cloudNumber in cloudNumbers) {
    final normalizedNumber = _normalizePhoneNumber(cloudNumber.number);
    if (normalizedNumber.isNotEmpty && knownNumbers.add(normalizedNumber)) {
      mergedContacts.add(cloudNumber);
    }
  }

  return mergedContacts;
}

String _normalizePhoneNumber(String value) {
  return value.replaceAll(RegExp(r'[^0-9+]'), '').trim();
}

void deleteAllDataInNumberDetails(AuthenticationBloc authenticationBloc) async {
  final authenticationState = authenticationBloc.state;
  if (authenticationState is Authenticated) {
    final currentUserUid = authenticationState.user.uid;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('numberDetails')
        .where('uid', isEqualTo: currentUserUid)
        .get();

    for (final doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }
}