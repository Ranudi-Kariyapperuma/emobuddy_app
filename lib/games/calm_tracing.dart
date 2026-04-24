import 'package:flutter/material.dart';

class TracingGame extends StatefulWidget {
  @override
  _TracingGameState createState() => _TracingGameState();
}

class _TracingGameState extends State<TracingGame> {
  List<Offset?> points = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tracing 😌")),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            points.add(details.localPosition);
          });
        },
        onPanEnd: (details) => points.add(null),
        child: CustomPaint(
          painter: DrawPainter(points),
          child: Container(color: Colors.white),
        ),
      ),
    );
  }
}

class DrawPainter extends CustomPainter {
  final List<Offset?> points;
  DrawPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = 4
      ..color = Colors.black;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i+1] != null) {
        canvas.drawLine(points[i]!, points[i+1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}