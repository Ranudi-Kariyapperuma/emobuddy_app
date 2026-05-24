import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final File image;
  final Map<String, dynamic> result;

  const ResultScreen({super.key, required this.image, required this.result});

  @override
  Widget build(BuildContext context) {
    // ── Detect which module's response this is ──────────────────────────────
    final bool isFacial = result.containsKey('confidence_label');

    // ── Facial fields ───────────────────────────────────────────────────────
    final double facialProb =
        ((result['asd_probability'] ?? result['module2_asd_probability'] ?? 0))
            .toDouble();
    final String confidenceLabel = result['confidence_label'] ?? '';

    // ── Activity fields ─────────────────────────────────────────────────────
    final double activityProb =
        ((result['overall_probability'] ?? result['module1_asd_probability'] ?? 0))
            .toDouble();

    final Map<String, dynamic>? cnn =
        result['cnn'] as Map<String, dynamic>?;
    final Map<String, dynamic>? xgboost =
        result['xgboost'] as Map<String, dynamic>?;

    final double cnnProb = cnn != null
        ? (cnn['asd_probability'] ?? 0).toDouble()
        : 0;
    final String cnnPrediction = cnn?['prediction'] ?? 'N/A';

    final double xgbProb = xgboost != null
        ? (xgboost['asd_probability'] ?? 0).toDouble()
        : 0;
    final String xgbPrediction = xgboost?['prediction'] ?? 'N/A';

    // ── Shared ──────────────────────────────────────────────────────────────
    final double overallProb = isFacial ? facialProb : activityProb;
    final bool asdDetected = isFacial
        ? result['prediction'] == 'ASD'
        : (result['asd_detected'] ?? false);
 

    final bool categoryMatch = result['category_match'] ?? true;
    final String message = result['message'] ?? '';

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              "assets/images/dashbg.jpg",
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
                  // ── Image + Status ────────────────────────────────────────
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
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
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
                      
                                ],
                              ),
                            ),
                            const SizedBox(width: 40),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Category mismatch warning ─────────────────────────────
                  if (!categoryMatch && message.isNotEmpty)
                    _glassCard(
                      color: Colors.orange.withOpacity(0.15),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.orange),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // ── AI Analysis Results ───────────────────────────────────
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

                        // ── FACIAL result rows ──────────────────────────────
                        if (isFacial) ...[
                          const SizedBox(height: 8),
                          _infoRow(
                            "Prediction",
                            result['prediction'] ?? 'N/A',
                          ),
                          if (confidenceLabel.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _infoRow("Confidence", confidenceLabel),
                          ],
                        ],

                        // ── ACTIVITY result rows (CNN + XGBoost) ────────────
                        if (!isFacial) ...[
                          const SizedBox(height: 8),
                          _infoRow(
                            "CNN",
                            "${cnnProb.toStringAsFixed(2)}% - $cnnPrediction",
                          ),
                          const SizedBox(height: 8),
                          _infoRow(
                            "XGBoost",
                            "${xgbProb.toStringAsFixed(2)}% - $xgbPrediction",
                          ),
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