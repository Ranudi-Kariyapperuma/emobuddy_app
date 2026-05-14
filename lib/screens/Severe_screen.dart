import 'package:flutter/material.dart';

class SevereScreen extends StatefulWidget {
  const SevereScreen({super.key});

  @override
  State<SevereScreen> createState() => _SevereScreenState();
}

class _SevereScreenState extends State<SevereScreen>
    with TickerProviderStateMixin {
  late List<AnimationController> _cardControllers;
  late List<Animation<double>> _cardAnimations;

  final List<_GameItem> games = const [
    _GameItem(
      name: 'Fruit & Vegetable Sort',
      description: 'Sort fruits & veggies into the right baskets!',
      imagePath: 'assets/images/fruit_veg_sort_game.png',
      emoji: '🍎',
      gradientStart: Color(0xFFFF5F6D),
      gradientEnd: Color(0xFFFFC371),
      shadowColor: Color(0xFFFF5F6D),
      badge: 'SORT',
      badgeColor: Color(0xFFD32F2F),
    ),
    _GameItem(
      name: 'Puzzle Game',
      description: 'Put the pieces together & solve it!',
      imagePath: 'assets/images/puzzle_game.png',
      emoji: '🧩',
      gradientStart: Color(0xFF11998E),
      gradientEnd: Color(0xFF38EF7D),
      shadowColor: Color(0xFF11998E),
      badge: 'SOLVE',
      badgeColor: Color(0xFF00796B),
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
          // Deep teal-to-green sky
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF00BCD4),
                  Color(0xFF0097A7),
                  Color(0xFF388E3C),
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // Clouds
          _buildClouds(),

          // Ground hills
          _buildGrassHills(),

          // Floating decoratives
          _buildDecorations(),

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
                const SizedBox(height: 20),
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
            bgColor: const Color(0xFF00838F),
            onTap: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Text(
            'SEVERE',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 3,
              shadows: [
                Shadow(color: Color(0x66000000), offset: Offset(0, 3), blurRadius: 6),
              ],
            ),
          ),
          const Text(
            ' GAMES',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFFFFF176),
              letterSpacing: 3,
              shadows: [
                Shadow(color: Color(0x66000000), offset: Offset(0, 3), blurRadius: 6),
              ],
            ),
          ),
          const Spacer(),
          _CircleButton(
            icon: Icons.emoji_events_rounded,
            iconColor: const Color(0xFFFFF176),
            bgColor: const Color(0xFF00838F),
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
          Text('🏆', style: TextStyle(fontSize: 18)),
          SizedBox(width: 8),
          Text(
            'Advanced Level · 2 Games',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(width: 8),
          Text('🏆', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildDecorations() {
    return Stack(
      children: [
        Positioned(
          top: 85,
          right: 28,
          child: _FloatingWidget(
            delay: 0,
            child: const Text('🍎', style: TextStyle(fontSize: 26)),
          ),
        ),
        Positioned(
          top: 155,
          left: 20,
          child: _FloatingWidget(
            delay: 350,
            child: const Text('🥕', style: TextStyle(fontSize: 22)),
          ),
        ),
        Positioned(
          top: 215,
          right: 60,
          child: _FloatingWidget(
            delay: 200,
            child: const Text('🌟', style: TextStyle(fontSize: 20)),
          ),
        ),
      ],
    );
  }

  Widget _buildClouds() {
    return Stack(
      children: [
        Positioned(top: 25, left: -15, child: _Cloud(width: 115, opacity: 0.85)),
        Positioned(top: 50, right: 35, child: _Cloud(width: 88, opacity: 0.7)),
        Positioned(top: 18, left: 135, child: _Cloud(width: 68, opacity: 0.6)),
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
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) => _pressController.reverse(),
      onTapCancel: () => _pressController.reverse(),
      child: ScaleTransition(
        scale: _pressAnimation,
        child: Container(
          height: 180,
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
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 2.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Replace with your image:
                          // Image.asset(g.imagePath, width: 80, height: 80, fit: BoxFit.contain),
                          Text(g.emoji, style: const TextStyle(fontSize: 52)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
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
  });
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final Color bgColor;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.bgColor,
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
          color: bgColor,
          boxShadow: [
            BoxShadow(
              color: bgColor.withOpacity(0.4),
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
    _animation = Tween(begin: 0.0, end: -12.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
    final paint = Paint()..color = const Color(0xFF2E7D32);
    final path = Path();
    path.moveTo(0, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.2,
        size.width * 0.5, size.height * 0.45);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.65, size.width, size.height * 0.4);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);

    final paint2 = Paint()..color = const Color(0xFF1B5E20);
    final path2 = Path();
    path2.moveTo(0, size.height * 0.7);
    path2.quadraticBezierTo(size.width * 0.3, size.height * 0.5,
        size.width * 0.6, size.height * 0.7);
    path2.quadraticBezierTo(
        size.width * 0.8, size.height * 0.85, size.width, size.height * 0.65);
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(_) => false;
}
