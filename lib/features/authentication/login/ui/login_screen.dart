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
  final ScrollController _scrollController = ScrollController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  int _snackBarDurationSeconds = 3;
  bool _isHandlingLoginSuccess = false;
  bool _isScrollLocked = true;
  bool rememberMe = false;

  List<FocusNode> get _allFocusNodes => [_emailFocus, _passwordFocus];

  @override
  void initState() {
    super.initState();
    _setupFocusListeners();
  }

  void _setupFocusListeners() {
    for (final node in _allFocusNodes) {
      node.addListener(() => _onFocusChanged(node));
    }
  }

  void _onFocusChanged(FocusNode node) {
    if (node.hasFocus) {
      setState(() => _isScrollLocked = false);
      _scrollFocusedFieldIntoView(node);
    } else {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        final anyFocused = _allFocusNodes.any((n) => n.hasFocus);
        if (!anyFocused) {
          setState(() => _isScrollLocked = true);
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  Future<void> _scrollFocusedFieldIntoView(FocusNode node) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted || !node.hasFocus || node.context == null) return;
    await Scrollable.ensureVisible(
      node.context!,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      alignment: 0.3,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();
    for (final node in _allFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 380;

    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) async {
        if (state is Authenticated && !_isHandlingLoginSuccess) {
          _isHandlingLoginSuccess = true;
          await Future.delayed(const Duration(milliseconds: 500));
          await Kontaku.snackbarNotification(
            context,
            "Login Successful",
            snackBarDurationSeconds: _snackBarDurationSeconds,
          );

          if (!mounted) return;
          context.go(AppRouter.mainNavigationPath(0));
          _isHandlingLoginSuccess = false;
        }

        if (state is Unauthenticated && state.errorMessage != null) {
          await Kontaku.snackbarNotification(
            context,
            'Login gagal: ${state.errorMessage}',
            snackBarDurationSeconds: _snackBarDurationSeconds,
          );
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false, // Tambahkan ini
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          child: SafeArea(
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
                      controller: _scrollController,
                      physics: _isScrollLocked
                          ? const NeverScrollableScrollPhysics()
                          : const BouncingScrollPhysics(),
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
                            focusNode: _emailFocus,
                            hintText: "Masukkan email kamu",
                            labelText: "Email",
                          ),
                          SizedBox(height: isCompact ? 14 : 20),
                          _KontakuTextField(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            hintText: "Masukan Password kamu",
                            labelText: "Password",
                            isPassword: true,
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
                              onTap: () async {
                                final trigger = await context.push('/registerScreen');
                                if (trigger == true) {
                                  await Kontaku.snackbarNotification(
                                    context,
                                    "Account Created!",
                                    snackBarDurationSeconds:
                                        _snackBarDurationSeconds,
                                  );
                                }
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
  final FocusNode? focusNode;
  final String hintText;
  final String labelText;
  final bool isPassword;

  const _KontakuTextField({
    // super.key,
    required this.controller,
    this.focusNode,
    required this.hintText,
    required this.labelText,
    this.isPassword = false,
  });

  @override
  State<_KontakuTextField> createState() => _KontakuTextFieldState();
}

class _KontakuTextFieldState extends State<_KontakuTextField> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: widget.isPassword && _isObscure,

      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _isObscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isObscure = !_isObscure;
                  });
                },
              )
            : null,
      ),
    );
  }
}
