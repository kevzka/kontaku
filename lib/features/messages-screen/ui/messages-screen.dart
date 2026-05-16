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

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late final AuthenticationBloc _authenticationBloc;
  late final ContactRepository _contactRepository;
  late final Stream<List<NumberModel>> _contactsStream;
  Future<List<Map<String, Object>>>? _groupedRowsFuture;
  String _groupedRowsCacheKey = '';

  String sortBy = "list";

  @override
  void initState() {
    super.initState();
    _authenticationBloc = context.read<AuthenticationBloc>();
    _contactRepository = ContactRepository(
      authenticationBloc: _authenticationBloc,
      localContacts: List<NumberModel>.from(DummyData.contacts),
    );
    _contactsStream = _contactRepository.watchCombinedContacts(messageScreen: true);
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

    return SafeArea(
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

                              final contacts =
                                  snapshot.data ??
                                  List<NumberModel>.from(DummyData.contacts);
                              
                              

                              return ContactGroupedList(
                                contacts: contacts,
                                sectionColor: Color(Kontaku.colors[0]),
                                sortBy: 'NotSorted',
                                categoriesRows: const <Map<String, Object>>[],
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
                  SearchContactsPanel()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
