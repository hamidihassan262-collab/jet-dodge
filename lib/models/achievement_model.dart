import 'dart:ui';

enum AchievementCategory {
  survival,
  points,
  powerups,
  games,
  special,
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final AchievementCategory category;
  final double multiplierReward;
  final int targetValue;
  final Color color;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.multiplierReward = 0.0,
    required this.targetValue,
    required this.color,
  });

  static const List<Achievement> allAchievements = [
    // Survival achievements
    Achievement(id: 'survive_30s', name: 'Rookie Pilot', description: 'Survive for 30 seconds', category: AchievementCategory.survival, targetValue: 30, color: Color(0xFF9E9E9E)),
    Achievement(id: 'survive_60s', name: 'Seasoned Flyer', description: 'Survive for 1 minute', category: AchievementCategory.survival, targetValue: 60, color: Color(0xFF4CAF50), multiplierReward: 0.05),
    Achievement(id: 'survive_120s', name: 'Ace Pilot', description: 'Survive for 2 minutes', category: AchievementCategory.survival, targetValue: 120, color: Color(0xFF2196F3), multiplierReward: 0.1),
    Achievement(id: 'survive_180s', name: 'Top Gun', description: 'Survive for 3 minutes', category: AchievementCategory.survival, targetValue: 180, color: Color(0xFF9C27B0), multiplierReward: 0.15),
    Achievement(id: 'survive_300s', name: 'Immortal', description: 'Survive for 5 minutes', category: AchievementCategory.survival, targetValue: 300, color: Color(0xFFFF9800), multiplierReward: 0.25),
    Achievement(id: 'survive_600s', name: 'Untouchable', description: 'Survive for 10 minutes', category: AchievementCategory.survival, targetValue: 600, color: Color(0xFFE91E63), multiplierReward: 0.5),

    // Points achievements
    Achievement(id: 'points_500', name: 'Point Collector', description: 'Score 500 points in one game', category: AchievementCategory.points, targetValue: 500, color: Color(0xFF9E9E9E)),
    Achievement(id: 'points_2000', name: 'Score Chaser', description: 'Score 2,000 points in one game', category: AchievementCategory.points, targetValue: 2000, color: Color(0xFF4CAF50), multiplierReward: 0.05),
    Achievement(id: 'points_5000', name: 'High Scorer', description: 'Score 5,000 points in one game', category: AchievementCategory.points, targetValue: 5000, color: Color(0xFF2196F3), multiplierReward: 0.1),
    Achievement(id: 'points_10000', name: 'Score Master', description: 'Score 10,000 points in one game', category: AchievementCategory.points, targetValue: 10000, color: Color(0xFF9C27B0), multiplierReward: 0.2),
    Achievement(id: 'points_25000', name: 'Point Legend', description: 'Score 25,000 points in one game', category: AchievementCategory.points, targetValue: 25000, color: Color(0xFFFF9800), multiplierReward: 0.3),
    Achievement(id: 'total_points_100k', name: 'Lifetime Scorer', description: 'Score 100,000 total points', category: AchievementCategory.points, targetValue: 100000, color: Color(0xFFE91E63), multiplierReward: 0.5),

    // Powerup achievements
    Achievement(id: 'powerups_10', name: 'Power User', description: 'Collect 10 powerups', category: AchievementCategory.powerups, targetValue: 10, color: Color(0xFF9E9E9E)),
    Achievement(id: 'powerups_50', name: 'Power Hungry', description: 'Collect 50 powerups', category: AchievementCategory.powerups, targetValue: 50, color: Color(0xFF4CAF50), multiplierReward: 0.05),
    Achievement(id: 'powerups_200', name: 'Power Addict', description: 'Collect 200 powerups', category: AchievementCategory.powerups, targetValue: 200, color: Color(0xFF2196F3), multiplierReward: 0.1),
    Achievement(id: 'all_powerups', name: 'Full Arsenal', description: 'Collect every type of powerup', category: AchievementCategory.powerups, targetValue: 10, color: Color(0xFF9C27B0), multiplierReward: 0.15),
    Achievement(id: 'erasure_20', name: 'Screen Cleaner', description: 'Use Erasure 20 times', category: AchievementCategory.powerups, targetValue: 20, color: Color(0xFFE91E63), multiplierReward: 0.1),

    // Games played achievements
    Achievement(id: 'games_5', name: 'Getting Started', description: 'Play 5 games', category: AchievementCategory.games, targetValue: 5, color: Color(0xFF9E9E9E)),
    Achievement(id: 'games_25', name: 'Regular', description: 'Play 25 games', category: AchievementCategory.games, targetValue: 25, color: Color(0xFF4CAF50), multiplierReward: 0.05),
    Achievement(id: 'games_50', name: 'Dedicated', description: 'Play 50 games', category: AchievementCategory.games, targetValue: 50, color: Color(0xFF2196F3), multiplierReward: 0.1),
    Achievement(id: 'games_100', name: 'Veteran', description: 'Play 100 games', category: AchievementCategory.games, targetValue: 100, color: Color(0xFF9C27B0), multiplierReward: 0.2),
    Achievement(id: 'games_500', name: 'Addicted', description: 'Play 500 games', category: AchievementCategory.games, targetValue: 500, color: Color(0xFFFF9800), multiplierReward: 0.3),
    Achievement(id: 'games_1000', name: 'No Life', description: 'Play 1,000 games', category: AchievementCategory.games, targetValue: 1000, color: Color(0xFFE91E63), multiplierReward: 0.5),

    // Special achievements
    Achievement(id: 'close_call_10', name: 'Daredevil', description: 'Have 10 close calls with missiles', category: AchievementCategory.special, targetValue: 10, color: Color(0xFF4CAF50), multiplierReward: 0.05),
    Achievement(id: 'close_call_50', name: 'Death Wish', description: 'Have 50 close calls with missiles', category: AchievementCategory.special, targetValue: 50, color: Color(0xFFFF9800), multiplierReward: 0.15),
    Achievement(id: 'no_powerup_60s', name: 'Purist', description: 'Survive 60s without using any powerup', category: AchievementCategory.special, targetValue: 60, color: Color(0xFF9C27B0), multiplierReward: 0.2),
    Achievement(id: 'dodge_100', name: 'Missile Dancer', description: 'Dodge 100 missiles in one game', category: AchievementCategory.special, targetValue: 100, color: Color(0xFF2196F3), multiplierReward: 0.1),
    Achievement(id: 'daily_streak_7', name: 'Week Warrior', description: 'Play 7 days in a row', category: AchievementCategory.special, targetValue: 7, color: Color(0xFFFF9800), multiplierReward: 0.2),
    Achievement(id: 'daily_streak_30', name: 'Monthly Devotee', description: 'Play 30 days in a row', category: AchievementCategory.special, targetValue: 30, color: Color(0xFFE91E63), multiplierReward: 0.5),
  ];
}
