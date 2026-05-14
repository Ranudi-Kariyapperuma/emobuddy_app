import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/result_provider.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ResultProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Summary")),
      body: Column(
        children: [
          Text("Overall Average: ${provider.overallAverage.toStringAsFixed(2)}%"),
          Text("Severity: ${provider.severity}"),
          Text(provider.asdDetected ? "ASD Detected" : "No ASD"),

          const Divider(),

          ...provider.allResults.map((r) => ListTile(
                title: Text(r.category),
                subtitle: Text(
                    "CNN: ${r.cnn}% | XGB: ${r.xgboost}% | Overall: ${r.overall}%"),
              )),
        ],
      ),
    );
  }
}