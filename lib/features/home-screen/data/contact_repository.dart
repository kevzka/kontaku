import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart' as rtdb;
import 'package:kontaku/core/models/number_model.dart';
import 'package:kontaku/features/authentication/logic/bloc/authentication.dart';
import 'package:kontaku/features/authentication/logic/event-state/authentication-event-state.dart';

import 'func.dart';

class ContactRepository {
  ContactRepository({
    required this.authenticationBloc,
    required this.localContacts,
    FirebaseFirestore? firestore,
    rtdb.FirebaseDatabase? database,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _database = database ?? rtdb.FirebaseDatabase.instance;

  final AuthenticationBloc authenticationBloc;
  final List<NumberModel> localContacts;
  final FirebaseFirestore _firestore;
  final rtdb.FirebaseDatabase _database;

  Stream<List<NumberModel>> watchCombinedContacts() async* {
    final authState = authenticationBloc.state;
    final baseContacts = List<NumberModel>.from(localContacts)
      ..sort((a, b) => a.name.compareTo(b.name));

    if (authState is! Authenticated) {
      yield baseContacts;
      return;
    }

    final currentUserUid = authState.user.uid;
    final chatParticipants = await fetchAllChatParticipants(
      authenticationBloc: authenticationBloc,
    );

    //debugprint profilepath nya pls
    final firestoreStream = _firestore
        .collection('userDetails')
        .doc(currentUserUid)
        .collection('contacts')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => NumberModel.fromFirestoreMap(
                  doc.data(),
                  fallbackUid: currentUserUid,
                ),
              )
              .toList(),
        );

    final rdbStream = watchRdbContacts(currentUserUid);

    yield* _combineLatest2<List<NumberModel>, List<NumberModel>, List<NumberModel>>(
      firestoreStream,
      rdbStream,
      (firestoreContacts, rdbContacts) {
        final mergedContacts = mergeContactsWithCloudNumbers(
          List<NumberModel>.from(localContacts),
          firestoreContacts,
          <NumberModel>[...chatParticipants, ...rdbContacts],
        )..sort((a, b) => a.name.compareTo(b.name));

        return mergedContacts;
      },
    );
  }

  // RDB stream sudah disiapkan agar mudah dipakai saat struktur datanya final.
  Stream<List<NumberModel>> watchRdbContacts(String currentUserUid) {
    return _database
        .ref()
        .child('users')
        .child(currentUserUid)
        .child('contacts')
        .onValue
        .map(
          (event) => _mapRdbSnapshotToContacts(
            event.snapshot.value,
            currentUserUid,
          ),
        );
  }

  List<NumberModel> _mapRdbSnapshotToContacts(
    dynamic value,
    String currentUserUid,
  ) {
    if (value is! Map) {
      return <NumberModel>[];
    }

    final contacts = <NumberModel>[];

    for (final entry in value.entries) {
      final payload = entry.value;
      if (payload is! Map) {
        continue;
      }

      final map = Map<String, dynamic>.from(payload);
      final number = (map['number'] ?? '').toString();
      if (number.isEmpty) {
        continue;
      }

      contacts.add(
        NumberModel.fromFirestoreMap(
          map,
          fallbackUid: currentUserUid,
        ),
      );
    }

    return contacts;
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
      if (!hasA || !hasB) {
        return;
      }
      controller.add(combine(latestA as A, latestB as B));
    }

    controller = StreamController<R>(
      onListen: () {
        subA = streamA.listen(
          (value) {
            latestA = value;
            hasA = true;
            emitIfReady();
          },
          onError: controller.addError,
        );

        subB = streamB.listen(
          (value) {
            latestB = value;
            hasB = true;
            emitIfReady();
          },
          onError: controller.addError,
        );
      },
      onCancel: () async {
        await subA?.cancel();
        await subB?.cancel();
      },
    );

    return controller.stream;
  }
}
