import 'package:flutter/material.dart';
import 'package:kontaku/core/utils/utils.dart';

class Contactlistscreen2 extends StatefulWidget {
  const Contactlistscreen2({super.key});

  @override
  State<Contactlistscreen2> createState() => _Contactlistscreen2State();
}

class _Contactlistscreen2State extends State<Contactlistscreen2> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: vw(100, context),
      height: vh(100, context),
      color: Color(Kontaku['color']![1]),
      child: Stack(
        children: [
          Container(
            width: vw(100, context) ,
            height: vh(100, context),
            decoration: BoxDecoration(
              color: Color(Kontaku['color']![2]),
            ),
          ),
          Center(child: Text("Contact List Screen")),
        ],
      ),
    );
  }
}
