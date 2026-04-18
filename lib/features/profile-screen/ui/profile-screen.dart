import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kontaku/core/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kontaku/features/authentication/bloc/authentication.dart';
import 'package:kontaku/features/authentication/event-state/authentication-event-state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: 'MiTest Subject',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'Kevin2Gather@Gmail.com',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: 'password123',
  );
  final TextEditingController _phoneController = TextEditingController(
    text: '+62 812-3456-7890',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 380;
    final avatarRadius = isCompact ? 36.0 : 50.0;
    final avatarInnerRadius = isCompact ? 34.0 : 48.0;
    final headerTop = isCompact ? 42.0 : 64.0;
    final sectionTop = isCompact ? 204.0 : 250.0;
    final actionTop = isCompact ? 364.0 : 450.0;
    final formWidth = isCompact ? Kontaku.vw(86, context) : Kontaku.vw(80, context);
    final actionWidth = isCompact ? Kontaku.vw(66, context) : Kontaku.vw(60, context);
    final buttonHeight = isCompact ? 36.0 : 42.0;
    final logoutHeight = isCompact ? 40.0 : 44.0;

    return Container(
      width: Kontaku.vw(100, context),
      height: Kontaku.vh(100, context),
      color: Color(Kontaku.colors[1]),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            child: Container(
              width: Kontaku.vw(100, context) - (isCompact ? 72 : 80),
              height: Kontaku.vh(100, context),
              decoration: BoxDecoration(
                color: Color(Kontaku.colors[2]),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Kontaku.vw(100, context) * 0.35),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            left: 0,
            top: headerTop,
            child: Column(
              children: [
                Center(
                  child: SizedBox(
                    child: CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: Color(Kontaku.sand),
                      child: CircleAvatar(
                        radius: avatarInnerRadius,
                        backgroundColor: Color(Kontaku.cream),
                        child: Icon(
                          Icons.person,
                          size: isCompact ? 42 : 50,
                          color: Color(Kontaku.dark),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isCompact ? 12 : 16),
                Center(
                  child: Container(
                    child: Column(
                      children: [
                        Text(
                          "MiTest Subject",
                          style: GoogleFonts.montserrat(
                            fontSize: isCompact ? 14 : 16,
                            fontWeight: FontWeight.bold,
                            color: Color(Kontaku.dark),
                          ),
                        ),
                        Container(
                          height: 4,
                          width: isCompact ? 220 : 300,
                          color: Color(Kontaku.lightBeige),
                        ),
                        Text(
                          "+62 812-3456-7890",
                          style: GoogleFonts.outfit(
                            fontSize: isCompact ? 13 : 16,
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
          Positioned(
            top: sectionTop,
            right: 0,
            left: 0,
            child: Center(
              child: SizedBox(
                width: formWidth,
                child: Column(
                  spacing: isCompact ? 10 : 16,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 150,
                          child: textFieldProfile(
                            labelText: 'Nama Pengguna',
                            controller: _nameController,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: textFieldProfile(
                            labelText: 'Email',
                            controller: _emailController,
                          ),
                        ),
                      ],
                    ),
                    textFieldProfile(
                      labelText: 'Password',
                      controller: _passwordController,
                    ),
                    textFieldProfile(
                      labelText: 'Nomor Telepon',
                      controller: _phoneController,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: actionTop,
            right: 0,
            left: isCompact ? 42 : 64,
            child: Center(
              child: SizedBox(
                width: actionWidth,
                child: Column(
                  spacing: isCompact ? 7 : 8,
                  children: [
                    SizedBox(
                      height: buttonHeight,
                      child: elevatedButtonProfile(
                        text: 'Tema',
                        icon: const Icon(Icons.palette),
                      ),
                    ),
                    SizedBox(
                      height: buttonHeight,
                      child: elevatedButtonProfile(
                        text: 'Bahasa',
                        icon: const Icon(Icons.language),
                      ),
                    ),
                    // SizedBox(
                    //   height: buttonHeight,
                    //   child: elevatedButtonProfile(
                    //     text: 'Notifikasi',
                    //     icon: const Icon(Icons.notifications),
                    //   ),
                    // ),
                    SizedBox(
                      height: buttonHeight,
                      child: elevatedButtonProfile(
                        text: 'Bantuan',
                        icon: const Icon(Icons.help),
                      ),
                    ),
                    SizedBox(
                      height: buttonHeight,
                      child: elevatedButtonProfile(
                        text: 'Tentang Kami',
                        icon: const Icon(Icons.info),
                      ),
                    ),
                    SizedBox(
                      width: Kontaku.vw(80, context),
                      height: logoutHeight,
                      child: elevatedButtonProfileLogout(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          //make an icon that can action when clicked to edit profile
          Positioned(
            top: 18,
            right: 18,
            child: GestureDetector(
              onTap: () {
                debugPrint('Edit profile tapped');
              },
              child: SizedBox(
                child: Icon(
                  Icons.edit,
                  size: isCompact ? 18 : 24,
                  color: Color(Kontaku.dark),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  ElevatedButton elevatedButtonProfileLogout() {
    return ElevatedButton(
      onPressed: () {
        context.read<AuthenticationBloc>().add(LoggedOut());
        debugPrint('Logout tapped');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE11B1B),
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        'Log Out',
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  ElevatedButton elevatedButtonProfile({
    required String text,
    required Widget icon,
  }) {
    return ElevatedButton(
      onPressed: () {
        debugPrint('$text tapped');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(Kontaku.accent),
        foregroundColor: Color(Kontaku.dark),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 14),
              child: icon,
            ),
          ),
          Text(
            text,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(Kontaku.dark),
            ),
          ),
        ],
      ),
    );
  }

  TextField textFieldProfile({
    double? width,
    required String labelText,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      showCursor: false,
      style: GoogleFonts.outfit(
        color: Color(Kontaku.dark),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.outfit(
          color: Color(Kontaku.dark),
          fontSize: 13,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        filled: true,
        fillColor: Color(Kontaku.sand),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Color(Kontaku.dark)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Color(Kontaku.dark)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Color(Kontaku.dark)),
        ),
      ),
    );
  }
}
