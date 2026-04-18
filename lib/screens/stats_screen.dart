import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '../utils/score_manager.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..forward();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await ScoreManager.getAllStats();
    if (mounted) setState(() => _stats = stats);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBrown,
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF050008), Color(0xFF0D0221), Color(0xFF1A0A00)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildHeader(context),
                const SizedBox(height: 40),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildStatCard('🏆', 'HIGH SCORE', _stats['highScore'] ?? 0, AppColors.gold),
                        const SizedBox(height: 16),
                        _buildStatCard('🪙', 'TOTAL COINS', _stats['totalCoins'] ?? 0, AppColors.orange),
                        const SizedBox(height: 16),
                        _buildStatCard('🎮', 'GAMES PLAYED', _stats['gamesPlayed'] ?? 0, AppColors.emerald),
                        const SizedBox(height: 40),
                        _buildAchievements(),
                      ],
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
              border: Border.all(color: AppColors.gold.withOpacity(0.4)),
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: AppColors.gold, size: 18),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'STATISTICS',
          style: GoogleFonts.cinzelDecorative(
            fontSize: 22,
            color: AppColors.gold,
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String icon, String title, int value, Color color) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cinzel(
                    fontSize: 12,
                    color: color.withOpacity(0.7),
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  value.toString(),
                  style: GoogleFonts.cinzel(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements() {
    final achievements = [
      {'icon': '🌟', 'title': 'First Run', 'desc': 'Complete your first game', 'unlocked': (_stats['gamesPlayed'] ?? 0) >= 1},
      {'icon': '💨', 'title': 'Speed Demon', 'desc': 'Score over 500 points', 'unlocked': (_stats['highScore'] ?? 0) >= 500},
      {'icon': '🪙', 'title': 'Gold Rush', 'desc': 'Collect 50 coins total', 'unlocked': (_stats['totalCoins'] ?? 0) >= 50},
      {'icon': '🏃', 'title': 'Veteran', 'desc': 'Play 10 games', 'unlocked': (_stats['gamesPlayed'] ?? 0) >= 10},
      {'icon': '👑', 'title': 'Legend', 'desc': 'Score over 2000 points', 'unlocked': (_stats['highScore'] ?? 0) >= 2000},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACHIEVEMENTS',
          style: GoogleFonts.cinzelDecorative(
            fontSize: 16,
            color: AppColors.gold,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 16),
        ...achievements.map((a) => _buildAchievementTile(
          a['icon'] as String,
          a['title'] as String,
          a['desc'] as String,
          a['unlocked'] as bool,
        )),
      ],
    );
  }

  Widget _buildAchievementTile(String icon, String title, String desc, bool unlocked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: unlocked
            ? AppColors.gold.withOpacity(0.1)
            : Colors.white.withOpacity(0.03),
        border: Border.all(
          color: unlocked ? AppColors.gold.withOpacity(0.4) : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Text(
            unlocked ? icon : '🔒',
            style: TextStyle(fontSize: 28, color: unlocked ? null : Colors.white30),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.cinzel(
                  fontSize: 13,
                  color: unlocked ? Colors.white : Colors.white38,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                desc,
                style: GoogleFonts.cinzel(
                  fontSize: 10,
                  color: unlocked ? Colors.white60 : Colors.white24,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (unlocked)
            const Icon(Icons.check_circle, color: AppColors.gold, size: 20),
        ],
      ),
    );
  }
}
