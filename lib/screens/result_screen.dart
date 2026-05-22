import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final File image;
  final Map<String, dynamic> result;

  const ResultScreen({super.key, required this.image, required this.result});

  @override
  Widget build(BuildContext context) {
    // Works for both facial and activity responses
    final double overallProb =
        (result['asd_probability'] ?? result['module2_asd_probability'] ?? 0)
            .toDouble();
    final bool asdDetected = result['prediction'] == 'ASD';
    final String confidenceLabel = result['confidence_label'] ?? '';
    final bool categoryMatch = result['category_match'] ?? true;
    final String message = result['message'] ?? '';

    return Scaffold(
      body: Stack(
        children: [
          // 🌄 Background Image
          SizedBox.expand(
            child: Image.asset(
              "assets/images/dashbg.jpg", // <-- replace with your background image
              fit: BoxFit.cover,
            ),
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.3),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _glassCard(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            image,
                            height: 500,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            // 🔙 Back button
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // 🧠 Status Text
                            Expanded(
                              child: Text(
                                asdDetected
                                    ? "ASD Detected"
                                    : "No ASD Detected",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 29,
                                  fontWeight: FontWeight.bold,
                                  color: asdDetected
                                      ? Colors.red
                                      : const Color.fromARGB(255, 20, 102, 22),
                                ),
                              ),
                            ),

                            const SizedBox(width: 40), // keeps balance
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (!categoryMatch)
                    _glassCard(
                      color: Colors.orange.withOpacity(0.15),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.orange),
                      ),
                    ),

                  const SizedBox(height: 16),

                  _glassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _title("AI Analysis Results"),
                        const SizedBox(height: 10),

                        _infoRow(
                          "Overall Probability",
                          "${overallProb.toStringAsFixed(1)}%",
                        ),
                        const SizedBox(height: 8),
                        _infoRow("Prediction", result['prediction'] ?? 'N/A'),
                        const SizedBox(height: 8),
                        if (confidenceLabel.isNotEmpty) ...[
                          _infoRow("Confidence", confidenceLabel),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🎨 Glass Card Widget
  Widget _glassCard({required Widget child, Color? color}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (color ?? Colors.white).withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _title(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
