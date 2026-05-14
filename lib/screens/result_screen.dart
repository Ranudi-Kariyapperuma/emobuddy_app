import 'dart:io';
import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final File image;
  final Map<String, dynamic> result;

  const ResultScreen({
    super.key,
    required this.image,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Result")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.file(image, height: 200),

            if (result['cnn'] != null)
              Text("CNN: ${result['cnn']['asd_probability']}%"),

            if (result['xgboost'] != null)
              Text("XGBoost: ${result['xgboost']['asd_probability']}%"),

            Text("Overall: ${result['overall_probability']}%"),
            Text(result['asd_detected'] ? "ASD Detected" : "No ASD"),

            Text("Severity: ${result['severity'] ?? "None"}"),
          ],
        ),
      ),
    );
  }
}