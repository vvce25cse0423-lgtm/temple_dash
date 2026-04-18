import 'dart:math';
import 'package:flutter/material.dart';
import '../game/game_engine.dart';
import '../models/game_models.dart';
import '../utils/constants.dart';

class GamePainter extends CustomPainter {
  final GameEngine engine;
  final double animationValue;
  final Paint _paint = Paint();

  GamePainter(this.engine, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawTrees(canvas, size);
    _drawTrack(canvas, size);
    _drawLaneMarkers(canvas, size);
    _drawCoins(canvas);
    _drawPowerUps(canvas);
    _drawObstacles(canvas);
    _drawPlayer(canvas, size);
    _drawParticles(canvas);
  }

  void _drawBackground(Canvas canvas, Size size) {
    // Sky gradient
    final skyRect = Rect.fromLTWH(0, 0, size.width, size.height * 0.6);
    final skyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF0D0221),
        const Color(0xFF1A0A00),
        const Color(0xFF3D1C02),
      ],
    );
    _paint.shader = skyGradient.createShader(skyRect);
    canvas.drawRect(skyRect, _paint);
    _paint.shader = null;

    // Stars
    _paint.color = Colors.white.withOpacity(0.6);
    final rand = Random(42);
    for (int i = 0; i < 80; i++) {
      final sx = rand.nextDouble() * size.width;
      final sy = rand.nextDouble() * size.height * 0.5;
      final ss = rand.nextDouble() * 2 + 0.5;
      final blink = (sin(animationValue * 3 + i) + 1) / 2;
      _paint.color = Colors.white.withOpacity(0.3 + blink * 0.4);
      canvas.drawCircle(Offset(sx, sy), ss, _paint);
    }

    // Moon
    _paint.color = const Color(0xFFFFF8DC);
    canvas.drawCircle(const Offset(300, 60), 30, _paint);
    _paint.color = const Color(0xFF1A0A00);
    canvas.drawCircle(const Offset(310, 55), 26, _paint);

    // Distant temple silhouette
    _drawTempleSilhouette(canvas, size);
  }

  void _drawTempleSilhouette(Canvas canvas, Size size) {
    final groundY = size.height * 0.55;
    _paint.color = const Color(0xFF0D0818).withOpacity(0.8);

    // Temple body
    final templeRect = Rect.fromLTWH(size.width * 0.3, groundY - 80, size.width * 0.4, 80);
    canvas.drawRect(templeRect, _paint);

    // Pillars
    for (int i = 0; i < 5; i++) {
      final px = size.width * 0.32 + i * (size.width * 0.38 / 4);
      canvas.drawRect(Rect.fromLTWH(px, groundY - 90, 10, 90), _paint);
    }

    // Roof tiers
    _drawRoofTier(canvas, size.width * 0.28, groundY - 80, size.width * 0.44, 25);
    _drawRoofTier(canvas, size.width * 0.33, groundY - 105, size.width * 0.34, 20);
    _drawRoofTier(canvas, size.width * 0.38, groundY - 125, size.width * 0.24, 18);

    // Spire
    final path = Path();
    path.moveTo(size.width * 0.5, groundY - 155);
    path.lineTo(size.width * 0.48, groundY - 125);
    path.lineTo(size.width * 0.52, groundY - 125);
    path.close();
    canvas.drawPath(path, _paint);
  }

  void _drawRoofTier(Canvas canvas, double x, double y, double w, double h) {
    final path = Path();
    path.moveTo(x + w / 2, y - h);
    path.lineTo(x, y);
    path.lineTo(x + w, y);
    path.close();
    canvas.drawPath(path, _paint);
  }

  void _drawTrees(Canvas canvas, Size size) {
    final groundY = size.height * 0.72;
    final offset = engine.treesOffset;

    for (int i = -1; i <= 3; i++) {
      final baseX = i * (size.width / 2) + offset % (size.width / 2);
      _drawTree(canvas, baseX - 40, groundY - 20, 0.7);
      _drawTree(canvas, baseX + size.width / 4 + 20, groundY - 15, 0.8);
    }
  }

  void _drawTree(Canvas canvas, double x, double y, double scale) {
    final h = 100 * scale;
    final w = 50 * scale;

    // Trunk
    _paint.color = const Color(0xFF4A2F1A);
    canvas.drawRect(Rect.fromLTWH(x - 5 * scale, y - h * 0.3, 10 * scale, h * 0.3), _paint);

    // Foliage layers
    final colors = [
      const Color(0xFF0B3D0B),
      const Color(0xFF145214),
      const Color(0xFF1A6B1A),
    ];

    for (int i = 0; i < 3; i++) {
      _paint.color = colors[i];
      final layerY = y - h * 0.25 - i * h * 0.22;
      final layerW = w * (1.0 - i * 0.2);
      final path = Path();
      path.moveTo(x, layerY - h * 0.3);
      path.lineTo(x - layerW / 2, layerY);
      path.lineTo(x + layerW / 2, layerY);
      path.close();
      canvas.drawPath(path, _paint);
    }
  }

  void _drawTrack(Canvas canvas, Size size) {
    final groundY = size.height * 0.72;
    final trackBottom = size.height;
    final trackWidth = GameConfig.laneWidth * 3 + 30;
    final centerX = size.width / 2;

    // Track base gradient
    final trackRect = Rect.fromLTWH(
      centerX - trackWidth / 2, groundY, trackWidth, trackBottom - groundY,
    );

    _paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF5C3A1E),
        const Color(0xFF3D2010),
        const Color(0xFF2A1508),
      ],
    ).createShader(trackRect);
    canvas.drawRect(trackRect, _paint);
    _paint.shader = null;

    // Track tiles
    final tileH = 60.0;
    final tileOffset = engine.groundOffset % tileH;
    _paint.color = const Color(0xFF6B4423).withOpacity(0.4);
    _paint.strokeWidth = 1;
    _paint.style = PaintingStyle.stroke;
    for (double ty = groundY - tileOffset; ty < trackBottom; ty += tileH) {
      canvas.drawLine(
        Offset(centerX - trackWidth / 2, ty),
        Offset(centerX + trackWidth / 2, ty),
        _paint,
      );
    }
    _paint.style = PaintingStyle.fill;

    // Track edges
    _paint.color = const Color(0xFF8B5E3C);
    _paint.strokeWidth = 3;
    _paint.style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(centerX - trackWidth / 2, groundY),
      Offset(centerX - trackWidth / 2, trackBottom),
      _paint,
    );
    canvas.drawLine(
      Offset(centerX + trackWidth / 2, groundY),
      Offset(centerX + trackWidth / 2, trackBottom),
      _paint,
    );
    _paint.style = PaintingStyle.fill;

    // Fog
    final fogRect = Rect.fromLTWH(0, groundY - 30, size.width, 60);
    _paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        const Color(0xFF1A0A00).withOpacity(0.3),
        Colors.transparent,
      ],
    ).createShader(fogRect);
    canvas.drawRect(fogRect, _paint);
    _paint.shader = null;
  }

  void _drawLaneMarkers(Canvas canvas, Size size) {
    final groundY = size.height * 0.72;
    final centerX = size.width / 2;
    _paint.color = const Color(0xFFFFD700).withOpacity(0.15);
    _paint.strokeWidth = 1.5;
    _paint.style = PaintingStyle.stroke;

    // Dashed lane lines
    final dashH = 20.0;
    final gapH = 15.0;
    final laneOffset = engine.groundOffset % (dashH + gapH);

    for (final lx in [centerX - GameConfig.laneWidth / 2, centerX + GameConfig.laneWidth / 2]) {
      double y = groundY - laneOffset;
      while (y < size.height) {
        canvas.drawLine(Offset(lx, y), Offset(lx, y + dashH), _paint);
        y += dashH + gapH;
      }
    }
    _paint.style = PaintingStyle.fill;
  }

  void _drawCoins(Canvas canvas) {
    for (final coin in engine.coins) {
      if (coin.isCollected) continue;
      final pulse = (sin(animationValue * 4 + coin.x) + 1) / 2;

      // Outer glow
      _paint.color = AppColors.gold.withOpacity(0.3 + pulse * 0.2);
      canvas.drawCircle(
        Offset(coin.x, coin.y),
        GameConfig.coinSize / 2 + 5 + pulse * 3,
        _paint,
      );

      // Coin body
      final gradient = RadialGradient(
        colors: [const Color(0xFFFFEA00), AppColors.gold, const Color(0xFFB8860B)],
        stops: const [0.0, 0.6, 1.0],
      );
      _paint.shader = gradient.createShader(
        Rect.fromCircle(center: Offset(coin.x, coin.y), radius: GameConfig.coinSize / 2),
      );
      canvas.drawCircle(Offset(coin.x, coin.y), GameConfig.coinSize / 2, _paint);
      _paint.shader = null;

      // Symbol
      final tp = TextPainter(
        text: const TextSpan(text: '✦', style: TextStyle(fontSize: 12, color: Color(0xFF8B6914))),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(coin.x - tp.width / 2, coin.y - tp.height / 2));
    }
  }

  void _drawPowerUps(Canvas canvas) {
    for (final pu in engine.powerUps) {
      if (pu.isCollected) continue;
      final pulse = (sin(animationValue * 5) + 1) / 2;

      // Glow ring
      _paint.color = pu.color.withOpacity(0.3 + pulse * 0.3);
      canvas.drawCircle(Offset(pu.x, pu.y), 28 + pulse * 5, _paint);

      // Background
      _paint.color = pu.color.withOpacity(0.9);
      canvas.drawCircle(Offset(pu.x, pu.y), 22, _paint);

      // Icon text
      final icons = {
        PowerUpType.shield: '🛡',
        PowerUpType.magnet: '🧲',
        PowerUpType.speedBoost: '⚡',
        PowerUpType.doubleCoins: '💰',
      };
      final tp = TextPainter(
        text: TextSpan(text: icons[pu.type], style: const TextStyle(fontSize: 20)),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(pu.x - tp.width / 2, pu.y - tp.height / 2));
    }
  }

  void _drawObstacles(Canvas canvas) {
    for (final obs in engine.obstacles) {
      if (!obs.isActive) continue;
      switch (obs.type) {
        case ObstacleType.rock:
          _drawRock(canvas, obs.x, obs.y);
          break;
        case ObstacleType.fire:
          _drawFire(canvas, obs.x, obs.y);
          break;
        case ObstacleType.wall:
          _drawWall(canvas, obs.x, obs.y);
          break;
        case ObstacleType.log:
          _drawLog(canvas, obs.x, obs.y);
          break;
      }
    }
  }

  void _drawRock(Canvas canvas, double x, double y) {
    final path = Path();
    path.moveTo(x - 28, y + 35);
    path.lineTo(x - 32, y + 5);
    path.lineTo(x - 15, y - 30);
    path.lineTo(x + 5, y - 38);
    path.lineTo(x + 28, y - 20);
    path.lineTo(x + 33, y + 15);
    path.lineTo(x + 20, y + 35);
    path.close();

    _paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [const Color(0xFF8C8C8C), const Color(0xFF4A4A4A), const Color(0xFF2A2A2A)],
    ).createShader(Rect.fromLTWH(x - 35, y - 40, 70, 80));
    canvas.drawPath(path, _paint);
    _paint.shader = null;

    _paint.color = const Color(0xFFAAAAAA).withOpacity(0.5);
    _paint.style = PaintingStyle.stroke;
    _paint.strokeWidth = 1.5;
    canvas.drawPath(path, _paint);
    _paint.style = PaintingStyle.fill;
  }

  void _drawFire(Canvas canvas, double x, double y) {
    final pulse = (sin(animationValue * 8) + 1) / 2;

    // Base glow
    _paint.color = AppColors.lava.withOpacity(0.3);
    canvas.drawOval(Rect.fromCenter(center: Offset(x, y + 30), width: 70, height: 20), _paint);

    for (int i = 0; i < 3; i++) {
      final offset = (i - 1) * 18.0;
      final h = 65.0 + pulse * 15 + i * 8;
      _drawFlame(canvas, x + offset, y, h, i == 1);
    }
  }

  void _drawFlame(Canvas canvas, double x, double y, double h, bool main) {
    final path = Path();
    path.moveTo(x - 18, y + 35);
    path.quadraticBezierTo(x - 22, y, x, y - h);
    path.quadraticBezierTo(x + 22, y, x + 18, y + 35);
    path.close();

    _paint.shader = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: main
          ? [const Color(0xFFFF0000), const Color(0xFFFF6600), const Color(0xFFFFCC00)]
          : [const Color(0xFFFF3300), const Color(0xFFFF6600), Colors.transparent],
    ).createShader(Rect.fromLTWH(x - 22, y - h, 44, h + 35));
    canvas.drawPath(path, _paint);
    _paint.shader = null;
  }

  void _drawWall(Canvas canvas, double x, double y) {
    // Wall body
    _paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [const Color(0xFF8B7355), const Color(0xFF6B5A45), const Color(0xFF4A3F2F)],
    ).createShader(Rect.fromLTWH(x - 32, y - 40, 64, 80));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x - 32, y - 40, 64, 80), const Radius.circular(4)),
      _paint,
    );
    _paint.shader = null;

    // Brick pattern
    _paint.color = Colors.black.withOpacity(0.3);
    _paint.strokeWidth = 1;
    _paint.style = PaintingStyle.stroke;
    for (int row = 0; row < 4; row++) {
      final by = y - 35 + row * 20;
      final offset = row.isEven ? 0.0 : 16.0;
      for (int col = -2; col <= 2; col++) {
        final bx = x + col * 32 + offset;
        canvas.drawRect(Rect.fromLTWH(bx - 14, by, 28, 18), _paint);
      }
    }
    _paint.style = PaintingStyle.fill;
  }

  void _drawLog(Canvas canvas, double x, double y) {
    _paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [const Color(0xFF8B4513), const Color(0xFF5C3317), const Color(0xFF3D2210)],
    ).createShader(Rect.fromLTWH(x - 35, y - 20, 70, 55));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x - 35, y - 20, 70, 55), const Radius.circular(8)),
      _paint,
    );
    _paint.shader = null;

    // Wood grain
    _paint.color = const Color(0xFF3D2210).withOpacity(0.5);
    _paint.strokeWidth = 1;
    _paint.style = PaintingStyle.stroke;
    for (int i = -2; i <= 2; i++) {
      canvas.drawLine(Offset(x + i * 12, y - 20), Offset(x + i * 12, y + 35), _paint);
    }
    // End caps
    canvas.drawOval(Rect.fromLTWH(x - 35, y - 28, 70, 20), _paint);
    canvas.drawOval(Rect.fromLTWH(x - 35, y + 27, 70, 20), _paint);
    _paint.style = PaintingStyle.fill;
  }

  void _drawPlayer(Canvas canvas, Size size) {
    final px = engine.playerX;
    final py = engine.playerY;
    final isSliding = engine.player.state == PlayerState.sliding;
    final isDead = engine.player.state == PlayerState.dead;

    // Shield effect
    if (engine.player.isShielded) {
      final pulse = (sin(animationValue * 6) + 1) / 2;
      _paint.color = AppColors.sapphire.withOpacity(0.3 + pulse * 0.2);
      canvas.drawCircle(
        Offset(px, py + GameConfig.playerHeight / 2),
        45 + pulse * 5,
        _paint,
      );
    }

    // Shadow
    _paint.color = Colors.black.withOpacity(0.4);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(px, engine.groundY - 5),
        width: isSliding ? 60 : 40,
        height: isSliding ? 15 : 10,
      ),
      _paint,
    );

    if (isSliding) {
      _drawPlayerSliding(canvas, px, py + GameConfig.playerHeight * 0.5);
    } else {
      _drawPlayerRunning(canvas, px, py, isDead);
    }

    // Magnet aura
    if (engine.player.hasMagnet) {
      final pulse = (sin(animationValue * 4) + 1) / 2;
      _paint.color = AppColors.ruby.withOpacity(0.2 + pulse * 0.1);
      _paint.style = PaintingStyle.stroke;
      _paint.strokeWidth = 2;
      canvas.drawCircle(
        Offset(px, py + GameConfig.playerHeight / 2),
        150,
        _paint,
      );
      _paint.style = PaintingStyle.fill;
    }
  }

  void _drawPlayerRunning(Canvas canvas, double px, double py, bool isDead) {
    final legSwing = isDead ? 0.0 : sin(animationValue * 12) * 8;

    // Body (torso)
    _paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [const Color(0xFFE8A020), const Color(0xFFC07010)],
    ).createShader(Rect.fromLTWH(px - 14, py + 20, 28, 28));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(px - 14, py + 20, 28, 28), const Radius.circular(5)),
      _paint,
    );
    _paint.shader = null;

    // Cape
    final capePath = Path();
    capePath.moveTo(px - 14, py + 22);
    capePath.lineTo(px - 24, py + 48 + legSwing);
    capePath.lineTo(px - 10, py + 45);
    capePath.close();
    _paint.color = const Color(0xFF8B0000);
    canvas.drawPath(capePath, _paint);

    // Head
    _paint.shader = RadialGradient(
      colors: [const Color(0xFFF4C88A), const Color(0xFFD4A870)],
      center: const Alignment(-0.3, -0.3),
    ).createShader(Rect.fromCircle(center: Offset(px, py + 12), radius: 16));
    canvas.drawCircle(Offset(px, py + 12), 16, _paint);
    _paint.shader = null;

    // Helmet/hat
    _paint.color = const Color(0xFF8B6914);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(px - 17, py - 2, 34, 10), const Radius.circular(3)),
      _paint,
    );
    final hatPath = Path();
    hatPath.moveTo(px - 12, py - 2);
    hatPath.lineTo(px - 8, py - 18);
    hatPath.lineTo(px + 8, py - 18);
    hatPath.lineTo(px + 12, py - 2);
    _paint.color = const Color(0xFFB8860B);
    canvas.drawPath(hatPath, _paint);

    // Eyes
    _paint.color = isDead ? Colors.red : Colors.white;
    canvas.drawOval(Rect.fromLTWH(px - 9, py + 8, 7, 8), _paint);
    canvas.drawOval(Rect.fromLTWH(px + 2, py + 8, 7, 8), _paint);
    _paint.color = isDead ? Colors.darkRed : Colors.black87;
    canvas.drawCircle(Offset(px - 5.5, py + 12), 3, _paint);
    canvas.drawCircle(Offset(px + 5.5, py + 12), 3, _paint);

    // Arms
    _paint.color = const Color(0xFFE8A020);
    _paint.strokeWidth = 7;
    _paint.strokeCap = StrokeCap.round;
    _paint.style = PaintingStyle.stroke;
    canvas.drawLine(Offset(px - 14, py + 26), Offset(px - 26, py + 36 - legSwing), _paint);
    canvas.drawLine(Offset(px + 14, py + 26), Offset(px + 26, py + 36 + legSwing), _paint);
    _paint.style = PaintingStyle.fill;

    // Legs
    _paint.color = const Color(0xFF4A3520);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(px - 13, py + 46, 11, 26 + legSwing),
        const Radius.circular(3),
      ),
      _paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(px + 2, py + 46, 11, 26 - legSwing),
        const Radius.circular(3),
      ),
      _paint,
    );

    // Boots
    _paint.color = const Color(0xFF2A1A0A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(px - 16, py + 68 + legSwing, 16, 10),
        const Radius.circular(3),
      ),
      _paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(px + 1, py + 68 - legSwing, 16, 10),
        const Radius.circular(3),
      ),
      _paint,
    );
  }

  void _drawPlayerSliding(Canvas canvas, double px, double py) {
    _paint.color = const Color(0xFF4A3520);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(px - 28, py - 12, 56, 20),
        const Radius.circular(8),
      ),
      _paint,
    );
    _paint.color = const Color(0xFFE8A020);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(px - 18, py - 22, 36, 16),
        const Radius.circular(6),
      ),
      _paint,
    );
    // Head
    _paint.color = const Color(0xFFF4C88A);
    canvas.drawCircle(Offset(px + 22, py - 15), 13, _paint);
  }

  void _drawParticles(Canvas canvas) {
    for (final p in engine.particles) {
      _paint.color = p.color.withOpacity(p.opacity);
      canvas.drawCircle(Offset(p.x, p.y), p.size, _paint);
    }
  }

  @override
  bool shouldRepaint(GamePainter oldDelegate) => true;
}
