import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../data/question_data.dart';
import '../models/question_model.dart';
import '../services/tts_service.dart';

class WHGameScreen extends StatefulWidget {
  @override
  State<WHGameScreen> createState() => _WHGameScreenState();
}

class _WHGameScreenState extends State<WHGameScreen>
    with SingleTickerProviderStateMixin {
  final TTSService tts = TTSService();

  int currentIndex = 0;
  int stars = 0;

  bool showStar = false;
  bool kidHappy = false;

  // 🌳 Backgrounds
  List<String> backgrounds = [
    "assets/images/bg1.jpg",
    "assets/images/bg2.jpg",
    "assets/images/bg3.jpg",
  ];

  // 🧒 Different kid animations
  List<String> kidAnimations = [
    'assets/lottie/kid.json',
    'assets/lottie/kid2.json',
    'assets/lottie/kid3.json',
  ];

  @override
  void initState() {
    super.initState();
    tts.init();
    speakQuestion();
  }

  void speakQuestion() {
    tts.speak(questionData[currentIndex].question);
  }

  String bg() {
    return backgrounds[currentIndex % backgrounds.length];
  }

  // 🧒 Current kid animation
  String currentKidAnimation() {
    return kidAnimations[currentIndex % kidAnimations.length];
  }

  void checkAnswer(bool correct) {
    if (correct) {
      setState(() {
        stars++;
        showStar = true;
        kidHappy = true;
      });

      tts.speak("Yay! Correct!");

      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          showStar = false;
          kidHappy = false;
        });

        nextQuestion();
      });
    } else {
      tts.speak("Try again!");
    }
  }

  void nextQuestion() {
    if (currentIndex < questionData.length - 1) {
      setState(() {
        currentIndex++;
      });

      speakQuestion();
    } else {
      tts.speak("Well done! Game finished!");
    }
  }

  @override
  Widget build(BuildContext context) {
    QuestionModel q = questionData[currentIndex];

    final screenWidth = MediaQuery.of(context).size.width;

    // 🎯 Triangle option layout
    final positions = [Offset(0, 0), Offset(-130, 180), Offset(130, 180)];

    return Scaffold(
      body: Stack(
        children: [
          // 🌳 BACKGROUND
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(bg()),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🌑 DARK OVERLAY
          Container(color: Colors.black.withOpacity(0.15)),

          // ⭐ STAR POPUP
          if (showStar)
            Positioned.fill(
              child: Align(
                alignment: Alignment(0, 0.1),

                child: AnimatedScale(
                  scale: showStar ? 1.2 : 0.8,
                  duration: Duration(milliseconds: 300),

                  child: Text("⭐", style: TextStyle(fontSize: 80)),
                ),
              ),
            ),

          // 🔙 CARTOON BACK BUTTON
          Positioned(
            top: 45,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },

              child: Container(
                padding: EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: Colors.pinkAccent,
                  shape: BoxShape.circle,

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),

                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),

          // 🔤 QUESTION TEXT
          Positioned(
            top: 110,
            left: 20,
            right: 20,
            child: Text(
              q.question,
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,

                shadows: [
                  Shadow(
                    blurRadius: 20,
                    color: Colors.black,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
          ),

          // 🎯 OPTIONS
          ...List.generate(q.options.length, (index) {
            final option = q.options[index];

            return Positioned(
              top: 240 + positions[index].dy,
              left: (screenWidth / 2) + positions[index].dx - 55,

              child: GestureDetector(
                onTap: () => checkAnswer(option.isCorrect),

                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  padding: EdgeInsets.all(12),

                  child: Column(
                    children: [
                      // 🧸 EMOJI
                      Text(option.emoji, style: TextStyle(fontSize: 80)),

                      SizedBox(height: 6),

                      // 📝 OPTION NAME
                      Text(
                        option.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,

                          shadows: [
                            Shadow(
                              blurRadius: 8,
                              color: Colors.black,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // 🧒 KID ANIMATION
          Positioned(
            bottom: 40,
            left: 70,

            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),

              child: Lottie.asset(
                currentKidAnimation(),
                width: kidHappy ? 330 : 280,
                repeat: true,
              ),
            ),
          ),

          // ⭐ STAR COUNTER
          Positioned(
            top: 50,
            right: 20,

            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),

              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(30),
              ),

              child: Text(
                "⭐ $stars",
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.yellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
