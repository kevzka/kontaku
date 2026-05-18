import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kontaku/core/models/number_model.dart';
import 'package:kontaku/core/utils/utils.dart';
import '../../authentication/logic/bloc/authentication.dart';
import '../../../core/dummies/number-dummy.dart';
import '../../home-screen/data/func.dart';
import '../../home-screen/data/contact_repository.dart';
// import '../../contact-list-screen/ui/contact-list-screen.dart';
import 'package:kontaku/core/widget/search_contacts_panel.dart';
import 'package:kontaku/core/widget/contact_grouped_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AuthenticationBloc _authenticationBloc;
  late final ContactRepository _contactRepository;
  late Stream<List<NumberModel>> _contactsStream;
  Future<List<Map<String, Object>>>? _groupedRowsFuture;
  String _groupedRowsCacheKey = '';

  String sortBy = "list";
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _authenticationBloc = context.read<AuthenticationBloc>();
    _contactRepository = ContactRepository(
      authenticationBloc: _authenticationBloc,
      localContacts: List<NumberModel>.from(DummyData.contacts),
    );
    _contactsStream = _contactRepository.watchCombinedContacts();
  }

  void _refreshContactsList() {
    setState(() {
      _groupedRowsFuture = null;
      _groupedRowsCacheKey = '';
      _contactsStream = _contactRepository.watchCombinedContacts();
    });
  }

  Future<List<Map<String, Object>>> _resolveGroupedRows(
    List<NumberModel> contacts,
  ) {
    final nextKey = contacts
        .map((contact) => '${contact.uid}_${contact.number}_${contact.name}')
        .join('|');
        

    if (_groupedRowsFuture != null && _groupedRowsCacheKey == nextKey) {
      return _groupedRowsFuture!;
    }

    _groupedRowsCacheKey = nextKey;
    _groupedRowsFuture = getAllContactsByCategory(
      authenticationBloc: _authenticationBloc,
      dummyContacts: contacts,
    );

    return _groupedRowsFuture!;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 380;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // Refresh contacts list ketika return dari navigation
        if (didPop && result == true) {
          _refreshContactsList();
        }
      },
      child: SafeArea(
        child: Container(
          width: Kontaku.vw(100, context),
          height: Kontaku.vh(100, context),
          color: Color(Kontaku.colors[1]),
          child: Stack(
            children: [
              Container(
                width: Kontaku.vw(100, context) - 50,
                height: Kontaku.vh(100, context),
                decoration: BoxDecoration(
                  color: Color(Kontaku.colors[2]),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(Kontaku.vw(100, context) * 0.35),
                  ),
                ),
              ),
              Positioned(
                left: -50,
                right: 0,
                top: isCompact ? 114 : 128,
                //check if screen height below
                child: Center(
                  child: SizedBox(
                    width: Kontaku.vw(80, context),
                    height: Kontaku.vh(100, context) - 224,
                    // height: ,
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 32,
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
                                          ? Color(Kontaku.dark)
                                          : Color(Kontaku.accent),
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
                                              ? Color(Kontaku.cream)
                                              : Color(Kontaku.dark),
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
                                          ? Color(Kontaku.dark)
                                          : Color(Kontaku.accent),
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
                                              ? Color(Kontaku.cream)
                                              : Color(Kontaku.dark),
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
                              // color: Color(Kontaku.cream),
                            ),
                            child: StreamBuilder<List<NumberModel>>(
                              stream: _contactsStream,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.waiting &&
                                    !snapshot.hasData) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text(
                                      'Terjadi kesalahan saat memuat kontak.',
                                      style: TextStyle(
                                        color: Color(Kontaku.dark),
                                      ),
                                    ),
                                  );
                                }

                                dynamic contacts =
                                    snapshot.data ??
                                    List<NumberModel>.from(DummyData.contacts);

                                //hapus kontak yang name nya "nomor tidak dikenal"
                                contacts = contacts
                                    .where(
                                      (contact) =>
                                          contact.name != "nomor tidak dikenal",
                                    )
                                    .toList();

                                // apply search filter from SearchContactsPanel (on Enter)
                                if (_searchQuery.isNotEmpty) {
                                  final q = _searchQuery.toLowerCase();
                                  contacts = contacts.where((c) {
                                    final blob =
                                        '${c.name} ${c.number} ${c.email ?? ''}'
                                            .toLowerCase();
                                    return blob.contains(q);
                                  }).toList();
                                }

                                if (sortBy == 'group') {
                                  return FutureBuilder<
                                    List<Map<String, Object>>
                                  >(
                                    future: _resolveGroupedRows(contacts),
                                    builder: (context, groupedSnapshot) {
                                      if (groupedSnapshot.connectionState ==
                                              ConnectionState.waiting &&
                                          !groupedSnapshot.hasData) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      return ContactGroupedList(
                                        contacts: contacts,
                                        sectionColor: Color(Kontaku.colors[0]),
                                        sortBy: 'category',
                                        categoriesRows:
                                            groupedSnapshot.data ??
                                            <Map<String, Object>>[],
                                        onContactDetailsChanged:
                                            _refreshContactsList,
                                      );
                                    },
                                  );
                                }

                                return ContactGroupedList(
                                  contacts: contacts,
                                  sectionColor: Color(Kontaku.colors[0]),
                                  sortBy: 'alphabet',
                                  categoriesRows: const <Map<String, Object>>[],
                                  onContactDetailsChanged: _refreshContactsList,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              //make plus button for adding number of contact
              if (sortBy == 'group')
                Positioned(
                  bottom: Kontaku.vh(12, context),
                  right: 32,
                  child: FloatingActionButton(
                    elevation: 0,
                    backgroundColor: Color(Kontaku.colors[1]),
                    shape: const CircleBorder(
                      side: BorderSide(color: Colors.white, width: 4),
                    ),
                    onPressed: () async {
                      // addContactNumberForCurrentUser(
                      //   authenticationBloc: context.read<AuthenticationBloc>(),
                      //   name: "kevin2",
                      //   number: "622234567890",
                      // );
                      final trigger = await context.push('/addGroupScreen');
                      if (trigger == true) {
                        setState(() {
                          _groupedRowsFuture = null;
                          _groupedRowsCacheKey = '';
                          _contactsStream = _contactRepository
                              .watchCombinedContacts();
                        });
                      }
                    },
                    child: Icon(
                      Icons.add,
                      color: Color(Kontaku.dark),
                      size: 30,
                    ),
                  ),
                ),
              const SizedBox.shrink(),
              Positioned(
                left: 18,
                right: 18,
                top: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Kontaku",
                      style: GoogleFonts.outfit(
                        color: Color(Kontaku.colors[0]),
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SearchContactsPanel(
                      onSubmitted: (query) {
                        setState(() {
                          _searchQuery = query.trim();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
