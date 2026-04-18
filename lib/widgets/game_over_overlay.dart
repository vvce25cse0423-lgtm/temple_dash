import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/game_engine.dart';
import '../utils/constants.dart';

class GameOverOverlay extends StatefulWidget {
  final GameEngine engine;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  const GameOverOverlay({
    super.key,
    required this.engine,
    required this.onRestart,
    required this.onHome,
  });

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gs = widget.engine.gameState;
    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        color: Colors.black.withOpacity(0.75),
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Container(
              width: 320,
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1A0A00), Color(0xFF0D0500)],
                ),
                border: Border.all(color: AppColors.gold.withOpacity(0.5), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Skull / Game over icon
                  const Text('💀', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 8),
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: [Color(0xFFFF6B35), Color(0xFFFFD700)],
                    ).createShader(b),
                    child: Text(
                      'GAME OVER',
                      style: GoogleFonts.cinzelDecorative(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 4,
                      ),
                    ),
                  ),

                  if (gs.isNewHighScore) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                        ),
                      ),
                      child: Text(
                        '✨ NEW BEST! ✨',
                        style: GoogleFonts.cinzel(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBrown,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Stats
                  _statRow('SCORE', gs.score.toString(), AppColors.gold),
                  const SizedBox(height: 10),
                  _statRow('COINS', gs.coins.toString(), AppColors.orange),
                  const SizedBox(height: 10),
                  _statRow('BEST', widget.engine.highScore.toString(), AppColors.emerald),

                  const SizedBox(height: 30),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 24),

                  // Restart button
                  _actionButton(
                    '↺  PLAY AGAIN',
                    const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8C00)]),
                    AppColors.darkBrown,
                    widget.onRestart,
                  ),
                  const SizedBox(height: 14),
                  // Home button
                  _actionButton(
                    '⌂  MAIN MENU',
                    LinearGradient(colors: [Colors.white.withOpacity(0.12), Colors.white.withOpacity(0.06)]),
                    Colors.white70,
                    widget.onHome,
                    border: Border.all(color: Colors.white24),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cinzel(fontSize: 12, color: Colors.white54, letterSpacing: 2),
        ),
        Text(
          value,
          style: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _actionButton(
    String label,
    Gradient gradient,
    Color textColor,
    VoidCallback onTap, {
    Border? border,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(27),
          gradient: gradient,
          border: border,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.cinzelDecorative(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 3,
            ),
          ),
        ),
      ),
    );
  }
}
