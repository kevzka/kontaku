import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kontaku/core/utils/auth-check.dart';
import 'package:kontaku/features/authentication/logic/bloc/authentication.dart';
import 'package:kontaku/core/models/number_model.dart';

Future<void> addToGroup({
  required List<NumberModel> selectedMembers,
  required String groupName,
  required String groupNote,
  required AuthenticationBloc authenticationBloc,
}) async {
  final currentUserUid = checkAuthenticationStatus(authenticationBloc);
  if (currentUserUid.isEmpty) {
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
  try {
    await batch.commit();
    print("Semua data grup dan kontak berhasil disimpan!");
    print(
      "Group '$groupName' successfully created with ${selectedMembers.length} members.",
    );
  } catch (e) {
    print("Gagal menyimpan data: $e");
    rethrow;
  }
}
