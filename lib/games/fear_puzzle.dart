import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Theme — Deep forest green / shadow teal (fear → courage palette) ─────────
const Color kBgDeep      = Color(0xFF0A0F14);
const Color kBgCard      = Color(0xFF111C22);
const Color kBgSurface   = Color(0xFF1A2B35);
const Color kAccent      = Color(0xFF3ECFB2);   // teal — calm courage
const Color kAccentSoft  = Color(0xFF8EEADA);
const Color kAccentGlow  = Color(0xFF1A5C52);
const Color kFear        = Color(0xFF6B3FA0);   // purple — fear
const Color kFearSoft    = Color(0xFFB08FD8);
const Color kStarGold    = Color(0xFFFFD166);
const Color kTextPrim    = Color(0xFFD8EEE8);
const Color kTextMuted   = Color(0xFF5A8070);
const Color kCorrect     = Color(0xFF3ECFB2);
const Color kWrong       = Color(0xFFE05C7A);
const Color kShadow      = Color(0xFF060B0F);

// ─── Puzzle Data ──────────────────────────────────────────────────────────────
class PuzzleItem {
  final String emoji;
  final String name;
  const PuzzleItem(this.emoji, this.name);
}

// Each level has themed puzzle sets
const List<List<PuzzleItem>> levelPuzzles = [
  // L1 — 2 pieces, animals
  [PuzzleItem('🐶','Dog'), PuzzleItem('🐱','Cat')],
  // L2 — 2 pieces, fruits
  [PuzzleItem('🍎','Apple'), PuzzleItem('🍌','Banana')],
  // L3 — 3 pieces, animals
  [PuzzleItem('🐸','Frog'), PuzzleItem('🦊','Fox'), PuzzleItem('🐻','Bear')],
  // L4 — 3 pieces, fruits
  [PuzzleItem('🍓','Berry'), PuzzleItem('🍇','Grapes'), PuzzleItem('🍊','Orange')],
  // L5 — 3 pieces, toys
  [PuzzleItem('🧸','Teddy'), PuzzleItem('🚗','Car'), PuzzleItem('⭐','Star')],
  // L6 — 4 pieces, animals
  [PuzzleItem('🦁','Lion'), PuzzleItem('🐘','Elephant'), PuzzleItem('🦒','Giraffe'), PuzzleItem('🐧','Penguin')],
  // L7 — 4 pieces, mixed
  [PuzzleItem('🌈','Rainbow'), PuzzleItem('🌙','Moon'), PuzzleItem('⚡','Lightning'), PuzzleItem('🌺','Flower')],
  // L8 — 4 pieces, toys+animals
  [PuzzleItem('🎈','Balloon'), PuzzleItem('🦋','Butterfly'), PuzzleItem('🎀','Ribbon'), PuzzleItem('🌟','Glow')],
  // L9 — 4 pieces, brave theme
  [PuzzleItem('🦅','Eagle'), PuzzleItem('🔥','Flame'), PuzzleItem('💎','Diamond'), PuzzleItem('🌊','Wave')],
  // L10 — 4 pieces, courage mastery
  [PuzzleItem('👑','Crown'), PuzzleItem('🗡️','Sword'), PuzzleItem('🛡️','Shield'), PuzzleItem('✨','Magic')],
];

const List<String> levelNames = [
  'First Step','Gentle Start','Feeling Brave','Growing Courage',
  'Finding Calm','Facing Fear','Bold Mind','Strong Heart',
  'Fearless','Conqueror',
];

const List<String> levelEmojis = [
  '🌱','🌿','🍀','🌸','💫','🌟','⚡','🔥','🦅','👑',
];

// ─── Score Service ────────────────────────────────────────────────────────────
class ScoreService {
  static Future<int>  getScore(int lvl) async =>
      ((await SharedPreferences.getInstance()).getInt('fp_score_$lvl') ?? 0);
  static Future<int>  getStars(int lvl)  async =>
      ((await SharedPreferences.getInstance()).getInt('fp_stars_$lvl') ?? 0);
  static Future<void> saveScore(int lvl, int score) async {
    if (score > await getScore(lvl))
      (await SharedPreferences.getInstance()).setInt('fp_score_$lvl', score);
  }
  static Future<void> saveStars(int lvl, int stars) async {
    if (stars > await getStars(lvl))
      (await SharedPreferences.getInstance()).setInt('fp_stars_$lvl', stars);
  }
  static Future<bool> isUnlocked(int lvl) async =>
      lvl == 1 || await getStars(lvl - 1) >= 1;
  static int calcStars(int placed, int total, int moves) {
    if (placed < total) return 0;
    if (moves <= total + 1) return 3;
    if (moves <= total * 2) return 2;
    return 1;
  }
}

// ─── Entry ────────────────────────────────────────────────────────────────────
void main() => runApp(const FearPuzzleApp());

class FearPuzzleApp extends StatelessWidget {
  const FearPuzzleApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Fear Puzzle',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: kBgDeep,
      colorScheme: const ColorScheme.dark(primary: kAccent, surface: kBgCard),
      appBarTheme: const AppBarTheme(
        backgroundColor: kBgDeep, elevation: 0, centerTitle: true,
        titleTextStyle: TextStyle(
          color: kAccentSoft, fontSize: 19, fontWeight: FontWeight.w500,
          letterSpacing: 0.4),
        iconTheme: IconThemeData(color: kAccentSoft),
      ),
    ),
    home: const fearpuzzelgame(),
  );
}

// ─── Home Screen ──────────────────────────────────────────────────────────────
class fearpuzzelgame extends StatefulWidget {
  const fearpuzzelgame({super.key});
  @override
  State<fearpuzzelgame> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<fearpuzzelgame> with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this,
      duration: const Duration(seconds: 2))..repeat(reverse: true);
  }
  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Title
            ShaderMask(
              shaderCallback: (r) => const LinearGradient(
                colors: [kAccent, kFearSoft]).createShader(r),
              child: const Text('Fear Puzzle', style: TextStyle(
                fontSize: 36, fontWeight: FontWeight.w700,
                color: Colors.white, letterSpacing: -1)),
            ),
            const SizedBox(height: 8),
            const Text('Solve puzzles.\nFace your fears gently. 🌿',
              style: TextStyle(fontSize: 15, color: kTextMuted, height: 1.6)),
            const SizedBox(height: 40),
            // Glow card
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: kBgCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: kAccent.withOpacity(0.15 + _pulse.value * 0.15),
                    width: 1.5),
                  boxShadow: [BoxShadow(
                    color: kAccentGlow.withOpacity(0.2 + _pulse.value * 0.15),
                    blurRadius: 24, spreadRadius: 2)],
                ),
                child: Column(children: [
                  const Text('🧩', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 14),
                  Text(
                    'Drag pieces to their place.\nNo rush. You are safe here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kTextMuted.withOpacity(0.9), fontSize: 14, height: 1.6)),
                ]),
              ),
            ),
            const SizedBox(height: 32),
            _Btn('Play', Icons.play_circle_outline_rounded, kAccent,
              () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const LevelSelectScreen()))),
            const SizedBox(height: 14),
            _Btn('Scoreboard', Icons.emoji_events_outlined, kFearSoft,
              () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ScoreboardScreen()))),
          ],
        ),
      ),
    ),
  );

  Widget _Btn(String label, IconData icon, Color color, VoidCallback onTap) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3))),
        child: Row(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 14),
          Text(label, style: TextStyle(
            color: color, fontSize: 17, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
}

// ─── Level Select ─────────────────────────────────────────────────────────────
class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});
  @override
  State<LevelSelectScreen> createState() => _LevelSelectState();
}

class _LevelSelectState extends State<LevelSelectScreen> {
  final Map<int, bool> _unlocked = {};
  final Map<int, int>  _stars    = {};
  final Map<int, int>  _scores   = {};

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final Map<int, bool> u = {};
    final Map<int, int>  s = {}, sc = {};
    for (int i = 1; i <= 10; i++) {
      u[i]  = await ScoreService.isUnlocked(i);
      s[i]  = await ScoreService.getStars(i);
      sc[i] = await ScoreService.getScore(i);
    }
    if (mounted) setState(() {
      _unlocked.addAll(u); _stars.addAll(s); _scores.addAll(sc);
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Choose Level'), leading: const BackButton()),
    body: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Levels', style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w600, color: kAccentSoft)),
          const SizedBox(height: 4),
          const Text('Earn ★ to unlock the next challenge.',
            style: TextStyle(color: kTextMuted, fontSize: 13)),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 12,
                mainAxisSpacing: 12, childAspectRatio: 1.05),
              itemCount: 10,
              itemBuilder: (_, i) {
                final unlocked = _unlocked[i + 1] ?? (i == 0);
                final stars    = _stars[i + 1]    ?? 0;
                final pieces   = levelPuzzles[i].length;
                return GestureDetector(
                  onTap: () async {
                    if (!await ScoreService.isUnlocked(i + 1)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Complete previous level first 🌿')));
                      return;
                    }
                    await Navigator.push(context, MaterialPageRoute(
                      builder: (_) => GameScreen(level: i + 1)));
                    _load();
                  },
                  child: _LevelCard(
                    level: i + 1, name: levelNames[i],
                    emoji: levelEmojis[i], pieces: pieces,
                    stars: stars, unlocked: unlocked),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class _LevelCard extends StatelessWidget {
  final int level, pieces, stars;
  final String name, emoji;
  final bool unlocked;
  const _LevelCard({required this.level, required this.name, required this.emoji,
    required this.pieces, required this.stars, required this.unlocked});

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: unlocked ? kBgCard : kBgDeep,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: unlocked ? kAccent.withOpacity(0.3) : kTextMuted.withOpacity(0.12),
        width: 1.2),
      boxShadow: unlocked ? [BoxShadow(
        color: kAccentGlow.withOpacity(0.15), blurRadius: 12)] : [],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(unlocked ? emoji : '🔒',
          style: const TextStyle(fontSize: 26)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: kAccent.withOpacity(unlocked ? 0.12 : 0.05),
            borderRadius: BorderRadius.circular(8)),
          child: Text('L$level', style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600,
            color: unlocked ? kAccent : kTextMuted)),
        ),
      ]),
      const Spacer(),
      Text(name, style: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w600,
        color: unlocked ? kTextPrim : kTextMuted)),
      const SizedBox(height: 3),
      Text('$pieces pieces', style: const TextStyle(
        fontSize: 11, color: kTextMuted)),
      const SizedBox(height: 8),
      Row(children: List.generate(3, (j) => Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Icon(Icons.star_rounded, size: 15,
          color: j < stars ? kStarGold : kTextMuted.withOpacity(0.2))))),
    ]),
  );
}

// ─── Game Screen ──────────────────────────────────────────────────────────────
class GameScreen extends StatefulWidget {
  final int level;
  const GameScreen({super.key, required this.level});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _PieceDragData {
  final int index;
  const _PieceDragData(this.index);
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late List<PuzzleItem> _puzzleItems;
  late List<PuzzleItem?> _slots;       // what's placed in each slot
  late List<bool> _slotCorrect;
  late List<PuzzleItem> _hand;         // pieces still to place
  int _moves = 0;
  bool _done = false;

  // Per-slot celebrate controllers
  late List<AnimationController> _celebCtrl;
  late AnimationController _completionCtrl;

  @override
  void initState() {
    super.initState();
    _puzzleItems = List.from(levelPuzzles[widget.level - 1]);
    _slots = List.filled(_puzzleItems.length, null);
    _slotCorrect = List.filled(_puzzleItems.length, false);
    _hand = List.from(_puzzleItems)..shuffle();

    _celebCtrl = List.generate(_puzzleItems.length, (_) =>
      AnimationController(vsync: this, duration: const Duration(milliseconds: 500)));
    _completionCtrl = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 800));
  }

  @override
  void dispose() {
    for (final c in _celebCtrl) c.dispose();
    _completionCtrl.dispose();
    super.dispose();
  }

  void _onDrop(int slotIndex, _PieceDragData data) {
    final piece = _hand[data.index];
    setState(() {
      _moves++;
      // If slot already has a wrong piece, return it to hand
      if (_slots[slotIndex] != null && !_slotCorrect[slotIndex]) {
        _hand.add(_slots[slotIndex]!);
      }
      _slots[slotIndex] = piece;
      _hand.removeAt(data.index);

      final correct = piece.name == _puzzleItems[slotIndex].name;
      _slotCorrect[slotIndex] = correct;

      if (correct) {
        _celebCtrl[slotIndex].forward(from: 0);
        _checkCompletion();
      }
    });
  }

  void _checkCompletion() {
    if (_slotCorrect.every((c) => c)) {
      _done = true;
      _completionCtrl.forward(from: 0);
      final stars = ScoreService.calcStars(
        _puzzleItems.length, _puzzleItems.length, _moves);
      final score = (stars * 100 + max(0, 50 - _moves * 5)).toInt();
      ScoreService.saveScore(widget.level, score);
      ScoreService.saveStars(widget.level, stars);
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => ResultScreen(
            level: widget.level, moves: _moves,
            stars: stars, score: score)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.level;
    return Scaffold(
      appBar: AppBar(
        title: Text('${levelEmojis[n - 1]} ${levelNames[n - 1]}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context)),
        actions: [Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(child: Text('Moves: $_moves',
            style: const TextStyle(color: kTextMuted, fontSize: 13))))],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(children: [
            _buildHint(),
            const SizedBox(height: 20),
            _buildSlots(),
            const SizedBox(height: 28),
            const Text('Drag a piece to its shadow',
              style: TextStyle(color: kTextMuted, fontSize: 13)),
            const SizedBox(height: 16),
            _buildHand(),
          ]),
        ),
      ),
    );
  }

  Widget _buildHint() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    decoration: BoxDecoration(
      color: kFear.withOpacity(0.12),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: kFear.withOpacity(0.25))),
    child: Row(children: [
      const Text('🧩', style: TextStyle(fontSize: 18)),
      const SizedBox(width: 10),
      Text(
        'Match each piece to its correct shadow slot below.',
        style: const TextStyle(color: kFearSoft, fontSize: 13)),
    ]),
  );

  Widget _buildSlots() {
    final n = _puzzleItems.length;
    return Wrap(
      spacing: 14, runSpacing: 14,
      alignment: WrapAlignment.center,
      children: List.generate(n, (i) => _buildSlot(i)),
    );
  }

  Widget _buildSlot(int i) {
    final correct  = _slotCorrect[i];
    final occupied = _slots[i] != null;
    return DragTarget<_PieceDragData>(
      onWillAcceptWithDetails: (d) => !correct,
      onAcceptWithDetails: (d) => _onDrop(i, d.data),
      builder: (context, candidates, _) {
        final hovering = candidates.isNotEmpty && !correct;
        return AnimatedBuilder(
          animation: _celebCtrl[i],
          builder: (_, child) {
            final scale = correct
              ? 1.0 + sin(_celebCtrl[i].value * pi) * 0.12
              : 1.0;
            return Transform.scale(scale: scale, child: child);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 90, height: 100,
            decoration: BoxDecoration(
              color: correct
                ? kCorrect.withOpacity(0.12)
                : hovering
                  ? kAccent.withOpacity(0.15)
                  : kBgSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: correct
                  ? kCorrect.withOpacity(0.6)
                  : hovering
                    ? kAccent.withOpacity(0.7)
                    : kTextMuted.withOpacity(0.2),
                width: correct || hovering ? 2 : 1),
              boxShadow: correct ? [BoxShadow(
                color: kCorrect.withOpacity(0.25), blurRadius: 16)] : [],
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              // Shadow hint (always show target name)
              Text(
                occupied ? _slots[i]!.emoji : '❓',
                style: TextStyle(
                  fontSize: occupied ? 34 : 28,
                  color: occupied ? null : Colors.white.withOpacity(0.15))),
              const SizedBox(height: 6),
              Text(_puzzleItems[i].name,
                style: TextStyle(
                  fontSize: 11,
                  color: correct ? kCorrect : kTextMuted,
                  fontWeight: correct ? FontWeight.w600 : FontWeight.normal)),
              if (correct) const Text('✓',
                style: TextStyle(color: kCorrect, fontSize: 13, fontWeight: FontWeight.bold)),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildHand() {
    if (_hand.isEmpty) return const SizedBox(height: 80,
      child: Center(child: Text('All placed! 🎉',
        style: TextStyle(color: kAccentSoft, fontSize: 16))));
    return Container(
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kAccent.withOpacity(0.15))),
      child: Wrap(
        spacing: 14, runSpacing: 14,
        alignment: WrapAlignment.center,
        children: List.generate(_hand.length, (i) {
          final piece = _hand[i];
          return Draggable<_PieceDragData>(
            data: _PieceDragData(i),
            feedback: Material(
              color: Colors.transparent,
              child: _PieceWidget(piece: piece, dragging: true)),
            childWhenDragging: Opacity(opacity: 0.3,
              child: _PieceWidget(piece: piece)),
            child: _PieceWidget(piece: piece),
          );
        }),
      ),
    );
  }
}

class _PieceWidget extends StatelessWidget {
  final PuzzleItem piece;
  final bool dragging;
  const _PieceWidget({required this.piece, this.dragging = false});

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 150),
    width: 80, height: 90,
    decoration: BoxDecoration(
      color: dragging ? kAccentGlow : kBgSurface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: dragging ? kAccent : kAccent.withOpacity(0.35),
        width: dragging ? 2 : 1.2),
      boxShadow: dragging ? [const BoxShadow(
        color: kAccentGlow, blurRadius: 20, spreadRadius: 2)] : [],
    ),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(piece.emoji, style: const TextStyle(fontSize: 32)),
      const SizedBox(height: 4),
      Text(piece.name, style: const TextStyle(
        fontSize: 11, color: kTextMuted, fontWeight: FontWeight.w500)),
    ]),
  );
}

// ─── Result Screen ────────────────────────────────────────────────────────────
class ResultScreen extends StatefulWidget {
  final int level, moves, stars, score;
  const ResultScreen({super.key, required this.level, required this.moves,
    required this.stars, required this.score});
  @override
  State<ResultScreen> createState() => _ResultState();
}

class _ResultState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _enter;
  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 600))..forward();
  }
  @override
  void dispose() { _enter.dispose(); super.dispose(); }

  String get _headline => widget.stars == 3
    ? 'Brilliant! You are BRAVE!'
    : widget.stars == 2 ? 'Well done! Keep going!'
    : widget.stars == 1 ? 'You did it! Great try!'
    : 'You finished! Proud of you!';

  String get _emoji =>
    widget.stars >= 3 ? '🏆' : widget.stars >= 2 ? '🌟' : '🌿';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Result'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded),
        onPressed: () => Navigator.of(context)..pop()..pop()..pop()),
    ),
    body: SafeArea(
      child: AnimatedBuilder(
        animation: _enter,
        builder: (_, child) => Opacity(
          opacity: _enter.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - _enter.value)), child: child)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(_emoji, style: const TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            Text(_headline, textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.w700, color: kAccentSoft)),
            const SizedBox(height: 6),
            Text('${levelEmojis[widget.level - 1]} ${levelNames[widget.level - 1]}',
              style: const TextStyle(color: kTextMuted, fontSize: 15)),
            const SizedBox(height: 32),
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: i < widget.stars ? 1.0 : 0.0),
                  duration: Duration(milliseconds: 400 + i * 150),
                  builder: (_, v, __) => Transform.scale(scale: 0.6 + v * 0.4,
                    child: Icon(Icons.star_rounded, size: 44,
                      color: Color.lerp(kTextMuted.withOpacity(0.2), kStarGold, v))),
                ),
              ))),
            const SizedBox(height: 28),
            _Stat('Score', '${widget.score} pts', kAccent),
            const SizedBox(height: 10),
            _Stat('Moves used', '${widget.moves}', kFearSoft),
            const SizedBox(height: 36),
            if (widget.level < 10)
              _Btn('Next Level →', Icons.arrow_forward_rounded, kAccent,
                () => Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (_) => GameScreen(level: widget.level + 1)))),
            if (widget.level < 10) const SizedBox(height: 12),
            _Btn('Play Again', Icons.replay_rounded, kFearSoft,
              () => Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (_) => GameScreen(level: widget.level)))),
            const SizedBox(height: 12),
            _Btn('All Levels', Icons.grid_view_rounded, kTextMuted,
              () => Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (_) => const LevelSelectScreen()))),
          ]),
        ),
      ),
    ),
  );

  Widget _Stat(String label, String value, Color color) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    decoration: BoxDecoration(
      color: kBgCard, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withOpacity(0.2))),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: kTextMuted, fontSize: 15)),
      Text(value, style: TextStyle(
        color: color, fontSize: 18, fontWeight: FontWeight.w600)),
    ]),
  );

  Widget _Btn(String label, IconData icon, Color color, VoidCallback onTap) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 22),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3))),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(
            color: color, fontSize: 16, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
}

// ─── Scoreboard ───────────────────────────────────────────────────────────────
class ScoreboardScreen extends StatefulWidget {
  const ScoreboardScreen({super.key});
  @override
  State<ScoreboardScreen> createState() => _ScoreboardState();
}

class _ScoreboardState extends State<ScoreboardScreen> {
  final Map<int, int> _scores = {}, _stars = {};

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final Map<int, int> s = {}, st = {};
    for (int i = 1; i <= 10; i++) {
      s[i]  = await ScoreService.getScore(i);
      st[i] = await ScoreService.getStars(i);
    }
    if (mounted) setState(() { _scores.addAll(s); _stars.addAll(st); });
  }

  int get _totalScore => _scores.values.fold(0, (a, b) => a + b);
  int get _totalStars  => _stars.values.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Scoreboard'), leading: const BackButton()),
    body: Column(children: [
      // Summary bar
      Container(
        margin: const EdgeInsets.all(18),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: kBgCard, borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kAccent.withOpacity(0.2))),
        child: Row(children: [
          _SumStat('Total Score', '$_totalScore pts', kAccent),
          Container(width: 1, height: 40, color: kTextMuted.withOpacity(0.2)),
          _SumStat('Stars', '$_totalStars / 30', kStarGold),
          Container(width: 1, height: 40, color: kTextMuted.withOpacity(0.2)),
          _SumStat('Levels', '${_stars.values.where((s) => s > 0).length} / 10', kFearSoft),
        ]),
      ),
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          itemCount: 10,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final score = _scores[i + 1] ?? 0;
            final stars = _stars[i + 1]  ?? 0;
            final played = score > 0;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              decoration: BoxDecoration(
                color: kBgCard, borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: played
                    ? kAccent.withOpacity(stars == 3 ? 0.4 : 0.18)
                    : kTextMuted.withOpacity(0.1))),
              child: Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: played ? kAccentGlow : kBgSurface,
                    borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text(levelEmojis[i],
                    style: const TextStyle(fontSize: 22)))),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('L${i + 1} · ${levelNames[i]}', style: const TextStyle(
                    color: kTextPrim, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(children: [
                    ...List.generate(3, (j) => Icon(Icons.star_rounded, size: 14,
                      color: j < stars ? kStarGold : kTextMuted.withOpacity(0.2))),
                    const SizedBox(width: 8),
                    Text('${levelPuzzles[i].length} pieces',
                      style: const TextStyle(color: kTextMuted, fontSize: 11)),
                  ]),
                ])),
                Text(played ? '$score pts' : '—',
                  style: TextStyle(
                    color: played ? kAccentSoft : kTextMuted,
                    fontSize: 16, fontWeight: FontWeight.w600)),
              ]),
            );
          },
        ),
      ),
      const SizedBox(height: 16),
    ]),
  );

  Widget _SumStat(String label, String value, Color color) => Expanded(
    child: Column(children: [
      Text(value, style: TextStyle(
        color: color, fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: kTextMuted, fontSize: 11)),
    ]),
  );
}