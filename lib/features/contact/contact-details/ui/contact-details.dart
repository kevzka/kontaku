import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:kontaku/core/models/number_model.dart';
import 'package:kontaku/core/utils/utils.dart';
import 'package:kontaku/core/utils/image_cache_service.dart';
import 'package:kontaku/core/widget/kontaku_text_field.dart';
import '../data/data-firestore.dart';
import '../logic/deleteContact.dart';
import '../../../home-screen/data/func.dart';

class ContactDetails extends StatefulWidget {
  const ContactDetails({super.key, required this.contact});

  final NumberModel contact;

  @override
  State<ContactDetails> createState() => _ContactDetailsState();
}

class _ContactDetailsState extends State<ContactDetails> {
  late Future<NumberModel?> _contactDetailsFuture;
  late final TextEditingController _emailController;
  late final TextEditingController _numberController;
  late final TextEditingController _notesController;
  bool _showDeleteDialog = false;
  Uint8List? _cachedAvatarBytes;

  @override
  void initState() {
    print(
      'Initializing ContactDetails for uid:${widget.contact.uid} number:${widget.contact.number} name:${widget.contact.name})',
    );
    super.initState();
    _contactDetailsFuture = getContactDetails(
      widget.contact.number,
      widget.contact.uid,
    );
    _emailController = TextEditingController();
    _numberController = TextEditingController();
    _notesController = TextEditingController();

    _contactDetailsFuture.then((contactDetails) {
      if (!mounted || contactDetails == null) {
        return;
      }

      _emailController.text = contactDetails.email ?? '';
      _numberController.text = contactDetails.number;
      _notesController.text = contactDetails.notes ?? '';

      // Cache profile image if available
      _cacheProfileImage(contactDetails.profilePath);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _numberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _openDeleteDialog() {
    setState(() {
      _showDeleteDialog = true;
    });
  }

  void _closeDeleteDialog() {
    setState(() {
      _showDeleteDialog = false;
    });
  }

  Future<void> _cacheProfileImage(String? profilePath) async {
    if (profilePath == null || profilePath.isEmpty) {
      return;
    }

    try {
      final cacheKey = '${widget.contact.uid}_${widget.contact.number}';
      debugPrint('[ContactDetails] Caching profile image: $profilePath');

      final bytes = await ImageCacheService.downloadAndCache(
        imageUrl: profilePath,
        cacheKey: cacheKey,
      );

      if (!mounted || bytes == null) {
        debugPrint(
          '[ContactDetails] Failed to download image or app unmounted',
        );
        return;
      }

      setState(() {
        _cachedAvatarBytes = bytes;
      });
      debugPrint('[ContactDetails] Profile image cached successfully');
    } catch (e) {
      debugPrint('[ContactDetails] Error caching profile image: $e');
      // Silently fail, UI remains functional without image
    }
  }

  ImageProvider<Object>? _resolveAvatarImage() {
    if (_cachedAvatarBytes != null) {
      return MemoryImage(_cachedAvatarBytes!);
    }
    return null;
  }

  Future<void> _deleteContact() async {
    try {
      await deleteContact(widget.contact.uid, widget.contact.number);
    } catch (_) {}

    if (!mounted) {
      return;
    }

    _closeDeleteDialog();
    context.pop(true); // Return true to refresh parent list
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
        final bottomActionWidth = isCompact ? 200.0 : 250.0;
        final avatarImage = _resolveAvatarImage();
        debugPrint(contactDetails.profilePath);

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
                    borderRadius: BorderRadius.vertical(
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
                    borderRadius: BorderRadius.vertical(
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
                        SizedBox(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: isCompact ? 54 : 64,
                                backgroundColor: const Color(0xFF8B6E3A),
                                backgroundImage: avatarImage,
                                child: avatarImage == null
                                    ? Text(
                                        contactDetails.name.isEmpty
                                            ? '?'
                                            : contactDetails.name[0]
                                                  .toUpperCase(),
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
                                  Text(
                                    contactDetails.name,
                                    style: GoogleFonts.montserrat(
                                      fontSize: isCompact ? 20 : 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(Kontaku.dark),
                                    ),
                                  ),
                                  Container(
                                    height: 4,
                                    width: Kontaku.vw(50, context),
                                    color: Color(Kontaku.lightBeige),
                                  ),
                                  Text(
                                    contactDetails.number,
                                    style: GoogleFonts.outfit(
                                      fontSize: isCompact ? 14 : 16,
                                      color: Color(Kontaku.dark),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Row(
                            spacing: 16,
                            children: [
                              Expanded(
                                child: _ActionCard(
                                  icon: Icons.phone,
                                  label: 'audio',
                                  onTap: () {},
                                ),
                              ),
                              Expanded(
                                child: _ActionCard(
                                  icon: Icons.message,
                                  label: 'pesan',
                                  onTap: () async {
                                    final String? targetUserUid =
                                        contactDetails.uidNumber ??
                                        await findUserUidByPhoneNumber(
                                          number: contactDetails.number,
                                        );
                                    if (targetUserUid != null) {
                                      context.push(
                                        '/chatScreen/$targetUserUid',
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Akun dengan nomor ini tidak ditemukan.",
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                              Expanded(
                                child: _ActionCard(
                                  icon: Icons.search,
                                  label: 'search',
                                  onTap: () {},
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          child: Center(
                            child: Container(
                              width: Kontaku.vw(90, context),
                              height: Kontaku.vh(50, context),
                              child: Column(
                                spacing: 4,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  KontakuTextField(
                                    controller: _emailController,
                                    label: 'Email',
                                    readOnly: true,
                                  ),
                                  KontakuTextField(
                                    controller: _numberController,
                                    label: 'Nomor Telepon',
                                    readOnly: true,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: notesWidth,
                                        height: notesHeight,
                                        child: KontakuTextField(
                                          controller: _notesController,
                                          label: 'Catatan Pribadi',
                                          expand: true,
                                          readOnly: true,
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: buttonColumnHeight,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              buttonContactDetails(
                                                text: 'Penyimpanan',
                                                onPressed: () {
                                                  print("Penyimpanan tapped");
                                                },
                                              ),
                                              buttonContactDetails(
                                                text: 'Notifikasi',
                                                onPressed: () {
                                                  print("Notifikasi tapped");
                                                },
                                              ),
                                              buttonContactDetails(
                                                text: 'Tambah Group',
                                                onPressed: () {
                                                  print("Tambah Group tapped");
                                                },
                                              ),
                                              buttonContactDetails(
                                                text: 'Hapus Nomor',
                                                destructive: true,
                                                onPressed: () {
                                                  _openDeleteDialog();
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: bottomActionWidth,
                                    height: 40,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _dangerActionItem(
                                          icon: Icons.block,
                                          label: 'Blokir',
                                          onTap: () {
                                            print('Blokir tapped');
                                          },
                                        ),
                                        _dangerActionItem(
                                          icon: Icons.report,
                                          label: 'Laporkan',
                                          onTap: () {
                                            print('Laporkan tapped');
                                          },
                                        ),
                                      ],
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
                ),
              ),
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
                          print('icon back button tapped');
                          if (context.canPop()) {
                            debugPrint('Popping back to previous screen');
                            context.pop();
                          } else {
                            debugPrint(
                              'No previous screen to pop back to, going to main navigation',
                            );
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
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () async {
                          final trigger = await context.push(
                            '/editContactScreen',
                            extra: contactDetails,
                          );
                          if (trigger == true) {
                            // Refresh details after edit
                            setState(() {
                              _contactDetailsFuture = getContactDetails(
                                widget.contact.number,
                                widget.contact.uid,
                              );
                            });
                          }
                          print('icon button tapped');
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(Icons.edit, color: Color(Kontaku.dark)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_showDeleteDialog)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _closeDeleteDialog,
                    child: Container(
                      width: Kontaku.vw(100, context),
                      height: Kontaku.vh(100, context),
                      color: Color(Kontaku.dark).withOpacity(0.5),
                      child: Center(
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 300,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
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
                                        'Hapus Kontak ini?',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.outfit(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF111111),
                                        ),
                                      ),
                                      SizedBox(height: 18),
                                      Text(
                                        'Yakin ingin menghapus kontak ini?',
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
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFD7D7D7),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: TextButton(
                                    onPressed: _deleteContact,
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                      ),
                                    ),
                                    child: Text(
                                      'Hapus',
                                      style: GoogleFonts.outfit(
                                        fontSize: 20,
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
                                    onPressed: _closeDeleteDialog,
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF111111),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                      ),
                                    ),
                                    child: Text(
                                      'Batalkan',
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

  SizedBox buttonContactDetails({
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
          backgroundColor: destructive
              ? const Color(0xFFCC6868)
              : const Color(0xFFEFB557),
          foregroundColor: destructive ? Colors.white : const Color(0xFF1C2026),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        ),
        child: Text(
          text,
          style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _dangerActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        splashColor: const Color(0x14CC6868),
        highlightColor: const Color(0x0FCC6868),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFCC6868), size: 17),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: const Color(0xFFCC6868),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: const Color(0x148B6E3A),
        highlightColor: const Color(0x148B6E3A),
        child: Container(
          height: 88,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Color(Kontaku.lightBeige), width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Color(Kontaku.dark), size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(Kontaku.dark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
