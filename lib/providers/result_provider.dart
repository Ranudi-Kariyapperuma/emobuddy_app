import 'package:flutter/material.dart';
import '../models/result_model.dart';

class ResultProvider extends ChangeNotifier {
  final Map<String, ResultModel> results = {};

  void addResult(ResultModel result) {
    results[result.category] = result;
    notifyListeners();
  }

  ResultModel? getResult(String category) {
    return results[category];
  }

  List<ResultModel> get allResults => results.values.toList();

  double get overallAverage {
    if (results.isEmpty) return 0;
    return results.values
            .map((e) => e.overall)
            .reduce((a, b) => a + b) /
        results.length;
  }

  String get severity {
    double avg = overallAverage;

    if (avg >= 80) return "Severe";
    if (avg >= 65) return "Moderate";
    if (avg >= 50) return "Mild";
    return "None";
  }

  bool get asdDetected => overallAverage >= 50;
}