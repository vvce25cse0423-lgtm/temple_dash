import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../utils/constants.dart';
import '../utils/score_manager.dart';

class GameEngine extends ChangeNotifier {
  final GameState gameState = GameState();
  final PlayerModel player = PlayerModel();
  final List<ObstacleModel> obstacles = [];
  final List<CoinModel> coins = [];
  final List<PowerUpModel> powerUps = [];
  final List<ParticleEffect> particles = [];

  final Random _random = Random();
  final double groundY = GameConfig.gameHeight * 0.72;

  // Scroll offsets for parallax
  double _bgOffset1 = 0;
  double _bgOffset2 = 0;
  double _groundOffset = 0;
  double _treesOffset = 0;

  int _highScore = 0;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  double get bgOffset1 => _bgOffset1;
  double get bgOffset2 => _bgOffset2;
  double get groundOffset => _groundOffset;
  double get treesOffset => _treesOffset;
  int get highScore => _highScore;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  Lane? _pendingLaneChange;
  bool _pendingJump = false;
  bool _pendingSlide = false;
  double _laneChangeProgress = 1.0;
  double _targetX = 0;
  double _startX = 0;

  double get playerX {
    if (_laneChangeProgress >= 1.0) {
      return player.lane.xPosition;
    }
    return _startX + (_targetX - _startX) * _laneChangeProgress;
  }

  double get playerY => groundY - GameConfig.playerHeight + player.yPosition;

  Future<void> init() async {
    _highScore = await ScoreManager.getHighScore();
    _startX = player.lane.xPosition;
    _targetX = player.lane.xPosition;
    notifyListeners();
  }

  void startGame() {
    gameState.reset();
    player.lane = Lane.center;
    player.state = PlayerState.running;
    player.yPosition = 0;
    player.yVelocity = 0;
    player.isShielded = false;
    player.hasMagnet = false;
    _laneChangeProgress = 1.0;
    _startX = Lane.center.xPosition;
    _targetX = Lane.center.xPosition;
    obstacles.clear();
    coins.clear();
    powerUps.clear();
    particles.clear();
    _bgOffset1 = 0;
    _bgOffset2 = 0;
    _groundOffset = 0;
    _treesOffset = 0;
    notifyListeners();
  }

  void update(double dt) {
    if (!gameState.isRunning || gameState.isPaused || gameState.isGameOver) return;

    // Speed ramp
    gameState.speed = min(
      GameConfig.maxSpeed,
      gameState.speed + GameConfig.speedIncrement * dt,
    );

    // Parallax scroll
    _bgOffset1 = (_bgOffset1 - gameState.speed * 0.2 * dt) % GameConfig.gameWidth;
    _bgOffset2 = (_bgOffset2 - gameState.speed * 0.35 * dt) % GameConfig.gameWidth;
    _treesOffset = (_treesOffset - gameState.speed * 0.5 * dt) % GameConfig.gameWidth;
    _groundOffset = (_groundOffset - gameState.speed * dt) % 200;

    // Lane change animation
    if (_laneChangeProgress < 1.0) {
      _laneChangeProgress = min(1.0, _laneChangeProgress + dt * 8.0);
    } else if (_pendingLaneChange != null) {
      _startX = playerX;
      player.lane = _pendingLaneChange!;
      _targetX = player.lane.xPosition;
      _laneChangeProgress = 0.0;
      _pendingLaneChange = null;
    }

    // Handle pending actions
    if (_pendingJump && player.state != PlayerState.jumping) {
      _doJump();
    }
    if (_pendingSlide && player.state == PlayerState.running) {
      _doSlide();
    }
    _pendingJump = false;
    _pendingSlide = false;

    // Physics
    _updatePhysics(dt);

    // Timers
    _updatePowerUpTimers(dt);

    // Spawning
    _updateSpawning(dt);

    // Move obstacles
    _moveObstacles(dt);

    // Move coins
    _moveCoins(dt);

    // Move power-ups
    _movePowerUps(dt);

    // Update particles
    _updateParticles(dt);

    // Collision detection
    _checkCollisions();

    // Score
    gameState.distance += gameState.speed * dt;
    gameState.score = (gameState.distance / 10).floor() + gameState.coins * GameConfig.coinScore;

    notifyListeners();
  }

  void _updatePhysics(double dt) {
    if (player.state == PlayerState.jumping) {
      player.yVelocity += GameConfig.gravity * dt;
      player.yPosition += player.yVelocity * dt;
      if (player.yPosition >= 0) {
        player.yPosition = 0;
        player.yVelocity = 0;
        player.state = PlayerState.running;
      }
    }
  }

  void _updatePowerUpTimers(double dt) {
    if (player.isShielded) {
      player.shieldTimer -= (dt * 1000).floor();
      if (player.shieldTimer <= 0) {
        player.isShielded = false;
      }
    }
    if (player.hasMagnet) {
      player.magnetTimer -= (dt * 1000).floor();
      if (player.magnetTimer <= 0) {
        player.hasMagnet = false;
      }
    }
  }

  void _doJump() {
    player.state = PlayerState.jumping;
    player.yVelocity = GameConfig.jumpForce;
    _spawnParticles(playerX, playerY + GameConfig.playerHeight, AppColors.gold, 6);
  }

  void _doSlide() {
    player.state = PlayerState.sliding;
    Future.delayed(const Duration(milliseconds: 600), () {
      if (player.state == PlayerState.sliding) {
        player.state = PlayerState.running;
      }
    });
  }

  void _updateSpawning(double dt) {
    final spawnInterval = max(
      GameConfig.minSpawnInterval,
      GameConfig.obstacleSpawnInterval - gameState.distance / 10000,
    );

    gameState.spawnTimer += dt;
    if (gameState.spawnTimer >= spawnInterval) {
      gameState.spawnTimer = 0;
      _spawnObstacle();
    }

    gameState.coinSpawnTimer += dt;
    if (gameState.coinSpawnTimer >= 0.8) {
      gameState.coinSpawnTimer = 0;
      if (_random.nextDouble() < GameConfig.coinSpawnChance) {
        _spawnCoinRow();
      }
    }

    gameState.powerUpSpawnTimer += dt;
    if (gameState.powerUpSpawnTimer >= 8.0) {
      gameState.powerUpSpawnTimer = 0;
      if (_random.nextDouble() < 0.4) {
        _spawnPowerUp();
      }
    }
  }

  void _spawnObstacle() {
    final lanes = [Lane.left, Lane.center, Lane.right];
    lanes.shuffle(_random);
    final blockedLanes = _random.nextInt(2) + 1;
    final types = ObstacleType.values;

    for (int i = 0; i < blockedLanes; i++) {
      obstacles.add(ObstacleModel(
        x: lanes[i].xPosition,
        y: -GameConfig.obstacleHeight,
        lane: lanes[i],
        type: types[_random.nextInt(types.length)],
      ));
    }
  }

  void _spawnCoinRow() {
    final lane = Lane.values[_random.nextInt(3)];
    final count = _random.nextInt(4) + 3;
    for (int i = 0; i < count; i++) {
      coins.add(CoinModel(
        x: lane.xPosition + (_random.nextDouble() - 0.5) * 20,
        y: -GameConfig.coinSize - i * (GameConfig.coinSize + 15),
        lane: lane,
      ));
    }
  }

  void _spawnPowerUp() {
    final lane = Lane.values[_random.nextInt(3)];
    final type = PowerUpType.values[_random.nextInt(PowerUpType.values.length)];
    powerUps.add(PowerUpModel(
      x: lane.xPosition,
      y: -40,
      lane: lane,
      type: type,
    ));
  }

  void _moveObstacles(double dt) {
    for (final obs in obstacles) {
      obs.y += gameState.speed * dt;
    }
    obstacles.removeWhere((o) => o.y > GameConfig.gameHeight + 100);
  }

  void _moveCoins(double dt) {
    for (final coin in coins) {
      if (!coin.isCollected) {
        coin.y += gameState.speed * dt;
        // Magnet attraction
        if (player.hasMagnet) {
          final px = playerX;
          final py = playerY;
          final dx = px - coin.x;
          final dy = py - coin.y;
          final dist = sqrt(dx * dx + dy * dy);
          if (dist < 150) {
            coin.x += dx / dist * 200 * dt;
            coin.y += dy / dist * 200 * dt;
          }
        }
      }
    }
    coins.removeWhere((c) => c.y > GameConfig.gameHeight + 50 || c.isCollected);
  }

  void _movePowerUps(double dt) {
    for (final pu in powerUps) {
      pu.y += gameState.speed * dt;
    }
    powerUps.removeWhere((p) => p.y > GameConfig.gameHeight + 50 || p.isCollected);
  }

  void _updateParticles(double dt) {
    for (final p in particles) {
      p.update(dt);
    }
    particles.removeWhere((p) => p.isDead);
  }

  void _checkCollisions() {
    final px = playerX;
    final py = playerY;
    final isSliding = player.state == PlayerState.sliding;
    final playerHeight = isSliding ? GameConfig.playerHeight * 0.5 : GameConfig.playerHeight;

    final playerRect = Rect.fromLTWH(
      px - GameConfig.playerWidth / 2 + 8,
      py + (isSliding ? GameConfig.playerHeight * 0.5 : 0),
      GameConfig.playerWidth - 16,
      playerHeight - 10,
    );

    // Obstacle collisions
    for (final obs in obstacles) {
      if (!obs.isActive) continue;
      if (obs.bounds.overlaps(playerRect)) {
        if (player.isShielded) {
          obs.isActive = false;
          player.isShielded = false;
          _spawnParticles(px, py, AppColors.sapphire, 12);
        } else {
          _triggerGameOver();
          return;
        }
      }
    }

    // Coin collisions
    for (final coin in coins) {
      if (coin.isCollected) continue;
      if (coin.bounds.overlaps(playerRect)) {
        coin.isCollected = true;
        gameState.coins++;
        _spawnParticles(coin.x, coin.y, AppColors.gold, 5);
      }
    }

    // Power-up collisions
    for (final pu in powerUps) {
      if (pu.isCollected) continue;
      final puRect = pu.bounds;
      if (puRect.overlaps(playerRect)) {
        pu.isCollected = true;
        _applyPowerUp(pu.type);
        _spawnParticles(pu.x, pu.y, pu.color, 10);
      }
    }
  }

  void _applyPowerUp(PowerUpType type) {
    switch (type) {
      case PowerUpType.shield:
        player.isShielded = true;
        player.shieldTimer = 5000;
        break;
      case PowerUpType.magnet:
        player.hasMagnet = true;
        player.magnetTimer = 6000;
        break;
      case PowerUpType.speedBoost:
        gameState.speed = min(GameConfig.maxSpeed, gameState.speed + 100);
        break;
      case PowerUpType.doubleCoins:
        gameState.coins += 5;
        break;
    }
  }

  void _spawnParticles(double x, double y, Color color, int count) {
    for (int i = 0; i < count; i++) {
      particles.add(ParticleEffect(
        x: x,
        y: y,
        color: color,
        vx: (_random.nextDouble() - 0.5) * 200,
        vy: (_random.nextDouble() - 1.0) * 200,
      ));
    }
  }

  Future<void> _triggerGameOver() async {
    player.state = PlayerState.dead;
    gameState.isRunning = false;
    gameState.isGameOver = true;
    _spawnParticles(playerX, playerY, AppColors.lava, 20);

    final isNew = await ScoreManager.setHighScore(gameState.score);
    gameState.isNewHighScore = isNew;
    if (isNew) _highScore = gameState.score;

    await ScoreManager.addCoins(gameState.coins);
    await ScoreManager.incrementGamesPlayed();
    notifyListeners();
  }

  // Input handlers
  void swipeLeft() {
    if (!gameState.isRunning || gameState.isPaused) return;
    if (player.lane == Lane.right) _pendingLaneChange = Lane.center;
    else if (player.lane == Lane.center) _pendingLaneChange = Lane.left;
  }

  void swipeRight() {
    if (!gameState.isRunning || gameState.isPaused) return;
    if (player.lane == Lane.left) _pendingLaneChange = Lane.center;
    else if (player.lane == Lane.center) _pendingLaneChange = Lane.right;
  }

  void swipeUp() {
    if (!gameState.isRunning || gameState.isPaused) return;
    if (player.state == PlayerState.running) _pendingJump = true;
  }

  void swipeDown() {
    if (!gameState.isRunning || gameState.isPaused) return;
    if (player.state == PlayerState.running || player.state == PlayerState.jumping) {
      _pendingSlide = true;
    }
  }

  void togglePause() {
    if (gameState.isGameOver) return;
    gameState.isPaused = !gameState.isPaused;
    notifyListeners();
  }

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    notifyListeners();
  }
}

class ParticleEffect {
  double x, y, vx, vy;
  final Color color;
  double life;
  double maxLife;
  double size;

  ParticleEffect({
    required this.x,
    required this.y,
    required this.color,
    required this.vx,
    required this.vy,
    this.life = 0.8,
    this.size = 6,
  }) : maxLife = 0.8;

  void update(double dt) {
    x += vx * dt;
    y += vy * dt;
    vy += 300 * dt; // gravity
    life -= dt;
    size = (life / maxLife) * 6;
  }

  bool get isDead => life <= 0;
  double get opacity => (life / maxLife).clamp(0, 1);
}
