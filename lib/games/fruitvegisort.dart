import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/tts_service.dart';

class FruitVegiSortGame extends StatefulWidget {
  @override
  State<FruitVegiSortGame> createState() => _FruitVegiSortGameState();
}

class _FruitVegiSortGameState extends State<FruitVegiSortGame>
    with TickerProviderStateMixin {

  final TTSService tts = TTSService();

  int score = 0;
  int level = 1;

  String feedbackText = "";
  bool showStars = false;

  int currentLevelIndex = 0;

  List<Map<String, dynamic>> levels = [

    {
      "background": "assets/images/room1.jpg",
      "animation": "assets/lottie/panda.json",
      "items": [
        {"name": "Apple", "emoji": "🍎", "type": "fruit", "matched": false},
        {"name": "Banana", "emoji": "🍌", "type": "fruit", "matched": false},
        {"name": "Carrot", "emoji": "🥕", "type": "vegi", "matched": false},
        {"name": "Tomato", "emoji": "🍅", "type": "vegi", "matched": false},
      ],
    },

    {
      "background": "assets/images/room2.jpg",
      "animation": "assets/lottie/kid2.json",
      "items": [
        {"name": "Orange", "emoji": "🍊", "type": "fruit", "matched": false},
        {"name": "Pear", "emoji": "🍐", "type": "fruit", "matched": false},
        {"name": "Grapes", "emoji": "🍇", "type": "fruit", "matched": false},
        {"name": "Broccoli", "emoji": "🥦", "type": "vegi", "matched": false},
        {"name": "Corn", "emoji": "🌽", "type": "vegi", "matched": false},
      ],
    },

    {
      "background": "assets/images/room3.jpg",
      "animation": "assets/lottie/kid3.json",
      "items": [
        {"name": "Apple", "emoji": "🍎", "type": "fruit", "matched": false},
        {"name": "Banana", "emoji": "🍌", "type": "fruit", "matched": false},
        {"name": "Orange", "emoji": "🍊", "type": "fruit", "matched": false},
        {"name": "Carrot", "emoji": "🥕", "type": "vegi", "matched": false},
        {"name": "Broccoli", "emoji": "🥦", "type": "vegi", "matched": false},
        {"name": "Corn", "emoji": "🌽", "type": "vegi", "matched": false},
      ],
    },
  ];

  List<Map<String, dynamic>> get items =>
      levels[currentLevelIndex]["items"];

  final List<String> successVoices = [
    "Great Job!",
    "Amazing!",
    "Awesome!",
    "Fantastic!",
    "Excellent!",
  ];

  final List<String> wrongVoices = [
    "Try Again",
    "Good Try",
    "Keep Going",
    "Almost",
  ];

  @override
  void initState() {
    super.initState();
    initTTS();
  }

  Future<void> initTTS() async {
    await tts.init();

    Future.delayed(Duration(milliseconds: 700), () async {
      await tts.speak(
        "Welcome! Drag fruits and vegetables into the correct box",
      );
    });
  }

  Future<void> handleCorrect(Map item) async {
    score++;

    String praise =
        successVoices[Random().nextInt(successVoices.length)];

    setState(() {
      feedbackText = praise;
      showStars = true;
      item["matched"] = true;
    });

    await tts.speak(item["name"]);
    await Future.delayed(Duration(milliseconds: 500));
    await tts.speak(praise);

    bool allMatched = items.every((item) => item["matched"] == true);

    if (allMatched) {
      await Future.delayed(Duration(seconds: 2));

      if (currentLevelIndex < levels.length - 1) {
        setState(() {
          currentLevelIndex++;
          level++;
          feedbackText = "Level Complete!";
        });

        await tts.speak("Welcome to level $level");
      } else {
        setState(() {
          feedbackText =
              "Congratulations! You Finished All Levels!";
        });

        await tts.speak(
          "Congratulations! You completed all levels",
        );
      }
    }

    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showStars = false;
          feedbackText = "";
        });
      }
    });
  }

  Future<void> handleWrong() async {
    String msg =
        wrongVoices[Random().nextInt(wrongVoices.length)];

    setState(() {
      feedbackText = msg;
    });

    await tts.speak(msg);

    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          feedbackText = "";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          // 🌈 BACKGROUND
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  levels[currentLevelIndex]["background"],
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🌫 OVERLAY
          Container(
            color: Colors.black.withOpacity(0.08),
          ),

          SafeArea(
            child: Stack(
              children: [

                Positioned(
                  top: 20,
                  left: 20,
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.blue),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Level $level",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),

                ...buildHalfCircleItems(),

                // ✅ CENTER FIXED (NO SHIFTING)
                Align(
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [

                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          Container(
                            height: 220,
                            width: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.15),
                            ),
                            child: Lottie.asset(
                              levels[currentLevelIndex]["animation"],
                            ),
                          ),

                          SizedBox(height: 20),

                          Text(
                            "Sort Fruits & Vegetables",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 10,
                                  color: Colors.black45,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 10),

                          Text(
                            feedbackText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.yellow,
                            ),
                          ),
                        ],
                      ),

                      // ✨ OVERLAY ANIMATION (no layout shift)
                      if (showStars)
                        IgnorePointer(
                          child: Lottie.asset(
                            "assets/lottie/sparkel.json",
                            height: 400,
                            width: 400,
                            repeat: false,
                          ),
                        ),
                    ],
                  ),
                ),

                Positioned(
                  bottom: 30,
                  left: 15,
                  right: 15,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildDropBox(
                        type: "vegi",
                        title: "Vegetables",
                        emoji: "🥕",
                        color: Colors.blue,
                      ),
                      buildDropBox(
                        type: "fruit",
                        title: "Fruits",
                        emoji: "🍎",
                        color: Colors.purple,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildHalfCircleItems() {
    final size = MediaQuery.of(context).size;

    double radius = size.width * 0.36;
    double centerX = size.width / 2;
    double centerY = size.height * 0.35;

    int total = items.length;
    List<Widget> widgets = [];

    for (int i = 0; i < total; i++) {
      var item = items[i];
      if (item["matched"]) continue;

      double startAngle = pi;
      double endAngle = 2 * pi;

      double angle =
          startAngle + (endAngle - startAngle) * (i / (total - 1));

      double x = centerX + radius * cos(angle);
      double y = centerY + radius * sin(angle);

      widgets.add(
        Positioned(
          left: x - 37,
          top: y - 37,
          child: Draggable<Map>(
            data: item,
            feedback: Material(
              color: Colors.transparent,
              child: itemCard(item["emoji"]),
            ),
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: itemCard(item["emoji"]),
            ),
            child: itemCard(item["emoji"]),
          ),
        ),
      );
    }

    return widgets;
  }

  Widget itemCard(String emoji) {
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Text(emoji, style: TextStyle(fontSize: 42)),
      ),
    );
  }

  Widget buildDropBox({
    required String type,
    required String title,
    required String emoji,
    required Color color,
  }) {
    return DragTarget<Map>(
      onAcceptWithDetails: (details) async {
        Map item = details.data;

        if (item["type"] == type) {
          await handleCorrect(item);
        } else {
          await handleWrong();
        }
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: 160,
          height: 140,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: TextStyle(fontSize: 50)),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}