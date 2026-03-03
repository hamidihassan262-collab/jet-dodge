import 'package:flutter/material.dart';
import '../models/achievement_model.dart';
import '../utils/game_data.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final unlocked = GameData.unlockedAchievements;
    final categories = AchievementCategory.values;

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
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'ACHIEVEMENTS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${unlocked.length}/${Achievement.allAchievements.length}',
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Multiplier info
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0x33FFD700)),
                  color: const Color(0x0DFFD700),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFFFFD700), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'TOTAL MULTIPLIER: x${GameData.totalMultiplier.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Achievement list
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    for (final category in categories) ...[
                      _categoryHeader(category),
                      ...Achievement.allAchievements
                          .where((a) => a.category == category)
                          .map((a) => _achievementTile(a, unlocked.contains(a.id))),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryHeader(AchievementCategory category) {
    String name;
    IconData icon;
    switch (category) {
      case AchievementCategory.survival:
        name = 'SURVIVAL';
        icon = Icons.timer_outlined;
        break;
      case AchievementCategory.points:
        name = 'POINTS';
        icon = Icons.star_outline;
        break;
      case AchievementCategory.powerups:
        name = 'POWERUPS';
        icon = Icons.bolt_outlined;
        break;
      case AchievementCategory.games:
        name = 'DEDICATION';
        icon = Icons.videogame_asset_outlined;
        break;
      case AchievementCategory.special:
        name = 'SPECIAL';
        icon = Icons.emoji_events_outlined;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: const Color(0x66FFFFFF), size: 16),
          const SizedBox(width: 6),
          Text(
            name,
            style: const TextStyle(
              color: Color(0x66FFFFFF),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _achievementTile(Achievement achievement, bool isUnlocked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isUnlocked ? achievement.color.withAlpha(15) : Colors.black.withAlpha(20),
        border: Border.all(
          color: isUnlocked ? achievement.color.withAlpha(60) : const Color(0x11FFFFFF),
        ),
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked ? achievement.color.withAlpha(40) : Colors.black.withAlpha(40),
              border: Border.all(
                color: isUnlocked ? achievement.color : const Color(0x22FFFFFF),
              ),
            ),
            child: Icon(
              isUnlocked ? Icons.check : Icons.lock_outline,
              color: isUnlocked ? achievement.color : const Color(0x44FFFFFF),
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.name,
                  style: TextStyle(
                    color: isUnlocked ? Colors.white : const Color(0x66FFFFFF),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  achievement.description,
                  style: TextStyle(
                    color: isUnlocked ? const Color(0x99FFFFFF) : const Color(0x44FFFFFF),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          // Multiplier reward
          if (achievement.multiplierReward > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: isUnlocked ? const Color(0x22FFD700) : Colors.transparent,
                border: Border.all(
                  color: isUnlocked ? const Color(0x44FFD700) : const Color(0x22FFFFFF),
                ),
              ),
              child: Text(
                '+${(achievement.multiplierReward * 100).toInt()}%',
                style: TextStyle(
                  color: isUnlocked ? const Color(0xFFFFD700) : const Color(0x44FFFFFF),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
