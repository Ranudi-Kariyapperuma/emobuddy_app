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

    double overall = json['overall_probability']?.toDouble() ?? 0;

    return ResultModel(
      category: category,
      cnn: cnn,
      xgboost: xgb,
      overall: overall,
      asdDetected: json['asd_detected'] ?? false,
    );
  }
}