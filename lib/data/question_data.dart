import '../models/question_model.dart';

List<QuestionModel> questionData = [
  QuestionModel(
    question: "What do we use to eat food?",
    options: [
      OptionModel(name: "Dress", emoji: "👗", isCorrect: false),
      OptionModel(name: "Spoon", emoji: "🥄", isCorrect: true),
      OptionModel(name: "Bone", emoji: "🦴", isCorrect: false),
    ],
  ),

  QuestionModel(
    question: "Who helps us when we are sick?",
    options: [
      OptionModel(name: "Teacher", emoji: "👩‍🏫", isCorrect: false),
      OptionModel(name: "Doctor", emoji: "👨‍⚕️", isCorrect: true),
      OptionModel(name: "Driver", emoji: "🚗", isCorrect: false),
    ],
  ),

  QuestionModel(
    question: "What do we use to write?",
    options: [
      OptionModel(name: "Pencil", emoji: "✏️", isCorrect: true),
      OptionModel(name: "Shoes", emoji: "👟", isCorrect: false),
      OptionModel(name: "Ball", emoji: "⚽", isCorrect: false),
    ],
  ),
];