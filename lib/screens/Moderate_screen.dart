import 'package:flutter/material.dart';

// IMPORT YOUR GAME SCREENS
import 'package:emobuddy_app/games/wh_game_screen.dart';
import 'package:emobuddy_app/games/routing_screen.dart';

class ModerateScreen extends StatefulWidget {
  const ModerateScreen({super.key});

  @override
  State<ModerateScreen> createState() => _ModerateScreenState();
}

class _ModerateScreenState extends State<ModerateScreen>
    with TickerProviderStateMixin {
  late List<AnimationController> _cardControllers;
  late List<Animation<double>> _cardAnimations;

  late final List<_GameItem> games = [
    _GameItem(
      name: 'WH Question Game',
      description: 'Who, What, Where, When, Why & How!',
      imagePath: 'assets/images/wh.jpg',
      emoji: '❓',
      gradientStart: const Color(0xFF667EEA),
      gradientEnd: const Color(0xFF764BA2),
      shadowColor: const Color(0xFF667EEA),
      badge: 'THINK',
      badgeColor: const Color(0xFF5C35A0),

      // NAVIGATION
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WHGameScreen(),
          ),
        );
      },
    ),

    _GameItem(
      name: 'Routine Game',
      description: 'Learn daily routines step by step!',
      imagePath: 'assets/images/routine.jpg',
      emoji: '📅',
      gradientStart: const Color(0xFFFA8231),
      gradientEnd: const Color(0xFFFFD32A),
      shadowColor: const Color(0xFFFA8231),
      badge: 'DAILY',
      badgeColor: const Color(0xFFE55A00),

      // NAVIGATION
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoutingScreen(),
          ),
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
        if (mounted) {
          _cardControllers[i].forward();
        }
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

          // BACKGROUND IMAGE
          SizedBox.expand(
            child: Image.asset(
              'assets/images/moderatebg.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // DARK OVERLAY
          Container(
            color: Colors.black.withOpacity(0.15),
          ),

          // Decorations
          _buildDecorations(),

          // Main Content
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
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 20),
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
            bgColor: const Color(0xFF5C6BC0),
            onTap: () => Navigator.pop(context),
          ),

          const Spacer(),

          const Text(
            'MODERATE',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 3,
            ),
          ),

          const Text(
            ' GAMES',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFFFFF176),
              letterSpacing: 3,
            ),
          ),

          const Spacer(),

          _CircleButton(
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFFFF176),
            bgColor: const Color(0xFF5C6BC0),
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
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🌿', style: TextStyle(fontSize: 18)),
          SizedBox(width: 8),

          Text(
            'Intermediate Level · 2 Games',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),

          SizedBox(width: 8),
          Text('🌿', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildDecorations() {
    return Stack(
      children: [
        Positioned(
          top: 90,
          right: 25,
          child: _FloatingWidget(
            delay: 0,
            child: const Text('❓', style: TextStyle(fontSize: 26)),
          ),
        ),

        Positioned(
          top: 160,
          left: 18,
          child: _FloatingWidget(
            delay: 400,
            child: const Text('📅', style: TextStyle(fontSize: 22)),
          ),
        ),

        Positioned(
          top: 220,
          right: 55,
          child: _FloatingWidget(
            delay: 250,
            child: const Text('✨', style: TextStyle(fontSize: 20)),
          ),
        ),
      ],
    );
  }
}

// GAME CARD

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

    _pressAnimation = Tween(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeInOut,
      ),
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
      onTap: g.onTap,

      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) => _pressController.reverse(),
      onTapCancel: () => _pressController.reverse(),

      child: ScaleTransition(
        scale: _pressAnimation,
        child: Container(
  constraints: const BoxConstraints(
    minHeight: 190,
  ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),

            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                g.gradientStart,
                g.gradientEnd,
              ],
            ),

            boxShadow: [
              BoxShadow(
                color: g.shadowColor.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),

          child: Padding(
            padding: const EdgeInsets.all(24),

            child: Row(
              children: [

                // ROUND IMAGE
                Container(
                  width: 120,
                  height: 120,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 3,
                    ),
                  ),

                  child: ClipOval(
                    child: Image.asset(
                      g.imagePath,
                      fit: BoxFit.cover,

                      errorBuilder: (_, __, ___) {
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

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [

                      // BADGE
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
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        g.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // PLAY BUTTON
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
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
        ),
      ),
    );
  }
}

// GAME MODEL

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

// ROUND ICON BUTTON

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
        width: 50,
        height: 50,

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

        child: Icon(
          icon,
          color: iconColor ?? Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

// FLOATING DECORATIONS

class _FloatingWidget extends StatefulWidget {
  final Widget child;
  final int delay;

  const _FloatingWidget({
    required this.child,
    required this.delay,
  });

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
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
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

      builder: (_, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },

      child: widget.child,
    );
  }
}