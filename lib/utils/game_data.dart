import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement_model.dart';

class GameData {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Selected skin
  static String get selectedSkinId => _prefs.getString('selectedSkin') ?? 'ghost';
  static set selectedSkinId(String id) => _prefs.setString('selectedSkin', id);

  // High scores
  static int get highScore => _prefs.getInt('highScore') ?? 0;
  static set highScore(int v) => _prefs.setInt('highScore', v);

  static double get longestSurvival => _prefs.getDouble('longestSurvival') ?? 0;
  static set longestSurvival(double v) => _prefs.setDouble('longestSurvival', v);

  // Totals
  static int get totalGamesPlayed => _prefs.getInt('totalGames') ?? 0;
  static set totalGamesPlayed(int v) => _prefs.setInt('totalGames', v);

  static int get totalPoints => _prefs.getInt('totalPoints') ?? 0;
  static set totalPoints(int v) => _prefs.setInt('totalPoints', v);

  static double get totalTimePlayed => _prefs.getDouble('totalTime') ?? 0;
  static set totalTimePlayed(double v) => _prefs.setDouble('totalTime', v);

  static int get totalPowerupsCollected => _prefs.getInt('totalPowerups') ?? 0;
  static set totalPowerupsCollected(int v) => _prefs.setInt('totalPowerups', v);

  static int get totalMissilesDodged => _prefs.getInt('totalDodged') ?? 0;
  static set totalMissilesDodged(int v) => _prefs.setInt('totalDodged', v);

  static int get totalCloseCalls => _prefs.getInt('totalCloseCalls') ?? 0;
  static set totalCloseCalls(int v) => _prefs.setInt('totalCloseCalls', v);

  static int get totalErasuresUsed => _prefs.getInt('totalErasures') ?? 0;
  static set totalErasuresUsed(int v) => _prefs.setInt('totalErasures', v);

  // Powerup types collected (for Full Arsenal achievement)
  static Set<String> get powerupTypesCollected {
    final list = _prefs.getStringList('powerupTypes') ?? [];
    return list.toSet();
  }
  static void addPowerupType(String type) {
    final types = powerupTypesCollected;
    types.add(type);
    _prefs.setStringList('powerupTypes', types.toList());
  }

  // Daily streak
  static String get lastPlayDate => _prefs.getString('lastPlayDate') ?? '';
  static set lastPlayDate(String v) => _prefs.setString('lastPlayDate', v);

  static int get dailyStreak => _prefs.getInt('dailyStreak') ?? 0;
  static set dailyStreak(int v) => _prefs.setInt('dailyStreak', v);

  // Achievements
  static Set<String> get unlockedAchievements {
    final list = _prefs.getStringList('achievements') ?? [];
    return list.toSet();
  }
  static void unlockAchievement(String id) {
    final achievements = unlockedAchievements;
    achievements.add(id);
    _prefs.setStringList('achievements', achievements.toList());
  }

  // Leaderboard entries (local)
  static List<Map<String, dynamic>> get leaderboardEntries {
    final str = _prefs.getString('leaderboard') ?? '[]';
    return List<Map<String, dynamic>>.from(json.decode(str) as List);
  }
  static void addLeaderboardEntry(Map<String, dynamic> entry) {
    final entries = leaderboardEntries;
    entries.add(entry);
    entries.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    if (entries.length > 100) entries.removeRange(100, entries.length);
    _prefs.setString('leaderboard', json.encode(entries));
  }

  // Calculate total multiplier from achievements
  static double get achievementMultiplier {
    double mult = 1.0;
    final unlocked = unlockedAchievements;
    for (final achievement in Achievement.allAchievements) {
      if (unlocked.contains(achievement.id)) {
        mult += achievement.multiplierReward;
      }
    }
    return mult;
  }

  // Games milestone multiplier
  static double get gamesMultiplier {
    final games = totalGamesPlayed;
    if (games >= 1000) return 1.5;
    if (games >= 500) return 1.4;
    if (games >= 200) return 1.3;
    if (games >= 100) return 1.2;
    if (games >= 50) return 1.1;
    return 1.0;
  }

  static double get totalMultiplier => achievementMultiplier * gamesMultiplier;

  // Update daily streak
  static void updateDailyStreak() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final yesterday = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().substring(0, 10);
    if (lastPlayDate == today) return;
    if (lastPlayDate == yesterday) {
      dailyStreak = dailyStreak + 1;
    } else {
      dailyStreak = 1;
    }
    lastPlayDate = today;
  }

  // Sound settings
  static bool get soundEnabled => _prefs.getBool('soundEnabled') ?? true;
  static set soundEnabled(bool v) => _prefs.setBool('soundEnabled', v);

  static bool get musicEnabled => _prefs.getBool('musicEnabled') ?? true;
  static set musicEnabled(bool v) => _prefs.setBool('musicEnabled', v);
}
