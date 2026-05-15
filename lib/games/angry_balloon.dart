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
  Color shadowColor;
  double swayOffset;
  double swaySpeed;
  bool isPopping;

  Balloon(this.position, this.letter, this.color, this.shadowColor)
      : swayOffset = Random().nextDouble() * 2 * pi,
        swaySpeed = 0.5 + Random().nextDouble() * 0.5,
        isPopping = false;
}

class BalloonLearningGame extends StatefulWidget {
  @override
  _BalloonLearningGameState createState() => _BalloonLearningGameState();
}

class _BalloonLearningGameState extends State<BalloonLearningGame>
    with TickerProviderStateMixin {
  final player = AudioPlayer();
  final Random random = Random();

  List<Balloon> balloons = [];
  List<_PopParticle> particles = [];

  int score = 0;
  int level = 1;

  String gameMode = "free";
  String targetLetter = "A";
  int currentIndex = 0;

  List<String> letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split("");

  // Rich balloon color pairs: [main, shadow]
  List<List<Color>> balloonColors = [
    [Color(0xFFFF4F6D), Color(0xFFB71C1C)],
    [Color(0xFF2979FF), Color(0xFF0D47A1)],
    [Color(0xFF00C853), Color(0xFF1B5E20)],
    [Color(0xFFFF6D00), Color(0xFFE65100)],
    [Color(0xFFAA00FF), Color(0xFF4A148C)],
    [Color(0xFFFF4081), Color(0xFF880E4F)],
    [Color(0xFF00BCD4), Color(0xFF006064)],
    [Color(0xFFFFD600), Color(0xFFF57F17)],
  ];

  late AnimationController _floatController;
  late AnimationController _bgController;
  late AnimationController _scoreController;
  late Animation<double> _scoreAnim;

  int? _lastScoreGain;
  Offset? _lastPopPos;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat();

    _bgController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
    )..repeat();

    _scoreController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );
    _scoreAnim = CurvedAnimation(parent: _scoreController, curve: Curves.elasticOut);

    generateLevel();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _bgController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  void generateLevel() {
    balloons.clear();
    particles.clear();

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
    int columns = 4;
    double spacingX = screenWidth / columns;
    double spacingY = 110;

    for (int i = 0; i < letters.length; i++) {
      int row = i ~/ columns;
      int col = i % columns;

      final colorPair = balloonColors[random.nextInt(balloonColors.length)];

      balloons.add(
        Balloon(
          Offset(
            col * spacingX + 16 + random.nextDouble() * 10,
            row * spacingY + 130,
          ),
          letters[i],
          colorPair[0],
          colorPair[1],
        ),
      );
    }

    if (gameMode == "target") {
      targetLetter = balloons[random.nextInt(balloons.length)].letter;
    }

    setState(() {});
  }

  Future<void> playLetterSound(String letter) async {
    try {
      await player.play(AssetSource("sounds/$letter.wav"));
    } catch (_) {}
  }

  void _spawnParticles(Offset pos, Color color) {
    final rng = Random();
    for (int i = 0; i < 12; i++) {
      particles.add(_PopParticle(
        pos: pos,
        vel: Offset(
          (rng.nextDouble() - 0.5) * 200,
          (rng.nextDouble() - 0.8) * 200,
        ),
        color: color,
        radius: 5 + rng.nextDouble() * 6,
      ));
    }
  }

  void popBalloon(int index) {
    String letter = balloons[index].letter;
    Offset pos = balloons[index].position + Offset(35, 45);
    Color color = balloons[index].color;

    playLetterSound(letter);

    if (gameMode == "free") {
      setState(() {
        _spawnParticles(pos, color);
        balloons.removeAt(index);
        score += 5;
        _lastScoreGain = 5;
        _lastPopPos = pos;
      });
      _scoreController.forward(from: 0);
    } else if (gameMode == "target") {
      if (letter == targetLetter) {
        setState(() {
          _spawnParticles(pos, color);
          balloons.removeAt(index);
          score += 10;
          _lastScoreGain = 10;
          _lastPopPos = pos;
        });
        _scoreController.forward(from: 0);
        if (balloons.isNotEmpty) {
          targetLetter = balloons[random.nextInt(balloons.length)].letter;
        }
      } else {
        setState(() {
          score -= 2;
          _lastScoreGain = -2;
          _lastPopPos = pos;
        });
        _scoreController.forward(from: 0);
      }
    } else if (gameMode == "order") {
      String expected = String.fromCharCode(65 + currentIndex);
      if (letter == expected) {
        setState(() {
          _spawnParticles(pos, color);
          balloons.removeAt(index);
          score += 10;
          currentIndex++;
          _lastScoreGain = 10;
          _lastPopPos = pos;
        });
        _scoreController.forward(from: 0);
      } else {
        setState(() {
          score -= 2;
          _lastScoreGain = -2;
          _lastPopPos = pos;
        });
        _scoreController.forward(from: 0);
      }
    }

    if (balloons.isEmpty) {
      level++;
      Future.delayed(Duration(milliseconds: 800), () {
        generateLevel();
      });
    }
  }

  // ☁️ Rich Sky Background
  Widget buildBackground() {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1A6FA8),
                Color(0xFF3AABDD),
                Color(0xFF87CEEB),
                Color(0xFFB0E2FF),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: CustomPaint(
            painter: _SkyPainter(_bgController.value),
            child: Container(),
          ),
        );
      },
    );
  }

  // ☁️ Cloud Widget
  Widget buildCloud(double top, double leftBase, double speed, double size) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, _) {
        double offset = (_bgController.value * speed * 400) % (MediaQuery.of(context).size.width + 200) - 100;
        return Positioned(
          top: top,
          left: leftBase + offset,
          child: _CloudWidget(size: size),
        );
      },
    );
  }

  // 🌿 Ground strip
  Widget buildGround() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 12, offset: Offset(0, -4))],
        ),
        child: Center(
          child: Text(
            "🌸  🌼  🌺  🌸  🌼",
            style: TextStyle(fontSize: 22),
          ),
        ),
      ),
    );
  }

  // 🎈 Balloon Widget with float animation
  Widget buildBalloon(Balloon balloon, int index) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, _) {
        double sway = sin(_floatController.value * 2 * pi * balloon.swaySpeed + balloon.swayOffset) * 5;
        double floatY = sin(_floatController.value * 2 * pi * 0.7 + balloon.swayOffset) * 4;

        return Positioned(
          left: balloon.position.dx + sway,
          top: balloon.position.dy + floatY,
          child: GestureDetector(
            onTap: () => popBalloon(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Balloon body
                Container(
                  width: 68,
                  height: 82,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        balloon.color.withOpacity(0.95),
                        balloon.shadowColor,
                      ],
                      center: Alignment(-0.3, -0.4),
                      radius: 0.9,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: balloon.shadowColor.withOpacity(0.5),
                        blurRadius: 14,
                        offset: Offset(4, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Shine highlight
                      Positioned(
                        top: 10,
                        left: 12,
                        child: Container(
                          width: 18,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          balloon.letter,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Colors.black38, blurRadius: 4, offset: Offset(1, 2)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Knot
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: balloon.shadowColor,
                    shape: BoxShape.circle,
                  ),
                ),
                // String
                CustomPaint(
                  painter: _StringPainter(
                    _floatController.value * 2 * pi * balloon.swaySpeed + balloon.swayOffset,
                  ),
                  size: Size(14, 28),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✨ Pop particles
  Widget buildParticles() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, _) {
        return Stack(
          children: particles.map((p) {
            p.update(0.016);
            if (p.life <= 0) return SizedBox.shrink();
            return Positioned(
              left: p.pos.dx - p.radius,
              top: p.pos.dy - p.radius,
              child: Opacity(
                opacity: p.life.clamp(0, 1),
                child: Container(
                  width: p.radius * 2,
                  height: p.radius * 2,
                  decoration: BoxDecoration(
                    color: p.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // 💫 Floating score label
  Widget buildScorePopup() {
    if (_lastScoreGain == null || _lastPopPos == null) return SizedBox.shrink();
    return AnimatedBuilder(
      animation: _scoreAnim,
      builder: (context, _) {
        double t = _scoreAnim.value;
        return Positioned(
          left: _lastPopPos!.dx - 20,
          top: _lastPopPos!.dy - 30 - t * 40,
          child: Opacity(
            opacity: (1 - (_scoreController.value)).clamp(0, 1),
            child: Text(
              _lastScoreGain! > 0 ? "+$_lastScoreGain" : "$_lastScoreGain",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: _lastScoreGain! > 0 ? Color(0xFF76FF03) : Colors.redAccent,
                shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
              ),
            ),
          ),
        );
      },
    );
  }

  // 🎮 Header
  Widget buildHeader() {
    String modeLabel = gameMode == "free"
        ? "Pop All 🎈"
        : gameMode == "target"
            ? "Find: $targetLetter 🎯"
            : "A → Z 🔤";

    Color modeBg = gameMode == "free"
        ? Color(0xFF00BCD4)
        : gameMode == "target"
            ? Color(0xFFFF6D00)
            : Color(0xFF7C4DFF);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 6, 12, 0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 14, offset: Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              // Back
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Color(0xFFE3F2FD),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF1565C0)),
                ),
              ),
              SizedBox(width: 8),
              // Title
              Text(
                "Learn & Pop",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A237E),
                  letterSpacing: 0.5,
                ),
              ),
              Spacer(),
              // Mode chip
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: modeBg,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: modeBg.withOpacity(0.4), blurRadius: 8)],
                ),
                child: Text(
                  modeLabel,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              SizedBox(width: 10),
              // Score
              _StatChip(icon: "⭐", value: "$score", color: Color(0xFFFFC107)),
              SizedBox(width: 8),
              // Level
              _StatChip(icon: "🏆", value: "Lv $level", color: Color(0xFF7C4DFF)),
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
          buildCloud(60, -60, 0.04, 1.3),
          buildCloud(110, 180, 0.025, 1.0),
          buildCloud(30, 100, 0.06, 0.8),
          buildGround(),
          ...balloons.asMap().entries.map((e) => buildBalloon(e.value, e.key)),
          buildParticles(),
          buildScorePopup(),
          buildHeader(),
        ],
      ),
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String icon;
  final String value;
  final Color color;
  const _StatChip({required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: Row(
        children: [
          Text(icon, style: TextStyle(fontSize: 13)),
          SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF1A237E),
            ),
          ),
        ],
      ),
    );
  }
}

class _CloudWidget extends StatelessWidget {
  final double size;
  const _CloudWidget({required this.size});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.88,
      child: Transform.scale(
        scale: size,
        child: SizedBox(
          width: 120,
          height: 60,
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 10,
                child: Container(
                  width: 100,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 25,
                child: Container(
                  width: 50,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 55,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Curvy string painter
class _StringPainter extends CustomPainter {
  final double phase;
  _StringPainter(this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.shade400
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.quadraticBezierTo(
      size.width / 2 + sin(phase) * 4,
      size.height / 2,
      size.width / 2,
      size.height,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_StringPainter old) => old.phase != phase;
}

// Sky painter: sun + distant birds
class _SkyPainter extends CustomPainter {
  final double t;
  _SkyPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    // Sun glow
    final sunPaint = Paint()
      ..shader = RadialGradient(
        colors: [Color(0xFFFFF176).withOpacity(0.7), Colors.transparent],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.8, 80), radius: 90));
    canvas.drawCircle(Offset(size.width * 0.8, 80), 90, sunPaint);

    // Sun disk
    canvas.drawCircle(
      Offset(size.width * 0.8, 80),
      32,
      Paint()..color = Color(0xFFFFF176).withOpacity(0.85),
    );

    // Birds
    final birdPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 5; i++) {
      double bx = (size.width * (i * 0.18 + t * 0.05)) % size.width;
      double by = 70 + i * 22.0;
      _drawBird(canvas, birdPaint, Offset(bx, by), 10 + i * 2.0);
    }
  }

  void _drawBird(Canvas canvas, Paint p, Offset pos, double w) {
    final path = Path();
    path.moveTo(pos.dx - w, pos.dy);
    path.quadraticBezierTo(pos.dx - w / 2, pos.dy - 5, pos.dx, pos.dy);
    path.quadraticBezierTo(pos.dx + w / 2, pos.dy - 5, pos.dx + w, pos.dy);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_SkyPainter old) => old.t != t;
}

// Pop particle
class _PopParticle {
  Offset pos;
  Offset vel;
  Color color;
  double radius;
  double life = 1.0;

  _PopParticle({
    required this.pos,
    required this.vel,
    required this.color,
    required this.radius,
  });

  void update(double dt) {
    pos += vel * dt;
    vel = Offset(vel.dx * 0.92, vel.dy * 0.92 + 120 * dt); // gravity
    life -= dt * 1.8;
  }
}
