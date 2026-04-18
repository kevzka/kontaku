import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kontaku/core/models/account_model.dart';
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
        // UID di level atas: numberDetails/{uid}/contacts/*
        .collection('numberDetails')
        .doc(currentUserUid)
        .collection('contacts')
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return NumberModel.fromFirestoreMap(data, fallbackUid: currentUserUid);
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
    final contact = NumberModel(
      name: name,
      number: number,
      profilePath: null,
      uid: currentUserUid,
      uidNumber: linkedUserUid,
    );

    // UID di level atas: numberDetails/{uid}
    await FirebaseFirestore.instance
        .collection('numberDetails')
        .doc(currentUserUid)
        .collection('contacts')
        .add(contact.toFirestoreMap());
  }
}

Future<String?> findUserUidByPhoneNumber({required String number}) async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('userDetails')
      .where('phoneNumber', isEqualTo: number)
      .get();
  if (querySnapshot.docs.isEmpty) {
    return null;
  }

  final firstUser = AccountModel.fromFirestoreMap(
    querySnapshot.docs.first.data(),
    fallbackUid: querySnapshot.docs.first.id,
  );
  return firstUser.uid;
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
    // Hapus semua kontak milik user di subcollection contacts.
    final querySnapshot = await FirebaseFirestore.instance
        .collection('numberDetails')
        .doc(currentUserUid)
        .collection('contacts')
        .get();

    for (final doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }
}
