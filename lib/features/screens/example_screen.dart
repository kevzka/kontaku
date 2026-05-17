import 'package:flutter/material.dart';

class TesImgbb extends StatefulWidget {
  const TesImgbb({super.key});

  @override
  State<TesImgbb> createState() => _TesImgbbState();
}

class _TesImgbbState extends State<TesImgbb> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Image.network(
              'https://i.ibb.co.com/G3BqhgnS/upload.jpg'),
        ],
      ),
    );
  }
}