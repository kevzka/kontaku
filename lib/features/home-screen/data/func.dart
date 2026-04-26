import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kontaku/core/models/account_model.dart';
import 'package:kontaku/core/models/number_model.dart';
import 'package:kontaku/core/utils/auth-check.dart';
import 'package:kontaku/features/authentication/logic/bloc/authentication.dart';
import 'package:kontaku/features/authentication/logic/event-state/authentication-event-state.dart';
import 'package:firebase_database/firebase_database.dart' as rtdb;

const int _defaultContactPageSize = 300;
const Duration _contactsCacheTtl = Duration(minutes: 3);

class _CachedContacts {
  const _CachedContacts({required this.items, required this.savedAt});

  final List<NumberModel> items;
  final DateTime savedAt;

  bool get isFresh => DateTime.now().difference(savedAt) < _contactsCacheTtl;
}

final Map<String, _CachedContacts> _contactsCacheByUser =
    <String, _CachedContacts>{};
final Map<String, String?> _uidByPhoneCache = <String, String?>{};

Future<List<NumberModel>> fetchCurrentUserContactNumbers(
  AuthenticationBloc authenticationBloc,
  {
  int pageSize = _defaultContactPageSize,
  bool forceRefresh = false,
}
) async {
  final authenticationState = authenticationBloc.state;
  if (authenticationState is Authenticated) {
    final currentUserUid = authenticationState.user.uid;
    final cached = _contactsCacheByUser[currentUserUid];
    if (!forceRefresh && cached != null && cached.isFresh) {
      return List<NumberModel>.from(cached.items);
    }

    final db = FirebaseFirestore.instance;
    final contactsRef = db
        .collection('userDetails')
        .doc(currentUserUid)
        .collection('contacts');

    QueryDocumentSnapshot<Map<String, dynamic>>? lastDoc;
    final contacts = <NumberModel>[];
    final effectivePageSize = pageSize < 50 ? 50 : pageSize;

    while (true) {
      Query<Map<String, dynamic>> query = contactsRef.limit(effectivePageSize);
      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        break;
      }

      for (final doc in snapshot.docs) {
        final model = NumberModel.fromFirestoreMap(
          doc.data(),
          fallbackUid: currentUserUid,
        );
        contacts.add(model);

        final normalized = _normalizePhoneNumber(model.number);
        if (normalized.isNotEmpty && model.uidNumber != null) {
          _uidByPhoneCache[normalized] = model.uidNumber;
        }
      }

      if (snapshot.docs.length < effectivePageSize) {
        break;
      }
      lastDoc = snapshot.docs.last;
    }

    _contactsCacheByUser[currentUserUid] = _CachedContacts(
      items: List<NumberModel>.from(contacts),
      savedAt: DateTime.now(),
    );

    return contacts;
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

    invalidateContactsCacheForCurrentUser(authenticationBloc);

    final normalized = _normalizePhoneNumber(number);
    if (normalized.isNotEmpty) {
      _uidByPhoneCache[normalized] = linkedUserUid;
    }
  }
}

Future<String?> findUserUidByPhoneNumber({required String number}) async {
  final normalized = _normalizePhoneNumber(number);
  if (normalized.isNotEmpty && _uidByPhoneCache.containsKey(normalized)) {
    return _uidByPhoneCache[normalized];
  }

  final querySnapshot = await FirebaseFirestore.instance
      .collection('userDetails')
      .where('phoneNumber', isEqualTo: number)
      .limit(1)
      .get();
  if (querySnapshot.docs.isEmpty) {
    if (normalized.isNotEmpty) {
      _uidByPhoneCache[normalized] = null;
    }
    return null;
  }

  final firstUser = AccountModel.fromFirestoreMap(
    querySnapshot.docs.first.data(),
    fallbackUid: querySnapshot.docs.first.id,
  );
  if (normalized.isNotEmpty) {
    _uidByPhoneCache[normalized] = firstUser.uid;
  }
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

Future<List<NumberModel>> loadMergedContactsForCurrentUser({
  required AuthenticationBloc authenticationBloc,
  required List<NumberModel> baseContacts,
  List<NumberModel> extraContacts = const <NumberModel>[],
  int pageSize = _defaultContactPageSize,
  bool forceRefresh = false,
}) async {
  final cloudContacts = await fetchCurrentUserContactNumbers(
    authenticationBloc,
    pageSize: pageSize,
    forceRefresh: forceRefresh,
  );

  final mergedContacts = mergeContactsWithCloudNumbers(
    baseContacts,
    cloudContacts,
    extraContacts,
  );
  mergedContacts.sort((a, b) => a.name.compareTo(b.name));
  return mergedContacts;
}

String _normalizePhoneNumber(String value) {
  return value.replaceAll(RegExp(r'[^0-9+]'), '').trim();
}

void invalidateContactsCacheForCurrentUser(AuthenticationBloc authenticationBloc) {
  final uid = checkAuthenticationStatus(authenticationBloc);
  if (uid.isEmpty) {
    return;
  }
  _contactsCacheByUser.remove(uid);
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

    invalidateContactsCacheForCurrentUser(authenticationBloc);
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
  final rows = <Map<String, Object>>[];
  final db = FirebaseFirestore.instance;

  try {
    final categoriesRef = db
        .collection('userDetails')
        .doc(currentUserUid)
        .collection('categories');

    final categories = await categoriesRef.get().then(
      (snapshot) => snapshot.docs.map((doc) => doc.id).toList()..sort(),
    );

    final categoryContactsSnapshots = await Future.wait(
      categories.map(
        (category) => categoriesRef.doc(category).collection('contacts').get(),
      ),
    );

    final categorizedNumbers = <String>{};

    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];
      rows.add({'type': 'section', 'value': category});

      final contactsSnapshot = categoryContactsSnapshots[i];
      for (final doc in contactsSnapshot.docs) {
        final contactData = doc.data();
        final contactModel = NumberModel.fromFirestoreMap(
          contactData,
          fallbackUid: currentUserUid,
        );
        final normalized = _normalizePhoneNumber(contactModel.number);
        if (normalized.isNotEmpty) {
          categorizedNumbers.add(normalized);
        }
        rows.add({'type': 'contact', 'value': contactModel});
      }
    }

    rows.add({'type': 'section', 'value': 'Uncategorized'});

    final uncategorizedContacts = dummyContacts
        .where(
          (contact) =>
              !categorizedNumbers.contains(_normalizePhoneNumber(contact.number)),
        )
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

  final dbRef = rtdb.FirebaseDatabase.instance.ref();
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

    final account = AccountModel.fromFirestoreMap(
      userData,
      fallbackUid: doc.id,
    );

    participants.add(NumberModel.fromAccountModel(account));
  }

  participants.sort((a, b) => a.name.compareTo(b.name));
  print("Fetched chat participants: ${participants.length}");
  for (final participant in participants) {
    print("Participant: ${participant.name}, ${participant.number}, ${participant.uid}");
  }
  return participants;
}
