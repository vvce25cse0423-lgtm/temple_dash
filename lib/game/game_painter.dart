import 'dart:math';
import 'package:flutter/material.dart';
import '../game/game_engine.dart';
import '../models/game_models.dart';
import '../utils/constants.dart';

class GamePainter extends CustomPainter {
  final GameEngine engine;
  final double animationValue;
  final Paint _paint = Paint()..isAntiAlias = true;

  GamePainter(this.engine, this.animationValue);

  double get _groundY => GameConfig.gameHeight * 0.72;

  @override
  void paint(Canvas canvas, Size size) {
    // Scale canvas to game resolution
    final scaleX = size.width / GameConfig.gameWidth;
    final scaleY = size.height / GameConfig.gameHeight;
    canvas.save();
    canvas.scale(scaleX, scaleY);

    _drawBackground(canvas);
    _drawTrees(canvas);
    _drawTrack(canvas);
    _drawLaneMarkers(canvas);
    _drawPowerUps(canvas);
    _drawCoins(canvas);
    _drawObstacles(canvas);
    _drawPlayer(canvas);
    _drawParticles(canvas);

    canvas.restore();
  }

  // ─────────────────────────────────────────────
  // BACKGROUND
  // ─────────────────────────────────────────────
  void _drawBackground(Canvas canvas) {
    final w = GameConfig.gameWidth;
    final h = GameConfig.gameHeight;

    // Sky gradient
    _paint.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0A001A), Color(0xFF1A0533), Color(0xFF2D0A00)],
    ).createShader(Rect.fromLTWH(0, 0, w, h * 0.72));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.72), _paint);
    _paint.shader = null;

    // Stars
    final rng = Random(42);
    for (int i = 0; i < 60; i++) {
      final sx = rng.nextDouble() * w;
      final sy = rng.nextDouble() * h * 0.55;
      final blink = (sin(animationValue * 3 + i * 1.3) + 1) / 2;
      _paint.color = Colors.white.withOpacity(0.3 + blink * 0.5);
      canvas.drawCircle(Offset(sx, sy), rng.nextDouble() * 1.2 + 0.4, _paint);
    }

    // Moon
    _paint.color = const Color(0xFFFFF5CC);
    canvas.drawCircle(const Offset(320, 55), 28, _paint);
    _paint.color = const Color(0xFF1A0533);
    canvas.drawCircle(const Offset(330, 50), 23, _paint);

    // Temple silhouette
    _drawTempleSilhouette(canvas, w, h * 0.58);
  }

  void _drawTempleSilhouette(Canvas canvas, double w, double groundY) {
    _paint.color = const Color(0xFF0D0020).withOpacity(0.9);
    final cx = w / 2;

    // Base
    canvas.drawRect(Rect.fromLTWH(cx - 90, groundY - 70, 180, 70), _paint);

    // Pillars
    for (int i = 0; i < 5; i++) {
      canvas.drawRect(Rect.fromLTWH(cx - 82 + i * 40, groundY - 80, 12, 80), _paint);
    }

    // Roof tiers
    _drawRoofTier(canvas, cx, groundY - 70, 200, 22);
    _drawRoofTier(canvas, cx, groundY - 92, 150, 18);
    _drawRoofTier(canvas, cx, groundY - 110, 100, 16);

    // Spire
    final sp = Path()
      ..moveTo(cx, groundY - 145)
      ..lineTo(cx - 10, groundY - 110)
      ..lineTo(cx + 10, groundY - 110)
      ..close();
    canvas.drawPath(sp, _paint);
  }

  void _drawRoofTier(Canvas canvas, double cx, double y, double w, double h) {
    final p = Path()
      ..moveTo(cx, y - h)
      ..lineTo(cx - w / 2, y)
      ..lineTo(cx + w / 2, y)
      ..close();
    canvas.drawPath(p, _paint);
  }

  // ─────────────────────────────────────────────
  // TREES
  // ─────────────────────────────────────────────
  void _drawTrees(Canvas canvas) {
    final offset = engine.treesOffset % (GameConfig.gameWidth * 0.6);
    for (int i = -1; i <= 4; i++) {
      _drawTree(canvas, i * GameConfig.gameWidth * 0.6 + offset - 30, _groundY - 10, 0.8);
      _drawTree(canvas, i * GameConfig.gameWidth * 0.6 + offset + 200, _groundY - 5, 0.65);
    }
  }

  void _drawTree(Canvas canvas, double x, double groundY, double s) {
    _paint.color = const Color(0xFF3D2010);
    canvas.drawRect(Rect.fromLTWH(x - 5 * s, groundY - 35 * s, 10 * s, 35 * s), _paint);

    final colors = [const Color(0xFF0B3D0B), const Color(0xFF145214), const Color(0xFF1F7A1F)];
    for (int i = 0; i < 3; i++) {
      _paint.color = colors[i];
      final ly = groundY - 28 * s - i * 22 * s;
      final lw = (55 - i * 12) * s;
      final p = Path()
        ..moveTo(x, ly - 28 * s)
        ..lineTo(x - lw / 2, ly)
        ..lineTo(x + lw / 2, ly)
        ..close();
      canvas.drawPath(p, _paint);
    }
  }

  // ─────────────────────────────────────────────
  // TRACK
  // ─────────────────────────────────────────────
  void _drawTrack(Canvas canvas) {
    final w = GameConfig.gameWidth;
    final h = GameConfig.gameHeight;
    final gY = _groundY;
    final cx = w / 2;
    final tw = GameConfig.laneWidth * 3 + 20.0;

    // Ground beyond track
    _paint.color = const Color(0xFF0A1A05);
    canvas.drawRect(Rect.fromLTWH(0, gY, w, h - gY), _paint);

    // Track surface gradient
    _paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF6B4A28),
        const Color(0xFF4A3018),
        const Color(0xFF2E1C0A),
      ],
    ).createShader(Rect.fromLTWH(cx - tw / 2, gY, tw, h - gY));
    canvas.drawRect(Rect.fromLTWH(cx - tw / 2, gY, tw, h - gY), _paint);
    _paint.shader = null;

    // Tile lines scrolling
    final tileH = 55.0;
    final tileOff = engine.groundOffset % tileH;
    _paint
      ..color = const Color(0xFF8B6040).withOpacity(0.35)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (double ty = gY - tileOff; ty < h; ty += tileH) {
      canvas.drawLine(Offset(cx - tw / 2, ty), Offset(cx + tw / 2, ty), _paint);
    }
    _paint.style = PaintingStyle.fill;

    // Track side borders
    _paint
      ..color = const Color(0xFFB87040)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - tw / 2, gY), Offset(cx - tw / 2, h), _paint);
    canvas.drawLine(Offset(cx + tw / 2, gY), Offset(cx + tw / 2, h), _paint);
    _paint.style = PaintingStyle.fill;

    // Horizon glow
    _paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFFF6600).withOpacity(0.18),
        Colors.transparent,
      ],
    ).createShader(Rect.fromLTWH(cx - tw / 2, gY - 25, tw, 50));
    canvas.drawRect(Rect.fromLTWH(cx - tw / 2, gY - 25, tw, 50), _paint);
    _paint.shader = null;
  }

  // ─────────────────────────────────────────────
  // LANE MARKERS
  // ─────────────────────────────────────────────
  void _drawLaneMarkers(Canvas canvas) {
    final gY = _groundY;
    final h = GameConfig.gameHeight;
    final cx = GameConfig.gameWidth / 2;
    final dashH = 22.0;
    final gapH = 14.0;
    final off = engine.groundOffset % (dashH + gapH);

    _paint
      ..color = const Color(0xFFFFCC44).withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final lx in [cx - GameConfig.laneWidth / 2, cx + GameConfig.laneWidth / 2]) {
      double y = gY - off;
      while (y < h) {
        canvas.drawLine(Offset(lx, y), Offset(lx, y + dashH), _paint);
        y += dashH + gapH;
      }
    }
    _paint.style = PaintingStyle.fill;
  }

  // ─────────────────────────────────────────────
  // COINS  – bright, large, unmissable
  // ─────────────────────────────────────────────
  void _drawCoins(Canvas canvas) {
    for (final coin in engine.coins) {
      if (coin.isCollected) continue;

      final cx = coin.x;
      final cy = coin.y;
      final pulse = (sin(animationValue * 5 + coin.x * 0.05) + 1) / 2;
      final r = GameConfig.coinSize / 2 + 2;

      // Outer glow
      _paint.shader = RadialGradient(colors: [
        const Color(0xFFFFDD00).withOpacity(0.5 + pulse * 0.3),
        Colors.transparent,
      ]).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r + 10));
      canvas.drawCircle(Offset(cx, cy), r + 10 + pulse * 4, _paint);
      _paint.shader = null;

      // Coin body
      _paint.shader = RadialGradient(
        center: const Alignment(-0.4, -0.4),
        colors: [const Color(0xFFFFFF88), const Color(0xFFFFCC00), const Color(0xFFAA7700)],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
      canvas.drawCircle(Offset(cx, cy), r, _paint);
      _paint.shader = null;

      // Inner ring
      _paint
        ..color = const Color(0xFFFFEE44).withOpacity(0.6)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(Offset(cx, cy), r * 0.65, _paint);
      _paint.style = PaintingStyle.fill;

      // Star symbol
      _drawStar(canvas, cx, cy, 5, r * 0.35, r * 0.18, const Color(0xFFAA7700));
    }
  }

  void _drawStar(Canvas canvas, double cx, double cy, int points, double outer, double inner, Color color) {
    final path = Path();
    final step = pi / points;
    for (int i = 0; i < points * 2; i++) {
      final angle = i * step - pi / 2;
      final r = i.isEven ? outer : inner;
      final x = cx + cos(angle) * r;
      final y = cy + sin(angle) * r;
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    path.close();
    _paint.color = color;
    canvas.drawPath(path, _paint);
  }

  // ─────────────────────────────────────────────
  // POWER-UPS
  // ─────────────────────────────────────────────
  void _drawPowerUps(Canvas canvas) {
    for (final pu in engine.powerUps) {
      if (pu.isCollected) continue;
      final pulse = (sin(animationValue * 4) + 1) / 2;
      final cx = pu.x;
      final cy = pu.y;

      // Outer glow ring
      _paint.shader = RadialGradient(colors: [
        pu.color.withOpacity(0.5 + pulse * 0.3),
        Colors.transparent,
      ]).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 36));
      canvas.drawCircle(Offset(cx, cy), 36 + pulse * 6, _paint);
      _paint.shader = null;

      // Body
      _paint.shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [
          Color.lerp(pu.color, Colors.white, 0.5)!,
          pu.color,
          Color.lerp(pu.color, Colors.black, 0.3)!,
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 22));
      canvas.drawCircle(Offset(cx, cy), 22, _paint);
      _paint.shader = null;

      // Border
      _paint
        ..color = Colors.white.withOpacity(0.8)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(Offset(cx, cy), 22, _paint);
      _paint.style = PaintingStyle.fill;

      // Icon
      final icons = {
        PowerUpType.shield: '🛡',
        PowerUpType.magnet: '🧲',
        PowerUpType.speedBoost: '⚡',
        PowerUpType.doubleCoins: '💰',
      };
      _drawEmoji(canvas, icons[pu.type]!, cx, cy, 22);
    }
  }

  void _drawEmoji(Canvas canvas, String emoji, double cx, double cy, double size) {
    final tp = TextPainter(
      text: TextSpan(text: emoji, style: TextStyle(fontSize: size)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  // ─────────────────────────────────────────────
  // OBSTACLES  – vivid, contrasting, clearly visible
  // ─────────────────────────────────────────────
  void _drawObstacles(Canvas canvas) {
    for (final obs in engine.obstacles) {
      if (!obs.isActive) continue;
      switch (obs.type) {
        case ObstacleType.rock:   _drawRock(canvas, obs.x, obs.y);   break;
        case ObstacleType.fire:   _drawFire(canvas, obs.x, obs.y);   break;
        case ObstacleType.wall:   _drawWall(canvas, obs.x, obs.y);   break;
        case ObstacleType.log:    _drawLog(canvas, obs.x, obs.y);    break;
      }
    }
  }

  // ROCK – bright cyan/white outline, obvious silhouette
  void _drawRock(Canvas canvas, double x, double y) {
    final path = Path()
      ..moveTo(x - 30, y + 38)
      ..lineTo(x - 36, y + 8)
      ..lineTo(x - 20, y - 28)
      ..lineTo(x + 4, y - 40)
      ..lineTo(x + 30, y - 22)
      ..lineTo(x + 36, y + 12)
      ..lineTo(x + 22, y + 38)
      ..close();

    // Drop shadow
    _paint.color = Colors.black.withOpacity(0.5);
    canvas.save();
    canvas.translate(4, 6);
    canvas.drawPath(path, _paint);
    canvas.restore();

    // Rock body
    _paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [const Color(0xFFCCDDEE), const Color(0xFF7799BB), const Color(0xFF334466)],
    ).createShader(Rect.fromLTWH(x - 38, y - 42, 76, 82));
    canvas.drawPath(path, _paint);
    _paint.shader = null;

    // Bright outline – makes it pop against dark track
    _paint
      ..color = const Color(0xFFAADDFF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, _paint);
    _paint.style = PaintingStyle.fill;

    // Highlight crack
    _paint
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final crack = Path()
      ..moveTo(x - 5, y - 25)
      ..lineTo(x + 2, y - 5)
      ..lineTo(x - 3, y + 10);
    canvas.drawPath(crack, _paint);
    _paint.style = PaintingStyle.fill;

    // Warning label
    _drawObstacleLabel(canvas, x, y - 52, '🪨', const Color(0xFF88CCFF));
  }

  // FIRE – massive bright animated flames, impossible to miss
  void _drawFire(Canvas canvas, double x, double y) {
    final t = animationValue;

    // Base glow on ground
    _paint.shader = RadialGradient(colors: [
      const Color(0xFFFF4400).withOpacity(0.6),
      Colors.transparent,
    ]).createShader(Rect.fromCircle(center: Offset(x, y + 38), radius: 50));
    canvas.drawOval(Rect.fromCenter(center: Offset(x, y + 38), width: 90, height: 28), _paint);
    _paint.shader = null;

    // Multiple flame layers for depth
    _drawFlameLayer(canvas, x - 18, y, 70, 0.85, t, 0.8);
    _drawFlameLayer(canvas, x + 18, y, 70, 0.85, t, 1.2);
    _drawFlameLayer(canvas, x, y, 90, 1.0, t, 0.0);    // Center tallest flame

    // Bright core
    _paint.shader = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [const Color(0xFFFFFFFF), const Color(0xFFFFFF88), const Color(0xFFFFCC00)],
    ).createShader(Rect.fromLTWH(x - 12, y - 30, 24, 50));
    final core = Path()
      ..moveTo(x - 10, y + 38)
      ..quadraticBezierTo(x - 14, y + 10, x, y - 30)
      ..quadraticBezierTo(x + 14, y + 10, x + 10, y + 38)
      ..close();
    canvas.drawPath(core, _paint);
    _paint.shader = null;

    // Ember particles
    for (int i = 0; i < 5; i++) {
      final ex = x + sin(t * 6 + i * 1.3) * 25;
      final ey = y - 50 - (t * 3 + i * 0.4) % 1.0 * 40;
      final es = 3.0 - i * 0.4;
      _paint.color = [
        const Color(0xFFFF4400),
        const Color(0xFFFF8800),
        const Color(0xFFFFCC00),
      ][i % 3].withOpacity(0.8);
      canvas.drawCircle(Offset(ex, ey), es, _paint);
    }

    _drawObstacleLabel(canvas, x, y - 102, '🔥', const Color(0xFFFF8800));
  }

  void _drawFlameLayer(Canvas canvas, double x, double y, double h, double w, double t, double phase) {
    final sway = sin(t * 7 + phase) * 10;
    final flicker = (sin(t * 11 + phase) + 1) / 2;
    final fh = h + flicker * 15;

    final path = Path()
      ..moveTo(x - 20 * w, y + 38)
      ..quadraticBezierTo(x - 25 * w + sway, y, x + sway * 0.5, y - fh)
      ..quadraticBezierTo(x + 25 * w + sway, y, x + 20 * w, y + 38)
      ..close();

    _paint.shader = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        const Color(0xFFFF2200),
        const Color(0xFFFF6600),
        const Color(0xFFFFAA00),
        Colors.transparent,
      ],
      stops: const [0.0, 0.4, 0.75, 1.0],
    ).createShader(Rect.fromLTWH(x - 30, y - fh, 60, fh + 40));
    canvas.drawPath(path, _paint);
    _paint.shader = null;
  }

  // WALL – vivid red-orange brick wall, highly visible
  void _drawWall(Canvas canvas, double x, double y) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x - 36, y - 44, 72, 84),
      const Radius.circular(4),
    );

    // Shadow
    _paint.color = Colors.black.withOpacity(0.5);
    canvas.save();
    canvas.translate(5, 7);
    canvas.drawRRect(rect, _paint);
    canvas.restore();

    // Wall gradient
    _paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [const Color(0xFFFF6633), const Color(0xFFCC3300), const Color(0xFF881100)],
    ).createShader(Rect.fromLTWH(x - 36, y - 44, 72, 84));
    canvas.drawRRect(rect, _paint);
    _paint.shader = null;

    // Bright outline
    _paint
      ..color = const Color(0xFFFF9966)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(rect, _paint);
    _paint.style = PaintingStyle.fill;

    // Brick pattern – white mortar lines, very visible
    _paint
      ..color = Colors.black.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    for (int row = 0; row < 5; row++) {
      final by = y - 40 + row * 17.0;
      canvas.drawLine(Offset(x - 34, by), Offset(x + 34, by), _paint);
      final shift = row.isEven ? 0.0 : 18.0;
      for (double bx = x - 34 + shift; bx < x + 34; bx += 36) {
        canvas.drawLine(Offset(bx, by), Offset(bx, by + 17), _paint);
      }
    }
    _paint.style = PaintingStyle.fill;

    // Highlight top edge
    _paint
      ..color = const Color(0xFFFFAA88)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(x - 36, y - 44), Offset(x + 36, y - 44), _paint);
    _paint.style = PaintingStyle.fill;

    _drawObstacleLabel(canvas, x, y - 58, '🧱', const Color(0xFFFF9966));
  }

  // LOG – vivid green/brown, clearly horizontal
  void _drawLog(Canvas canvas, double x, double y) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x - 38, y - 18, 76, 50),
      const Radius.circular(10),
    );

    // Shadow
    _paint.color = Colors.black.withOpacity(0.45);
    canvas.save();
    canvas.translate(4, 6);
    canvas.drawRRect(rect, _paint);
    canvas.restore();

    // Log body
    _paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [const Color(0xFFCC8833), const Color(0xFF885522), const Color(0xFF553311)],
    ).createShader(Rect.fromLTWH(x - 38, y - 18, 76, 50));
    canvas.drawRRect(rect, _paint);
    _paint.shader = null;

    // Bright outline
    _paint
      ..color = const Color(0xFFFFBB44)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(rect, _paint);
    _paint.style = PaintingStyle.fill;

    // Wood grain lines
    _paint
      ..color = const Color(0xFF553311).withOpacity(0.5)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (int i = -2; i <= 2; i++) {
      canvas.drawLine(Offset(x + i * 13, y - 18), Offset(x + i * 13, y + 32), _paint);
    }
    _paint.style = PaintingStyle.fill;

    // End caps with rings
    for (final ex in [x - 30.0, x + 30.0]) {
      _paint.shader = RadialGradient(
        colors: [const Color(0xFFDDAA55), const Color(0xFF885522), const Color(0xFF553311)],
      ).createShader(Rect.fromCircle(center: Offset(ex, y + 7), radius: 18));
      canvas.drawOval(Rect.fromCenter(center: Offset(ex, y + 7), width: 22, height: 30), _paint);
      _paint.shader = null;
      // Tree rings
      _paint
        ..color = const Color(0xFF553311).withOpacity(0.4)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      canvas.drawOval(Rect.fromCenter(center: Offset(ex, y + 7), width: 14, height: 18), _paint);
      canvas.drawOval(Rect.fromCenter(center: Offset(ex, y + 7), width: 6, height: 8), _paint);
      _paint.style = PaintingStyle.fill;
    }

    _drawObstacleLabel(canvas, x, y - 32, '🪵', const Color(0xFFFFBB44));
  }

  // Warning label above each obstacle
  void _drawObstacleLabel(Canvas canvas, double x, double y, String emoji, Color color) {
    // Pulsing warning glow
    final pulse = (sin(animationValue * 6) + 1) / 2;
    _paint.color = color.withOpacity(0.2 + pulse * 0.25);
    canvas.drawCircle(Offset(x, y + 10), 18 + pulse * 4, _paint);

    // Emoji icon
    _drawEmoji(canvas, emoji, x, y + 10, 20);
  }

  // ─────────────────────────────────────────────
  // PLAYER
  // ─────────────────────────────────────────────
  void _drawPlayer(Canvas canvas) {
    final px = engine.playerX;
    final py = engine.playerY;
    final isSliding = engine.player.state == PlayerState.sliding;
    final isDead = engine.player.state == PlayerState.dead;

    // Shield aura
    if (engine.player.isShielded) {
      final pulse = (sin(animationValue * 6) + 1) / 2;
      _paint.shader = RadialGradient(
        colors: [const Color(0xFF4488FF).withOpacity(0.4 + pulse * 0.2), Colors.transparent],
      ).createShader(Rect.fromCircle(center: Offset(px, py + 35), radius: 50));
      canvas.drawCircle(Offset(px, py + 35), 50 + pulse * 6, _paint);
      _paint.shader = null;

      _paint
        ..color = const Color(0xFF44AAFF).withOpacity(0.6)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(Offset(px, py + 35), 46, _paint);
      _paint.style = PaintingStyle.fill;
    }

    // Shadow
    _paint.color = Colors.black.withOpacity(0.35);
    canvas.drawOval(Rect.fromCenter(
      center: Offset(px, _groundY - 4),
      width: isSliding ? 68 : 40,
      height: isSliding ? 14 : 9,
    ), _paint);

    if (isSliding) {
      _drawPlayerSliding(canvas, px, py + GameConfig.playerHeight * 0.5);
    } else {
      _drawPlayerRunning(canvas, px, py, isDead);
    }

    // Magnet field
    if (engine.player.hasMagnet) {
      final pulse = (sin(animationValue * 4) + 1) / 2;
      _paint
        ..color = const Color(0xFFFF4488).withOpacity(0.15 + pulse * 0.08)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(Offset(px, py + 35), 150, _paint);
      canvas.drawCircle(Offset(px, py + 35), 100, _paint);
      _paint.style = PaintingStyle.fill;
    }
  }

  void _drawPlayerRunning(Canvas canvas, double px, double py, bool isDead) {
    final leg = sin(animationValue * 12) * (isDead ? 0 : 9);

    // Cape
    _paint.color = const Color(0xFF8B0000);
    final cape = Path()
      ..moveTo(px - 13, py + 20)
      ..lineTo(px - 26, py + 48 + leg)
      ..lineTo(px - 9, py + 42)
      ..close();
    canvas.drawPath(cape, _paint);
    _paint.color = const Color(0xFFAA0000);
    final capeEdge = Path()
      ..moveTo(px - 13, py + 20)
      ..lineTo(px - 26, py + 48 + leg)
      ..lineTo(px - 20, py + 45)
      ..close();
    canvas.drawPath(capeEdge, _paint);

    // Legs
    _paint.color = const Color(0xFF4A3520);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(px - 13, py + 46, 11, 26 + leg), const Radius.circular(3)), _paint);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(px + 2, py + 46, 11, 26 - leg), const Radius.circular(3)), _paint);

    // Boots
    _paint.color = const Color(0xFF1A0A00);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(px - 16, py + 68 + leg, 16, 10), const Radius.circular(3)), _paint);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(px + 1, py + 68 - leg, 16, 10), const Radius.circular(3)), _paint);

    // Torso
    _paint.shader = LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [const Color(0xFFEEAA22), const Color(0xFFCC8800)],
    ).createShader(Rect.fromLTWH(px - 14, py + 20, 28, 28));
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(px - 14, py + 20, 28, 28), const Radius.circular(5)), _paint);
    _paint.shader = null;

    // Belt
    _paint.color = const Color(0xFF884400);
    canvas.drawRect(Rect.fromLTWH(px - 14, py + 40, 28, 5), _paint);
    _paint.color = const Color(0xFFFFDD00);
    canvas.drawRect(Rect.fromLTWH(px - 4, py + 40, 8, 5), _paint);

    // Arms
    _paint
      ..color = const Color(0xFFEEAA22)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(px - 14, py + 26), Offset(px - 28, py + 38 - leg), _paint);
    canvas.drawLine(Offset(px + 14, py + 26), Offset(px + 28, py + 38 + leg), _paint);
    _paint.style = PaintingStyle.fill;

    // Neck
    _paint.color = const Color(0xFFE8A060);
    canvas.drawRect(Rect.fromLTWH(px - 5, py + 15, 10, 8), _paint);

    // Head
    _paint.shader = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      colors: [const Color(0xFFF8D090), const Color(0xFFD4A060)],
    ).createShader(Rect.fromCircle(center: Offset(px, py + 10), radius: 17));
    canvas.drawCircle(Offset(px, py + 10), 17, _paint);
    _paint.shader = null;

    // Helmet band
    _paint.color = const Color(0xFFAA8800);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(px - 18, py - 3, 36, 11), const Radius.circular(3)), _paint);

    // Hat
    _paint.color = const Color(0xFFDDAA00);
    final hat = Path()
      ..moveTo(px - 14, py - 3)
      ..lineTo(px - 9, py - 20)
      ..lineTo(px + 9, py - 20)
      ..lineTo(px + 14, py - 3);
    canvas.drawPath(hat, _paint);
    // Hat tip
    _paint.color = const Color(0xFFFFCC00);
    canvas.drawCircle(Offset(px, py - 20), 4, _paint);

    // Eyes
    _paint.color = isDead ? const Color(0xFFFF2200) : Colors.white;
    canvas.drawOval(Rect.fromLTWH(px - 10, py + 5, 8, 9), _paint);
    canvas.drawOval(Rect.fromLTWH(px + 2, py + 5, 8, 9), _paint);
    _paint.color = isDead ? const Color(0xFF8B0000) : Colors.black87;
    canvas.drawCircle(Offset(px - 6, py + 9), 3, _paint);
    canvas.drawCircle(Offset(px + 6, py + 9), 3, _paint);
    // Eye shine
    _paint.color = Colors.white.withOpacity(0.8);
    canvas.drawCircle(Offset(px - 5, py + 7), 1, _paint);
    canvas.drawCircle(Offset(px + 7, py + 7), 1, _paint);
  }

  void _drawPlayerSliding(Canvas canvas, double px, double py) {
    // Sliding body
    _paint.color = const Color(0xFF4A3520);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(px - 30, py - 10, 60, 18), const Radius.circular(8)), _paint);
    _paint.shader = LinearGradient(
      colors: [const Color(0xFFEEAA22), const Color(0xFFCC8800)],
    ).createShader(Rect.fromLTWH(px - 20, py - 22, 38, 16));
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(px - 20, py - 22, 38, 16), const Radius.circular(6)), _paint);
    _paint.shader = null;
    // Head
    _paint.color = const Color(0xFFF8D090);
    canvas.drawCircle(Offset(px + 24, py - 14), 13, _paint);
    _paint.color = const Color(0xFFAA8800);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(px + 12, py - 24, 24, 8), const Radius.circular(3)), _paint);
  }

  // ─────────────────────────────────────────────
  // PARTICLES
  // ─────────────────────────────────────────────
  void _drawParticles(Canvas canvas) {
    for (final p in engine.particles) {
      _paint.color = p.color.withOpacity(p.opacity);
      canvas.drawCircle(Offset(p.x, p.y), p.size.clamp(1, 8), _paint);
    }
  }

  @override
  bool shouldRepaint(GamePainter old) => true;
}
