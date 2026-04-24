import 'package:flutter/material.dart';
import 'dart:math';

class ColorTherapyGame extends StatefulWidget {
  @override
  _ColorTherapyGameState createState() => _ColorTherapyGameState();
}

class _ColorTherapyGameState extends State<ColorTherapyGame> {
  Color bgColor = Colors.blue.shade100;

  void changeColor() {
    setState(() {
      bgColor = Colors.primaries[Random().nextInt(Colors.primaries.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Relax 😢")),
      body: GestureDetector(
        onTap: changeColor,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 500),
          color: bgColor,
          child: Center(
            child: Text("Tap to relax 🌈", style: TextStyle(fontSize: 22)),
          ),
        ),
      ),
    );
  }
}