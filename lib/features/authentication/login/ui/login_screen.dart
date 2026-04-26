import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kontaku/core/router/app_router.dart';
import 'package:kontaku/core/utils/utils.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kontaku/features/authentication/logic/bloc/authentication.dart';
import 'package:kontaku/features/authentication/logic/event-state/authentication-event-state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  int _snackBarDurationSeconds = 3;
  bool _isHandlingLoginSuccess = false;
  bool rememberMe = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 380;

    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) async {
        if (state is Authenticated && !_isHandlingLoginSuccess) {
          _isHandlingLoginSuccess = true;
          await Future.delayed(const Duration(milliseconds: 500));
          await Kontaku.snackbarNotification(context, "Login Successful", snackBarDurationSeconds: _snackBarDurationSeconds);

          if (!mounted) return;
          context.go(AppRouter.mainNavigationPath(0));
          _isHandlingLoginSuccess = false;
        }

        if (state is Unauthenticated && state.errorMessage != null) {
          await Kontaku.snackbarNotification(
            context,
            'Login gagal: ${state.errorMessage}',
            snackBarDurationSeconds:  _snackBarDurationSeconds,
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
            Column(
              children: [
                ColoredBox(
                  color: Color(Kontaku.dark),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: Kontaku.vw(100, context),
                        height: isCompact ? 88 : 100,
                      ),
                      Positioned(
                        bottom: 0,
                        left: 20,
                        child: Text(
                          "Kontaku",
                          style: GoogleFonts.outfit(
                            color: Color(Kontaku.cream),
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ColoredBox(
                    color: Color(Kontaku.accent),
                    child: SizedBox(
                      width: Kontaku.vw(100, context),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          "Safe Calling, Safe Living",
                          style: GoogleFonts.outfit(
                            color: Color(Kontaku.dark),
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: isCompact ? 16 : 20,
              top: isCompact ? 30 : 40,
              child: CircleAvatar(
                radius: isCompact ? 52 : 60,
                backgroundColor: Color(Kontaku.dark),
                child: SvgPicture.asset(
                  'assets/icons/LogoIcon.svg',
                  width: ((isCompact ? 52 : 60) * 2) - 10,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                width: Kontaku.vw(100, context),
                height: isCompact
                    ? Kontaku.vh(78, context)
                    : Kontaku.vh(75, context),
                decoration: BoxDecoration(
                  color: Color(Kontaku.cream),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(Kontaku.vh(10, context)),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    isCompact ? 22 : 40,
                    isCompact ? 22 : 40,
                    isCompact ? 22 : 40,
                    isCompact ? 16 : 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Login",
                        style: GoogleFonts.montserrat(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Color(Kontaku.dark),
                        ),
                      ),
                      SizedBox(height: isCompact ? 24 : 40),
                      _KontakuTextField(
                        controller: _emailController,
                        hintText: "Masukkan email kamu",
                        labelText: "Email",
                      ),
                      SizedBox(height: isCompact ? 14 : 20),
                      _KontakuTextField(
                        controller: _passwordController,
                        hintText: "Masukan Password kamu",
                        labelText: "Password",
                      ),
                      Row(
                        children: [
                          SizedBox(
                            child: Row(
                              children: [
                                Checkbox(
                                  value: rememberMe,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      rememberMe = value ?? false;
                                    });
                                  },
                                ),
                                Text("Remember me"),
                              ],
                            ),
                          ),
                          Spacer(),
                          Text("Lupa password?"),
                        ],
                      ),
                      SizedBox(height: isCompact ? 14 : 20),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          width: isCompact ? 130 : 150,
                          height: isCompact ? 44 : 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              context.read<AuthenticationBloc>().add(
                                LoggedIn(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(Kontaku.accent),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              "Login",
                              style: TextStyle(
                                fontSize: isCompact ? 20 : 24,
                                color: Color(Kontaku.dark),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isCompact ? 14 : 20),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Text("belum punya akun?"),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: GestureDetector(
                          onTap: () {
                            context.go('/registerScreen');
                          },
                          child: Text(
                            "Klik disini",
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
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

        // TextField(
        //   controller: _emailController,
        //   decoration: InputDecoration(labelText: 'Email'),
        // ),
        // TextField(
        //   controller: _passwordController,
        //   decoration: InputDecoration(labelText: 'Password'),
        // ),
        // ElevatedButton(
        //   onPressed: () {
        //     LoginFunc();
        //     print(
        //       'Email: ${_emailController.text}, Password: ${_passwordController.text}',
        //     );
        //   },
        //   child: Text('Login'),
        // ),
      ),
    );
  }
}

class _KontakuTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;

  const _KontakuTextField({
    // super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
  });

  @override
  State<_KontakuTextField> createState() => _KontakuTextFieldState();
}

class _KontakuTextFieldState extends State<_KontakuTextField> {
  // 2. Variable State untuk menyimpan status sembunyi/lihat
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,

      // 3. Logika: Jika isPassword false, teks selalu terlihat.
      //    Jika isPassword true, ikut status _isObscure.
      obscureText: (widget.labelText == "Password") ? _isObscure : false,

      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ), // Saya ubah 0 jadi 10 biar konsisten
        // 4. Tombol Mata (Suffix Icon)
        suffixIcon: (widget.labelText == "Password")
            ? IconButton(
                icon: Icon(
                  // Ganti icon berdasarkan status
                  _isObscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  // Ubah status saat ditekan
                  setState(() {
                    _isObscure = !_isObscure;
                  });
                },
              )
            : null, // Jika bukan password, tidak ada icon
      ),
    );
  }
}
