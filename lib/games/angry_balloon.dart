import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(
    MaterialApp(debugShowCheckedModeBanner: false, home: BalloonLearningGame()),
  );
}

class Balloon {
  Offset position;
  String letter;
  Color color;

  Balloon(this.position, this.letter, this.color);
}

class BalloonLearningGame extends StatefulWidget {
  @override
  _BalloonLearningGameState createState() => _BalloonLearningGameState();
}

class _BalloonLearningGameState extends State<BalloonLearningGame> {
  final player = AudioPlayer();
  final Random random = Random();

  List<Balloon> balloons = [];

  int score = 0;
  int level = 1;

  String gameMode = "free";
  String targetLetter = "A";
  int currentIndex = 0;

  List<String> letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split("");

  List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    generateLevel();
  }

  void generateLevel() {
    balloons.clear();

    // 🎯 Decide mode based on level
    if (level == 1) {
      gameMode = "free";
    } else if (level == 2) {
      gameMode = "target";
    } else if (level == 3) {
      gameMode = "order";
      currentIndex = 0;
    } else {
      gameMode = "target";
    }

    letters.shuffle();

    double screenWidth = 360;
    int columns = 5;
    double spacingX = screenWidth / columns;
    double spacingY = 100;

    for (int i = 0; i < letters.length; i++) {
      int row = i ~/ columns;
      int col = i % columns;

      balloons.add(
        Balloon(
          Offset(col * spacingX + 20, row * spacingY + 120),
          letters[i],
          colors[random.nextInt(colors.length)],
        ),
      );
    }

    // 🎯 Set target for level 2+
    if (gameMode == "target") {
      targetLetter = letters[random.nextInt(letters.length)];
    }

    setState(() {});
  }

  Future<void> playLetterSound(String letter) async {
    await player.play(AssetSource("sounds/$letter.wav"));
  }

  void popBalloon(int index) {
    String letter = balloons[index].letter;

    playLetterSound(letter);

    if (gameMode == "free") {
      // 🎈 Level 1
      setState(() {
        balloons.removeAt(index);
        score += 5;
      });
    } else if (gameMode == "target") {
      // 🎯 Level 2+
      if (letter == targetLetter) {
        setState(() {
          balloons.removeAt(index);
          score += 10;
        });

        if (balloons.isNotEmpty) {
          targetLetter = balloons[random.nextInt(balloons.length)].letter;
        }
      } else {
        score -= 2;
      }
    } else if (gameMode == "order") {
      // 🔤 Level 3
      String expected = String.fromCharCode(65 + currentIndex);

      if (letter == expected) {
        setState(() {
          balloons.removeAt(index);
          score += 10;
          currentIndex++;
        });
      } else {
        score -= 2;
      }
    }

    // 🎯 Next level
    if (balloons.isEmpty) {
      level++;
      Future.delayed(Duration(milliseconds: 600), () {
        generateLevel();
      });
    }
  }

  // 🌤 Background
  Widget buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF87CEFA), Color(0xFFE0F7FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  // ☁️ Cloud
  Widget cloud(double top, double left) {
    return Positioned(
      top: top,
      left: left,
      child: Icon(Icons.cloud, size: 80, color: Colors.white70),
    );
  }

  // 🎈 Balloon UI
  Widget buildBalloon(Balloon balloon, int index) {
    return Positioned(
      left: balloon.position.dx,
      top: balloon.position.dy,
      child: GestureDetector(
        onTap: () => popBalloon(index),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 90,
              decoration: BoxDecoration(
                color: balloon.color,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
              ),
              child: Center(
                child: Text(
                  balloon.letter,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Container(width: 2, height: 20, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  // 🎮 Header
  Widget buildHeader() {
  return SafeArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: Colors.black12)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 🔙 Back Button + Title
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, size: 20),
                  onPressed: () {
                    Navigator.pop(context); // go back
                  },
                ),
                Text(
                  "🔤 Learn & Pop",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            // 🎯 Game Mode Text
            Text(
              gameMode == "free"
                  ? "Pop All 🎈"
                  : gameMode == "target"
                      ? "Find: $targetLetter 🎯"
                      : "A → Z 🔤",
              style: TextStyle(fontWeight: FontWeight.bold),
               overflow: TextOverflow.ellipsis,
            ),

            // ⭐ Score + Level
            Row(
              children: [
                Text("⭐ $score"),
                SizedBox(width: 15),
                Text("Level $level"),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          buildBackground(),
          cloud(80, 40),
          cloud(150, 250),

          ...balloons.asMap().entries.map((entry) {
            return buildBalloon(entry.value, entry.key);
          }).toList(),

          buildHeader(),
        ],
      ),
    );
  }
}
