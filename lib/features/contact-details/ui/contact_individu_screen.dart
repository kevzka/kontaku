import 'package:flutter/material.dart';
import 'package:kontaku/core/utils/utils.dart';

class ContactIndividuScreen extends StatefulWidget {
  const ContactIndividuScreen({super.key});

  @override
  State<ContactIndividuScreen> createState() => _ContactIndividuScreenState();
}

class _ContactIndividuScreenState extends State<ContactIndividuScreen> {
  String displayName = "kevin apt";
  String NumberTelephone = "+62 812-3456-7890";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ColoredBox(
                color: Colors.blue,
                child: SizedBox(
                  width: Kontaku.vw(100, context),
                  height: Kontaku.vh(40, context),
                ),
                // child: ,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        print("haelo");
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  NumberTelephone,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text("Ponsel | Indonesia"),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.phone, color: Colors.green, size: 30),
                                Icon(Icons.message, color: Colors.blue, size: 30),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 64,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "whatsapp",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(Icons.telegram, color: Colors.blue, size: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24, child: Text("lainnya")),
              SizedBox(
                height: 64,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Nada dering bawaan",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.arrow_right),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Kode QR",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.arrow_right),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
