import 'package:flutter/material.dart';
import '../utils/game_data.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = GameData.leaderboardEntries;

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
                      'LEADERBOARD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),

              // Overall stats
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x22FFFFFF)),
                  color: Colors.black.withAlpha(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _overallStat('TOTAL POINTS', '${GameData.totalPoints}', const Color(0xFFFF9800)),
                    _overallStat('TOTAL TIME', _formatTime(GameData.totalTimePlayed), const Color(0xFF00FF88)),
                    _overallStat('BEST TIME', _formatTime(GameData.longestSurvival), const Color(0xFF42A5F5)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black.withAlpha(40),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0x3300FF88),
                  ),
                  labelColor: const Color(0xFF00FF88),
                  unselectedLabelColor: const Color(0x66FFFFFF),
                  labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                  tabs: const [
                    Tab(text: 'POINTS'),
                    Tab(text: 'TIME'),
                    Tab(text: 'RECENT'),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // List
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildScoreList(entries, 'score'),
                    _buildTimeList(entries),
                    _buildRecentList(entries),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _overallStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 8, letterSpacing: 1),
        ),
      ],
    );
  }

  Widget _buildScoreList(List<Map<String, dynamic>> entries, String sortKey) {
    final sorted = List<Map<String, dynamic>>.from(entries);
    sorted.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

    if (sorted.isEmpty) {
      return const Center(
        child: Text(
          'No games played yet',
          style: TextStyle(color: Color(0x66FFFFFF), fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final entry = sorted[index];
        return _leaderboardTile(
          rank: index + 1,
          mainValue: '${entry['score']}',
          subValue: _formatTime((entry['time'] as num).toDouble()),
          isTop3: index < 3,
        );
      },
    );
  }

  Widget _buildTimeList(List<Map<String, dynamic>> entries) {
    final sorted = List<Map<String, dynamic>>.from(entries);
    sorted.sort((a, b) => (b['time'] as num).compareTo(a['time'] as num));

    if (sorted.isEmpty) {
      return const Center(
        child: Text(
          'No games played yet',
          style: TextStyle(color: Color(0x66FFFFFF), fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final entry = sorted[index];
        return _leaderboardTile(
          rank: index + 1,
          mainValue: _formatTime((entry['time'] as num).toDouble()),
          subValue: '${entry['score']} pts',
          isTop3: index < 3,
        );
      },
    );
  }

  Widget _buildRecentList(List<Map<String, dynamic>> entries) {
    final sorted = List<Map<String, dynamic>>.from(entries);
    sorted.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));

    if (sorted.isEmpty) {
      return const Center(
        child: Text(
          'No games played yet',
          style: TextStyle(color: Color(0x66FFFFFF), fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final entry = sorted[index];
        final date = DateTime.tryParse(entry['date'] as String);
        final dateStr = date != null
            ? '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}'
            : '';
        return _leaderboardTile(
          rank: index + 1,
          mainValue: '${entry['score']} pts',
          subValue: dateStr,
          isTop3: false,
        );
      },
    );
  }

  Widget _leaderboardTile({
    required int rank,
    required String mainValue,
    required String subValue,
    required bool isTop3,
  }) {
    Color rankColor;
    if (rank == 1) {
      rankColor = const Color(0xFFFFD700);
    } else if (rank == 2) {
      rankColor = const Color(0xFFC0C0C0);
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32);
    } else {
      rankColor = const Color(0x66FFFFFF);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isTop3 ? rankColor.withAlpha(15) : Colors.black.withAlpha(20),
        border: Border.all(color: isTop3 ? rankColor.withAlpha(40) : const Color(0x11FFFFFF)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '#$rank',
              style: TextStyle(
                color: rankColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mainValue,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            subValue,
            style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 11),
          ),
        ],
      ),
    );
  }

  String _formatTime(double seconds) {
    final m = (seconds / 60).floor();
    final s = (seconds % 60).floor();
    return '${m}m ${s}s';
  }
}
