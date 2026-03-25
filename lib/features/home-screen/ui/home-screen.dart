import 'package:flutter/material.dart';
import 'package:kontaku/core/utils/utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: vw(100, context),
      height: vh(100, context),
      color: Color(Kontaku['color']![1]),
      child: Stack(
        children: [
          Container(
            width: vw(100, context) - 80,
            height: vh(100, context),
            decoration: BoxDecoration(
              color: Color(Kontaku['color']![2]),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(vw(100, context) * 0.35),
              ),
            ),
          ),
          //make plus button for adding number of contact
          Positioned(
            bottom: vh(12, context),
            right: 50,
            child: FloatingActionButton(
              elevation: 0,
              backgroundColor: Color(Kontaku['color']![1]),
              shape: const CircleBorder(
                side: BorderSide(color: Colors.white, width: 4),
              ),
              onPressed: () {},
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            ),
          ),
          Center(child: Text("Home Screen")),
        ],
      ),
    );
  }
}
