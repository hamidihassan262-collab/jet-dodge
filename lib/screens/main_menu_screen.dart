import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/game_data.dart';
import 'game_screen.dart';
import 'skin_selection_screen.dart';
import 'leaderboard_screen.dart';
import 'achievements_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _radarController;
  final Random _random = Random();
  final List<_MenuParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    for (int i = 0; i < 20; i++) {
      _particles.add(_MenuParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speed: 0.01 + _random.nextDouble() * 0.03,
        size: 1 + _random.nextDouble() * 3,
        alpha: 0.1 + _random.nextDouble() * 0.3,
      ));
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0E21), Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Animated background particles
              AnimatedBuilder(
                animation: _radarController,
                builder: (context, child) {
                  return CustomPaint(
                    size: MediaQuery.of(context).size,
                    painter: _MenuBackgroundPainter(
                      particles: _particles,
                      radarAngle: _radarController.value * 2 * pi,
                    ),
                  );
                },
              ),
              // Content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    // Title
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + _pulseController.value * 0.03,
                          child: child,
                        );
                      },
                      child: const Column(
                        children: [
                          Text(
                            'JET',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 12,
                              height: 1.0,
                              shadows: [
                                Shadow(color: Color(0x6000FF88), blurRadius: 30),
                              ],
                            ),
                          ),
                          Text(
                            'DODGE',
                            style: TextStyle(
                              color: Color(0xFF00FF88),
                              fontSize: 36,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 18,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'SURVIVE THE STORM',
                      style: TextStyle(
                        color: Color(0x66FFFFFF),
                        fontSize: 10,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Stats banner
                    if (GameData.highScore > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0x22FFFFFF)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _miniStat('BEST', '${GameData.highScore}'),
                            Container(width: 1, height: 20, color: const Color(0x22FFFFFF), margin: const EdgeInsets.symmetric(horizontal: 16)),
                            _miniStat('GAMES', '${GameData.totalGamesPlayed}'),
                            if (GameData.dailyStreak > 0) ...[
                              Container(width: 1, height: 20, color: const Color(0x22FFFFFF), margin: const EdgeInsets.symmetric(horizontal: 16)),
                              _miniStat('STREAK', '${GameData.dailyStreak}d'),
                            ],
                          ],
                        ),
                      ),

                    const Spacer(),

                    // Play button
                    _menuButton(
                      'PLAY',
                      const Color(0xFF00FF88),
                      Icons.play_arrow_rounded,
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const GameScreen()),
                        );
                      },
                      large: true,
                    ),
                    const SizedBox(height: 16),

                    // Secondary buttons row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _smallMenuButton('SKINS', Icons.palette_outlined, const Color(0xFFBB86FC), () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SkinSelectionScreen()),
                          );
                        }),
                        const SizedBox(width: 12),
                        _smallMenuButton('RANKS', Icons.leaderboard_outlined, const Color(0xFFFF9800), () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                          );
                        }),
                        const SizedBox(width: 12),
                        _smallMenuButton('MEDALS', Icons.emoji_events_outlined, const Color(0xFFFFD700), () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Settings row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _iconButton(
                          GameData.soundEnabled ? Icons.volume_up : Icons.volume_off,
                          () {
                            setState(() {
                              GameData.soundEnabled = !GameData.soundEnabled;
                            });
                          },
                        ),
                        const SizedBox(width: 16),
                        _iconButton(
                          GameData.musicEnabled ? Icons.music_note : Icons.music_off,
                          () {
                            setState(() {
                              GameData.musicEnabled = !GameData.musicEnabled;
                            });
                          },
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Version
                    const Text(
                      'v1.0.0',
                      style: TextStyle(color: Color(0x33FFFFFF), fontSize: 10),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 8, letterSpacing: 2),
        ),
      ],
    );
  }

  Widget _menuButton(String text, Color color, IconData icon, VoidCallback onTap, {bool large = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: large ? 220 : 180,
        padding: EdgeInsets.symmetric(vertical: large ? 16 : 12),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: large ? 2 : 1.5),
          borderRadius: BorderRadius.circular(16),
          color: color.withAlpha(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: large ? 28 : 22),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: large ? 18 : 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallMenuButton(String text, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 95,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: color.withAlpha(120), width: 1),
          borderRadius: BorderRadius.circular(12),
          color: color.withAlpha(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0x33FFFFFF)),
        ),
        child: Icon(icon, color: const Color(0x99FFFFFF), size: 18),
      ),
    );
  }
}

class _MenuParticle {
  double x, y, speed, size, alpha;
  _MenuParticle({required this.x, required this.y, required this.speed, required this.size, required this.alpha});
}

class _MenuBackgroundPainter extends CustomPainter {
  final List<_MenuParticle> particles;
  final double radarAngle;

  _MenuBackgroundPainter({required this.particles, required this.radarAngle});

  @override
  void paint(Canvas canvas, Size size) {
    // Radar circles in background
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width * 0.45;

    for (int i = 1; i <= 5; i++) {
      final r = radius * (i / 5);
      final paint = Paint()
        ..color = const Color(0x0800FF88)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }

    // Sweep
    final sweepEnd = Offset(
      cx + cos(radarAngle) * radius,
      cy + sin(radarAngle) * radius,
    );
    canvas.drawLine(
      Offset(cx, cy),
      sweepEnd,
      Paint()..color = const Color(0x1500FF88)..strokeWidth = 1,
    );

    // Particles
    for (final p in particles) {
      p.y = (p.y + p.speed * 0.016) % 1.0;
      final paint = Paint()
        ..color = Color.fromARGB((p.alpha * 255).toInt(), 0, 255, 136)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(p.x * size.width, p.y * size.height), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
