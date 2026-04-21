import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:kontaku/core/models/account_model.dart';
import 'package:kontaku/core/utils/utils.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  bool rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Column(
            children: [
              ColoredBox(
                color: Color(Kontaku.colors[0]),
                child: Stack(
                  children: [
                    SizedBox(width: Kontaku.vw(100, context), height: 100),
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
            right: 20,
            top: 40,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Color(Kontaku.dark),
              child: SvgPicture.asset(
                'assets/icons/LogoIcon.svg',
                width: (60 * 2) - 10,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: Kontaku.vw(100, context),
              height: Kontaku.vh(75, context),
              decoration: BoxDecoration(
                color: Color(Kontaku.cream),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(Kontaku.vh(10, context)),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(40.0),
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
                    SizedBox(height: 40),
                    _KontakuTextField(
                      controller: _emailController,
                      hintText: "Masukkan email kamu",
                      labelText: "Email",
                    ),
                    SizedBox(height: 20),
                    _KontakuTextField(
                      controller: _usernameController,
                      hintText: "Masukan Username kamu",
                      labelText: "Username",
                    ),
                    _KontakuTextField(
                      controller: _phoneNumberController,
                      hintText: "Masukan Nomor Telepon kamu",
                      labelText: "Nomor Telepon",
                    ),
                    SizedBox(height: 20),
                    _KontakuTextField(
                      controller: _passwordController,
                      hintText: "Masukan Password kamu",
                      labelText: "Password",
                    ),
                    SizedBox(height: 20),
                    _KontakuTextField(
                      controller: _confirmPasswordController,
                      hintText: "Konfirmasi Password kamu",
                      labelText: "Confirm Password",
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
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        width: 150,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            var resault = await regisFunc(
                              email: _emailController.text,
                              password: _passwordController.text,
                              confirmPassword: _confirmPasswordController.text,
                              username: _usernameController.text,
                              phone: _phoneNumberController.text,
                            );
                            if (resault["success"]) {
                              context.go('/loginScreen');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Register Gagal: ${resault["error"]}",
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(Kontaku.accent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 24,
                              color: Color(Kontaku.dark),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Text("Sudah punya akun?"),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: GestureDetector(
                        onTap: () {
                          context.go('/loginScreen');
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
      obscureText:
          (widget.labelText == "Password" ||
              widget.labelText == "Confirm Password")
          ? _isObscure
          : false,

      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ), // Saya ubah 0 jadi 10 biar konsisten
        // 4. Tombol Mata (Suffix Icon)
        suffixIcon:
            (widget.labelText == "Password" ||
                widget.labelText == "Confirm Password")
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

Future regisFunc({
  required String email,
  required String password,
  required String confirmPassword,
  required String username,
  required String phone,
}) async {
  try {
    if (password != confirmPassword) {
      return {
        "success": false,
        "error": "Password dan Confirm Password tidak cocok",
      };
    }
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    print("User registered successfully: ${credential.user?.uid}");
    addUserDetails(
      account: AccountModel(
        username: username,
        uid: credential.user!.uid,
        imageProfile: "",
        phoneNumber: Kontaku.normalizePhoneNumber(phone),
      ),
    );

    return {"success": true};
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      print('The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      print('The account already exists for that email.');
    }
    print(e);
    return {"success": false, "error": e.code};
  }
}

void addUserDetails({required AccountModel account}) async {
  dynamic db = FirebaseFirestore.instance;
  // UID diletakkan sebagai dokumen level atas agar Security Rules lebih mudah.
  db.collection("userDetails").doc(account.uid).set(account.toFirestoreMap());
}
