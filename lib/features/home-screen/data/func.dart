import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kontaku/core/models/account_model.dart';
import 'package:kontaku/core/models/number_model.dart';
import 'package:kontaku/core/utils/auth-check.dart';
import 'package:kontaku/features/authentication/logic/bloc/authentication.dart';
import 'package:kontaku/features/authentication/logic/event-state/authentication-event-state.dart';
import 'package:firebase_database/firebase_database.dart';

Future<List<NumberModel>> fetchCurrentUserContactNumbers(
  AuthenticationBloc authenticationBloc,
) async {
  final authenticationState = authenticationBloc.state;
  if (authenticationState is Authenticated) {
    final currentUserUid = authenticationState.user.uid;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('userDetails')
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

    // UID di level atas: userDetails/{uid}/contacts
    await FirebaseFirestore.instance
        .collection('userDetails')
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
  [List<NumberModel> extraContacts = const <NumberModel>[]]
) {
  final knownNumbers = existingContacts
      .map((contact) => _normalizePhoneNumber(contact.number))
      .where((number) => number.isNotEmpty)
      .toSet();
  final mergedContacts = [...existingContacts];

  for (final contact in [...cloudNumbers, ...extraContacts]) {
    final normalizedNumber = _normalizePhoneNumber(contact.number);
    if (normalizedNumber.isEmpty || !knownNumbers.add(normalizedNumber)) {
      continue;
    }

    mergedContacts.add(contact);
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
        .collection('userDetails')
        .doc(currentUserUid)
        .collection('contacts')
        .get();

    for (final doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }
}

Future<List<Map<String, Object>>> getAllContactsByCategory({
  required AuthenticationBloc authenticationBloc,
  required List<NumberModel> dummyContacts,
}) async {
  final currentUserUid = checkAuthenticationStatus(authenticationBloc);
  if (currentUserUid.isEmpty) {
    return <Map<String, Object>>[];
  }
  print("ini no dummy");
  print(dummyContacts);

  final rows = <Map<String, Object>>[];
  final db = FirebaseFirestore.instance;

  try {
    final categoriesSnapshot = await db
        .collection('userDetails')
        .doc(currentUserUid)
        .collection('categories');

    final categories = await categoriesSnapshot.get().then(
      (snapshot) => snapshot.docs.map((doc) => doc.id).toList()..sort(),
    );

    //add number in category
    for (final category in categories) {
      rows.add({'type': 'section', 'value': category});

      final contactsSnapshot = await db
          .collection('userDetails')
          .doc(currentUserUid)
          .collection('categories')
          .doc(category)
          .collection('contacts')
          .get();
      for (final doc in contactsSnapshot.docs) {
        final contactData = doc.data();
        final contactModel = NumberModel.fromFirestoreMap(
          contactData,
          fallbackUid: currentUserUid,
        );
        print(contactModel);
        rows.add({'type': 'contact', 'value': contactModel});
      }
    }

    //add number that not in category to uncategorized section
    rows.add({'type': 'section', 'value': 'Uncategorized'});
    final categorizedNumbers = rows
        .where((row) => row['type'] == 'contact')
        .map((row) {
          print((row['value'] as NumberModel).number);
          return (row['value'] as NumberModel).number;
        })
        .toSet();
    print("Categorized numbers:");
    print(categorizedNumbers);

    final uncategorizedContacts = dummyContacts
        .where((contact) => !categorizedNumbers.contains(contact.number))
        .toList();
    for (final contact in uncategorizedContacts) {
      rows.add({'type': 'contact', 'value': contact});
    }
  } catch (e) {
    return <Map<String, Object>>[];
  }

  // debugPrint("Loaded grouped rows: ${rows.length}");
  return rows;
}

Future<List<NumberModel>> fetchAllChatParticipants({
  required AuthenticationBloc authenticationBloc,
}) async {
  final currentUserUid = checkAuthenticationStatus(authenticationBloc);
  if (currentUserUid.isEmpty) {
    return <NumberModel>[];
  }

  final dbRef = FirebaseDatabase.instance.ref();
  final userChatsSnapshot = await dbRef
      .child('userChats/$currentUserUid')
      .get();
  if (!userChatsSnapshot.exists || userChatsSnapshot.value is! Map) {
    return <NumberModel>[];
  }

  final rawUserChats = Map<dynamic, dynamic>.from(
    userChatsSnapshot.value as Map,
  );
  final chatIds = rawUserChats.keys.map((key) => key.toString()).toList();

  final otherMemberIds = <String>{};

  for (final chatId in chatIds) {
    final chatSnapshot = await dbRef.child('chats/$chatId').get();
    if (!chatSnapshot.exists || chatSnapshot.value is! Map) {
      continue;
    }

    final chatData = Map<dynamic, dynamic>.from(chatSnapshot.value as Map);
    final membersRaw = chatData['members'];
    if (membersRaw is! Map) {
      continue;
    }

    final members = Map<dynamic, dynamic>.from(membersRaw);
    for (final memberId in members.keys) {
      final uid = memberId.toString();
      if (uid != currentUserUid && uid.isNotEmpty) {
        otherMemberIds.add(uid);
      }
    }
  }

  if (otherMemberIds.isEmpty) {
    return <NumberModel>[];
  }

  final userDocs = await Future.wait(
    otherMemberIds.map(
      (uid) =>
          FirebaseFirestore.instance.collection('userDetails').doc(uid).get(),
    ),
  );
  print("Fetched user details for chat participants: ${userDocs.length}");
  for (final doc in userDocs) {
    print("User detail doc: ${doc.id}, exists: ${doc.exists}");
    print("User detail data: ${doc.data()}");
  }

  final participants = <NumberModel>[];
  for (final doc in userDocs) {
    final userData = doc.data();
    if (userData == null) {
      continue;
    }

    participants.add(
      NumberModel(
        name: userData['username'] as String? ?? 'Unknown',
        number: userData['phoneNumber'] as String? ?? '',
        profilePath: userData['imageProfile'] as String?,
        uid: doc.id,
        uidNumber: null,
      )
    );
  }

  participants.sort((a, b) => a.name.compareTo(b.name));
  print("Fetched chat participants: ${participants.length}");
  for (final participant in participants) {
    print("Participant: ${participant.name}, ${participant.number}, ${participant.uid}");
  }
  return participants;
}
