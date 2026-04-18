import 'package:flutter/material.dart';

class AppColors {
  static const Color gold = Color(0xFFFFD700);
  static const Color orange = Color(0xFFFF6B35);
  static const Color darkBrown = Color(0xFF1A0A00);
  static const Color brown = Color(0xFF3D1C02);
  static const Color lightBrown = Color(0xFF8B4513);
  static const Color cream = Color(0xFFFFF8DC);
  static const Color forestGreen = Color(0xFF228B22);
  static const Color skyBlue = Color(0xFF87CEEB);
  static const Color lava = Color(0xFFFF4500);
  static const Color emerald = Color(0xFF50C878);
  static const Color ruby = Color(0xFFE0115F);
  static const Color sapphire = Color(0xFF0F52BA);
}

class GameConfig {
  static const double gameWidth = 400.0;
  static const double gameHeight = 700.0;
  static const double playerWidth = 50.0;
  static const double playerHeight = 70.0;
  static const double laneWidth = 120.0;
  static const int totalLanes = 3;

  // Speed config
  static const double initialSpeed = 300.0;
  static const double maxSpeed = 800.0;
  static const double speedIncrement = 10.0;

  // Jump config
  static const double jumpForce = -600.0;
  static const double gravity = 1200.0;

  // Obstacle
  static const double obstacleWidth = 76.0;
  static const double obstacleHeight = 90.0;
  static const double obstacleSpawnInterval = 2.2;
  static const double minSpawnInterval = 1.0;

  // Coin
  static const double coinSize = 30.0;
  static const double coinSpawnChance = 0.6;

  // Scoring
  static const int coinScore = 10;
  static const int distanceScore = 1;
}

class AppStrings {
  static const String appName = 'Temple Dash';
  static const String play = 'PLAY';
  static const String highScore = 'HIGH SCORE';
  static const String score = 'SCORE';
  static const String coins = 'COINS';
  static const String gameOver = 'GAME OVER';
  static const String restart = 'RESTART';
  static const String home = 'HOME';
  static const String settings = 'SETTINGS';
  static const String pause = 'PAUSE';
  static const String resume = 'RESUME';
}
