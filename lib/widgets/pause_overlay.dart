import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class PauseOverlay extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onHome;

  const PauseOverlay({super.key, required this.onResume, required this.onHome});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A0A00), Color(0xFF0D0500)],
            ),
            border: Border.all(color: AppColors.gold.withOpacity(0.4), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⏸', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                'PAUSED',
                style: GoogleFonts.cinzelDecorative(
                  fontSize: 24,
                  color: AppColors.gold,
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: 30),
              _btn('▶  RESUME', const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8C00)]),
                  AppColors.darkBrown, onResume),
              const SizedBox(height: 14),
              _btn(
                '⌂  QUIT',
                LinearGradient(colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)]),
                Colors.white70,
                onHome,
                border: Border.all(color: Colors.white24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _btn(String label, Gradient gradient, Color textColor, VoidCallback onTap, {Border? border}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: gradient,
          border: border,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.cinzelDecorative(
              fontSize: 15,
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
