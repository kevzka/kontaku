import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class page3 extends StatelessWidget {
  const page3({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          child: SizedBox(
            width: double.infinity,
            child: Image.asset(
              'assets/images/image 2 (2).png',
              // fit: BoxFit.contain,
              // height: MediaQuery.of(context).size.height * 0.7,
            ),
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          left: 0,
          child: Container(
            width: double.infinity,
            child: Stack(
              children: [
                SvgPicture.asset("assets/icons/Vector11.svg", width: MediaQuery.of(context).size.width,),
                Positioned(
                  top: 100,
                  left: 30,
                  child: SvgPicture.asset("assets/icons/Atur kontak dengan mudah!.svg", width: 300),
                ),
              ],
            ),
          )
        ),
      ],
    );
  }
}
