import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../game/jet_dodge_game.dart';
import '../models/achievement_model.dart';
import 'death_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late JetDodgeGame _game;
  final List<String> _achievementQueue = [];
  bool _showAchievement = false;
  String _currentAchievementName = '';

  @override
  void initState() {
    super.initState();
    _game = JetDodgeGame();
    _game.onGameOver = _onGameOver;
    _game.onAchievementUnlocked = _onAchievementUnlocked;
  }

  void _onGameOver() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => DeathScreen(
          score: _game.displayScore,
          survivalTime: _game.survivalTime,
          onPlayAgain: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const GameScreen()),
            );
          },
          onMainMenu: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _onAchievementUnlocked(String id) {
    final achievement = Achievement.allAchievements.where((a) => a.id == id).firstOrNull;
    if (achievement == null) return;
    _achievementQueue.add(achievement.name);
    _showNextAchievement();
  }

  void _showNextAchievement() {
    if (_showAchievement || _achievementQueue.isEmpty) return;
    setState(() {
      _showAchievement = true;
      _currentAchievementName = _achievementQueue.removeAt(0);
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showAchievement = false;
        });
        Future.delayed(const Duration(milliseconds: 300), () {
          _showNextAchievement();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: _game),
          // Achievement popup
          if (_showAchievement)
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _showAchievement ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(180),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFD700), width: 1),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'ACHIEVEMENT UNLOCKED',
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentAchievementName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // Pause button
          Positioned(
            top: 45,
            left: 15,
            child: GestureDetector(
              onTap: () {
                if (_game.gameState == GameState.playing) {
                  _game.gameState = GameState.paused;
                  _showPauseDialog();
                }
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(80),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.pause, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPauseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'PAUSED',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, letterSpacing: 3, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _pauseButton('RESUME', const Color(0xFF00FF88), () {
              Navigator.of(ctx).pop();
              _game.gameState = GameState.playing;
            }),
            const SizedBox(height: 12),
            _pauseButton('MAIN MENU', const Color(0xFFFF6D00), () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            }),
          ],
        ),
      ),
    );
  }

  Widget _pauseButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
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
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
