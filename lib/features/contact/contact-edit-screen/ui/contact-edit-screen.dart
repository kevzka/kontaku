import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:kontaku/core/models/number_model.dart';
import 'package:kontaku/core/utils/utils.dart';
import 'package:kontaku/core/utils/image_cache_service.dart';
import 'package:kontaku/core/widget/kontaku_text_field.dart';
import 'package:kontaku/core/services/contact_firestore_service.dart';
import '../logic/deleteContact.dart';

class EditContactScreen extends StatefulWidget {
  const EditContactScreen({super.key, required this.contact});

  final NumberModel contact;

  @override
  State<EditContactScreen> createState() => _EditContactScreenState();
}

class _EditContactScreenState extends State<EditContactScreen> {
  late final Future<NumberModel?> _contactDetailsFuture;
  late final TextEditingController _emailController;
  late final TextEditingController _numberController;
  late final TextEditingController _notesController;
  late final TextEditingController _nameController;
  bool _showCancelDialog = false;
  Uint8List? _cachedAvatarBytes;

  @override
  void initState() {
    super.initState();
    _contactDetailsFuture = ContactFirestoreService.getContactDetails(
      widget.contact.number,
      widget.contact.uid,
    );
    _emailController = TextEditingController();
    _numberController = TextEditingController();
    _notesController = TextEditingController();
    _nameController = TextEditingController();

    _contactDetailsFuture.then((contactDetails) {
      if (!mounted || contactDetails == null) return;
      _emailController.text = contactDetails.email ?? '';
      _numberController.text = contactDetails.number;
      _notesController.text = contactDetails.notes ?? '';
      _nameController.text = contactDetails.name;
      _cacheProfileImage(contactDetails.profilePath);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _numberController.dispose();
    _notesController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _openCancelDialog() => setState(() => _showCancelDialog = true);
  void _closeCancelDialog() => setState(() => _showCancelDialog = false);

  Future<void> _cacheProfileImage(String? profilePath) async {
    if (profilePath == null || profilePath.isEmpty) return;
    try {
      final cacheKey = '${widget.contact.uid}_${widget.contact.number}';
      final bytes = await ImageCacheService.downloadAndCache(
        imageUrl: profilePath,
        cacheKey: cacheKey,
      );
      if (!mounted || bytes == null) return;
      setState(() => _cachedAvatarBytes = bytes);
    } catch (e) {
      debugPrint('[EditContactScreen] Error caching profile image: $e');
    }
  }

  ImageProvider<Object>? _resolveAvatarImage() {
    if (_cachedAvatarBytes != null) return MemoryImage(_cachedAvatarBytes!);
    return null;
  }

  Future<void> _handleDeleteContact() async {
    try {
      await deleteContact(widget.contact.uid, widget.contact.number);
    } catch (_) {}
    if (!mounted) return;
    _closeCancelDialog();
    context.pop(true);
  }

  Future<void> _handleSave(NumberModel contactDetails) async {
    final result = await ContactFirestoreService.updateContact(
      uid: contactDetails.uid,
      number: _numberController.text,
      numberOri: contactDetails.number,
      name: _nameController.text,
      email: _emailController.text,
      notes: _notesController.text,
    );

    if (!mounted) return;

    if (result == 'true') {
      await Kontaku.snackbarNotification(context, 'Perubahan berhasil disimpan');
      context.pop(true);
    } else if (result == 'number_changed') {
      await Kontaku.snackbarNotification(
        context,
        'Nomor berhasil diubah. Perubahan lainnya juga disimpan.',
      );
      context.go('/mainNavigation/0');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyimpan perubahan. Silakan coba lagi.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<NumberModel?>(
      future: _contactDetailsFuture,
      builder: (context, snapshot) {
        final contactDetails = snapshot.data ?? widget.contact;
        final screenWidth = MediaQuery.sizeOf(context).width;
        final isCompact = screenWidth < 380;
        final topSection =
            MediaQuery.paddingOf(context).top + (isCompact ? 24.0 : 40.0);
        final notesWidth = isCompact ? 200.0 : 250.0;
        final notesHeight = isCompact ? 220.0 : 264.0;
        final buttonColumnHeight = isCompact ? 196.0 : 232.0;
        final avatarImage = _resolveAvatarImage();

        return Scaffold(
          body: Stack(
            children: [
              Container(
                width: Kontaku.vw(100, context),
                height: Kontaku.vh(100, context),
                color: Color(Kontaku.dark),
              ),
              Positioned(
                bottom: -24,
                child: Container(
                  width: Kontaku.vw(100, context),
                  height: Kontaku.vh(100, context),
                  decoration: BoxDecoration(
                    color: Color(Kontaku.accent),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(64),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -44,
                child: Container(
                  width: Kontaku.vw(100, context),
                  height: Kontaku.vh(100, context),
                  decoration: BoxDecoration(
                    color: Color(Kontaku.cream),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(64),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: topSection,
                child: Container(
                  width: Kontaku.vw(100, context),
                  height: Kontaku.vh(100, context),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: isCompact ? 140 : 110),
                    child: Column(
                      spacing: 16,
                      children: [
                        Column(
                          children: [
                            CircleAvatar(
                              radius: isCompact ? 54 : 64,
                              backgroundColor: const Color(0xFF8B6E3A),
                              backgroundImage: avatarImage,
                              child: avatarImage == null
                                  ? Text(
                                      contactDetails.name.isEmpty
                                          ? '?'
                                          : contactDetails.name[0].toUpperCase(),
                                      style: GoogleFonts.montserrat(
                                        fontSize: isCompact ? 28 : 34,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            Column(
                              children: [
                                ValueListenableBuilder<TextEditingValue>(
                                  valueListenable: _nameController,
                                  builder: (context, value, child) => Text(
                                    value.text.isEmpty ? 'No Name' : value.text,
                                    style: GoogleFonts.montserrat(
                                      fontSize: isCompact ? 20 : 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(Kontaku.dark),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 4,
                                  width: Kontaku.vw(50, context),
                                  color: Color(Kontaku.lightBeige),
                                ),
                                ValueListenableBuilder<TextEditingValue>(
                                  valueListenable: _numberController,
                                  builder: (context, value, child) => Text(
                                    value.text.isEmpty ? 'No Number' : value.text,
                                    style: GoogleFonts.outfit(
                                      fontSize: isCompact ? 14 : 16,
                                      color: Color(Kontaku.dark),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Center(
                          child: SizedBox(
                            width: Kontaku.vw(90, context),
                            height: Kontaku.vh(50, context),
                            child: Column(
                              spacing: 4,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                KontakuTextField(
                                  controller: _nameController,
                                  label: 'Nama',
                                  readOnly: false,
                                ),
                                KontakuTextField(
                                  controller: _emailController,
                                  label: 'Email',
                                  readOnly: false,
                                  type: TextInputType.emailAddress,
                                ),
                                KontakuTextField(
                                  controller: _numberController,
                                  label: 'Nomor Telepon',
                                  readOnly: false,
                                  type: TextInputType.phone,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: notesWidth,
                                      height: notesHeight,
                                      child: KontakuTextField(
                                        controller: _notesController,
                                        label: 'Catatan Pribadi',
                                        expand: true,
                                        readOnly: false,
                                      ),
                                    ),
                                    Expanded(
                                      child: SizedBox(
                                        height: buttonColumnHeight,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          spacing: 16,
                                          children: [
                                            _actionButton(
                                              text: 'Simpan',
                                              onPressed: () =>
                                                  _handleSave(contactDetails),
                                            ),
                                            _actionButton(
                                              text: 'Batalkan',
                                              destructive: true,
                                              onPressed: _openCancelDialog,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Back button
              Positioned(
                top: topSection,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  width: Kontaku.vw(100, context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          if (context.canPop()) {
                            context.pop(true);
                          } else {
                            context.go('/mainNavigation/0');
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: SvgPicture.asset(
                            'assets/icons/iconBack.svg',
                            width: isCompact ? 20 : 22,
                            height: isCompact ? 20 : 22,
                            colorFilter: ColorFilter.mode(
                              Color(Kontaku.dark),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Cancel confirmation dialog
              if (_showCancelDialog)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _closeCancelDialog,
                    child: Container(
                      color: Color(Kontaku.dark).withOpacity(0.5),
                      child: Center(
                        child: GestureDetector(
                          onTap: () {},
                          child: _buildConfirmDialog(
                            isCompact: isCompact,
                            title: 'Batalkan perubahan kontak?',
                            body:
                                'Perubahan yang sudah dilakukan akan hilang dan tidak bisa dikembalikan.',
                            confirmLabel: 'Batalkan Perubahan',
                            cancelLabel: 'Lanjutkan Edit',
                            onConfirm: () {
                              _closeCancelDialog();
                              context.pop();
                            },
                            onCancel: _closeCancelDialog,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Positioned.fill(
                  child: IgnorePointer(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  SizedBox _actionButton({
    required String text,
    required VoidCallback onPressed,
    bool destructive = false,
  }) {
    return SizedBox(
      width: 110,
      height: 30,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              destructive ? const Color(0xFFCC6868) : const Color(0xFFEFB557),
          foregroundColor:
              destructive ? Colors.white : const Color(0xFF1C2026),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        child: Text(
          text,
          style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildConfirmDialog({
    required bool isCompact,
    required String title,
    required String body,
    required String confirmLabel,
    required String cancelLabel,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
  }) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF222222),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFD7D7D7)),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onConfirm,
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: Text(
                confirmLabel,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFD7D7D7)),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF111111),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: Text(
                cancelLabel,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF111111),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
