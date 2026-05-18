class ResultModel {
  final String category;
  final double cnn;
  final double xgboost;
  final double overall;
  final bool asdDetected;

  ResultModel({
    required this.category,
    required this.cnn,
    required this.xgboost,
    required this.overall,
    required this.asdDetected,
  });

  Map<String, dynamic> toJson() => {
        "category": category,
        "cnn": cnn,
        "xgboost": xgboost,
        "overall": overall,
        "asdDetected": asdDetected,
      };

 factory ResultModel.fromJson(String category, Map<String, dynamic> json) {
    double cnn = json['cnn'] != null
        ? json['cnn']['asd_probability']?.toDouble() ?? 0
        : 0;

    double xgb = json['xgboost'] != null
        ? json['xgboost']['asd_probability']?.toDouble() ?? 0
        : 0;

    // For facial response, use asd_probability directly
    double overall = category == 'face'
        ? json['asd_probability']?.toDouble() ?? 0
        : json['overall_probability']?.toDouble() ?? 0;

    bool asdDetected = category == 'face'
        ? (overall >= 50)
        : json['asd_detected'] ?? false;

    // For facial, show asd_probability in both CNN and XGB columns
    if (category == 'face') {
      cnn = overall;
      xgb = overall;
    }

    return ResultModel(
      category: category,
      cnn: cnn,
      xgboost: xgb,
      overall: overall,
      asdDetected: asdDetected,
    );
  }
}