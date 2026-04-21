import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kontaku/core/utils/auth-check.dart';
import 'package:kontaku/features/authentication/logic/bloc/authentication.dart';
import 'package:kontaku/core/models/number_model.dart';
import '../../authentication/logic/event-state/authentication-event-state.dart';


void addToGroup({
  required List<NumberModel> selectedMembers,
  required String groupName,
  required String groupNote,
  required AuthenticationBloc authenticationBloc,
}) async {
  final currentUserUid = checkAuthenticationStatus(authenticationBloc);
  if (currentUserUid == null || currentUserUid.isEmpty) {
    print("User not authenticated. Cannot add to group.");
    return;
  }

  FirebaseFirestore db = FirebaseFirestore.instance;
  final batch = db.batch();

  // 1. Referensi ke dokumen kategori/grup
  var categoryRef = db
      .collection("userDetails")
      .doc(currentUserUid)
      .collection("categories")
      .doc(groupName);

  // Tambahkan operasi pembuatan grup ke batch
  batch.set(categoryRef, {"label": groupName, "note": groupNote});

  // 2. Tambahkan semua member ke sub-collection 'contacts' di dalam batch
  for (var member in selectedMembers) {
    var contactRef = categoryRef.collection("contacts").doc(member.number);
    batch.set(contactRef, {"name": member.name, "number": member.number});
  }

  // 3. Commit semua operasi sekaligus
  batch
      .commit()
      .then((_) {
        print("Semua data grup dan kontak berhasil disimpan!");
      })
      .catchError((e) {
        print("Gagal menyimpan data: $e");
      });
  print(
    "Group '$groupName' successfully created with ${selectedMembers.length} members.",
  );
}
