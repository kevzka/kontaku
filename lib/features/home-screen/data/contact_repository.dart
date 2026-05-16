import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart' as rtdb;
import 'package:kontaku/core/models/account_model.dart';
import 'package:kontaku/core/models/number_model.dart';
import 'package:kontaku/features/authentication/logic/bloc/authentication.dart';
import 'package:kontaku/features/authentication/logic/event-state/authentication-event-state.dart';
import 'func.dart'; // Pastikan mergeContactsWithCloudNumbers ada di sini

class ContactRepository {
  ContactRepository({
    required this.authenticationBloc,
    this.localContacts = const [],
    FirebaseFirestore? firestore,
    rtdb.FirebaseDatabase? database,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _database = database ?? rtdb.FirebaseDatabase.instance;

  final AuthenticationBloc authenticationBloc;
  final List<NumberModel> localContacts;
  final FirebaseFirestore _firestore;
  final rtdb.FirebaseDatabase _database;

  Stream<List<NumberModel>> watchCombinedContacts({bool messageScreen = false}) async* {
    final authState = authenticationBloc.state;
    final baseContacts = List<NumberModel>.from(localContacts)
      ..sort((a, b) => a.name.compareTo(b.name));

    if (authState is! Authenticated) {
      yield baseContacts;
      return;
    }

    final currentUserUid = authState.user.uid;

    // 1. Stream dari Firestore (Kontak yang disimpan manual)
    final firestoreStream = _firestore
        .collection('userDetails')
        .doc(currentUserUid)
        .collection('contacts')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NumberModel.fromFirestoreMap(
                  doc.data(),
                  fallbackUid: doc.id,
                ))
            .toList());

    // 2. Stream dari RDB (Riwayat Chat / Orang yang nge-chat kamu)
    final rdbStream = watchRdbContacts(currentUserUid);

    if (messageScreen) {
      yield* rdbStream.map((rdbContacts) => List<NumberModel>.from(rdbContacts)
        ..sort((a, b) => a.name.compareTo(b.name)));
      return;
    }

    // 3. Gabungkan keduanya
    yield* _combineLatest2<List<NumberModel>, List<NumberModel>, List<NumberModel>>(
      firestoreStream,
      rdbStream,
      (firestoreContacts, rdbContacts) {
        final mergedContacts = mergeContactsWithCloudNumbers(
          List<NumberModel>.from(localContacts),
          firestoreContacts,
          rdbContacts,
        )..sort((a, b) => a.name.compareTo(b.name));

        return mergedContacts;
      },
    );
  }

  Stream<List<NumberModel>> watchRdbContacts(String currentUserUid) {
    return _database
        .ref()
        .child('userChats')
        .child(currentUserUid)
        .onValue
        .asyncMap((event) async {
      final value = event.snapshot.value;
      if (value == null || value is! Map) return <NumberModel>[];

      final chatIds = value.keys.map((e) => e.toString()).toSet();
      return await _loadChatParticipants(chatIds, currentUserUid);
    });
  }

  Future<List<NumberModel>> _loadChatParticipants(Set<String> chatIds, String currentUserUid) async {
    final otherMemberIds = <String>{};

    // Ambil metadata setiap chat untuk mencari siapa lawannya (member lain)
    final chatSnapshots = await Future.wait(
      chatIds.map((id) => _database.ref().child('chats').child(id).get()),
    );

    for (final snap in chatSnapshots) {
      if (snap.exists && snap.value is Map) {
        final data = Map<dynamic, dynamic>.from(snap.value as Map);
        final members = data['members'];
        if (members is Map) {
          members.forEach((uid, active) {
            if (uid.toString() != currentUserUid) {
              otherMemberIds.add(uid.toString());
            }
          });
        }
      }
    }

    if (otherMemberIds.isEmpty) return [];

    // Ambil detail profile (Username/Foto) dari Firestore userDetails
    final userDocs = await Future.wait(
      otherMemberIds.map((uid) => _firestore.collection('userDetails').doc(uid).get()),
    );

    final participants = <NumberModel>[];
    for (int i = 0; i < userDocs.length; i++) {
      final doc = userDocs[i];
      if (doc.exists && doc.data() != null) {
        
/* {phoneNumber: 6287828495141, profilePath: , uid: 5g1GNGB3IVf9FKyt1HYKAFtonTn1, email: giffary009@gmail.com, username: faizh}
{imageProfile: , phoneNumber: 6282234567890, profilePath: https://i.ibb.co/Lw5KXcK/upload.jpg, uid: KS9kujM11lMklQKAIvfZFfqLTmS2, username: kevin2, email: kevinapta100@gmail.com}
 */        

        //sebelum di firestoremap cek dulu apakah nomor sudah ada di firestoreContact atau belum jika belum name nya "nomor tidak diketahui"
        // final firestoreContact = await _firestore
        //     .collection('userDetails')
        //     .doc(currentUserUid)
        //     .collection('contacts')
        //     .doc(number)
        //begini struktur nya
        final dataContact = await checkIfContactSaved(currentUserUid, doc.data()!['phoneNumber'], _firestore);
        final dataFormated = {
          'number': (dataContact != null) ? dataContact.number : doc.data()!['phoneNumber'] ?? '',
          'name': (dataContact != null) ? dataContact.name : "nomor tidak dikenal" ?? '',
          'profilePath': (dataContact != null) ? dataContact.profilePath : doc.data()!['profilePath'] ?? '',
          'uidNumber': (dataContact != null) ? chatIds.elementAt(i) : '',
          'uid': currentUserUid, // Gunakan UID pengguna saat ini sebagai fallback
        };
                final account = NumberModel.fromFirestoreMap(
          dataFormated,
          fallbackUid: currentUserUid,
        );
        participants.add(account);
      }
    }

    return participants;
  }

  Stream<R> _combineLatest2<A, B, R>(
    Stream<A> streamA,
    Stream<B> streamB,
    R Function(A a, B b) combine,
  ) {
    late StreamController<R> controller;
    StreamSubscription<A>? subA;
    StreamSubscription<B>? subB;

    A? latestA;
    B? latestB;
    var hasA = false;
    var hasB = false;

    void emitIfReady() {
      if (hasA && hasB) {
        controller.add(combine(latestA as A, latestB as B));
      }
    }

    controller = StreamController<R>(
      onListen: () {
        subA = streamA.listen((val) {
          latestA = val;
          hasA = true;
          emitIfReady();
        }, onError: controller.addError);
        subB = streamB.listen((val) {
          latestB = val;
          hasB = true;
          emitIfReady();
        }, onError: controller.addError);
      },
      onCancel: () {
        subA?.cancel();
        subB?.cancel();
      },
    );

    return controller.stream;
  }
}

Future<NumberModel?> checkIfContactSaved(String currentUserUid, String number, FirebaseFirestore firestore) async {
  final doc = await firestore
      .collection('userDetails')
      .doc(currentUserUid)
      .collection('contacts')
      .doc(number)
      .get();

  if (doc.exists) {
    return NumberModel.fromFirestoreMap(doc.data()!, fallbackUid: currentUserUid);
  } else {
    return null;
  }
}