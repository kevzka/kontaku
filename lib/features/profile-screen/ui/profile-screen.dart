import 'package:flutter/material.dart';
import 'package:kontaku/core/utils/utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: Kontaku.vw(100, context),
      height: Kontaku.vh(100, context),
      color: Color(Kontaku.colors[1]),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            child: Container(
              width: Kontaku.vw(100, context) - 80,
              height: Kontaku.vh(100, context),
              decoration: BoxDecoration(
                color: Color(Kontaku.colors[2]),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Kontaku.vw(100, context) * 0.35),
                ),
              ),
            ),
          ),

          Center(child: Text("Profile Screen")),
        ],
      ),
    );
  }
}
