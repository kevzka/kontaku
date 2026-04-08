import 'package:flutter/material.dart';
import 'package:kontaku/core/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: Kontaku.vw(100, context),
        height: Kontaku.vh(100, context),
        decoration: const BoxDecoration(
          color: Color.fromARGB(193, 0, 172, 100),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 50,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 72,
                    backgroundColor: Colors.white.withOpacity(0.5),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    child: Column(
                      children: [
                        Center(
                          child: Container(
                            child: Column(
                              children: [
                                Text(
                                  "MiTest Subject",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(Kontaku.dark),
                                  ),
                                ),
                                Container(
                                  height: 4,
                                  width: 300,
                                  color: Color(Kontaku.lightBeige),
                                ),
                                Text(
                                  "+62 812-3456-7890",
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
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
            Positioned(child: 
            Container(
              
              child: 
              Column(
                children: [
                  //isi nanti ya
                ],
              ),
            )
            )
          ],
        ),
      ),
    );
  }
}
