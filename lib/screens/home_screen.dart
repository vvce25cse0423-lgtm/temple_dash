import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '../utils/score_manager.dart';
import 'game_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _titleController;
  late AnimationController _pulseController;
  late Animation<double> _titleAnimation;
  late Animation<double> _pulseAnimation;
  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 20))
      ..repeat();
    _titleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..forward();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _titleAnimation = CurvedAnimation(parent: _titleController, curve: Curves.elasticOut);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final hs = await ScoreManager.getHighScore();
    if (mounted) setState(() => _highScore = hs);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _titleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _bgController,
            builder: (_, __) => CustomPaint(
              painter: HomeBackgroundPainter(_bgController.value),
              size: MediaQuery.of(context).size,
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildTitle(),
                const SizedBox(height: 10),
                _buildSubtitle(),
                const Spacer(),
                _buildCharacterPreview(),
                const Spacer(),
                _buildHighScore(),
                const SizedBox(height: 30),
                _buildPlayButton(context),
                const SizedBox(height: 20),
                _buildSecondaryButtons(context),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return ScaleTransition(
      scale: _titleAnimation,
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFF8C00), Color(0xFFFFD700)],
            ).createShader(bounds),
            child: Text(
              '⛩ TEMPLE',
              style: GoogleFonts.cinzelDecorative(
                fontSize: 44,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 6,
              ),
            ),
          ),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFFFD700), Color(0xFFFF6B35)],
            ).createShader(bounds),
            child: Text(
              'DASH',
              style: GoogleFonts.cinzelDecorative(
                fontSize: 60,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Run • Dodge • Survive',
      style: GoogleFonts.cinzel(
        fontSize: 14,
        color: AppColors.gold.withOpacity(0.7),
        letterSpacing: 4,
      ),
    );
  }

  Widget _buildCharacterPreview() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, __) => Transform.scale(
        scale: _pulseAnimation.value,
        child: SizedBox(
          height: 220,
          child: CustomPaint(
            painter: CharacterPreviewPainter(_bgController.value),
            size: const Size(220, 220),
          ),
        ),
      ),
    );
  }

  Widget _buildHighScore() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withOpacity(0.15),
            AppColors.orange.withOpacity(0.1),
          ],
        ),
        border: Border.all(color: AppColors.gold.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🏆', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Column(
            children: [
              Text(
                'BEST',
                style: GoogleFonts.cinzel(
                  fontSize: 11,
                  color: AppColors.gold.withOpacity(0.7),
                  letterSpacing: 3,
                ),
              ),
              Text(
                _highScore.toString(),
                style: GoogleFonts.cinzel(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, child) => Transform.scale(
        scale: 0.98 + _pulseAnimation.value * 0.02,
        child: child,
      ),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GameScreen()),
        ).then((_) => _loadHighScore()),
        child: Container(
          width: 220,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: AppColors.orange.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: Text(
              '▶  PLAY',
              style: GoogleFonts.cinzelDecorative(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBrown,
                letterSpacing: 4,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _secondaryBtn(context, '📊', 'STATS', () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen()));
        }),
        const SizedBox(width: 20),
        _secondaryBtn(context, '⚙️', 'SETTINGS', () {
          _showSettings(context);
        }),
      ],
    );
  }

  Widget _secondaryBtn(BuildContext context, String icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          color: Colors.white.withOpacity(0.08),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.cinzel(
                fontSize: 11,
                color: Colors.white70,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.darkBrown,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.gold.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SETTINGS',
              style: GoogleFonts.cinzelDecorative(
                fontSize: 20,
                color: AppColors.gold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 24),
            _settingTile('🔊', 'Sound Effects', true),
            _settingTile('📳', 'Vibration', true),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _settingTile(String icon, String title, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 16),
          Text(
            title,
            style: GoogleFonts.cinzel(color: Colors.white70, fontSize: 14, letterSpacing: 1),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: (_) {},
            activeThumbColor: AppColors.gold,
          ),
        ],
      ),
    );
  }
}

class HomeBackgroundPainter extends CustomPainter {
  final double t;
  HomeBackgroundPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Deep dark gradient
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Color(0xFF050008),
        Color(0xFF0D0221),
        Color(0xFF1A0A00),
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    paint.shader = null;

    // Stars
    final rand = Random(99);
    for (int i = 0; i < 100; i++) {
      final sx = rand.nextDouble() * size.width;
      final sy = rand.nextDouble() * size.height * 0.7;
      final blink = (sin(t * pi * 2 * 3 + i) + 1) / 2;
      paint.color = Colors.white.withOpacity(0.2 + blink * 0.5);
      canvas.drawCircle(Offset(sx, sy), rand.nextDouble() * 1.5 + 0.5, paint);
    }

    // Mystical glow orbs
    for (int i = 0; i < 3; i++) {
      final ox = size.width * (0.2 + i * 0.3) + sin(t * pi * 2 + i) * 30;
      final oy = size.height * (0.3 + sin(t * pi * 2 * 0.5 + i) * 0.1);
      paint.shader = RadialGradient(
        colors: [
          [AppColors.orange, AppColors.gold, AppColors.sapphire][i].withOpacity(0.15),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(ox, oy), radius: 100));
      canvas.drawCircle(Offset(ox, oy), 100, paint);
      paint.shader = null;
    }

    // Bottom jungle
    paint.color = const Color(0xFF0A2010);
    final junglePath = Path();
    junglePath.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x += 30) {
      final h = 80 + sin(x * 0.05 + t * pi * 2) * 30;
      junglePath.lineTo(x, size.height - h);
    }
    junglePath.lineTo(size.width, size.height);
    junglePath.close();
    canvas.drawPath(junglePath, paint);
  }

  @override
  bool shouldRepaint(HomeBackgroundPainter old) => true;
}

class CharacterPreviewPainter extends CustomPainter {
  final double t;
  CharacterPreviewPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final paint = Paint();
    final bounce = sin(t * pi * 2 * 2) * 8;

    // Glow platform
    paint.shader = RadialGradient(
      colors: [AppColors.gold.withOpacity(0.3), Colors.transparent],
    ).createShader(Rect.fromCircle(center: Offset(cx, cy + 70), radius: 60));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 72), width: 100, height: 20), paint);
    paint.shader = null;

    // Torch effects
    _drawTorch(canvas, cx - 60, cy + 60 + bounce, t, paint);
    _drawTorch(canvas, cx + 60, cy + 60 + bounce, t, paint);

    // Hero body
    _drawHero(canvas, cx, cy + bounce, t, paint);
  }

  void _drawTorch(Canvas canvas, double x, double y, double t, Paint paint) {
    paint.color = const Color(0xFF6B4423);
    canvas.drawRect(Rect.fromLTWH(x - 4, y - 30, 8, 35), paint);

    final flame = (sin(t * pi * 2 * 8) + 1) / 2;
    final path = Path();
    path.moveTo(x - 10, y - 30);
    path.quadraticBezierTo(x - 12, y - 50, x, y - 60 - flame * 10);
    path.quadraticBezierTo(x + 12, y - 50, x + 10, y - 30);
    path.close();
    paint.shader = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [const Color(0xFFFF4500), const Color(0xFFFFCC00), Colors.transparent],
    ).createShader(Rect.fromLTWH(x - 15, y - 75, 30, 50));
    canvas.drawPath(path, paint);
    paint.shader = null;
  }

  void _drawHero(Canvas canvas, double cx, double cy, double t, Paint paint) {
    final legSwing = sin(t * pi * 2 * 3) * 10;

    // Cape
    paint.color = const Color(0xFF8B0000);
    final cape = Path();
    cape.moveTo(cx - 14, cy - 20);
    cape.lineTo(cx - 28, cy + 10 + legSwing);
    cape.lineTo(cx - 8, cy + 5);
    cape.close();
    canvas.drawPath(cape, paint);

    // Body
    paint.shader = LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [const Color(0xFFE8A020), const Color(0xFFC07010)],
    ).createShader(Rect.fromLTWH(cx - 16, cy - 20, 32, 34));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - 16, cy - 20, 32, 34), const Radius.circular(6)),
      paint,
    );
    paint.shader = null;

    // Head
    paint.shader = RadialGradient(
      colors: [const Color(0xFFF4C88A), const Color(0xFFD4A870)],
      center: const Alignment(-0.3, -0.3),
    ).createShader(Rect.fromCircle(center: Offset(cx, cy - 32), radius: 20));
    canvas.drawCircle(Offset(cx, cy - 32), 20, paint);
    paint.shader = null;

    // Helmet
    paint.color = const Color(0xFFB8860B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - 20, cy - 48, 40, 12), const Radius.circular(4)),
      paint,
    );
    final hatTop = Path();
    hatTop.moveTo(cx - 14, cy - 48);
    hatTop.lineTo(cx - 10, cy - 68);
    hatTop.lineTo(cx + 10, cy - 68);
    hatTop.lineTo(cx + 14, cy - 48);
    paint.color = const Color(0xFFFFD700);
    canvas.drawPath(hatTop, paint);

    // Eyes
    paint.color = Colors.white;
    canvas.drawOval(Rect.fromLTWH(cx - 11, cy - 38, 8, 9), paint);
    canvas.drawOval(Rect.fromLTWH(cx + 3, cy - 38, 8, 9), paint);
    paint.color = Colors.black87;
    canvas.drawCircle(Offset(cx - 7, cy - 33), 3.5, paint);
    canvas.drawCircle(Offset(cx + 7, cy - 33), 3.5, paint);

    // Arms
    paint.color = const Color(0xFFE8A020);
    paint.strokeWidth = 8;
    paint.strokeCap = StrokeCap.round;
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - 16, cy - 14), Offset(cx - 30, cy - 2 - legSwing), paint);
    canvas.drawLine(Offset(cx + 16, cy - 14), Offset(cx + 30, cy - 2 + legSwing), paint);
    paint.style = PaintingStyle.fill;

    // Legs
    paint.color = const Color(0xFF4A3520);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 14, cy + 12, 12, 30 + legSwing),
      const Radius.circular(4),
    ), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(cx + 2, cy + 12, 12, 30 - legSwing),
      const Radius.circular(4),
    ), paint);

    // Boots
    paint.color = const Color(0xFF2A1A0A);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 17, cy + 38 + legSwing, 17, 10),
      const Radius.circular(3),
    ), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(cx + 1, cy + 38 - legSwing, 17, 10),
      const Radius.circular(3),
    ), paint);
  }

  @override
  bool shouldRepaint(CharacterPreviewPainter old) => true;
}
