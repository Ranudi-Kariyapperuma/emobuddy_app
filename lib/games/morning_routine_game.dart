import 'package:flutter/material.dart';
import '../../services/tts_service.dart'; // adjust path to your tts_service.dart

// ─────────────────────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────────────────────
class RoutineStep {
  final String id;
  final String instruction; // TTS text
  final String scene; // which scene widget to show
  final String draggableLabel;
  final String draggableEmoji;
  final String successMessage;
  final String background;

  const RoutineStep({
    required this.id,
    required this.instruction,
    required this.scene,
    required this.draggableLabel,
    required this.draggableEmoji,
    required this.successMessage,
    required this.background,
  });
}

const List<RoutineStep> _morningSteps = [
  RoutineStep(
    id: 'wake_up',
    instruction: 'Good morning! Time to wake up! Tap the alarm clock!',
    scene: 'wake_up',
    draggableLabel: 'Alarm',
    draggableEmoji: '⏰',
    successMessage: 'Great! You woke up!',
    background: 'bedroom',
  ),
  RoutineStep(
    id: 'brush_teeth',
    instruction:
        'Now take the toothbrush and give it to the child to brush teeth!',
    scene: 'brush_teeth',
    draggableLabel: 'Toothbrush',
    draggableEmoji: '🪥',
    successMessage: 'Amazing! Brushing teeth keeps them healthy!',
    background: 'bathroom',
  ),
  RoutineStep(
    id: 'wash_face',
    instruction: 'Splash! Drag the water to wash your face!',
    scene: 'wash_face',
    draggableLabel: 'Water',
    draggableEmoji: '💧',
    successMessage: 'Wonderful! Your face is so clean!',
    background: 'bathroom',
  ),
  RoutineStep(
    id: 'eat_breakfast',
    instruction: 'Yummy! Drag the spoon to eat your breakfast!',
    scene: 'breakfast',
    draggableLabel: 'Spoon',
    draggableEmoji: '🥄',
    successMessage: 'Delicious! You ate your breakfast!',
    background: 'kitchen',
  ),
  RoutineStep(
    id: 'wear_bag',
    instruction: 'Last step! Pick up your school bag to go to school!',
    scene: 'school_bag',
    draggableLabel: 'School Bag',
    draggableEmoji: '🎒',
    successMessage: 'Hooray! You are ready for school! Great job!',
    background: 'bedroom',
  ),
];

Widget _buildBackground(String bg) {
  String imagePath;

  switch (bg) {
    case 'bedroom':
      imagePath = 'assets/images/bedroom.jpg';
      break;
    case 'bathroom':
      imagePath = 'assets/images/bathroom.jpg';
      break;
    case 'kitchen':
      imagePath = 'assets/images/kitchen.jpg';
      break;
    default:
      return Container(color: Colors.white);
  }

  return SizedBox.expand(
    child: Image.asset(
      imagePath,
      fit: BoxFit.cover,
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// MAIN GAME WIDGET
// ─────────────────────────────────────────────────────────────
class MorningRoutineGame extends StatefulWidget {
  const MorningRoutineGame({super.key});

  @override
  State<MorningRoutineGame> createState() => _MorningRoutineGameState();
}

class _MorningRoutineGameState extends State<MorningRoutineGame>
    with TickerProviderStateMixin {
  final TTSService _tts = TTSService();

  int _currentStep = 0;
  bool _stepDone = false;
  bool _showCelebration = false;
  bool _gameComplete = false;

  late AnimationController _kidController;
  late Animation<double> _kidBounce;
  late AnimationController _celebController;
  late Animation<double> _celebScale;

  @override
  void initState() {
    super.initState();
    _tts.init().then((_) => _speakInstruction());

    _kidController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _kidBounce = Tween(
      begin: 0.0,
      end: -12.0,
    ).animate(CurvedAnimation(parent: _kidController, curve: Curves.easeInOut));

    _celebController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _celebScale = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _celebController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    _kidController.dispose();
    _celebController.dispose();
    super.dispose();
  }

  void _speakInstruction() {
    if (_currentStep < _morningSteps.length) {
      _tts.speak(_morningSteps[_currentStep].instruction);
    }
  }

  void _onItemDropped() async {
    if (_stepDone) return;
    setState(() => _stepDone = true);

    // Kid bounces
    _kidController.repeat(reverse: true);

    final step = _morningSteps[_currentStep];
    await _tts.speak(step.successMessage);

    _kidController.stop();
    _kidController.reset();

    // Show celebration overlay
    setState(() => _showCelebration = true);
    _celebController.forward(from: 0);

    await Future.delayed(const Duration(milliseconds: 1800));

    if (_currentStep + 1 >= _morningSteps.length) {
      setState(() {
        _gameComplete = true;
        _showCelebration = false;
      });
      await _tts.speak(
        'You finished the morning routine! What a superstar! Well done!',
      );
    } else {
      setState(() {
        _currentStep++;
        _stepDone = false;
        _showCelebration = false;
      });
      _celebController.reset();
      _speakInstruction();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_gameComplete) return _CompletionScreen(onReplay: _replay);

    final step = _morningSteps[_currentStep];

    return Scaffold(
      backgroundColor: const Color(0xFFB388FF),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _TopBar(
                  currentStep: _currentStep,
                  totalSteps: _morningSteps.length,
                  onBack: () => Navigator.pop(context),
                  onRepeat: _speakInstruction,
                ),
                _ProgressDots(
                  current: _currentStep,
                  total: _morningSteps.length,
                ),
                const SizedBox(height: 8),

                // Scene
                Expanded(
                  child: _SceneWidget(
                    step: step,
                    stepDone: _stepDone,
                    kidBounce: _kidBounce,
                    onDropped: _onItemDropped,
                  ),
                ),

                // Instruction banner
                _InstructionBanner(text: step.instruction),
                const SizedBox(height: 12),
              ],
            ),

            // Celebration overlay
            if (_showCelebration)
              ScaleTransition(
                scale: _celebScale,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🌟', style: TextStyle(fontSize: 60)),
                        const SizedBox(height: 8),
                        Text(
                          step.successMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E1B4B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _replay() {
    setState(() {
      _currentStep = 0;
      _stepDone = false;
      _gameComplete = false;
      _showCelebration = false;
    });
    _speakInstruction();
  }
}

// ─────────────────────────────────────────────────────────────
// TOP BAR
// ─────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onBack;
  final VoidCallback onRepeat;

  const _TopBar({
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
    required this.onRepeat,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF7C3AED),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Morning Routine',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Step ${currentStep + 1} of $totalSteps',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRepeat,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.volume_up_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PROGRESS DOTS
// ─────────────────────────────────────────────────────────────
class _ProgressDots extends StatelessWidget {
  final int current;
  final int total;
  const _ProgressDots({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final done = i < current;
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 28 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: done
                ? const Color(0xFFFFD700)
                : active
                ? Colors.white
                : Colors.white.withOpacity(0.35),
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SCENE WIDGET  (the big illustrated area)
// ─────────────────────────────────────────────────────────────
class _SceneWidget extends StatelessWidget {
  final RoutineStep step;
  final bool stepDone;
  final Animation<double> kidBounce;
  final VoidCallback onDropped;

  const _SceneWidget({
    required this.step,
    required this.stepDone,
    required this.kidBounce,
    required this.onDropped,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF3EAFF),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: _buildScene(context),
        ),
      ),
    );
  }

  Widget _buildScene(BuildContext context) {
    switch (step.scene) {
      case 'brush_teeth':
        return _BrushTeethScene(
          stepDone: stepDone,
          kidBounce: kidBounce,
          onDropped: onDropped,
          step: step,
        );
      case 'wake_up':
        return _GenericScene(
          emoji: '🛏️',
          bgColor: const Color(0xFFE0F2FE),
          stepDone: stepDone,
          kidBounce: kidBounce,
          onDropped: onDropped,
          step: step,
        );
      case 'wash_face':
        return _GenericScene(
          emoji: '🚿',
          bgColor: const Color(0xFFE0F7FA),
          stepDone: stepDone,
          kidBounce: kidBounce,
          onDropped: onDropped,
          step: step,
        );
      case 'breakfast':
        return _BreakfastScene(
          stepDone: stepDone,
          kidBounce: kidBounce,
          onDropped: onDropped,
          step: step,
        );
      default:
        return _GenericScene(
          emoji: '🎒',
          bgColor: const Color(0xFFF0FFF4),
          stepDone: stepDone,
          kidBounce: kidBounce,
          onDropped: onDropped,
          step: step,
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────
// BRUSH TEETH SCENE  (detailed, matches screenshot aesthetic)
// ─────────────────────────────────────────────────────────────
class _BrushTeethScene extends StatelessWidget {
  final bool stepDone;
  final Animation<double> kidBounce;
  final VoidCallback onDropped;
  final RoutineStep step;

  const _BrushTeethScene({
    required this.stepDone,
    required this.kidBounce,
    required this.onDropped,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background: bathroom tiles
       Positioned.fill(child: _buildBackground(step.background)),
        // Sink
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: CustomPaint(
            size: const Size(double.infinity, 100),
            painter: _SinkPainter(),
          ),
        ),

        
        // Kid (animated bounce)
        Positioned(
          bottom: 60,
          left: 0,
          right: 0,
          child: AnimatedBuilder(
            animation: kidBounce,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, kidBounce.value),
              child: child,
            ),
            child: _KidCharacter(
              isBrushing: stepDone,
              expression: stepDone ? '😁' : '🙂',
            ),
          ),
        ),

        // Toothbrush (draggable)
        if (!stepDone)
          Positioned(
            bottom: 70,
            right: 40,
            child: Draggable<String>(
              data: 'toothbrush',
              feedback: _DraggableItem(
                emoji: step.draggableEmoji,
                label: step.draggableLabel,
              ),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: _DraggableItem(
                  emoji: step.draggableEmoji,
                  label: step.draggableLabel,
                ),
              ),
              child: _DraggableItem(
                emoji: step.draggableEmoji,
                label: step.draggableLabel,
              ),
            ),
          ),

        // Drop target on kid
        Positioned(
          bottom: 110,
          left: 0,
          right: 0,
          child: Center(
            child: DragTarget<String>(
              onWillAcceptWithDetails: (d) => !stepDone,
              onAcceptWithDetails: (_) => onDropped(),
              builder: (_, candidateData, __) {
                final hovering = candidateData.isNotEmpty;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: stepDone
                        ? Colors.green.withOpacity(0.3)
                        : hovering
                        ? Colors.orange.withOpacity(0.4)
                        : Colors.white.withOpacity(0.2),
                    border: Border.all(
                      color: stepDone
                          ? Colors.green
                          : hovering
                          ? Colors.orange
                          : Colors.white.withOpacity(0.5),
                      width: 2.5,
                    ),
                  ),
                  child: stepDone
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
                          size: 40,
                        )
                      : Icon(
                          Icons.touch_app_rounded,
                          color: Colors.white.withOpacity(0.7),
                          size: 30,
                        ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// BREAKFAST SCENE
// ─────────────────────────────────────────────────────────────
class _BreakfastScene extends StatelessWidget {
  final bool stepDone;
  final Animation<double> kidBounce;
  final VoidCallback onDropped;
  final RoutineStep step;

  const _BreakfastScene({
    required this.stepDone,
    required this.kidBounce,
    required this.onDropped,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // BG
        Positioned.fill(child: _buildBackground(step.background)),
        // Table
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF80DEEA).withOpacity(0.6),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: CustomPaint(painter: _CheckeredPainter()),
          ),
        ),

        // Bowl
        Positioned(
          bottom: 55,
          left: 0,
          right: 0,
          child: Center(
            child: Text('🍚', style: TextStyle(fontSize: stepDone ? 70 : 60)),
          ),
        ),

        // Kid
        Positioned(
          bottom: 80,
          left: 0,
          right: 0,
          child: AnimatedBuilder(
            animation: kidBounce,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, kidBounce.value),
              child: child,
            ),
            child: _KidCharacter(
              isBrushing: stepDone,
              expression: stepDone ? '😋' : '🙂',
            ),
          ),
        ),

        // Drop target
        Positioned(
          bottom: 115,
          left: 0,
          right: 0,
          child: Center(
            child: DragTarget<String>(
              onWillAcceptWithDetails: (_) => !stepDone,
              onAcceptWithDetails: (_) => onDropped(),
              builder: (_, candidateData, __) {
                final hovering = candidateData.isNotEmpty;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: stepDone
                        ? Colors.green.withOpacity(0.3)
                        : hovering
                        ? Colors.orange.withOpacity(0.4)
                        : Colors.white.withOpacity(0.2),
                    border: Border.all(
                      color: stepDone
                          ? Colors.green
                          : hovering
                          ? Colors.orange
                          : Colors.white.withOpacity(0.5),
                      width: 2.5,
                    ),
                  ),
                  child: stepDone
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
                          size: 36,
                        )
                      : const SizedBox.shrink(),
                );
              },
            ),
          ),
        ),

        // Spoon (draggable)
        if (!stepDone)
          Positioned(
            bottom: 60,
            right: 50,
            child: Draggable<String>(
              data: 'spoon',
              feedback: _DraggableItem(
                emoji: step.draggableEmoji,
                label: step.draggableLabel,
              ),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: _DraggableItem(
                  emoji: step.draggableEmoji,
                  label: step.draggableLabel,
                ),
              ),
              child: _DraggableItem(
                emoji: step.draggableEmoji,
                label: step.draggableLabel,
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// GENERIC SCENE (reused for wake_up, wash_face, school_bag)
// ─────────────────────────────────────────────────────────────
class _GenericScene extends StatelessWidget {
  final String emoji;
  final Color bgColor;
  final bool stepDone;
  final Animation<double> kidBounce;
  final VoidCallback onDropped;
  final RoutineStep step;

  const _GenericScene({
    required this.emoji,
    required this.bgColor,
    required this.stepDone,
    required this.kidBounce,
    required this.onDropped,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: _buildBackground(step.background)),

        // Background emoji
        Positioned(
          top: 20,
          right: 30,
          child: Opacity(
            opacity: 0.2,
            child: Text(emoji, style: const TextStyle(fontSize: 90)),
          ),
        ),

        // Kid
        Positioned(
          bottom: 60,
          left: 0,
          right: 0,
          child: AnimatedBuilder(
            animation: kidBounce,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, kidBounce.value),
              child: child,
            ),
            child: _KidCharacter(
              isBrushing: stepDone,
              expression: stepDone ? '😄' : '😊',
            ),
          ),
        ),

        // Drop target on kid
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Center(
            child: DragTarget<String>(
              onWillAcceptWithDetails: (_) => !stepDone,
              onAcceptWithDetails: (_) => onDropped(),
              builder: (_, candidateData, __) {
                final hovering = candidateData.isNotEmpty;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: stepDone
                        ? Colors.green.withOpacity(0.25)
                        : hovering
                        ? Colors.orange.withOpacity(0.35)
                        : Colors.white.withOpacity(0.25),
                    border: Border.all(
                      color: stepDone
                          ? Colors.green
                          : hovering
                          ? Colors.orange
                          : Colors.white54,
                      width: 2.5,
                    ),
                  ),
                  child: stepDone
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
                          size: 38,
                        )
                      : Icon(
                          Icons.touch_app_rounded,
                          color: Colors.white70,
                          size: 28,
                        ),
                );
              },
            ),
          ),
        ),

        // Draggable item
        if (!stepDone)
          Positioned(
            bottom: 60,
            left: 40,
            child: Draggable<String>(
              data: step.id,
              feedback: _DraggableItem(
                emoji: step.draggableEmoji,
                label: step.draggableLabel,
              ),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: _DraggableItem(
                  emoji: step.draggableEmoji,
                  label: step.draggableLabel,
                ),
              ),
              child: _DraggableItem(
                emoji: step.draggableEmoji,
                label: step.draggableLabel,
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// KID CHARACTER (drawn with Flutter widgets)
// ─────────────────────────────────────────────────────────────
class _KidCharacter extends StatelessWidget {
  final bool isBrushing;
  final String expression; // kept for API compatibility, ignored visually

  const _KidCharacter({this.isBrushing = false, this.expression = '🙂'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 160,
        height: 200,
        child: CustomPaint(painter: _KidPainter(isBrushing: isBrushing)),
      ),
    );
  }
}

class _KidPainter extends CustomPainter {
  final bool isBrushing;
  _KidPainter({required this.isBrushing});

  static const skin = Color(0xFFFFCC99);
  static const skinD = Color(0xFFE8A870);
  static const hairC = Color(0xFF6B3A1F);
  static const hairL = Color(0xFF8B4F2A);
  static const red = Color(0xFFE84530);
  static const redD = Color(0xFFC03020);
  static const bib = Color(0xFF7B5EA7);
  static const eyeDark = Color(0xFF3D1F0A);
  static const eyeMid = Color(0xFF5A2D0C);
  static const cheekC = Color(0xFFFF9977);
  static const lipFill = Color(0xFFCC4433);
  static const lipLine = Color(0xFFAA3322);
  static const shoeC = Color(0xFF8B5A2B);
  static const gold = Color(0xFFFFD700);

  Paint f(Color c) => Paint()
    ..color = c
    ..style = PaintingStyle.fill;
  Paint st(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round;

  void oval(Canvas cv, Paint p, double x, double y, double rx, double ry) =>
      cv.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: rx * 2, height: ry * 2),
        p,
      );

  void rr(
    Canvas cv,
    Paint p,
    double x,
    double y,
    double w,
    double h,
    double r,
  ) => cv.drawRRect(
    RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r)),
    p,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2; // 80
    final cy = size.height; // 200

    _shadow(canvas, cx, cy);
    _legs(canvas, cx, cy);
    _dress(canvas, cx);
    _leftArm(canvas, cx);
    _rightArm(canvas, cx);
    if (isBrushing) _toothbrush(canvas, cx);
    _neck(canvas, cx);
    _ears(canvas, cx);
    _head(canvas, cx);
    _hair(canvas, cx);
    _eyebrows(canvas, cx);
    _eyes(canvas, cx);
    _nose(canvas, cx);
    _cheeks(canvas, cx);
    _mouth(canvas, cx);
    if (isBrushing) _foam(canvas, cx);
  }

  void _shadow(Canvas cv, double cx, double cy) =>
      oval(cv, f(const Color(0xFFDDD0C0).withOpacity(.4)), cx, cy - 6, 52, 7);

  void _legs(Canvas cv, double cx, double cy) {
    rr(cv, f(skin), cx - 28, cy - 90, 24, 72, 11);
    rr(cv, f(skin), cx + 4, cy - 90, 24, 72, 11);
    // socks
    rr(cv, f(Colors.white), cx - 30, cy - 38, 28, 22, 9);
    rr(cv, f(Colors.white), cx + 2, cy - 38, 28, 22, 9);
    // shoes
    oval(cv, f(shoeC), cx - 16, cy - 10, 20, 10);
    oval(cv, f(shoeC), cx + 16, cy - 10, 20, 10);
  }

  void _dress(Canvas cv, double cx) {
    // skirt flare
    final skirt = Path()
      ..moveTo(cx - 42, 118)
      ..quadraticBezierTo(cx - 58, 168, cx - 48, 122 + 88)
      ..quadraticBezierTo(cx, 222 + 10, cx + 48, 122 + 88)
      ..quadraticBezierTo(cx + 58, 168, cx + 42, 118)
      ..close();
    cv.drawPath(skirt, f(red));
    // bodice
    rr(cv, f(red), cx - 36, 82, 72, 52, 14);
    // bib panel
    rr(cv, f(bib), cx - 20, 88, 40, 42, 10);
    // collar
    final collar = Path()
      ..moveTo(cx - 20, 85)
      ..quadraticBezierTo(cx, 96, cx + 20, 85);
    cv.drawPath(collar, st(Colors.white, 2.5));
    // waist
    rr(cv, f(redD.withOpacity(.45)), cx - 36, 126, 72, 10, 4);
  }

  void _leftArm(Canvas cv, double cx) {
    cv.save();
    cv.translate(cx - 36, 90);
    cv.rotate(isBrushing ? -0.85 : 0.25);
    rr(cv, f(skin), -12, 0, 22, 62, 11);
    oval(cv, f(skin), -1, 66, 11, 10);
    cv.restore();
  }

  void _rightArm(Canvas cv, double cx) {
    cv.save();
    cv.translate(cx + 36, 90);
    cv.rotate(isBrushing ? 0.85 : -0.25);
    rr(cv, f(skin), -10, 0, 22, 62, 11);
    oval(cv, f(skin), 1, 66, 11, 10);
    cv.restore();
  }

  void _toothbrush(Canvas cv, double cx) {
    cv.save();
    cv.translate(cx - 48, 88);
    cv.rotate(-0.65);
    rr(cv, f(const Color(0xFF4CAF7D)), -8, 0, 16, 68, 8);
    rr(cv, f(Colors.white), -9, -26, 18, 28, 7);
    rr(cv, st(const Color(0xFF4CAF7D), 1.2), -9, -26, 18, 28, 7);
    final bp = st(const Color(0xFF88CCAA), 1.4);
    for (final x in [-3.0, 2.0, 7.0]) {
      cv.drawLine(Offset(x, -20), Offset(x, -4), bp);
    }
    cv.restore();
  }

  void _neck(Canvas cv, double cx) => rr(cv, f(skin), cx - 11, 68, 22, 22, 8);

  void _ears(Canvas cv, double cx) {
    for (final sign in [-1.0, 1.0]) {
      final ex = cx + sign * 44;
      oval(cv, f(skin), ex, 46, 10, 13);
      oval(cv, f(skinD), ex, 46, 6, 8);
      cv.drawCircle(Offset(ex, 46), 3.5, f(gold));
    }
  }

  void _head(Canvas cv, double cx) {
    oval(cv, f(skin), cx, 36, 52, 54);
    oval(cv, f(skinD.withOpacity(.09)), cx, 48, 38, 36);
  }

  void _hair(Canvas cv, double cx) {
    oval(cv, f(hairC), cx, 10, 52, 26);
    // side curls
    for (final sign in [-1.0, 1.0]) {
      oval(cv, f(hairC), cx + sign * 50, 32, 12, 30);
      oval(cv, f(hairC), cx + sign * 48, 56, 10, 16);
    }
    oval(cv, f(hairC), cx, 6, 48, 22);
    // curl texture
    final cp = st(hairL, 2.2);
    for (final dx in [-18.0, 4.0]) {
      final p = Path()
        ..moveTo(cx + dx, 6)
        ..quadraticBezierTo(cx + dx + 8, -2, cx + dx + 16, 5);
      cv.drawPath(p, cp);
    }
    oval(cv, f(Colors.white.withOpacity(.1)), cx - 10, 8, 11, 5);
  }

  void _eyebrows(Canvas cv, double cx) {
    final bp = st(const Color(0xFF4A2408), 2.8);
    for (final sign in [-1.0, 1.0]) {
      final ex = cx + sign * 20;
      final p = Path()
        ..moveTo(ex - sign * 10, 26)
        ..quadraticBezierTo(ex, 19, ex + sign * 10, 23);
      cv.drawPath(p, bp);
    }
  }

  void _eyes(Canvas cv, double cx) {
    final lash = st(eyeDark, 1.6);
    for (final sign in [-1.0, 1.0]) {
      final ex = cx + sign * 20;
      oval(cv, f(Colors.white), ex, 38, 11, 12);
      oval(cv, f(eyeDark), ex + 1, 39, 8, 9);
      oval(cv, f(eyeMid), ex + 1, 38, 5, 5.5);
      cv.drawCircle(Offset(ex + 4, 33), 3, f(Colors.white));
      // lashes
      for (int i = -1; i <= 1; i++) {
        cv.drawLine(
          Offset(ex - 5 + i * 5.0, 28),
          Offset(ex - 5 + i * 5.0 + sign * 0.5, 22),
          lash,
        );
      }
    }
  }

  void _nose(Canvas cv, double cx) {
    oval(cv, f(skinD.withOpacity(.6)), cx, 50, 5, 3.5);
    cv.drawCircle(
      Offset(cx - 3, 50),
      1.5,
      f(const Color(0xFFC87A40).withOpacity(.5)),
    );
    cv.drawCircle(
      Offset(cx + 3, 50),
      1.5,
      f(const Color(0xFFC87A40).withOpacity(.5)),
    );
  }

  void _cheeks(Canvas cv, double cx) {
    final p = f(cheekC.withOpacity(.4));
    oval(cv, p, cx - 34, 56, 12, 8);
    oval(cv, p, cx + 34, 56, 12, 8);
  }

  void _mouth(Canvas cv, double cx) {
    if (isBrushing) {
      final outer = Path()
        ..moveTo(cx - 16, 62)
        ..quadraticBezierTo(cx, 76, cx + 16, 62);
      cv.drawPath(outer, f(lipFill));
      cv.drawPath(outer, st(lipLine, 1.5));
      final inner = Path()
        ..moveTo(cx - 16, 62)
        ..quadraticBezierTo(cx, 70, cx + 16, 62);
      cv.drawPath(inner, f(Colors.white));
      final tp = st(const Color(0xFFDDDDDD), 1.0);
      for (final dx in [-5.0, 3.0, 11.0]) {
        cv.drawLine(Offset(cx - 8 + dx, 62), Offset(cx - 8 + dx, 70), tp);
      }
    } else {
      final p = Path()
        ..moveTo(cx - 14, 60)
        ..quadraticBezierTo(cx, 72, cx + 14, 60);
      cv.drawPath(p, st(lipLine, 2.2));
    }
  }

  void _foam(Canvas cv, double cx) {
    final p = f(Colors.white.withOpacity(.85));
    oval(cv, p, cx + 20, 60, 7, 4.5);
    oval(cv, p, cx + 16, 66, 5, 3.5);
    oval(cv, p, cx + 24, 66, 4.5, 3);
  }

  @override
  bool shouldRepaint(_KidPainter o) => o.isBrushing != isBrushing;
}

// ─────────────────────────────────────────────────────────────
// DRAGGABLE ITEM WIDGET
// ─────────────────────────────────────────────────────────────
class _DraggableItem extends StatelessWidget {
  final String emoji;
  final String label;

  const _DraggableItem({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 36)),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E1B4B),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// INSTRUCTION BANNER
// ─────────────────────────────────────────────────────────────
class _InstructionBanner extends StatelessWidget {
  final String text;
  const _InstructionBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFEDE9FE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.record_voice_over_rounded,
                color: Color(0xFF7C3AED),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E1B4B),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// COMPLETION SCREEN
// ─────────────────────────────────────────────────────────────
class _CompletionScreen extends StatelessWidget {
  final VoidCallback onReplay;
  const _CompletionScreen({required this.onReplay});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB388FF),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '🌟🎉🌟',
                  style: TextStyle(fontSize: 60),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Amazing Job! 🏆',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E1B4B),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'You completed your\nmorning routine!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6B7280),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          5,
                          (i) => const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Text('⭐', style: TextStyle(fontSize: 28)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onReplay,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.replay_rounded, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Play Again',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.home_rounded,
                                color: Color(0xFF7C3AED),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Home',
                                style: TextStyle(
                                  color: Color(0xFF7C3AED),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CUSTOM PAINTERS
// ─────────────────────────────────────────────────────────────
class _SinkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFB0BEC5);
    final oval = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.4),
      width: size.width * 0.5,
      height: 50,
    );
    canvas.drawOval(oval, paint);

    final counterPaint = Paint()..color = const Color(0xFFECEFF1);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.5, size.width, size.height * 0.5),
      counterPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CheckeredPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF4DD0E1).withOpacity(0.3);
    const cellSize = 30.0;
    for (double x = 0; x < size.width; x += cellSize) {
      for (double y = 0; y < size.height; y += cellSize) {
        if (((x / cellSize).round() + (y / cellSize).round()) % 2 == 0) {
          canvas.drawRect(Rect.fromLTWH(x, y, cellSize, cellSize), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
