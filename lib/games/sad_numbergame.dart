import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Theme ───────────────────────────────────────────────────────────────────
const Color kBgDeep     = Color(0xFF0F0E1A);
const Color kBgCard     = Color(0xFF1A1830);
const Color kAccent     = Color(0xFF9B7FD4);
const Color kAccentSoft = Color(0xFFCBB8F5);
const Color kStarGold   = Color(0xFFF5C842);
const Color kTextPrim   = Color(0xFFE8D5F5);
const Color kTextMuted  = Color(0xFF8880AA);
const Color kCorrect    = Color(0xFF60C8A0);
const Color kWrong      = Color(0xFFE47A7A);
const Color kBlue       = Color(0xFF7EB8F5);

// ─── Models ──────────────────────────────────────────────────────────────────
enum GameMode { tapInOrder, countObjects, matchDots }

class LevelConfig {
  final int level;
  final String name, emoji;
  final int maxNumber, questionsPerRound, timeLimitSeconds, pointsPerCorrect;
  final List<GameMode> modes;
  const LevelConfig({
    required this.level, required this.name, required this.emoji,
    required this.maxNumber, required this.questionsPerRound,
    required this.timeLimitSeconds, required this.pointsPerCorrect,
    required this.modes,
  });
}

const levels = [
  LevelConfig(level:1,  name:'Baby Steps',   emoji:'🌙', maxNumber:3,  questionsPerRound:5,  timeLimitSeconds:60, pointsPerCorrect:10, modes:[GameMode.tapInOrder]),
  LevelConfig(level:2,  name:'Gentle Count', emoji:'⭐', maxNumber:5,  questionsPerRound:6,  timeLimitSeconds:55, pointsPerCorrect:12, modes:[GameMode.tapInOrder, GameMode.countObjects]),
  LevelConfig(level:3,  name:'Soft Match',   emoji:'☁️', maxNumber:5,  questionsPerRound:7,  timeLimitSeconds:50, pointsPerCorrect:14, modes:[GameMode.countObjects, GameMode.matchDots]),
  LevelConfig(level:4,  name:'Growing',      emoji:'🌸', maxNumber:7,  questionsPerRound:8,  timeLimitSeconds:45, pointsPerCorrect:16, modes:[GameMode.tapInOrder, GameMode.matchDots]),
  LevelConfig(level:5,  name:'Halfway',      emoji:'💫', maxNumber:7,  questionsPerRound:8,  timeLimitSeconds:42, pointsPerCorrect:18, modes:[GameMode.tapInOrder, GameMode.countObjects, GameMode.matchDots]),
  LevelConfig(level:6,  name:'Clarity',      emoji:'🔮', maxNumber:9,  questionsPerRound:9,  timeLimitSeconds:40, pointsPerCorrect:20, modes:[GameMode.tapInOrder, GameMode.countObjects, GameMode.matchDots]),
  LevelConfig(level:7,  name:'Focus',        emoji:'🌿', maxNumber:10, questionsPerRound:10, timeLimitSeconds:38, pointsPerCorrect:22, modes:[GameMode.countObjects, GameMode.matchDots]),
  LevelConfig(level:8,  name:'Flow',         emoji:'🌊', maxNumber:12, questionsPerRound:10, timeLimitSeconds:35, pointsPerCorrect:25, modes:[GameMode.tapInOrder, GameMode.countObjects, GameMode.matchDots]),
  LevelConfig(level:9,  name:'Calm Peak',    emoji:'🏔️', maxNumber:15, questionsPerRound:12, timeLimitSeconds:30, pointsPerCorrect:28, modes:[GameMode.tapInOrder, GameMode.countObjects, GameMode.matchDots]),
  LevelConfig(level:10, name:'Serenity',     emoji:'✨', maxNumber:20, questionsPerRound:15, timeLimitSeconds:25, pointsPerCorrect:30, modes:[GameMode.tapInOrder, GameMode.countObjects, GameMode.matchDots]),
];

// ─── Score Service ────────────────────────────────────────────────────────────
class ScoreService {
  static Future<int> getBestScore(int level) async {
    final p = await SharedPreferences.getInstance();
    return p.getInt('score_$level') ?? 0;
  }
  static Future<void> saveBestScore(int level, int score) async {
    if (score > await getBestScore(level)) {
      (await SharedPreferences.getInstance()).setInt('score_$level', score);
    }
  }
  static Future<int> getStars(int level) async =>
      (await SharedPreferences.getInstance()).getInt('stars_$level') ?? 0;
  static Future<void> saveStars(int level, int stars) async {
    if (stars > await getStars(level)) {
      (await SharedPreferences.getInstance()).setInt('stars_$level', stars);
    }
  }
  static Future<bool> isUnlocked(int level) async =>
      level == 1 || await getStars(level - 1) >= 1;
  static int calcStars(int score, int max) =>
      score / max >= 0.85 ? 3 : score / max >= 0.60 ? 2 : score / max >= 0.30 ? 1 : 0;
}

// ─── App Entry ────────────────────────────────────────────────────────────────
void main() => runApp(const NumberCalmApp());

class NumberCalmApp extends StatelessWidget {
  const NumberCalmApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Number Calm',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: kBgDeep,
      colorScheme: const ColorScheme.dark(primary: kAccent, surface: kBgCard),
      appBarTheme: const AppBarTheme(
        backgroundColor: kBgDeep, elevation: 0, centerTitle: true,
        titleTextStyle: TextStyle(color: kAccentSoft, fontSize: 19, fontWeight: FontWeight.w500),
        iconTheme: IconThemeData(color: kAccentSoft),
      ),
    ),
    home: const HomeScreen(),
  );
}

// ─── Home Screen ──────────────────────────────────────────────────────────────
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text('Number Calm', style: TextStyle(
              fontSize: 34, fontWeight: FontWeight.w500,
              color: kAccentSoft, letterSpacing: -0.5)),
            const SizedBox(height: 8),
            const Text("It's okay to feel sad.\nLet's gently play.", style: TextStyle(
              fontSize: 16, color: kTextMuted, height: 1.6)),
            const SizedBox(height: 40),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kBgCard, borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kAccent.withOpacity(0.25))),
              child: const Column(children: [
                Text('🌙', style: TextStyle(fontSize: 52)),
                SizedBox(height: 12),
                Text('Tap numbers gently,\none breath at a time.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kTextMuted, fontSize: 15, height: 1.5)),
              ]),
            ),
            const SizedBox(height: 32),
            _HomeBtn('Play', Icons.play_circle_outline_rounded, kAccent,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LevelSelectScreen()))),
            const SizedBox(height: 14),
            _HomeBtn('Scoreboard', Icons.leaderboard_rounded, kBlue,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScoreboardScreen()))),
          ],
        ),
      ),
    ),
  );

  Widget _HomeBtn(String label, IconData icon, Color color, VoidCallback onTap) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.35))),
        child: Row(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 14),
          Text(label, style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.w500)),
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

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final Map<int, bool> u = {};
    final Map<int, int>  s = {};
    for (int i = 1; i <= 10; i++) {
      u[i] = await ScoreService.isUnlocked(i);
      s[i] = await ScoreService.getStars(i);
    }
    if (mounted) setState(() { _unlocked.addAll(u); _stars.addAll(s); });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Choose Level'), leading: const BackButton()),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Levels', style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w500, color: kAccentSoft)),
          const SizedBox(height: 4),
          const Text('Earn ★ to unlock the next level.',
            style: TextStyle(color: kTextMuted, fontSize: 13)),
          const SizedBox(height: 18),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 12,
                mainAxisSpacing: 12, childAspectRatio: 1.1),
              itemCount: 10,
              itemBuilder: (_, i) {
                final unlocked = _unlocked[i + 1] ?? (i == 0);
                final stars    = _stars[i + 1] ?? 0;
                return GestureDetector(
                  onTap: () async {
                    if (!await ScoreService.isUnlocked(i + 1)) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Complete the previous level first 🌙')));
                      return;
                    }
                    await Navigator.push(context, MaterialPageRoute(
                      builder: (_) => GameScreen(config: levels[i])));
                    _load();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: unlocked ? kBgCard : kBgDeep,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: unlocked
                          ? kAccent.withOpacity(0.35)
                          : kTextMuted.withOpacity(0.15))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(unlocked ? levels[i].emoji : '🔒',
                            style: const TextStyle(fontSize: 26)),
                          Text('L${i + 1}', style: TextStyle(
                            fontSize: 12,
                            color: unlocked ? kAccent : kTextMuted,
                            fontWeight: FontWeight.w500)),
                        ]),
                        const Spacer(),
                        Text(levels[i].name, style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500,
                          color: unlocked ? kTextPrim : kTextMuted)),
                        const SizedBox(height: 6),
                        Row(children: List.generate(3, (j) => Padding(
                          padding: const EdgeInsets.only(right: 3),
                          child: Icon(Icons.star_rounded, size: 15,
                            color: j < stars ? kStarGold : kTextMuted.withOpacity(0.25))))),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

// ─── Game Screen ──────────────────────────────────────────────────────────────
class GameScreen extends StatefulWidget {
  final LevelConfig config;
  const GameScreen({super.key, required this.config});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final _rng     = Random();
  final _emojis  = ['⭐','🌸','☁️','🌙','💫','🔮','🌿'];
  late GameMode _mode;
  late Timer    _timer;
  int _timeLeft = 0, _score = 0, _question = 0, _correct = 0;

  // tapInOrder
  List<int> _orderNums = []; int _nextExp = 1;
  // countObjects
  int _objCount = 0; List<int> _countChoices = []; String _objEmoji = '⭐';
  // matchDots
  int _dotsTarget = 0; List<int> _dotChoices = [];

  late AnimationController _shakeCtrl, _flashCtrl;
  bool _showOk = false;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _flashCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _timeLeft  = widget.config.timeLimitSeconds;
    _nextQ();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) _endGame();
    });
  }

  void _nextQ() {
    if (_question >= widget.config.questionsPerRound) { _endGame(); return; }
    _mode = widget.config.modes[_rng.nextInt(widget.config.modes.length)];
    if (_mode == GameMode.tapInOrder) {
      final n = min(widget.config.maxNumber, 3 + widget.config.level ~/ 3);
      _orderNums = List.generate(n, (i) => i + 1)..shuffle();
      _nextExp = 1;
    } else if (_mode == GameMode.countObjects) {
      _objCount     = 1 + _rng.nextInt(widget.config.maxNumber);
      _objEmoji     = _emojis[_rng.nextInt(_emojis.length)];
      _countChoices = [_objCount,
        max(1, _objCount + 1 + _rng.nextInt(3)),
        max(1, _objCount - 1 - _rng.nextInt(2))]..shuffle();
    } else {
      _dotsTarget = 1 + _rng.nextInt(widget.config.maxNumber);
      _dotChoices = [_dotsTarget,
        max(1, _dotsTarget + 1 + _rng.nextInt(2)),
        max(1, _dotsTarget - 1 - _rng.nextInt(2))]..shuffle();
    }
    setState(() {});
  }

  void _tap(int n) {
    bool correct = false;
    if (_mode == GameMode.tapInOrder) {
      if (n == _nextExp) {
        _nextExp++;
        if (_nextExp > _orderNums.length) correct = true;
        else setState(() {});
      } else { _shakeCtrl.forward(from: 0); _score = max(0, _score - 2); setState(() {}); }
    } else if (_mode == GameMode.countObjects) {
      correct = n == _objCount;
    } else {
      correct = n == _dotsTarget;
    }
    if (correct) {
      _score += widget.config.pointsPerCorrect; _correct++; _question++;
      _showOk = true; _flashCtrl.forward(from: 0).then((_) { _showOk = false; _nextQ(); });
    } else if (_mode != GameMode.tapInOrder) {
      _shakeCtrl.forward(from: 0); _score = max(0, _score - 2); setState(() {});
    }
  }

  void _endGame() {
    _timer.cancel();
    final max = widget.config.questionsPerRound * widget.config.pointsPerCorrect;
    final stars = ScoreService.calcStars(_score, max);
    ScoreService.saveBestScore(widget.config.level, _score);
    ScoreService.saveStars(widget.config.level, stars);
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => ResultScreen(config: widget.config,
        score: _score, correct: _correct, stars: stars)));
  }

  @override
  void dispose() { _timer.cancel(); _shakeCtrl.dispose(); _flashCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('${widget.config.emoji} ${widget.config.name}'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded),
        onPressed: () { _timer.cancel(); Navigator.pop(context); }),
      actions: [Padding(padding: const EdgeInsets.only(right: 16),
        child: Center(child: Text('Q${_question + 1}/${widget.config.questionsPerRound}',
          style: const TextStyle(color: kTextMuted, fontSize: 13))))],
    ),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // HUD
          Row(children: [
            _Pill('Score', '$_score', kAccent),
            const SizedBox(width: 10),
            _Pill('Time', '$_timeLeft s', _timeLeft < 10 ? kWrong : kBlue),
            const SizedBox(width: 10),
            _Pill('Right', '$_correct', kCorrect),
          ]),
          const SizedBox(height: 24),
          Expanded(child: _buildGame()),
          if (_showOk) _OkBanner(),
        ]),
      ),
    ),
  );

  Widget _buildGame() {
    if (_mode == GameMode.tapInOrder) return _buildOrder();
    if (_mode == GameMode.countObjects) return _buildCount();
    return _buildDots();
  }

  Widget _buildOrder() => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Text('Tap in order', style: TextStyle(color: kTextMuted, fontSize: 15)),
    const SizedBox(height: 8),
    Text('Next: $_nextExp', style: const TextStyle(
      color: kAccentSoft, fontSize: 24, fontWeight: FontWeight.w500)),
    const SizedBox(height: 32),
    AnimatedBuilder(
      animation: _shakeCtrl,
      builder: (_, child) => Transform.translate(
        offset: Offset(8 * sin(_shakeCtrl.value * pi * 4), 0), child: child),
      child: Wrap(spacing: 14, runSpacing: 14, alignment: WrapAlignment.center,
        children: _orderNums.map((n) {
          final done = n < _nextExp;
          return _NumTile(n, done: done, onTap: done ? null : () => _tap(n));
        }).toList()),
    ),
  ]);

  Widget _buildCount() => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Text('How many?', style: TextStyle(color: kTextMuted, fontSize: 15)),
    const SizedBox(height: 20),
    Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: kBgCard, borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kAccent.withOpacity(0.2))),
      child: AnimatedBuilder(
        animation: _shakeCtrl,
        builder: (_, child) => Transform.translate(
          offset: Offset(8 * sin(_shakeCtrl.value * pi * 4), 0), child: child),
        child: Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center,
          children: List.generate(_objCount,
            (_) => Text(_objEmoji, style: const TextStyle(fontSize: 28)))),
      ),
    ),
    const SizedBox(height: 28),
    Row(mainAxisAlignment: MainAxisAlignment.center,
      children: _countChoices.map((n) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: _NumTile(n, onTap: () => _tap(n)))).toList()),
  ]);

  Widget _buildDots() => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Text('Match the dots', style: TextStyle(color: kTextMuted, fontSize: 15)),
    const SizedBox(height: 20),
    AnimatedBuilder(
      animation: _shakeCtrl,
      builder: (_, child) => Transform.translate(
        offset: Offset(8 * sin(_shakeCtrl.value * pi * 4), 0), child: child),
      child: Container(
        width: 160, height: 160,
        decoration: BoxDecoration(color: kBgCard, borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kAccent.withOpacity(0.2))),
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 4, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 6, mainAxisSpacing: 6,
          children: List.generate(_dotsTarget, (_) => Container(
            decoration: BoxDecoration(
              color: kAccent.withOpacity(0.65), shape: BoxShape.circle))),
        ),
      ),
    ),
    const SizedBox(height: 28),
    Row(mainAxisAlignment: MainAxisAlignment.center,
      children: _dotChoices.map((n) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: _NumTile(n, onTap: () => _tap(n)))).toList()),
  ]);

  Widget _Pill(String label, String value, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25))),
      child: Column(children: [
        Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.w500)),
      ]),
    ),
  );

  Widget _OkBanner() => Container(
    margin: const EdgeInsets.only(top: 10),
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    decoration: BoxDecoration(
      color: kCorrect.withOpacity(0.15), borderRadius: BorderRadius.circular(12),
      border: Border.all(color: kCorrect.withOpacity(0.4))),
    child: const Text('Well done! 🌙',
      style: TextStyle(color: kCorrect, fontSize: 16, fontWeight: FontWeight.w500)),
  );
}

// ─── Number Tile ──────────────────────────────────────────────────────────────
class _NumTile extends StatefulWidget {
  final int number;
  final bool done;
  final VoidCallback? onTap;
  const _NumTile(this.number, {this.done = false, this.onTap});
  @override
  State<_NumTile> createState() => _NumTileState();
}

class _NumTileState extends State<_NumTile> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 120)); }
  @override void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => _c.forward(),
    onTapUp:   (_) { _c.reverse(); widget.onTap?.call(); },
    onTapCancel: () => _c.reverse(),
    child: AnimatedBuilder(
      animation: _c,
      builder: (_, child) => Transform.scale(scale: 1 - _c.value * 0.08, child: child),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 66, height: 66,
        decoration: BoxDecoration(
          color: widget.done ? kCorrect.withOpacity(0.15) : kBgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.done ? kCorrect.withOpacity(0.5) : kAccent.withOpacity(0.35),
            width: 1.2)),
        child: Center(child: Text('${widget.number}', style: TextStyle(
          fontSize: 24, fontWeight: FontWeight.w500,
          color: widget.done ? kCorrect : kTextPrim))),
      ),
    ),
  );
}

// ─── Result Screen ────────────────────────────────────────────────────────────
class ResultScreen extends StatelessWidget {
  final LevelConfig config;
  final int score, correct, stars;
  const ResultScreen({super.key, required this.config,
    required this.score, required this.correct, required this.stars});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Result'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded),
        onPressed: () => Navigator.of(context)..pop()..pop()),
    ),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(stars >= 3 ? '🌟' : stars >= 2 ? '🌙' : '☁️',
            style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 14),
          Text(stars >= 3 ? 'Beautiful!' : stars >= 2 ? 'Well done' :
               stars >= 1 ? 'Good try'  : 'Keep going',
            style: const TextStyle(
              fontSize: 26, fontWeight: FontWeight.w500, color: kAccentSoft)),
          const SizedBox(height: 6),
          Text('${config.emoji} ${config.name}',
            style: const TextStyle(color: kTextMuted, fontSize: 15)),
          const SizedBox(height: 32),
          _Stat('Score', '$score'),
          const SizedBox(height: 12),
          _Stat('Correct answers', '$correct'),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Icon(Icons.star_rounded, size: 36,
                color: i < stars ? kStarGold : kTextMuted.withOpacity(0.2))))),
          const SizedBox(height: 36),
          _Btn('Play again', Icons.replay_rounded, kAccent,
            () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => GameScreen(config: config)))),
          const SizedBox(height: 12),
          _Btn('All levels', Icons.grid_view_rounded, kBlue,
            () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const LevelSelectScreen()))),
        ]),
      ),
    ),
  );

  Widget _Stat(String label, String value) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    decoration: BoxDecoration(color: kBgCard, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: kAccent.withOpacity(0.2))),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: kTextMuted, fontSize: 15)),
      Text(value, style: const TextStyle(
        color: kAccentSoft, fontSize: 20, fontWeight: FontWeight.w500)),
    ]),
  );

  Widget _Btn(String label, IconData icon, Color color, VoidCallback onTap) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.35))),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(
            color: color, fontSize: 16, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
}

// ─── Scoreboard Screen ────────────────────────────────────────────────────────
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
      s[i]  = await ScoreService.getBestScore(i);
      st[i] = await ScoreService.getStars(i);
    }
    if (mounted) setState(() { _scores.addAll(s); _stars.addAll(st); });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Scoreboard'), leading: const BackButton()),
    body: ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: 10,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final cfg   = levels[i];
        final score = _scores[i + 1] ?? 0;
        final stars = _stars[i + 1]  ?? 0;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          decoration: BoxDecoration(
            color: kBgCard, borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kAccent.withOpacity(score > 0 ? 0.3 : 0.1))),
          child: Row(children: [
            Text(cfg.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('L${cfg.level} · ${cfg.name}', style: const TextStyle(
                color: kTextPrim, fontSize: 15, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Row(children: List.generate(3, (j) => Icon(Icons.star_rounded, size: 14,
                color: j < stars ? kStarGold : kTextMuted.withOpacity(0.25)))),
            ])),
            Text(score > 0 ? '$score pts' : '—', style: TextStyle(
              color: score > 0 ? kAccentSoft : kTextMuted,
              fontSize: 16, fontWeight: FontWeight.w500)),
          ]),
        );
      },
    ),
  );
}