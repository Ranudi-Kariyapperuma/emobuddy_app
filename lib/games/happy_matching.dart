import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(
    MaterialApp(debugShowCheckedModeBanner: false, home: HappyMatchingGame()),
  );
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🎨 LEVEL THEMES — each level has its own vibe
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class LevelTheme {
  final String backgroundAsset; // e.g. "assets/bg/jungle.jpg"
  final List<Color> overlayColors;
  final Color accentColor;
  final Color cardColor;
  final Color cardSelectedColor;
  final Color cardMatchedColor;
  final String levelLabel;
  final String emoji;

  const LevelTheme({
    required this.backgroundAsset,
    required this.overlayColors,
    required this.accentColor,
    required this.cardColor,
    required this.cardSelectedColor,
    required this.cardMatchedColor,
    required this.levelLabel,
    required this.emoji,
  });
}

// Define one theme per level (cycles if levels exceed list)
const List<LevelTheme> kLevelThemes = [
  LevelTheme(
    backgroundAsset: 'assets/images/jungle.jpg',
    overlayColors: [Color(0xCC0D2B1A), Color(0x991B5E20)],
    accentColor: Color(0xFF76FF03),
    cardColor: Color(0xFFE8F5E9),
    cardSelectedColor: Color(0xFFA5D6A7),
    cardMatchedColor: Color(0xFF69F0AE),
    levelLabel: 'Jungle',
    emoji: '🌿',
  ),
  LevelTheme(
    backgroundAsset: 'assets/images/ocean.jpg',
    overlayColors: [Color(0xCC01263D), Color(0x990D47A1)],
    accentColor: Color(0xFF00E5FF),
    cardColor: Color(0xFFE3F2FD),
    cardSelectedColor: Color(0xFF90CAF9),
    cardMatchedColor: Color(0xFF40C4FF),
    levelLabel: 'Ocean',
    emoji: '🌊',
  ),
  LevelTheme(
    backgroundAsset: 'assets/images/volcano.jpg',
    overlayColors: [Color(0xCC3E0000), Color(0x99BF360C)],
    accentColor: Color(0xFFFF6D00),
    cardColor: Color(0xFFFBE9E7),
    cardSelectedColor: Color(0xFFFFAB91),
    cardMatchedColor: Color(0xFFFF6E40),
    levelLabel: 'Volcano',
    emoji: '🌋',
  ),
  LevelTheme(
    backgroundAsset: 'assets/images/galaxy.jpg',
    overlayColors: [Color(0xCC0A0020), Color(0x994A148C)],
    accentColor: Color(0xFFE040FB),
    cardColor: Color(0xFFF3E5F5),
    cardSelectedColor: Color(0xFFCE93D8),
    cardMatchedColor: Color(0xFFEA80FC),
    levelLabel: 'Galaxy',
    emoji: '🌌',
  ),
  LevelTheme(
    backgroundAsset: 'assets/images/snow.jpg',
    overlayColors: [Color(0xCC0B2340), Color(0x994FC3F7)],
    accentColor: Color(0xFFB3E5FC),
    cardColor: Color(0xFFE1F5FE),
    cardSelectedColor: Color(0xFF81D4FA),
    cardMatchedColor: Color(0xFF00B0FF),
    levelLabel: 'Arctic',
    emoji: '❄️',
  ),
];

LevelTheme themeForLevel(int level) =>
    kLevelThemes[(level - 1) % kLevelThemes.length];

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🔗 Line Model
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class MatchLine {
  final Offset start;
  final Offset end;
  final Color color;

  MatchLine(this.start, this.end, this.color);
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🎮 Main Game Widget
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
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

  // Wrong answer flash
  bool _wrongFlash = false;

  @override
  void initState() {
    super.initState();
    loadLevel();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void loadLevel() {
    int pairCount = (level + 2).clamp(3, allPairs.length);

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
    setState(() => selectedTopIndex = index);
  }

  void selectBottom(int index) {
    if (matchedBottom[index] || selectedTopIndex == null) return;

    String animal = topItems[selectedTopIndex!];
    String match = bottomItems[index];

    bool correct = currentPairs.any(
      (pair) => pair["animal"] == animal && pair["match"] == match,
    );

    if (correct) {
      final topBox =
          topKeys[selectedTopIndex!].currentContext!.findRenderObject()
              as RenderBox;
      final bottomBox =
          bottomKeys[index].currentContext!.findRenderObject() as RenderBox;

      final topPos = topBox.localToGlobal(Offset.zero);
      final bottomPos = bottomBox.localToGlobal(Offset.zero);

      final theme = themeForLevel(level);

      setState(() {
        matchedTop[selectedTopIndex!] = true;
        matchedBottom[index] = true;
        lines.add(MatchLine(
          topPos + Offset(topBox.size.width / 2, topBox.size.height),
          bottomPos + Offset(bottomBox.size.width / 2, 0),
          theme.accentColor,
        ));
        selectedTopIndex = null;
        score += 10;
      });

      checkLevelComplete();
    } else {
      setState(() {
        selectedTopIndex = null;
        score = (score - 2).clamp(0, 9999);
        _wrongFlash = true;
      });
      Future.delayed(Duration(milliseconds: 400), () {
        if (mounted) setState(() => _wrongFlash = false);
      });
    }
  }

  void checkLevelComplete() {
    if (matchedTop.every((e) => e)) {
      Future.delayed(Duration(milliseconds: 500), showLevelCompleteDialog);
    }
  }

  void showLevelCompleteDialog() {
    final theme = themeForLevel(level);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.overlayColors[0].withOpacity(0.98),
                theme.overlayColors[1].withOpacity(0.98),
              ],
            ),
            border: Border.all(color: theme.accentColor.withOpacity(0.6), width: 2),
            boxShadow: [
              BoxShadow(
                color: theme.accentColor.withOpacity(0.3),
                blurRadius: 32,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(theme.emoji, style: TextStyle(fontSize: 52)),
              SizedBox(height: 12),
              Text(
                "Level $level Complete!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 6),
              Text(
                "Amazing work!",
                style: TextStyle(color: Colors.white60, fontSize: 15),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: theme.accentColor.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, color: theme.accentColor, size: 22),
                    SizedBox(width: 8),
                    Text(
                      "Score: $score",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  level++;
                  loadLevel();
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.accentColor, theme.accentColor.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.accentColor.withOpacity(0.4),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Next Level",
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            letterSpacing: 0.4,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, color: Colors.black87, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🌄 Background
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildBackground(LevelTheme theme) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Level-specific background image
        Image.asset(
          theme.backgroundAsset,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D1B2A),
                  Color(0xFF1B263B),
                ],
              ),
            ),
          ),
        ),
        // Dark overlay with animated shimmer
        AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.overlayColors[0],
                    Color.lerp(
                      theme.overlayColors[1],
                      theme.overlayColors[0],
                      (sin(_controller.value * 2 * pi) * 0.5 + 0.5),
                    )!,
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🃏 Card Item
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget buildCardItem(
    String image,
    bool matched,
    bool selected,
    VoidCallback onTap,
    GlobalKey key,
    LevelTheme theme,
  ) {
    Color bgColor = matched
        ? theme.cardMatchedColor
        : selected
            ? theme.cardSelectedColor
            : theme.cardColor;

    return GestureDetector(
      key: key,
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        transform: Matrix4.identity()
          ..scale(selected ? 1.06 : matched ? 1.0 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? theme.accentColor
                : matched
                    ? theme.accentColor.withOpacity(0.6)
                    : Colors.white.withOpacity(0.25),
            width: selected ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? theme.accentColor.withOpacity(0.45)
                  : matched
                      ? theme.accentColor.withOpacity(0.25)
                      : Colors.black.withOpacity(0.25),
              blurRadius: selected ? 16 : 8,
              offset: Offset(0, 4),
              spreadRadius: selected ? 2 : 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  "assets/images/$image",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            if (matched)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: theme.accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_rounded, size: 12, color: Colors.black87),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🔲 Grid
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget buildGrid(
    List<String> items,
    List<bool> matched,
    bool isTop,
    LevelTheme theme,
  ) {
    int crossCount = items.length <= 3 ? 3 : 3;
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 4),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        return buildCardItem(
          items[index],
          matched[index],
          isTop && selectedTopIndex == index,
          () => isTop ? selectTop(index) : selectBottom(index),
          isTop ? topKeys[index] : bottomKeys[index],
          theme,
        );
      },
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🏗️ Build
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  @override
  Widget build(BuildContext context) {
    final theme = themeForLevel(level);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // — Background
          Positioned.fill(child: _buildBackground(theme)),

          // — Connecting lines
          CustomPaint(
            size: Size.infinite,
            painter: LinePainter(lines),
          ),

          // — Wrong flash overlay
          if (_wrongFlash)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _wrongFlash ? 0.18 : 0,
                  duration: Duration(milliseconds: 200),
                  child: Container(color: Colors.red),
                ),
              ),
            ),

          // — Main UI
          SafeArea(
            child: Column(
              children: [
                // ── TOP HEADER BAR
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: theme.accentColor.withOpacity(0.35),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Back button
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white24,
                                width: 1,
                              ),
                            ),
                            child: Icon(Icons.arrow_back_ios_new_rounded,
                                color: Colors.white, size: 16),
                          ),
                        ),
                        SizedBox(width: 12),

                        // Game title
                        Expanded(
                          child: Row(
                            children: [
                              Text("🎯", style: TextStyle(fontSize: 20)),
                              SizedBox(width: 6),
                              Text(
                                "MatchBox",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Score badge
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.accentColor.withOpacity(0.85),
                                theme.accentColor.withOpacity(0.55),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: theme.accentColor.withOpacity(0.4),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star_rounded,
                                  color: Colors.black87, size: 16),
                              SizedBox(width: 5),
                              Text(
                                "$score",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── LEVEL BADGE
                SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: theme.accentColor.withOpacity(0.5),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(theme.emoji,
                              style: TextStyle(fontSize: 16)),
                          SizedBox(width: 8),
                          Text(
                            "Level $level · ${theme.levelLabel}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // ── GAME AREA
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16, 18, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Section label: Animals
                        _sectionLabel("Animals", theme),
                        SizedBox(height: 10),

                        buildGrid(topItems, matchedTop, true, theme),

                        SizedBox(height: 20),

                        // Divider with arrow hint
                        _connectDivider(theme),

                        SizedBox(height: 20),

                        // Section label: Food
                        _sectionLabel("Food & Items", theme),
                        SizedBox(height: 10),

                        buildGrid(bottomItems, matchedBottom, false, theme),
                      ],
                    ),
                  ),
                ),

                // ── BOTTOM HINT BAR
                _buildBottomHint(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label, LevelTheme theme) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: theme.accentColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _connectDivider(LevelTheme theme) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  theme.accentColor.withOpacity(0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: theme.accentColor.withOpacity(0.4), width: 1),
          ),
          child: Row(
            children: [
              Icon(Icons.swap_vert_rounded, color: theme.accentColor, size: 16),
              SizedBox(width: 4),
              Text(
                "Match",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  theme.accentColor.withOpacity(0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomHint(LevelTheme theme) {
    int matched = matchedTop.where((e) => e).length;
    int total = matchedTop.length;
    double progress = total == 0 ? 0 : matched / total;

    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.accentColor.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedTopIndex != null
                    ? "✨ Now tap a matching item below"
                    : "👆 Tap an animal to start",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "$matched / $total",
                style: TextStyle(
                  color: theme.accentColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(theme.accentColor),
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🎨 Line Painter — gradient lines with glow dots
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class LinePainter extends CustomPainter {
  final List<MatchLine> lines;

  LinePainter(this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    for (var line in lines) {
      // Glow effect
      final glowPaint = Paint()
        ..color = line.color.withOpacity(0.25)
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawLine(line.start, line.end, glowPaint);

      // Main line
      final paint = Paint()
        ..shader = LinearGradient(
          colors: [line.color.withOpacity(0.9), line.color.withOpacity(0.6)],
        ).createShader(Rect.fromPoints(line.start, line.end))
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(line.start, line.end, paint);

      // Dot at start
      canvas.drawCircle(
        line.start,
        5,
        Paint()..color = line.color,
      );
      // Dot at end
      canvas.drawCircle(
        line.end,
        5,
        Paint()..color = line.color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant LinePainter old) => old.lines != lines;
}
