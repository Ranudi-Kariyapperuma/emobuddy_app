import 'dart:io';
import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const ResultPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final bool isRejected = data['status'] == 'rejected';

    // ── If category mismatch → show rejection screen ────────────────────────
    if (isRejected) {
      return _RejectedView(data: data);
    }

    // ── Normal ASD result screen ─────────────────────────────────────────────
    return _ResultView(data: data);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REJECTED VIEW — wrong category uploaded
// ─────────────────────────────────────────────────────────────────────────────
class _RejectedView extends StatelessWidget {
  final Map<String, dynamic> data;
  const _RejectedView({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wrong Image Type"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image preview
            if (data['image_path'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(data['image_path']),
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            SizedBox(height: 28),

            // Big warning icon
            Icon(Icons.warning_amber_rounded, size: 64, color: Colors.orange),

            SizedBox(height: 16),

            // Title
            Text(
              "Image Type Mismatch",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 16),

            // Detail message from backend
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Text(
                data['message'] ?? 'Please upload the correct image type.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, height: 1.5),
              ),
            ),

            SizedBox(height: 20),

            // Category confidence breakdown
            _CategoryScoreRow(
              selectedTab: data['selected_tab'] ?? '',
              predictedCategory: data['predicted_category'] ?? '',
              scores: Map<String, dynamic>.from(data['category_scores'] ?? {}),
            ),

            Spacer(),

            // Back button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.arrow_back, color: Colors.white),
                label: Text("Try Again", style: TextStyle(color: Colors.white, fontSize: 16)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RESULT VIEW — ASD detection result
// ─────────────────────────────────────────────────────────────────────────────
class _ResultView extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ResultView({required this.data});

  @override
  Widget build(BuildContext context) {
    final bool isASD = data['final_prediction'] == "ASD";

    // Confidences come as 0–100 from the updated backend (no ×100 needed)
    final double confidence    = (data['confidence']     ?? 0).toDouble();
    final double cnnConfidence = (data['cnn_confidence'] ?? 0).toDouble();
    final double xgbConfidence = (data['xgb_confidence'] ?? 0).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: Text("Result"),
        backgroundColor: isASD ? Colors.red : Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Image with overlay ──────────────────────────────────────────
            if (data['image_path'] != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(data['image_path']),
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (isASD)
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.red.withOpacity(0.25),
                      ),
                      child: Center(
                        child: Text(
                          "ASD Indicators Detected",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

            SizedBox(height: 20),

            // ── Category badge ──────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 18),
                SizedBox(width: 6),
                Text(
                  "Category: ${data['predicted_category'] ?? data['selected_tab']}  "
                  "(${data['category_confidence']}% confidence)",
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ],
            ),

            SizedBox(height: 12),

            // ── Main verdict ────────────────────────────────────────────────
            Text(
              isASD ? "🟥 ASD Detected" : "🟩 No ASD Detected",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            // ── Confidence cards ────────────────────────────────────────────
            Row(
              children: [
                Expanded(child: _ConfidenceCard("Ensemble", confidence,        isASD ? Colors.red : Colors.green)),
                SizedBox(width: 10),
                Expanded(child: _ConfidenceCard("CNN",      cnnConfidence,     Colors.blue)),
                SizedBox(width: 10),
                Expanded(child: _ConfidenceCard("XGBoost",  xgbConfidence,     Colors.purple)),
              ],
            ),

            SizedBox(height: 20),

            // ── Explanation ─────────────────────────────────────────────────
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Why this result?",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  SizedBox(height: 8),
                  Text(
                    data['explanation'] ?? '',
                    textAlign: TextAlign.left,
                    style: TextStyle(height: 1.5),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // ── Back button ─────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isASD ? Colors.red : Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text("Back", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SMALL WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _ConfidenceCard extends StatelessWidget {
  final String label;
  final double value;   // 0–100
  final Color  color;

  const _ConfidenceCard(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(
            "${value.toStringAsFixed(0)}%",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class _CategoryScoreRow extends StatelessWidget {
  final String selectedTab;
  final String predictedCategory;
  final Map<String, dynamic> scores;

  const _CategoryScoreRow({
    required this.selectedTab,
    required this.predictedCategory,
    required this.scores,
  });

  @override
  Widget build(BuildContext context) {
    if (scores.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Category Scores",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        SizedBox(height: 8),
        ...scores.entries.map((e) {
          final bool isSelected  = e.key == selectedTab;
          final bool isPredicted = e.key == predictedCategory;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    e.key,
                    style: TextStyle(
                      fontWeight: isPredicted ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: (e.value as num).toDouble() / 100,
                    backgroundColor: Colors.grey.shade200,
                    color: isPredicted ? Colors.orange : Colors.grey.shade400,
                    minHeight: 8,
                  ),
                ),
                SizedBox(width: 8),
                Text("${e.value}%",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                SizedBox(width: 6),
                if (isSelected)
                  Icon(Icons.arrow_back_ios, size: 12, color: Colors.blue),
                if (isPredicted && !isSelected)
                  Icon(Icons.check, size: 12, color: Colors.orange),
              ],
            ),
          );
        }).toList(),
        SizedBox(height: 6),
        Text(
          "← selected tab   ✓ predicted",
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}
