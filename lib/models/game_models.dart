import 'package:flutter/material.dart';
import '../utils/constants.dart';

enum Lane { left, center, right }

enum PlayerState { running, jumping, sliding, dead }

enum ObstacleType { rock, fire, wall, log }

enum PowerUpType { shield, magnet, speedBoost, doubleCoins }

extension LaneExtension on Lane {
  double get xPosition {
    switch (this) {
      case Lane.left:
        return GameConfig.gameWidth / 2 - GameConfig.laneWidth;
      case Lane.center:
        return GameConfig.gameWidth / 2;
      case Lane.right:
        return GameConfig.gameWidth / 2 + GameConfig.laneWidth;
    }
  }
}

class PlayerModel {
  Lane lane;
  PlayerState state;
  double yPosition;
  double yVelocity;
  bool isShielded;
  bool hasMagnet;
  int shieldTimer;
  int magnetTimer;

  PlayerModel({
    this.lane = Lane.center,
    this.state = PlayerState.running,
    this.yPosition = 0,
    this.yVelocity = 0,
    this.isShielded = false,
    this.hasMagnet = false,
    this.shieldTimer = 0,
    this.magnetTimer = 0,
  });
}

class ObstacleModel {
  double x;
  double y;
  Lane lane;
  ObstacleType type;
  bool isActive;

  ObstacleModel({
    required this.x,
    required this.y,
    required this.lane,
    required this.type,
    this.isActive = true,
  });

  Rect get bounds => Rect.fromLTWH(
        x - GameConfig.obstacleWidth / 2,
        y - GameConfig.obstacleHeight / 2,
        GameConfig.obstacleWidth * 0.8,
        GameConfig.obstacleHeight * 0.8,
      );
}

class CoinModel {
  double x;
  double y;
  Lane lane;
  bool isCollected;
  bool isMagnetized;

  CoinModel({
    required this.x,
    required this.y,
    required this.lane,
    this.isCollected = false,
    this.isMagnetized = false,
  });

  Rect get bounds => Rect.fromLTWH(
        x - GameConfig.coinSize / 2,
        y - GameConfig.coinSize / 2,
        GameConfig.coinSize,
        GameConfig.coinSize,
      );
}

class PowerUpModel {
  double x;
  double y;
  Lane lane;
  PowerUpType type;
  bool isCollected;

  PowerUpModel({
    required this.x,
    required this.y,
    required this.lane,
    required this.type,
    this.isCollected = false,
  });

  Rect get bounds => Rect.fromLTWH(x - 20, y - 20, 40, 40);

  Color get color {
    switch (type) {
      case PowerUpType.shield:
        return AppColors.sapphire;
      case PowerUpType.magnet:
        return AppColors.ruby;
      case PowerUpType.speedBoost:
        return AppColors.orange;
      case PowerUpType.doubleCoins:
        return AppColors.gold;
    }
  }

  IconData get icon {
    switch (type) {
      case PowerUpType.shield:
        return Icons.shield;
      case PowerUpType.magnet:
        return Icons.radar;
      case PowerUpType.speedBoost:
        return Icons.flash_on;
      case PowerUpType.doubleCoins:
        return Icons.monetization_on;
    }
  }
}

class GameState {
  bool isRunning;
  bool isPaused;
  bool isGameOver;
  int score;
  int coins;
  double distance;
  double speed;
  double spawnTimer;
  double coinSpawnTimer;
  double powerUpSpawnTimer;
  int combo;
  bool isNewHighScore;

  GameState({
    this.isRunning = false,
    this.isPaused = false,
    this.isGameOver = false,
    this.score = 0,
    this.coins = 0,
    this.distance = 0,
    this.speed = GameConfig.initialSpeed,
    this.spawnTimer = 0,
    this.coinSpawnTimer = 0,
    this.powerUpSpawnTimer = 0,
    this.combo = 0,
    this.isNewHighScore = false,
  });

  void reset() {
    isRunning = true;
    isPaused = false;
    isGameOver = false;
    score = 0;
    coins = 0;
    distance = 0;
    speed = GameConfig.initialSpeed;
    spawnTimer = 0;
    coinSpawnTimer = 0;
    powerUpSpawnTimer = 0;
    combo = 0;
    isNewHighScore = false;
  }
}
