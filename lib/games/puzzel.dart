import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

// ─────────────────────────────────────────────
// TTS Service
// ─────────────────────────────────────────────
class TTSService {
  final FlutterTts tts = FlutterTts();

  Future<void> init() async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.45);
  }

  Future<void> speak(String text) async {
    await tts.stop();
    await tts.speak(text);
  }

  Future<void> stop() async {
    await tts.stop();
  }
}

// ─────────────────────────────────────────────
// Level Config
// Each level has its own image, animal name,
// grid dimensions, and piece count.
//
// Level 1 → 4 pieces  (2 cols × 2 rows, all 4 slots used)
// Level 2 → 5 pieces  (3 cols × 2 rows, 5 of 6 slots used)
// Level 3 → 6 pieces  (3 cols × 2 rows, all 6 slots used)
// ─────────────────────────────────────────────
class LevelConfig {
  final String imagePath;
  final String animalName;
  final int cols;
  final int rows;
  final int totalPieces;
  final String backgroundPath;

  const LevelConfig({
    required this.imagePath,
    required this.animalName,
    required this.cols,
    required this.rows,
    required this.totalPieces,
    required this.backgroundPath, 
  });
}

// ── CONFIGURE YOUR IMAGES HERE ──────────────────
// Replace the imagePath values with your actual asset paths.
const List<LevelConfig> kLevels = [
  LevelConfig(
    imagePath: 'assets/images/puzzel1.jpg', // 🔁 your image
    animalName: 'Rabit',
    cols: 2,
    rows: 2,
    totalPieces: 4,
    backgroundPath: 'assets/images/b1.jpg',
  ),
  LevelConfig(
    imagePath: 'assets/images/puzzel2.jpg', // 🔁 your image
    animalName: 'Raino',
    cols: 2,
    rows: 2,
    totalPieces: 4,
    backgroundPath: 'assets/images/b2.jpg',
  ),
  LevelConfig(
    imagePath: 'assets/images/puzzel3.jpg', // 🔁 your image
    animalName: 'Giraffe',
    cols: 2,
    rows: 2,
    totalPieces: 4,
    backgroundPath: 'assets/images/b3.jpg', 
  ),
];

// ─────────────────────────────────────────────
// Feedback messages
// ─────────────────────────────────────────────
const List<String> kWrongMessages = [
  "Try Again",
  "Good Try",
  "Keep Going",
  "Almost",
];

const List<String> kCorrectMessages = [
  "Great Job!",
  "Amazing!",
  "Awesome!",
  "Fantastic!",
  "Excellent!",
];

// Fallback block colours shown when asset image is missing
const List<Color> kFallbackColors = [
  Color(0xFF388E3C),
  Color(0xFF1976D2),
  Color(0xFFE64A19),
  Color(0xFF7B1FA2),
  Color(0xFF00838F),
  Color(0xFFF57F17),
];

// ─────────────────────────────────────────────
// Puzzle Piece model
// ─────────────────────────────────────────────
class PuzzlePiece {
  final int index; // correct slot index (0-based, left→right, top→bottom)
  final int row;
  final int col;
  bool isPlaced;

  PuzzlePiece({
    required this.index,
    required this.row,
    required this.col,
    this.isPlaced = false,
  });
}

// ─────────────────────────────────────────────
// Main Puzzle Screen
// ─────────────────────────────────────────────
class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen>
    with TickerProviderStateMixin {
  final TTSService _tts = TTSService();
  final Random _random = Random();

  int _currentLevel = 0;
  LevelConfig get _cfg => kLevels[_currentLevel];

  // ── Puzzle state ──────────────────────────────
  late List<PuzzlePiece> _pieces;
  late List<PuzzlePiece> _trayPieces;
  // Length = cols × rows.
  // null  → empty slot (accepts drops)
  // -1    → blocked slot (level 2's unused 6th slot)
  // >= 0  → index of placed piece
  late List<int?> _boardSlots;

  // ── Feedback ──────────────────────────────────
  String _feedbackText = '';
  bool _showFeedback = false;
  bool _isCorrect = false;

  // ── Completion ────────────────────────────────
  bool _showStars = false;
  bool _levelComplete = false;

  // ── Animation controllers ─────────────────────
  late AnimationController _feedbackCtrl;
  late AnimationController _starsCtrl;
  late AnimationController _shakeCtrl;
  late Animation<double> _feedbackAnim;
  late Animation<double> _starsAnim;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _tts.init();

    _feedbackCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _feedbackAnim = CurvedAnimation(
      parent: _feedbackCtrl,
      curve: Curves.elasticOut,
    );

    _starsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _starsAnim = CurvedAnimation(parent: _starsCtrl, curve: Curves.easeOut);

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -9.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -9.0, end: 9.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 9.0, end: -9.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -9.0, end: 0.0), weight: 1),
    ]).animate(_shakeCtrl);

    _initLevel();
  }

  // ── Level initialisation ──────────────────────
  void _initLevel() {
    final cfg = _cfg;
    final slotCount = cfg.cols * cfg.rows;

    // Mark extra slots as blocked (-1) for 5-piece level
    _boardSlots = List.generate(
      slotCount,
      (i) => i >= cfg.totalPieces ? -1 : null,
    );

    _pieces = List.generate(cfg.totalPieces, (i) {
      return PuzzlePiece(index: i, row: i ~/ cfg.cols, col: i % cfg.cols);
    });

    _trayPieces = List.from(_pieces)..shuffle(_random);

    _showFeedback = false;
    _showStars = false;
    _levelComplete = false;
    _feedbackText = '';

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _tts.speak(
          "Level ${_currentLevel + 1}! Build the ${cfg.animalName} puzzle!",
        );
      }
    });
  }

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    _starsCtrl.dispose();
    _shakeCtrl.dispose();
    _tts.stop();
    super.dispose();
  }

  // ── Drop logic ────────────────────────────────
  void _onDrop(PuzzlePiece piece, int slotIndex) {
    final current = _boardSlots[slotIndex];
    if (current != null || _levelComplete) return; // occupied / blocked / done

    if (piece.index == slotIndex) {
      // ✅ Correct
      setState(() {
        _boardSlots[slotIndex] = piece.index;
        _trayPieces.removeWhere((p) => p.index == piece.index);
        piece.isPlaced = true;
        _isCorrect = true;
        _feedbackText =
            kCorrectMessages[_random.nextInt(kCorrectMessages.length)];
        _showFeedback = true;
      });
      _feedbackCtrl.forward(from: 0);
      _tts.speak(_feedbackText);
      _checkComplete();
    } else {
      // ❌ Wrong
      setState(() {
        _isCorrect = false;
        _feedbackText = kWrongMessages[_random.nextInt(kWrongMessages.length)];
        _showFeedback = true;
      });
      _feedbackCtrl.forward(from: 0);
      _shakeCtrl.forward(from: 0);
      _tts.speak(_feedbackText);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showFeedback = false);
      });
    }
  }

  void _checkComplete() {
    if (_trayPieces.isEmpty) {
      setState(() {
        _levelComplete = true;
        _showStars = true;
      });
      _starsCtrl.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 400), () {
        final isLast = _currentLevel == kLevels.length - 1;
        _tts.speak(
          isLast
              ? "You finished all levels! You are a puzzle star!"
              : "You completed level ${_currentLevel + 1}! Get ready for the next one!",
        );
      });
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showFeedback = false);
      });
    }
  }

  void _nextLevel() {
    if (_currentLevel < kLevels.length - 1) {
      setState(() {
        _currentLevel++;
        _initLevel();
      });
    }
  }

  void _restartLevel() => setState(_initLevel);

  // ── Build ─────────────────────────────────────
  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.transparent,
    extendBodyBehindAppBar: true,
    body: Stack(
      children: [
        _buildBg(),                              // ← full screen, behind everything
        SafeArea(
          top: false,                            // ← let bg go behind status bar
          child: Column(
            children: [
              _buildTopBar(),
              const SizedBox(height: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 4,
                        child: AnimatedBuilder(
                          animation: _shakeAnim,
                          builder: (_, child) => Transform.translate(
                            offset: Offset(_shakeAnim.value, 0),
                            child: child,
                          ),
                          child: _buildBoard(),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(height: 120, child: _buildTray()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
        if (_showFeedback) _buildFeedback(),
        if (_showStars) _buildComplete(),
      ],
    ),
  );
}

  Widget _buildBg() {
  return Positioned.fill(
    child: Stack(
      children: [
        // Background image for current level
        Image.asset(
          _cfg.backgroundPath,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => Container(
            color: const Color.fromARGB(255, 255, 255, 255), // fallback if image missing
          ),
        ),
        // Dark overlay so puzzle stays readable
        Container(color: const Color.fromARGB(255, 166, 233, 255).withOpacity(0.35)),
        // Original bubbles on top
        CustomPaint(painter: _BubblePainter()),
      ],
    ),
  );
}
  // ── Top bar ───────────────────────────────────
 Widget _buildTopBar() {
  return Padding(
    padding: EdgeInsets.only(
      top: MediaQuery.of(context).padding.top + 6,  // ← pushes below status bar
      left: 14,
      right: 14,
      bottom: 10,
    ),
    child: Row(
      children: [
        _circleBtn(
          Icons.arrow_back_rounded,
          bg: Colors.transparent,        // ← no background
          iconColor: Colors.white,
          onTap: () {
            _tts.stop();
            Navigator.of(context).maybePop();
          },
        ),
        const SizedBox(width: 12),
        ...List.generate(kLevels.length, (i) {
          final active = i == _currentLevel;
          final done = i < _currentLevel;
          return Container(
            margin: const EdgeInsets.only(right: 7),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: done
                  ? const Color(0xFF43A047)
                  : active
                  ? Colors.white.withOpacity(0.9)
                  : Colors.white24,
              shape: BoxShape.circle,
              border: Border.all(
                color: active ? const Color(0xFFFFC107) : Colors.transparent,
                width: 2.5,
              ),
            ),
            child: Center(
              child: done
                  ? const Icon(Icons.star_rounded, color: Colors.white, size: 18)
                  : Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: active ? const Color(0xFF1565C0) : Colors.white60,
                      ),
                    ),
            ),
          );
        }),
        const Spacer(),
        Text(
          'Level ${_currentLevel + 1} · ${_cfg.animalName}',
          style: const TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontSize: 17,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black45, blurRadius: 6)],
          ),
        ),
        const Spacer(),
        _circleBtn(
          Icons.refresh_rounded,
          bg: Colors.transparent,        // ← no background
          iconColor: Colors.white,
          onTap: _restartLevel,
        ),
      ],
    ),
  );
}

  Widget _circleBtn(
    IconData icon, {
    required Color bg,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 26),
      ),
    );
  }

  // ── Board ──────────────────────────────────────
  Widget _buildBoard() {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final cfg = _cfg;
        final cellSize = min(
          constraints.maxWidth / cfg.cols,
          constraints.maxHeight / cfg.rows,
        );
        final boardW = cellSize * cfg.cols;
        final boardH = cellSize * cfg.rows;

        return Center(
          child: Container(
            width: boardW,
            height: boardH,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: List.generate(cfg.cols * cfg.rows, (slot) {
                  final row = slot ~/ cfg.cols;
                  final col = slot % cfg.cols;
                  final blocked = _boardSlots[slot] == -1;
                  final placed = (!blocked && _boardSlots[slot] != null)
                      ? _boardSlots[slot]!
                      : null;

                  return Positioned(
                    left: col * cellSize,
                    top: row * cellSize,
                    width: cellSize,
                    height: cellSize,
                    child: blocked
                        // Level 2's unused slot: faintly shows image fragment
                        ? Opacity(
                            opacity: 0.15,
                            child: _pieceImage(slot, cellSize),
                          )
                        : DragTarget<PuzzlePiece>(
                            onWillAcceptWithDetails: (d) =>
                                _boardSlots[slot] == null && !_levelComplete,
                            onAcceptWithDetails: (d) => _onDrop(d.data, slot),
                            builder: (_, candidates, __) {
                              final highlight = candidates.isNotEmpty;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                decoration: BoxDecoration(
                                  color: highlight
                                      ? Colors.white30
                                      : Colors.black.withOpacity(0.22),
                                  border: Border.all(
                                    color: highlight
                                        ? Colors.white
                                        : Colors.white38,
                                    width: highlight ? 3 : 1.5,
                                  ),
                                ),
                                child: placed != null
                                    ? _pieceImage(placed, cellSize)
                                    : Stack(
                                        children: [
                                          ImageFiltered(
                                            imageFilter: ImageFilter.blur(
                                              sigmaX: 3,
                                              sigmaY: 3,
                                            ),
                                            child: Opacity(
                                              opacity: 0.5,
                                              child: _pieceImage(
                                                slot,
                                                cellSize,
                                              ), // ← uses slot index!
                                            ),
                                          ),
                                          Container(
                                            color: Colors.black.withOpacity(
                                              0.12,
                                            ),
                                          ),
                                        ],
                                      ),
                              );
                            },
                          ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Tray ───────────────────────────────────────
Widget _buildTray() {
  return SizedBox(
    height: 100, // reduce height a little
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Pieces',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(height: 4), // smaller gap

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _trayPieces.map((p) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildDraggable(p),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ),
  );
}
  Widget _buildDraggable(PuzzlePiece piece) {
    const sz = 90.0;
    final tile = _trayTile(piece, sz);
    return Draggable<PuzzlePiece>(
      data: piece,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.12,
          child: Container(
            width: sz,
            height: sz,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 14,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _pieceImage(piece.index, sz),
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.22, child: tile),
      child: tile,
    );
  }

  Widget _trayTile(PuzzlePiece piece, double sz) {
    return Container(
      width: sz,
      height: sz,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white60, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _pieceImage(piece.index, sz),
      ),
    );
  }

  // ── Piece image crop ───────────────────────────
  /// Uses OverflowBox + Alignment to crop the correct sub-region
  /// of the full puzzle image for the given piece index.
  Widget _pieceImage(int pieceIndex, double cellSize) {
    final cfg = _cfg;
    final row = pieceIndex ~/ cfg.cols;
    final col = pieceIndex % cfg.cols;

    final alignX = cfg.cols == 1 ? 0.0 : (col / (cfg.cols - 1)) * 2.0 - 1.0;
    final alignY = cfg.rows == 1 ? 0.0 : (row / (cfg.rows - 1)) * 2.0 - 1.0;

    return SizedBox(
      width: cellSize,
      height: cellSize,
      child: ClipRect(
        child: OverflowBox(
          maxWidth: cellSize * cfg.cols,
          maxHeight: cellSize * cfg.rows,
          alignment: Alignment(alignX, alignY),
          child: SizedBox(
            width: cellSize * cfg.cols,
            height: cellSize * cfg.rows,
            child: Image.asset(
              cfg.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: kFallbackColors[pieceIndex % kFallbackColors.length],
                child: Center(
                  child: Text(
                    '${pieceIndex + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Feedback banner ────────────────────────────
  Widget _buildFeedback() {
    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: Center(
        child: ScaleTransition(
          scale: _feedbackAnim,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: BoxDecoration(
              color: _isCorrect
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFBF360C),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: (_isCorrect ? Colors.green : Colors.deepOrange)
                      .withOpacity(0.5),
                  blurRadius: 22,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isCorrect ? Icons.star_rounded : Icons.refresh_rounded,
                  color: Colors.white,
                  size: 26,
                ),
                const SizedBox(width: 8),
                Text(
                  _feedbackText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Level complete overlay ─────────────────────
  Widget _buildComplete() {
    final isLast = _currentLevel == kLevels.length - 1;
    return Positioned.fill(
      child: FadeTransition(
        opacity: _starsAnim,
        child: Container(
          color: Colors.black.withOpacity(0.72),
          child: Center(
            child: ScaleTransition(
              scale: _starsAnim,
              child: Container(
                width: 310,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 16, 11, 80),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: const Color(0xFFFFC107), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFC107).withOpacity(0.35),
                      blurRadius: 32,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _AnimatedStars(
                      starCount: _currentLevel + 1,
                      controller: _starsCtrl,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      isLast ? '🎉 All Done!' : '⭐ Level Complete!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isLast
                          ? "You're a puzzle master!"
                          : 'Ready for ${kLevels[_currentLevel + 1].animalName}?',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.8),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 22),
                    isLast
                        ? ElevatedButton.icon(
                            onPressed: () => setState(() {
                              _currentLevel = 0;
                              _initLevel();
                            }),
                            icon: const Icon(Icons.replay_rounded),
                            label: const Text(
                              'Play Again',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF43A047),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 26,
                                vertical: 13,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: _nextLevel,
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: const Text(
                              'Next Level',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFC107),
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 26,
                                vertical: 13,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Animated Stars (1–3 earned stars bounce in)
// ─────────────────────────────────────────────
class _AnimatedStars extends StatelessWidget {
  final int starCount;
  final AnimationController controller;

  const _AnimatedStars({required this.starCount, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final start = i * 0.2;
        final end = min(start + 0.5, 1.0);
        final anim = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(start, end, curve: Curves.elasticOut),
          ),
        );
        final earned = i < starCount;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedBuilder(
            animation: anim,
            builder: (_, __) => Transform.scale(
              scale: anim.value,
              child: Icon(
                earned ? Icons.star_rounded : Icons.star_outline_rounded,
                color: earned ? const Color(0xFFFFC107) : Colors.white30,
                size: 54,
                shadows: earned
                    ? const [Shadow(color: Color(0xFFFFC107), blurRadius: 14)]
                    : null,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────
// Background decorator
// ─────────────────────────────────────────────
class _BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    const spots = [
      [0.08, 0.12, 65.0],
      [0.92, 0.08, 90.0],
      [0.04, 0.72, 72.0],
      [0.88, 0.82, 78.0],
      [0.5, 0.96, 50.0],
      [0.6, 0.3, 40.0],
    ];
    for (final s in spots) {
      canvas.drawCircle(
        Offset(size.width * s[0], size.height * s[1]),
        s[2],
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
