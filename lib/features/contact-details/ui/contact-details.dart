import 'package:flutter/material.dart';
import 'package:kontaku/core/models/number_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kontaku/core/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ContactDetails extends StatefulWidget {
  const ContactDetails({super.key, required this.contact});

  final NumberModel contact;

  @override
  State<ContactDetails> createState() => _ContactDetailsState();
}

class _ContactDetailsState extends State<ContactDetails> {
  late final Future<NumberModel?> _contactDetailsFuture;

  @override
  void initState() {
    super.initState();
    _contactDetailsFuture = getContactDetails(
      widget.contact.number,
      widget.contact.uid,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<NumberModel?>(
      future: _contactDetailsFuture,
      builder: (context, snapshot) {
        final contactDetails = snapshot.data ?? widget.contact;

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
                top: 64,
                child: Container(
                  width: Kontaku.vw(100, context),
                  height: Kontaku.vh(100, context),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    spacing: 16,
                    children: [
                      SizedBox(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 64,
                              backgroundColor: const Color(0xFF8B6E3A),
                              child: Text(
                                contactDetails.name.isEmpty
                                    ? '?'
                                    : contactDetails.name[0].toUpperCase(),
                                style: GoogleFonts.montserrat(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Column(
                              children: [
                                Text(
                                  contactDetails.name,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 24,
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
                                    fontSize: 16,
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
                                icon: Icons.videocam,
                                label: 'video',
                                onTap: () {},
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
                                textFieldContactDetails(
                                  text: contactDetails.email ?? '-',
                                  label: 'Email',
                                ),
                                textFieldContactDetails(
                                  text: contactDetails.number ?? '-',
                                  label: 'Nomor Telepon',
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 250,
                                      height: 264,
                                      child: textFieldContactDetails(
                                        text: contactDetails.notes ?? '-',
                                        label: 'Catatan Pribadi',
                                        expand: true,
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 232,
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
                                                print("Hapus Kontak tapped");
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 250,
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
              Positioned(
                top: 64,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  width: Kontaku.vw(100, context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          print('icon button tapped');
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: SvgPicture.asset(
                            'assets/icons/iconBack.svg',
                            width: 22,
                            height: 22,
                            colorFilter: ColorFilter.mode(
                              Color(Kontaku.dark),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
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

  TextField textFieldContactDetails({
    required String text,
    required String label,
    bool expand = false,
  }) {
    return TextField(
      readOnly: true,
      controller: TextEditingController(text: text),
      expands: expand,
      minLines: expand ? null : 1,
      maxLines: expand ? null : 1,
      textAlignVertical: expand
          ? TextAlignVertical.top
          : TextAlignVertical.center,
      style: GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF1C2026),
      ),
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: expand,
        labelStyle: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1C2026),
        ),
        filled: true,
        fillColor: const Color(0xFFF5F0DD),
        contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5D7A9), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5D7A9), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5D7A9), width: 2),
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

Future<NumberModel?> getContactDetails(String number, String meUid) async {
  final db = FirebaseFirestore.instance;
  final numDetailsRef = db
      .collection('numberDetails')
      .where('number', isEqualTo: number)
      .where('uid', isEqualTo: meUid);

  final querySnapshot = await numDetailsRef.get();
  if (querySnapshot.docs.isEmpty) {
    return null;
  }

  final data = querySnapshot.docs.first.data();
  return NumberModel(
    name: data['name'] as String? ?? '',
    number: data['number'] as String? ?? number,
    profilePath: data['profilePath'] as String?,
    uid: data['uid'] as String? ?? meUid,
    uidNumber: data['uidNumber'] as String?,
    email: data['email'] as String?,
    notes: data['notes'] as String?,
  );
}
