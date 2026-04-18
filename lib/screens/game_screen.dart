import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/game_engine.dart';
import '../game/game_painter.dart';
import '../utils/constants.dart';
import '../widgets/hud_widget.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/pause_overlay.dart';
import '../widgets/countdown_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameEngine _engine;
  late AnimationController _animController;
  Timer? _gameLoop;
  DateTime? _lastUpdate;

  // Swipe detection
  Offset? _swipeStart;
  DateTime? _swipeStartTime;

  bool _showCountdown = true;
  int _countdown = 3;

  @override
  void initState() {
    super.initState();
    _engine = GameEngine();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _engine.init().then((_) {
      _startCountdown();
    });
  }

  void _startCountdown() {
    setState(() {
      _showCountdown = true;
      _countdown = 3;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _countdown--);
      if (_countdown <= 0) {
        timer.cancel();
        setState(() => _showCountdown = false);
        _engine.startGame();
        _startGameLoop();
      }
    });
  }

  void _startGameLoop() {
    _lastUpdate = DateTime.now();
    _gameLoop = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final now = DateTime.now();
      final dt = now.difference(_lastUpdate!).inMilliseconds / 1000.0;
      _lastUpdate = now;
      _engine.update(dt.clamp(0.0, 0.05));
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _gameLoop?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _handleSwipeStart(Offset pos) {
    _swipeStart = pos;
    _swipeStartTime = DateTime.now();
  }

  void _handleSwipeEnd(Offset pos) {
    if (_swipeStart == null) return;
    final dx = pos.dx - _swipeStart!.dx;
    final dy = pos.dy - _swipeStart!.dy;
    final elapsed = DateTime.now().difference(_swipeStartTime!).inMilliseconds;

    if (elapsed > 500) {
      _swipeStart = null;
      return;
    }

    const minSwipe = 30.0;
    if (dx.abs() > dy.abs() && dx.abs() > minSwipe) {
      if (dx > 0) _engine.swipeRight();
      else _engine.swipeLeft();
    } else if (dy.abs() > minSwipe) {
      if (dy < 0) _engine.swipeUp();
      else _engine.swipeDown();
    }
    _swipeStart = null;
  }

  void _handleTap(Offset pos, Size size) {
    // Tap left half = move left, right half = move right
    // Tap top quarter = jump
    if (pos.dy < size.height * 0.25) {
      _engine.swipeUp();
    } else if (pos.dx < size.width * 0.35) {
      _engine.swipeLeft();
    } else if (pos.dx > size.width * 0.65) {
      _engine.swipeRight();
    } else {
      _engine.swipeUp();
    }
  }

  void _restartGame() {
    _gameLoop?.cancel();
    _startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.darkBrown,
      body: GestureDetector(
        onPanStart: (d) => _handleSwipeStart(d.localPosition),
        onPanEnd: (d) => _handleSwipeEnd(d.localPosition),
        onTapDown: (d) => _handleTap(d.localPosition, size),
        child: Stack(
          children: [
            // Game canvas
            AnimatedBuilder(
              animation: _animController,
              builder: (_, __) => CustomPaint(
                painter: GamePainter(_engine, _animController.value * 2 * 3.14159),
                size: size,
              ),
            ),

            // HUD
            if (!_engine.gameState.isGameOver && !_showCountdown)
              HudWidget(engine: _engine),

            // Countdown
            if (_showCountdown) CountdownWidget(count: _countdown),

            // Pause overlay
            if (_engine.gameState.isPaused && !_engine.gameState.isGameOver)
              PauseOverlay(
                onResume: () {
                  _engine.togglePause();
                  setState(() {});
                },
                onHome: () => Navigator.pop(context),
              ),

            // Game over overlay
            if (_engine.gameState.isGameOver)
              GameOverOverlay(
                engine: _engine,
                onRestart: _restartGame,
                onHome: () => Navigator.pop(context),
              ),

            // Pause button
            if (!_engine.gameState.isGameOver && !_showCountdown)
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                right: 16,
                child: GestureDetector(
                  onTap: () {
                    _engine.togglePause();
                    setState(() {});
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.5),
                      border: Border.all(color: AppColors.gold.withOpacity(0.5)),
                    ),
                    child: Icon(
                      _engine.gameState.isPaused ? Icons.play_arrow : Icons.pause,
                      color: AppColors.gold,
                      size: 22,
                    ),
                  ),
                ),
              ),

            // Swipe hints (shown briefly)
            if (!_showCountdown && _engine.gameState.score == 0 && !_engine.gameState.isGameOver)
              _buildSwipeHints(size),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeHints(Size size) {
    return Positioned(
      bottom: 60,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _hintItem('←', 'Left'),
          _hintItem('↑', 'Jump'),
          _hintItem('↓', 'Slide'),
          _hintItem('→', 'Right'),
        ],
      ),
    );
  }

  Widget _hintItem(String icon, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24, color: Colors.white54)),
        Text(
          label,
          style: GoogleFonts.cinzel(fontSize: 10, color: Colors.white38, letterSpacing: 1),
        ),
      ],
    );
  }
}
