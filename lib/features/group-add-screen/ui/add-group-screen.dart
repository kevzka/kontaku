import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:kontaku/core/models/number_model.dart';
import 'package:kontaku/core/utils/utils.dart';
import 'package:kontaku/core/widget/search_contacts_panel.dart';
import 'package:kontaku/core/widget/kontaku_text_field.dart';
import 'package:kontaku/core/widget/contact_grouped_list.dart';
import '../../authentication/logic/bloc/authentication.dart';
import '../../../core/dummies/number-dummy.dart';
import '../../home-screen/data/func.dart';
import '../data/func.dart';

class AddGroupScreen extends StatefulWidget {
  const AddGroupScreen({super.key});

  @override
  State<AddGroupScreen> createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController(
    text: '...',
  );
  final TextEditingController _groupNoteController = TextEditingController(
    text: '...',
  );
  final TextEditingController _groupMembersListController =
      TextEditingController();

  final List<NumberModel> dummyContacts = List<NumberModel>.from(
    DummyData.contacts,
  );
  final List<NumberModel> _selectedMembers = <NumberModel>[];
  final Set<String> _selectedContactNumbers = <String>{};
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

  void _toggleContactSelection(NumberModel contact) {
    setState(() {
      if (_selectedContactNumbers.contains(contact.number)) {
        _selectedContactNumbers.remove(contact.number);
        _selectedMembers.removeWhere((item) => item.number == contact.number);
      } else {
        _selectedContactNumbers.add(contact.number);
        _selectedMembers.add(contact);
      }

      _groupMembersListController.text = _selectedMembers
          .map((member) => member.name)
          .join(', ');
    });
  }

  void _clearSelectedMembers() {
    setState(() {
      _selectedContactNumbers.clear();
      _selectedMembers.clear();
      _groupMembersListController.clear();
    });
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _groupNoteController.dispose();
    _groupMembersListController.dispose();
    super.dispose();
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
            top: 200,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 400,
                height: Kontaku.vh(60, context),
                child: Column(
                  spacing: 8,
                  children: [
                    SizedBox(
                      child: KontakuTextField(
                        controller: _groupNameController,
                        label: 'Nama Grup',
                        readOnly: false,
                      ),
                    ),
                    SizedBox(
                      child: KontakuTextField(
                        controller: _groupNoteController,
                        label: 'Catatan Group',
                        readOnly: false,
                      ),
                    ),
                    // SizedBox(
                    //   child: KontakuTextField(
                    //     controller: _groupMembersController,
                    //     label: 'Tambah Anggota',
                    //     readOnly: false,
                    //   ),
                    // ),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 256,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F0DD),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFE5D7A9),
                              width: 2,
                            ),
                          ),
                          child: isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ContactGroupedList(
                                  contacts: dummyContacts,
                                  sectionColor: Color(Kontaku.colors[0]),
                                  enableSelection: true,
                                  selectedContactNumbers:
                                      _selectedContactNumbers,
                                  onToggleContactSelection:
                                      _toggleContactSelection,
                                ),
                        ),
                        Positioned(
                          left: 12,
                          top: -10,
                          child: Container(
                            color: const Color(0xFFF5F0DD),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              'Daftar Anggota',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1C2026),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 100,
                          child: KontakuTextField(
                            controller: _groupMembersListController,
                            label: 'List Anggota',
                            readOnly: false,
                            expand: true,
                          ),
                        ),
                        Container(
                          width: 120,
                          height: 100,
                          // decoration: BoxDecoration(color: Colors.amber),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 8,
                            children: [
                              IconButton(
                                onPressed: () {
                                  showDialog<void>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (dialogContext) {
                                      return Dialog(
                                        backgroundColor: Colors.transparent,
                                        insetPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 20,
                                            ),
                                        child: Center(
                                          child: Container(
                                            width: 300,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 30,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        'Batalkan pilihan ini?',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            GoogleFonts.outfit(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  const Color(
                                                                    0xFF111111,
                                                                  ),
                                                            ),
                                                      ),
                                                      SizedBox(height: 18),
                                                      Text(
                                                        'Yakin ingin membatalkan pilihan?',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            GoogleFonts.outfit(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color:
                                                                  const Color(
                                                                    0xFF222222,
                                                                  ),
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Divider(
                                                  height: 1,
                                                  thickness: 1,
                                                  color: Color(0xFFD7D7D7),
                                                ),
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: TextButton(
                                                    onPressed: () {
                                                      _clearSelectedMembers();
                                                      Navigator.of(
                                                        dialogContext,
                                                      ).pop();
                                                      context.go(
                                                        '/mainNavigation/0',
                                                      );
                                                    },
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.red,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            vertical: 18,
                                                          ),
                                                      shape:
                                                          const RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .zero,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      'Batalkan',
                                                      style: GoogleFonts.outfit(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const Divider(
                                                  height: 1,
                                                  thickness: 1,
                                                  color: Color(0xFFD7D7D7),
                                                ),
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: TextButton(
                                                    onPressed: () {
                                                      Navigator.of(
                                                        dialogContext,
                                                      ).pop();
                                                    },
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          const Color(
                                                            0xFF111111,
                                                          ),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            vertical: 18,
                                                          ),
                                                      shape:
                                                          const RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .zero,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      'Tetap mengedit',
                                                      style: GoogleFonts.outfit(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: const Color(
                                                          0xFF111111,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                iconSize: 28,
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: CircleBorder(
                                    side: BorderSide(
                                      color: Color(Kontaku.cream),
                                      width: 4,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  fixedSize: const Size(56, 56),
                                ),
                                icon: Icon(
                                  Icons.close,
                                  color: Color(Kontaku.cream),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  // ScaffoldMessenger.of(context).showSnackBar(
                                  //   SnackBar(
                                  //     content: Text(
                                  //       'Anggota dipilih: ${_selectedMembers.length}',
                                  //     ),
                                  //   ),
                                  // );
                                  addToGroup(
                                    selectedMembers: _selectedMembers,
                                    groupName: _groupNameController.text,
                                    groupNote: _groupNoteController.text,
                                    authenticationBloc: context
                                        .read<AuthenticationBloc>(),
                                  );
                                },
                                iconSize: 28,
                                style: IconButton.styleFrom(
                                  backgroundColor: Color(Kontaku.accent),
                                  shape: CircleBorder(
                                    side: BorderSide(
                                      color: Color(Kontaku.cream),
                                      width: 4,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  fixedSize: const Size(56, 56),
                                ),
                                icon: Icon(
                                  Icons.check,
                                  color: Color(Kontaku.dark),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
