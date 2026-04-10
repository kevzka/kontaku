import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kontaku/core/models/number_model.dart';
import 'package:kontaku/core/utils/utils.dart';
import 'package:kontaku/features/authentication/bloc/authentication.dart';
import 'package:kontaku/features/home-screen/data/dummy.dart';
import 'package:kontaku/features/home-screen/data/func.dart';
import '../../contact-list-screen/ui/contact-list-screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<NumberModel> dummyContacts = List<NumberModel>.from(
    DummyData.contacts,
  );
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllNumberInAccount();
  }

  Future<void> _loadAllNumberInAccount() async {
    final accountNumbers = await fetchCurrentUserContactNumbers(
      context.read<AuthenticationBloc>(),
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
            left: 12,
            right: 12,
            top: 40,
            child: const SearchContactsPanel(),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 128,
            child: Center(
              child: Container(
                width: Kontaku.vw(80, context),
                height: Kontaku.vh(70, context),
                padding: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ContactGroupedList(
                        contacts: dummyContacts,
                        sectionColor: Color(Kontaku.colors[0]),
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
                context.go('/chatScreen');
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
              onPressed: () {
                print("delete all data firestore in document numberDetails");
                deleteAllDataInNumberDetails(
                  context.read<AuthenticationBloc>(),
                );
              },
              child: Text(
                "delete all data firestore in document numberDetails",
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ContactGroupedList extends StatelessWidget {
  const ContactGroupedList({
    required this.contacts,
    required this.sectionColor,
    super.key,
  });

  final List<NumberModel> contacts;
  final Color sectionColor;

  List<Map<String, Object>> _buildGroupedRows() {
    final sortedContacts = [...contacts]
      ..sort((a, b) => a.name.compareTo(b.name));

    final rows = <Map<String, Object>>[];
    String? currentSection;

    for (final contact in sortedContacts) {
      final name = contact.name;
      final section = name.isEmpty ? '#' : name[0].toUpperCase();

      if (section != currentSection) {
        rows.add({'type': 'section', 'value': section});
        currentSection = section;
      }

      rows.add({'type': 'contact', 'value': contact});
    }

    return rows;
  }

  Widget _buildAvatar(BuildContext context, NumberModel contact) {
    final profilePath = contact.profilePath;
    final name = contact.name;
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();

    if (profilePath != null && profilePath.isNotEmpty) {
      ImageProvider imageProvider = AssetImage(profilePath);
      if (profilePath.startsWith('http')) {
        imageProvider = NetworkImage(profilePath);
      }

      return Material(
        color: Colors.transparent,
        child: InkResponse(
          onTap: () => context.go('/contactDetailsScreen', extra: contact),
          containedInkWell: true,
          highlightShape: BoxShape.circle,
          radius: 24,
          splashColor: const Color(0x1A8B6E3A),
          highlightColor: const Color(0x148B6E3A),
          child: CircleAvatar(radius: 22, backgroundImage: imageProvider),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: () => context.go('/contactDetailsScreen', extra: contact),
        containedInkWell: true,
        highlightShape: BoxShape.circle,
        radius: 24,
        splashColor: const Color(0x1A8B6E3A),
        highlightColor: const Color(0x148B6E3A),
        child: CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFF8B6E3A),
          child: Text(
            initial,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupedRows = _buildGroupedRows();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemBuilder: (context, index) {
        final row = groupedRows[index];

        if (row['type'] == 'section') {
          final section = row['value'] as String;

          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 6),
            child: Row(
              children: [
                Text(
                  section,
                  style: TextStyle(
                    color: sectionColor,
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Container(height: 2, color: sectionColor)),
              ],
            ),
          );
        }

        final contact = row['value'] as NumberModel;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              _buildAvatar(context, contact),
              const SizedBox(width: 12),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    splashColor: const Color(0x1A8B6E3A),
                    highlightColor: const Color(0x148B6E3A),
                    onTap: () async {
                      final String? targetUserUid =
                          await findUserUidByPhoneNumber(
                            number: contact.number,
                          );
                      if (targetUserUid != null) {
                        context.go('/chatScreen/$targetUserUid');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Akun dengan nomor ini tidak ditemukan.",
                            ),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      child: Text(
                        contact.name,
                        style: const TextStyle(
                          color: Color(0xFF1C2026),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.05,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      itemCount: groupedRows.length,
    );
  }
}
