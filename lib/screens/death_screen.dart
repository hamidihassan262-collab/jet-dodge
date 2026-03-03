import 'package:flutter/material.dart';
import '../utils/game_data.dart';

class DeathScreen extends StatelessWidget {
  final int score;
  final double survivalTime;
  final VoidCallback onPlayAgain;
  final VoidCallback onMainMenu;

  const DeathScreen({
    super.key,
    required this.score,
    required this.survivalTime,
    required this.onPlayAgain,
    required this.onMainMenu,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = (survivalTime / 60).floor();
    final seconds = (survivalTime % 60).floor();
    final isHighScore = score >= GameData.highScore;

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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Death title
                const Text(
                  'DESTROYED',
                  style: TextStyle(
                    color: Color(0xFFFF0000),
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 6,
                    shadows: [
                      Shadow(color: Color(0x80FF0000), blurRadius: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Score
                if (isHighScore)
                  const Text(
                    'NEW HIGH SCORE!',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  '$score',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const Text(
                  'POINTS',
                  style: TextStyle(
                    color: Color(0x99FFFFFF),
                    fontSize: 12,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 20),

                // Time
                Text(
                  '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: Color(0xCC00FF88),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
                const Text(
                  'SURVIVED',
                  style: TextStyle(
                    color: Color(0x99FFFFFF),
                    fontSize: 12,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 10),

                // Multiplier info
                if (GameData.totalMultiplier > 1.0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0x44FFD700)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'MULTIPLIER: x${GameData.totalMultiplier.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xCCFFD700),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),

                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _statItem('GAMES', '${GameData.totalGamesPlayed}'),
                    const SizedBox(width: 24),
                    _statItem('BEST', '${GameData.highScore}'),
                    const SizedBox(width: 24),
                    _statItem('STREAK', '${GameData.dailyStreak}d'),
                  ],
                ),
                const SizedBox(height: 40),

                // Buttons
                _actionButton('PLAY AGAIN', const Color(0xFF00FF88), onPlayAgain),
                const SizedBox(height: 16),
                _actionButton('MAIN MENU', const Color(0x99FFFFFF), onMainMenu),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Color(0x66FFFFFF),
            fontSize: 9,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _actionButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
      ),
    );
  }
}
