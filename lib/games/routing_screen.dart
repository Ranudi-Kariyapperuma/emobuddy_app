import 'package:flutter/material.dart';
import 'morning_routine_game.dart';

class RoutingScreen extends StatelessWidget {
  const RoutingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_GameCard> games = [
      _GameCard(
        title: 'Morning Routine',
        subtitle: 'Wake up & get ready!',
        emoji: '🌅',
        color1: const Color(0xFFFF9A56),
        color2: const Color(0xFFFF6B35),
        steps: '5 steps',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MorningRoutineGame()),
        ),
      ),
      _GameCard(
        title: 'School Routine',
        subtitle: 'Ready for school!',
        emoji: '🎒',
        color1: const Color(0xFF56C8FF),
        color2: const Color(0xFF3B82F6),
        steps: '4 steps',
        onTap: () {},
        comingSoon: true,
      ),
      _GameCard(
        title: 'Grocery Shopping',
        subtitle: 'Let\'s go shopping!',
        emoji: '🛒',
        color1: const Color(0xFF6EE7A0),
        color2: const Color(0xFF22C55E),
        steps: '4 steps',
        onTap: () {},
        comingSoon: true,
      ),
      _GameCard(
        title: 'Dress for Weather',
        subtitle: 'What to wear today?',
        emoji: '🌤️',
        color1: const Color(0xFFD8A0FF),
        color2: const Color(0xFFA855F7),
        steps: '3 steps',
        onTap: () {},
        comingSoon: true,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFEEF4FF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7C3AED).withOpacity(0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.auto_stories_rounded,
                            color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Life Games',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E1B4B),
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Learn everyday routines!',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Stars banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFED7AA), width: 1),
                ),
                child: const Row(
                  children: [
                    Text('⭐', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 8),
                    Text(
                      'Complete activities to earn stars!',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEA580C),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Game cards
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 6, 24, 24),
                itemCount: games.length,
                itemBuilder: (context, i) => _GameCardWidget(card: games[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameCard {
  final String title;
  final String subtitle;
  final String emoji;
  final Color color1;
  final Color color2;
  final String steps;
  final VoidCallback onTap;
  final bool comingSoon;

  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color1,
    required this.color2,
    required this.steps,
    required this.onTap,
    this.comingSoon = false,
  });
}

class _GameCardWidget extends StatefulWidget {
  final _GameCard card;
  const _GameCardWidget({required this.card});

  @override
  State<_GameCardWidget> createState() => _GameCardWidgetState();
}

class _GameCardWidgetState extends State<_GameCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween(begin: 1.0, end: 0.96).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.card;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          c.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            height: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [c.color1, c.color2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: c.color2.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.12),
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
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      // Emoji circle
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(c.emoji,
                              style: const TextStyle(fontSize: 36)),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              c.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              c.subtitle,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.85),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                c.comingSoon ? '🔒 Coming Soon' : '▶ ${c.steps}',
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (!c.comingSoon)
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 20),
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
