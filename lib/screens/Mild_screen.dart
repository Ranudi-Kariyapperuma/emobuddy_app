import 'package:emobuddy_app/games/happy_matching.dart';
import 'package:flutter/material.dart';
import 'package:emobuddy_app/games/angry_balloon.dart';

class MildScreen extends StatefulWidget {
  const MildScreen({super.key});

  @override
  State<MildScreen> createState() => _MildScreenState();
}

class _MildScreenState extends State<MildScreen> with TickerProviderStateMixin {
  late List<AnimationController> _cardControllers;
  late List<Animation<double>> _cardAnimations;
  late final List<_GameItem> games = [
    _GameItem(
      name: 'Balloon Game',
      description: 'Pop & learn with colorful balloons!',
      imagePath: 'assets/images/pandab.jpg',
      emoji: '🎈',
      gradientStart: const Color(0xFFFF6B9D),
      gradientEnd: const Color(0xFFFF8E53),
      shadowColor: const Color(0xFFFF6B9D),
      badge: 'FUN',
      badgeColor: const Color(0xFFFF4081),

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BalloonLearningGame()),
        );
      },
    ),

    _GameItem(
      name: 'Matching Game',
      description: 'Find the pairs & sharpen your memory!',
      imagePath: 'assets/images/catpuzzel.jpg',
      emoji: '🧩',
      gradientStart: const Color(0xFF43E97B),
      gradientEnd: const Color(0xFF38F9D7),
      shadowColor: const Color(0xFF43E97B),
      badge: 'MATCH',
      badgeColor: const Color(0xFF00C853),

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HappyMatchingGame()),
        );
      },
    ),
  ];

  @override
  void initState() {
    super.initState();
    _cardControllers = List.generate(
      games.length,
      (i) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 600 + i * 150),
      ),
    );
    _cardAnimations = _cardControllers.map((c) {
      return CurvedAnimation(parent: c, curve: Curves.elasticOut);
    }).toList();

    for (int i = 0; i < _cardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 200 + i * 150), () {
        if (mounted) _cardControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _cardControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Sky background
          // Background image
          SizedBox.expand(
            child: Image.asset('assets/images/mildbg.jpg', fit: BoxFit.cover),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                const SizedBox(height: 12),
                _buildLevelBadge(),
                const SizedBox(height: 24),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView.separated(
                      itemCount: games.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 20),
                      itemBuilder: (context, i) {
                        return ScaleTransition(
                          scale: _cardAnimations[i],
                          child: _GameCard(game: games[i]),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _CircleButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Text(
            'MILD',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 4,
              shadows: [
                Shadow(
                  color: Color(0x66000000),
                  offset: Offset(0, 3),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const Text(
            ' GAMES',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFFFFF176),
              letterSpacing: 4,
              shadows: [
                Shadow(
                  color: Color(0x66000000),
                  offset: Offset(0, 3),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const Spacer(),
          _CircleButton(
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFFFF176),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildLevelBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🌱', style: TextStyle(fontSize: 18)),
          SizedBox(width: 8),
          Text(
            'Beginner Level · 2 Games',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(width: 8),
          Text('🌱', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildDecorativeBalloons() {
    return Stack(
      children: [
        Positioned(
          top: 80,
          right: 30,
          child: _FloatingWidget(
            delay: 0,
            child: const Text('🎈', style: TextStyle(fontSize: 28)),
          ),
        ),
        Positioned(
          top: 140,
          left: 20,
          child: _FloatingWidget(
            delay: 500,
            child: const Text('🎀', style: TextStyle(fontSize: 22)),
          ),
        ),
        Positioned(
          top: 200,
          right: 60,
          child: _FloatingWidget(
            delay: 300,
            child: const Text('⭐', style: TextStyle(fontSize: 20)),
          ),
        ),
      ],
    );
  }

  Widget _buildClouds() {
    return Stack(
      children: [
        Positioned(top: 30, left: -20, child: _Cloud(width: 120, opacity: 0.9)),
        Positioned(top: 50, right: 40, child: _Cloud(width: 90, opacity: 0.7)),
        Positioned(top: 20, left: 140, child: _Cloud(width: 70, opacity: 0.6)),
      ],
    );
  }

  Widget _buildGrassHills() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: CustomPaint(
        size: const Size(double.infinity, 120),
        painter: _GrassPainter(),
      ),
    );
  }
}

// ─── Game Card ────────────────────────────────────────────────────────────────

class _GameCard extends StatefulWidget {
  final _GameItem game;
  const _GameCard({required this.game});

  @override
  State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _pressAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pressAnimation = Tween(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.game;
    return GestureDetector(
      onTap: widget.game.onTap,
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) => _pressController.reverse(),
      onTapCancel: () => _pressController.reverse(),
      child: ScaleTransition(
        scale: _pressAnimation,
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [g.gradientStart, g.gradientEnd],
            ),
            boxShadow: [
              BoxShadow(
                color: g.shadowColor.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // Background bubbles
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
              ),
              Positioned(
                right: 30,
                bottom: -30,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    // Game image / emoji placeholder
                    // In _GameItem, you can remove the emoji field if you want,
                    // or keep it as fallback. The imagePath is already there.

                    // Inside _GameCard build(), replace the emoji container with this:
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, // ← round shape
                        color: Colors.white.withOpacity(0.25),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 2.5,
                        ),
                      ),
                      child: ClipOval(
                        // ← clips image to circle
                        child: Image.asset(
                          g.imagePath,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover, // ← fills the circle
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to emoji if image missing
                            return Center(
                              child: Text(
                                g.emoji,
                                style: const TextStyle(fontSize: 52),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Text info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: g.badgeColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              g.badge,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            g.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                              height: 1.1,
                              shadows: [
                                Shadow(
                                  color: Color(0x44000000),
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            g.description,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Play button
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.play_arrow_rounded,
                                  color: g.gradientStart,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Play Now',
                                  style: TextStyle(
                                    color: g.gradientStart,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _GameItem {
  final String name;
  final String description;
  final String imagePath;
  final String emoji;
  final Color gradientStart;
  final Color gradientEnd;
  final Color shadowColor;
  final String badge;
  final Color badgeColor;

  final VoidCallback onTap;

  const _GameItem({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.emoji,
    required this.gradientStart,
    required this.gradientEnd,
    required this.shadowColor,
    required this.badge,
    required this.badgeColor,
    required this.onTap,
  });
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF2196F3),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2196F3).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor ?? Colors.white, size: 24),
      ),
    );
  }
}

class _Cloud extends StatelessWidget {
  final double width;
  final double opacity;
  const _Cloud({required this.width, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: width,
        height: width * 0.5,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    );
  }
}

class _FloatingWidget extends StatefulWidget {
  final Widget child;
  final int delay;
  const _FloatingWidget({required this.child, required this.delay});

  @override
  State<_FloatingWidget> createState() => _FloatingWidgetState();
}

class _FloatingWidgetState extends State<_FloatingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _animation = Tween(
      begin: 0.0,
      end: -12.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _animation.value),
        child: child,
      ),
      child: widget.child,
    );
  }
}

class _GrassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF388E3C);
    final path = Path();
    path.moveTo(0, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.2,
      size.width * 0.5,
      size.height * 0.45,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.65,
      size.width,
      size.height * 0.4,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);

    final paint2 = Paint()..color = const Color(0xFF2E7D32);
    final path2 = Path();
    path2.moveTo(0, size.height * 0.7);
    path2.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.5,
      size.width * 0.6,
      size.height * 0.7,
    );
    path2.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.85,
      size.width,
      size.height * 0.65,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(_) => false;
}
