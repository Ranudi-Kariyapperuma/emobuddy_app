import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(
    MaterialApp(debugShowCheckedModeBanner: false, home: HappyMatchingGame()),
  );
}

// 🔗 Line Model
class MatchLine {
  final Offset start;
  final Offset end;

  MatchLine(this.start, this.end);
}

class HappyMatchingGame extends StatefulWidget {
  @override
  _HappyMatchingGameState createState() => _HappyMatchingGameState();
}

class _HappyMatchingGameState extends State<HappyMatchingGame>
    with SingleTickerProviderStateMixin {
  int level = 1;
  int score = 0;

  int? selectedTopIndex;

  late AnimationController _controller;

  List<MatchLine> lines = [];
  List<GlobalKey> topKeys = [];
  List<GlobalKey> bottomKeys = [];

  List<Map<String, String>> allPairs = [
    {"animal": "lion.jpg", "match": "meat.jpeg"},
    {"animal": "cat.jpeg", "match": "fish.jpeg"},
    {"animal": "dog.jpeg", "match": "bone.jpeg"},
    {"animal": "frog.jpeg", "match": "fly.jpeg"},
    {"animal": "monkey.jpeg", "match": "banana.jpeg"},
    {"animal": "scooter.jpg", "match": "fuel.jpg"},
  ];

  List<Map<String, String>> currentPairs = [];

  List<String> topItems = [];
  List<String> bottomItems = [];

  List<bool> matchedTop = [];
  List<bool> matchedBottom = [];

  @override
  void initState() {
    super.initState();
    loadLevel();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void loadLevel() {
    int pairCount = level + 2;

    currentPairs = List.from(allPairs)..shuffle();
    currentPairs = currentPairs.take(pairCount).toList();

    topItems = currentPairs.map((e) => e["animal"]!).toList();
    bottomItems = currentPairs.map((e) => e["match"]!).toList();

    topItems.shuffle();
    bottomItems.shuffle();

    matchedTop = List.filled(topItems.length, false);
    matchedBottom = List.filled(bottomItems.length, false);

    topKeys = List.generate(topItems.length, (_) => GlobalKey());
    bottomKeys = List.generate(bottomItems.length, (_) => GlobalKey());

    lines.clear();
    selectedTopIndex = null;

    setState(() {});
  }

  void selectTop(int index) {
    if (matchedTop[index]) return;

    setState(() {
      selectedTopIndex = index;
    });
  }

  void selectBottom(int index) {
    if (matchedBottom[index] || selectedTopIndex == null) return;

    String animal = topItems[selectedTopIndex!];
    String match = bottomItems[index];

    bool correct = currentPairs.any(
      (pair) => pair["animal"] == animal && pair["match"] == match,
    );

    if (correct) {
      // 🔥 DRAW LINE IMMEDIATELY
      final topBox =
          topKeys[selectedTopIndex!].currentContext!.findRenderObject()
              as RenderBox;
      final bottomBox =
          bottomKeys[index].currentContext!.findRenderObject() as RenderBox;

      final topPos = topBox.localToGlobal(Offset.zero);
      final bottomPos = bottomBox.localToGlobal(Offset.zero);

      setState(() {
        matchedTop[selectedTopIndex!] = true;
        matchedBottom[index] = true;

        lines.add(
          MatchLine(
            topPos + Offset(topBox.size.width / 2, topBox.size.height),
            bottomPos + Offset(bottomBox.size.width / 2, 0),
          ),
        );

        selectedTopIndex = null;
        score += 10;
      });

      checkLevelComplete();
    } else {
      setState(() {
        selectedTopIndex = null;
        score -= 2;
      });
    }
  }

  void checkLevelComplete() {
    if (matchedTop.every((e) => e)) {
      showLevelCompleteDialog();
    }
  }

  void showLevelCompleteDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("🎉 Level $level Complete!"),
        content: Text("Score: $score"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              level++;
              loadLevel();
            },
            child: Text("Next Level 🚀"),
          ),
        ],
      ),
    );
  }

  // 🌈 Background
  Widget animatedBackground() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(Colors.blue, Colors.purple, _controller.value)!,
                Color.lerp(Colors.orange, Colors.pink, _controller.value)!,
              ],
            ),
          ),
        );
      },
    );
  }

  // 🎴 Card
  Widget buildCardItem(
    String image,
    bool matched,
    bool selected,
    VoidCallback onTap,
    GlobalKey key,
  ) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: matched
              ? Colors.greenAccent
              : selected
              ? Colors.orangeAccent
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Image.asset("assets/images/$image"),
        ),
      ),
    );
  }

  Widget buildGrid(List<String> items, List<bool> matched, bool isTop) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        return buildCardItem(
          items[index],
          matched[index],
          isTop && selectedTopIndex == index,
          () => isTop ? selectTop(index) : selectBottom(index),
          isTop ? topKeys[index] : bottomKeys[index],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          animatedBackground(),

          // 🔗 LINES
          CustomPaint(size: Size.infinite, painter: LinePainter(lines)),

          SafeArea(
            child: Column(
              children: [
                // 🎮 MATCHBOX HEADER
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 230, 193, 248),
                          Color.fromARGB(255, 127, 171, 248),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            // 🎮 Title
                            Row(
                              children: [
                                Text("🎯", style: TextStyle(fontSize: 22)),
                                SizedBox(width: 8),
                                Text(
                                  "MatchBox",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // ⭐ Score Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text("⭐", style: TextStyle(fontSize: 16)),
                              SizedBox(width: 4),
                              Text(
                                "$score",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            "Level $level",
                            style: TextStyle(
                              fontSize: 26,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 20),

                          buildGrid(topItems, matchedTop, true),

                          SizedBox(height: 30),

                          buildGrid(bottomItems, matchedBottom, false),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 🎨 Line Painter
class LinePainter extends CustomPainter {
  final List<MatchLine> lines;

  LinePainter(this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4;

    for (var line in lines) {
      canvas.drawLine(line.start, line.end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
