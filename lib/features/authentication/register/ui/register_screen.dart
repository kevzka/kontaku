import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kontaku/core/utils/utils.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/register_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _scrollController = ScrollController();

  final _emailFocus = FocusNode();
  final _usernameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _rememberMe = false;
  bool _isScrollLocked = true;

  List<FocusNode> get _allFocusNodes => [
        _emailFocus,
        _usernameFocus,
        _phoneFocus,
        _passwordFocus,
        _confirmPasswordFocus,
      ];

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

  Future<void> _onSignUpPressed() async {
    final result = await regisFunc(
      email: _emailCtrl.text,
      password: _passwordCtrl.text,
      confirmPassword: _confirmPasswordCtrl.text,
      username: _usernameCtrl.text,
      phone: _phoneCtrl.text,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      context.go('/loginScreen');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Register Gagal: ${result["error"]}')),
      );
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _phoneCtrl.dispose();
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

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            _buildBackground(context, isCompact),
            _buildLogoAvatar(context, isCompact),
            _buildScrollableForm(context, isCompact),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(BuildContext context, bool isCompact) {
    return Column(
      children: [
        ColoredBox(
          color: Color(Kontaku.colors[0]),
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
    );
  }

  Widget _buildLogoAvatar(BuildContext context, bool isCompact) {
    final radius = isCompact ? 52.0 : 60.0;
    return Positioned(
      right: isCompact ? 16 : 20,
      top: isCompact ? 30 : 40,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Color(Kontaku.dark),
        child: SvgPicture.asset(
          'assets/icons/LogoIcon.svg',
          width: radius * 2 - 10,
        ),
      ),
    );
  }

  Widget _buildScrollableForm(BuildContext context, bool isCompact) {
    return Positioned.fill(
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: _isScrollLocked
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 200),
        child: SizedBox(
          width: Kontaku.vw(100, context),
          height: Kontaku.vh(110, context),
          child: _buildFormCard(context, isCompact),
        ),
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, bool isCompact) {
    return Container(
      width: Kontaku.vw(100, context),
      decoration: BoxDecoration(
        color: Color(Kontaku.cream),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(Kontaku.vh(10, context)),
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 22 : 40,
          vertical: isCompact ? 18 : 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Sign Up",
              style: GoogleFonts.montserrat(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Color(Kontaku.dark),
              ),
            ),
            SizedBox(height: isCompact ? 18 : 40),
            _KontakuTextField(
              controller: _emailCtrl,
              focusNode: _emailFocus,
              hintText: "Masukkan email kamu",
              labelText: "Email",
            ),
            SizedBox(height: isCompact ? 12 : 20),
            _KontakuTextField(
              controller: _usernameCtrl,
              focusNode: _usernameFocus,
              hintText: "Masukkan Username kamu",
              labelText: "Username",
            ),
            SizedBox(height: isCompact ? 12 : 20),
            _KontakuTextField(
              controller: _phoneCtrl,
              focusNode: _phoneFocus,
              hintText: "Masukkan Nomor Telepon kamu",
              labelText: "Nomor Telepon",
            ),
            SizedBox(height: isCompact ? 12 : 20),
            _KontakuTextField(
              controller: _passwordCtrl,
              focusNode: _passwordFocus,
              hintText: "Masukkan Password kamu",
              labelText: "Password",
              isPassword: true,
            ),
            SizedBox(height: isCompact ? 12 : 20),
            _KontakuTextField(
              controller: _confirmPasswordCtrl,
              focusNode: _confirmPasswordFocus,
              hintText: "Konfirmasi Password kamu",
              labelText: "Confirm Password",
              isPassword: true,
            ),
            Row(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (v) => setState(() => _rememberMe = v ?? false),
                    ),
                    const Text("Remember me"),
                  ],
                ),
                const Spacer(),
                const Text("Lupa password?"),
              ],
            ),
            SizedBox(height: isCompact ? 12 : 20),
            Center(
              child: SizedBox(
                width: isCompact ? 130 : 150,
                height: isCompact ? 44 : 50,
                child: ElevatedButton(
                  onPressed: _onSignUpPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(Kontaku.accent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: isCompact ? 20 : 24,
                      color: Color(Kontaku.dark),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: isCompact ? 12 : 20),
            Center(child: const Text("Sudah punya akun?")),
            Center(
              child: GestureDetector(
                onTap: () => context.go('/loginScreen'),
                child: const Text(
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
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable TextField
// ---------------------------------------------------------------------------

class _KontakuTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final String labelText;
  final bool isPassword;

  const _KontakuTextField({
    required this.controller,
    this.focusNode,
    required this.hintText,
    required this.labelText,
    this.isPassword = false, // eksplisit, bukan cek string
  });

  @override
  State<_KontakuTextField> createState() => _KontakuTextFieldState();
}

class _KontakuTextFieldState extends State<_KontakuTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: widget.isPassword && _obscureText,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,
      ),
    );
  }
}