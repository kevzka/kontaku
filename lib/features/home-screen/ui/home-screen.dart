import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kontaku/core/models/number_model.dart';
import 'package:kontaku/core/utils/utils.dart';
import '../../authentication/bloc/authentication.dart';
import '../../home-screen/data/dummy.dart';
import '../../home-screen/data/func.dart';
// import '../../contact-list-screen/ui/contact-list-screen.dart';
import 'package:kontaku/core/widget/search_contacts_panel.dart';
import '../../authentication/event-state/authentication-event-state.dart';
import 'package:kontaku/core/widget/contact_grouped_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<NumberModel> dummyContacts = List<NumberModel>.from(
    DummyData.contacts,
  );
  final List<Map<String, Object>> dummyCategoriesRows = [];
  String sortBy = "list";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllNumberInAccount();
    print(dummyCategoriesRows);
  }

  Future<void> _loadAllNumberInAccount() async {
    final accountNumbers = await fetchCurrentUserContactNumbers(
      context.read<AuthenticationBloc>(),
    );
    final groupedRows = await getAllContactsByCategory(
      authenticationBloc: context.read<AuthenticationBloc>(),
      dummyContacts: DummyData.contacts,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      final mergedContacts = mergeContactsWithCloudNumbers(
        dummyContacts,
        accountNumbers,
      )..sort((a, b) => a.name.compareTo(b.name));

      dummyContacts
        ..clear()
        ..addAll(mergedContacts);
      dummyCategoriesRows
        ..clear()
        ..addAll(groupedRows);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Kontaku.vw(100, context),
      height: Kontaku.vh(100, context),
      color: Color(Kontaku.colors[1]),
      child: Stack(
        children: [
          Container(
            width: Kontaku.vw(100, context) - 80,
            height: Kontaku.vh(100, context),
            decoration: BoxDecoration(
              color: Color(Kontaku.colors[2]),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(Kontaku.vw(100, context) * 0.35),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 128,
            child: Center(
              child: SizedBox(
                width: Kontaku.vw(80, context),
                height: Kontaku.vh(70, context),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 44,
                      child: Row(
                        spacing: 4,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  sortBy = "list";
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: (sortBy == "list")
                                      ? const Color(Kontaku.dark)
                                      : const Color(Kontaku.accent),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  border: Border.all(
                                    color: Color(Kontaku.colors[2]),
                                    width: 1.2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "List",
                                    style: TextStyle(
                                      color: (sortBy == "list")
                                          ? const Color(Kontaku.cream)
                                          : const Color(Kontaku.dark),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  sortBy = "group";
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: (sortBy == "group")
                                      ? const Color(Kontaku.dark)
                                      : const Color(Kontaku.accent),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  border: Border.all(
                                    color: Color(Kontaku.colors[2]),
                                    width: 1.2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Group",
                                    style: TextStyle(
                                      color: (sortBy == "group")
                                          ? const Color(Kontaku.cream)
                                          : const Color(Kontaku.dark),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ContactGroupedList(
                                contacts: dummyContacts,
                                sectionColor: Color(Kontaku.colors[0]),
                                sortBy: sortBy == "list"
                                    ? "alphabet"
                                    : "category",
                                categoriesRows: dummyCategoriesRows,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          //make plus button for adding number of contact
          Positioned(
            bottom: Kontaku.vh(12, context),
            right: 50,
            child: FloatingActionButton(
              elevation: 0,
              backgroundColor: Color(Kontaku.colors[1]),
              shape: const CircleBorder(
                side: BorderSide(color: Colors.white, width: 4),
              ),
              onPressed: () {
                // addContactNumberForCurrentUser(
                //   authenticationBloc: context.read<AuthenticationBloc>(),
                //   name: "kevin2",
                //   number: "622234567890",
                // );
                context.go('/addGroupScreen');
              },
              child: const Icon(
                Icons.add,
                color: Color(Kontaku.dark),
                size: 30,
              ),
            ),
          ),
          Positioned(
            child: ElevatedButton(
              onPressed: () async {
                // print("delete all data firestore in document numberDetails");
                // deleteAllDataInNumberDetails(
                //   context.read<AuthenticationBloc>(),
                // );
                final groupedRows = await getAllContactsByCategory(
                  authenticationBloc: context.read<AuthenticationBloc>(),
                  dummyContacts: DummyData.contacts,
                );
                debugPrint('Grouped rows: ${groupedRows.length}');
              },
              child: Text(
                "delete all data firestore in document numberDetails",
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            top: 40,
            child: const SearchContactsPanel(),
          ),
        ],
      ),
    );
  }
}

Future<List<Map<String, Object>>> getAllContactsByCategory({
  required AuthenticationBloc authenticationBloc,
  required List<NumberModel> dummyContacts,
}) async {
  final authenticationState = authenticationBloc.state;
  final currentUserUid = (authenticationState is Authenticated)
      ? authenticationState.user.uid
      : null;
  if (currentUserUid == null || currentUserUid.isEmpty) {
    debugPrint("User not authenticated. Cannot load grouped contacts.");
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
          return  (row['value'] as NumberModel).number;
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
    debugPrint("Error fetching contacts: $e");
    return <Map<String, Object>>[];
  }

  // debugPrint("Loaded grouped rows: ${rows.length}");
  return rows;
}
