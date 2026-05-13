class QuestionModel {
  final String question;
  final List<OptionModel> options;

  QuestionModel({
    required this.question,
    required this.options,
  });
}

class OptionModel {
  final String name;
  final String emoji;
  final bool isCorrect;

  OptionModel({
    required this.name,
    required this.emoji,
    required this.isCorrect,
  });
}