import 'package:flutter/material.dart';

// IMPORT YOUR GAME SCREENS
import 'package:emobuddy_app/games/fruitvegisort.dart';
import 'package:emobuddy_app/games/puzzel.dart';

class SevereScreen extends StatefulWidget {
  const SevereScreen({super.key});

  @override
  State<SevereScreen> createState() => _SevereScreenState();
}

class _SevereScreenState extends State<SevereScreen>
    with TickerProviderStateMixin {
  late List<AnimationController> _cardControllers;
  late List<Animation<double>> _cardAnimations;

  late final List<_GameItem> games = [
    _GameItem(
      name: 'Fruit & Vegetable Sort',
      description: 'Sort fruits & veggies into the right baskets!',
      imagePath: 'assets/images/sort.jpg',
      emoji: '🍎',
      gradientStart: const Color(0xFFFF5F6D),
      gradientEnd: const Color(0xFFFFC371),
      shadowColor: const Color(0xFFFF5F6D),
      badge: 'SORT',
      badgeColor: const Color(0xFFD32F2F),

      // NAVIGATION
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FruitVegiSortGame(),
          ),
        );
      },
    ),

    _GameItem(
      name: 'Puzzle Game',
      description: 'Put the pieces together & solve it!',
      imagePath: 'assets/images/puz.jpg',
      emoji: '🧩',
      gradientStart: const Color(0xFF11998E),
      gradientEnd: const Color(0xFF38EF7D),
      shadowColor: const Color(0xFF11998E),
      badge: 'SOLVE',
      badgeColor: const Color(0xFF00796B),

      // NAVIGATION
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PuzzleScreen(),
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
      return CurvedAnimation(
        parent: c,
        curve: Curves.elasticOut,
      );
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
              'assets/images/severebg.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // DARK OVERLAY
          Container(
            color: Colors.black.withOpacity(0.15),
          ),

          // DECORATIONS
          _buildDecorations(),

          // MAIN CONTENT
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),

                const SizedBox(height: 12),

                _buildLevelBadge(),

                const SizedBox(height: 20),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),

                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 40),

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

          // BACK BUTTON
          _CircleButton(
            icon: Icons.arrow_back_rounded,
            bgColor: const Color(0xFF00838F),
            onTap: () => Navigator.pop(context),
          ),

          const Spacer(),

          const Text(
            'SEVERE',
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

          // TROPHY BUTTON
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
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ),

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
          Text('🏆', style: TextStyle(fontSize: 18)),

          SizedBox(width: 8),

          Text(
            'Advanced Level · 2 Games',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
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
            child: const Text(
              '🍎',
              style: TextStyle(fontSize: 26),
            ),
          ),
        ),

        Positioned(
          top: 155,
          left: 20,
          child: _FloatingWidget(
            delay: 350,
            child: const Text(
              '🥕',
              style: TextStyle(fontSize: 22),
            ),
          ),
        ),

        Positioned(
          top: 215,
          right: 60,
          child: _FloatingWidget(
            delay: 200,
            child: const Text(
              '🌟',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }
}

// GAME CARD

class _GameCard extends StatefulWidget {
  final _GameItem game;

  const _GameCard({
    required this.game,
  });

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
      end: 0.96,
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
            minHeight: 180,
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
            padding: const EdgeInsets.all(20),

            child: Row(
              children: [

                // ROUND IMAGE
                Container(
                  width: 100,
                  height: 100,

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
                            style: const TextStyle(fontSize: 42),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Flexible(
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
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        g.name,

                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          height: 1.1,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        g.description,

                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // PLAY BUTTON
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
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

// ROUND BUTTON

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

// FLOATING ANIMATION

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