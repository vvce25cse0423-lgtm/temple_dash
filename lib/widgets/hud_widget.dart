import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/game_engine.dart';
import '../utils/constants.dart';

class HudWidget extends StatelessWidget {
  final GameEngine engine;
  const HudWidget({super.key, required this.engine});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Positioned(
      top: topPad + 8,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Row(
              children: [
                _buildScoreBox(),
                const Spacer(),
                _buildCoinBox(),
              ],
            ),
            const SizedBox(height: 8),
            _buildPowerUpIndicators(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black.withOpacity(0.5),
        border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SCORE',
            style: GoogleFonts.cinzel(fontSize: 9, color: Colors.white54, letterSpacing: 2),
          ),
          Text(
            engine.gameState.score.toString(),
            style: GoogleFonts.cinzel(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black.withOpacity(0.5),
        border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          const Text('🪙', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Text(
            engine.gameState.coins.toString(),
            style: GoogleFonts.cinzel(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerUpIndicators() {
    return Row(
      children: [
        if (engine.player.isShielded)
          _powerUpBadge('🛡', AppColors.sapphire, engine.player.shieldTimer),
        if (engine.player.hasMagnet)
          _powerUpBadge('🧲', AppColors.ruby, engine.player.magnetTimer),
      ],
    );
  }

  Widget _powerUpBadge(String icon, Color color, int timerMs) {
    final secs = (timerMs / 1000).ceil();
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withOpacity(0.25),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            '${secs}s',
            style: GoogleFonts.cinzel(fontSize: 12, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
