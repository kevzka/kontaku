import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kontaku/core/models/number_model.dart';
import 'package:kontaku/core/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kontaku/features/authentication/event-state/authentication-event-state.dart';
import 'package:kontaku/features/authentication/bloc/authentication.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key, required this.numberPhone});
  final String numberPhone;

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: 'Abgan osis ril or fake',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'iLopTelkomaGmail.com',
  );
  TextEditingController _phoneController = TextEditingController(text: '0');
  final TextEditingController _notesController = TextEditingController(
    text: '...',
  );

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _phoneController.text = widget.numberPhone.toString();
  }

  void _onFieldChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFieldChanged);
    _phoneController.removeListener(_onFieldChanged);
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 380;

    final headerTop = isCompact ? 30.0 : 50.0;
    final avatarRadius = isCompact ? 58.0 : 72.0;
    final headerSpacing = isCompact ? 14.0 : 20.0;
    final nameFontSize = isCompact ? 15.0 : 16.0;
    final phoneFontSize = isCompact ? 15.0 : 16.0;
    final lineWidth = isCompact ? 250.0 : 300.0;

    final panelBottom = isCompact ? 150.0 : 128.0;
    final panelWidth = isCompact
        ? Kontaku.vw(94, context)
        : Kontaku.vw(92, context);
    final panelInnerSpacing = isCompact ? 6.0 : 4.0;
    final panelButtonSpacing = isCompact ? 8.0 : 6.0;
    final panelButtonHeight = isCompact ? 34.0 : 36.0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: Kontaku.vw(100, context),
        height: Kontaku.vh(100, context),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(Kontaku.cream),
              Color(Kontaku.accent),
              Color(Kontaku.dark),
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: headerTop,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: Colors.white.withOpacity(0.5),
                  ),
                  SizedBox(height: headerSpacing),
                  SizedBox(
                    child: Column(
                      children: [
                        Center(
                          child: Container(
                            child: Column(
                              children: [
                                Text(
                                  _nameController.text,
                                  style: GoogleFonts.montserrat(
                                    fontSize: nameFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Color(Kontaku.dark),
                                  ),
                                ),
                                Container(
                                  height: 4,
                                  width: lineWidth,
                                  color: Color(Kontaku.lightBeige),
                                ),
                                Text(
                                  _phoneController.text,
                                  style: GoogleFonts.outfit(
                                    fontSize: phoneFontSize,
                                    color: Color(Kontaku.dark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: panelBottom,
              child: Center(
                child: Container(
                  width: panelWidth,
                  padding: EdgeInsets.all(isCompact ? 2 : 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _EditableFieldTile(
                                  label: 'Nama Kontak',
                                  controller: _nameController,
                                  backgroundColor: const Color(0xFFF8F2DF),
                                  isCompact: isCompact,
                                ),
                              ),
                              SizedBox(width: panelInnerSpacing),
                              Expanded(
                                child: _EditableFieldTile(
                                  label: 'Email',
                                  controller: _emailController,
                                  backgroundColor: const Color(0xFFF8F2DF),
                                  isCompact: isCompact,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: panelInnerSpacing),
                          _EditableFieldTile(
                            label: 'Nomor Telepon',
                            controller: _phoneController,
                            backgroundColor: const Color(0xFFF8F2DF),
                            isCompact: isCompact,
                          ),
                          SizedBox(height: panelInnerSpacing),
                          _EditableNotesTile(
                            label: 'Catatan Pribadi',
                            controller: _notesController,
                            backgroundColor: const Color(0xFFF8F2DF),
                            isCompact: isCompact,
                          ),
                        ],
                      ),
                      SizedBox(height: isCompact ? 10 : 12),
                      SizedBox(
                        width: double.infinity,
                        height: panelButtonHeight,
                        child: ElevatedButton(
                          onPressed: () async {
                            final success = await addContact(
                              name: _nameController.text,
                              email: _emailController.text,
                              phone: _phoneController.text,
                              notes: _notesController.text,
                              authenticationBloc: context
                                  .read<AuthenticationBloc>(),
                            );

                            if (!mounted) return;

                            if (success) {
                              await Kontaku.snackbarNotification(
                                context,
                                "Kontak berhasil ditambahkan",
                              );
                              Future.delayed(
                                const Duration(milliseconds: 500),
                                () {
                                  if (mounted) {
                                    context.go('/mainNavigation');
                                  }
                                },
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Gagal menambahkan kontak"),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF95BE67),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            "Simpan",
                            style: GoogleFonts.outfit(
                              fontSize: isCompact ? 12 : 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: panelButtonSpacing),
                      SizedBox(
                        width: double.infinity,
                        height: panelButtonHeight,
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog<void>(
                              context: context,
                              barrierDismissible: false,
                              builder: (dialogContext) {
                                return Dialog(
                                  backgroundColor: Colors.transparent,
                                  insetPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: isCompact ? 280 : 300,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: isCompact ? 18 : 20,
                                              vertical: isCompact ? 24 : 30,
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  'Batalkan pilihan ini?',
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.outfit(
                                                    fontSize: isCompact
                                                        ? 18
                                                        : 20,
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(
                                                      0xFF111111,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: isCompact ? 14 : 18,
                                                ),
                                                Text(
                                                  'Yakin ingin membatalkan pilihan?',
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.outfit(
                                                    fontSize: isCompact
                                                        ? 15
                                                        : 16,
                                                    fontWeight: FontWeight.w400,
                                                    color: const Color(
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
                                                Navigator.of(
                                                  dialogContext,
                                                ).pop();
                                                context.go('/mainNavigation');
                                              },
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.red,
                                                padding: EdgeInsets.symmetric(
                                                  vertical: isCompact ? 16 : 18,
                                                ),
                                                shape:
                                                    const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.zero,
                                                    ),
                                              ),
                                              child: Text(
                                                'Batalkan',
                                                style: GoogleFonts.outfit(
                                                  fontSize: isCompact ? 18 : 20,
                                                  fontWeight: FontWeight.w600,
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
                                                foregroundColor: const Color(
                                                  0xFF111111,
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  vertical: isCompact ? 16 : 18,
                                                ),
                                                shape:
                                                    const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.zero,
                                                    ),
                                              ),
                                              child: Text(
                                                'Tetap mengedit',
                                                style: GoogleFonts.outfit(
                                                  fontSize: isCompact ? 18 : 20,
                                                  fontWeight: FontWeight.w400,
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A474A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            "Batal",
                            style: GoogleFonts.outfit(
                              fontSize: isCompact ? 12 : 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditableFieldTile extends StatelessWidget {
  const _EditableFieldTile({
    required this.label,
    required this.controller,
    required this.backgroundColor,
    required this.isCompact,
  });

  final String label;
  final TextEditingController controller;
  final Color backgroundColor;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: isCompact ? 50 : 54,
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 12,
        vertical: isCompact ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE3D7B3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: isCompact ? 10 : 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1E1E1E),
            ),
          ),
          SizedBox(height: isCompact ? 1 : 2),
          TextField(
            controller: controller,
            style: GoogleFonts.outfit(
              fontSize: isCompact ? 13 : 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1E1E1E),
            ),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableNotesTile extends StatelessWidget {
  const _EditableNotesTile({
    required this.label,
    required this.controller,
    required this.backgroundColor,
    required this.isCompact,
  });

  final String label;
  final TextEditingController controller;
  final Color backgroundColor;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isCompact ? 126 : 140,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 12,
        vertical: isCompact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE3D7B3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: isCompact ? 10 : 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1E1E1E),
            ),
          ),
          SizedBox(height: isCompact ? 1 : 2),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: null,
              expands: true,
              keyboardType: TextInputType.multiline,
              style: GoogleFonts.outfit(
                fontSize: isCompact ? 13 : 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1E1E1E),
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool> addContact({
  required String name,
  required String email,
  required String phone,
  required String notes,
  required AuthenticationBloc authenticationBloc,
}) async {
  final NumberModel number = NumberModel(
    name: name,
    number: phone,
    profilePath: null,
    email: email,
    notes: notes,
  );

  final authenticationState = authenticationBloc.state;
  final currentUserUid = (authenticationState is Authenticated)
      ? authenticationState.user.uid
      : null;
  final db = FirebaseFirestore.instance;
  try {
    final contactExists = await checkIfContactExistsInFirestore(phone);
    if (!contactExists) {
      db.collection("numberDetails").doc().set({
        "name": number.name,
        "email": number.email,
        "number": number.number,
        "notes": number.notes,
        "uid": currentUserUid,
      });

      return true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}

Future<bool> checkIfContactExistsInFirestore(String phone) async {
  final db = FirebaseFirestore.instance;
  try {
    print(phone);
    final querySnapshot = await db
        .collection("numberDetails")
        .where("number", isEqualTo: phone)
        .get();
    print(querySnapshot.docs.isNotEmpty);
    return querySnapshot.docs.isNotEmpty;
  } catch (e) {
    return false;
  }
}
