import 'dart:io';
import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final Map data;

  ResultPage({required this.data});

  @override
  Widget build(BuildContext context) {

    bool isASD = data['final_prediction'] == "ASD";

    return Scaffold(
      appBar: AppBar(
        title: Text("Result"),
        backgroundColor: isASD ? Colors.red : Colors.green,
      ),

      body: Padding(
        padding: EdgeInsets.all(20),

        child: Column(
          children: [

 // 🖼 IMAGE WITH OVERLAY
            if (data['image_path'] != null)
              Stack(
                children: [

                  // Uploaded Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(data['image_path']),
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // 🔴 Overlay explanation (ASD heatmap style)
                  if (isASD)
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.red.withOpacity(0.25),
                      ),
                      child: Center(
                        child: Text(
                          "ASD Indicators Detected\n(Facial region analysis)",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

            SizedBox(height: 20),
            Text(
              isASD ? "🟥 ASD Detected" : "🟩 No ASD Detected",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            Text("Confidence: ${(data['confidence'] * 100).toStringAsFixed(0)}%"),

            SizedBox(height: 10),

            Text("CNN: ${(data['cnn_confidence'] * 100).toStringAsFixed(0)}%"),
            Text("XGBoost: ${(data['xgb_confidence'] * 100).toStringAsFixed(0)}%"),

            SizedBox(height: 20),

            Text(
              "Why this result?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            Text(data['explanation'], textAlign: TextAlign.center),

            Spacer(),

            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Back"),
            )
          ],
        ),
      ),
    );
  }
}