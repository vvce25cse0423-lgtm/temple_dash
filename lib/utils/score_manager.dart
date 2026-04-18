import 'package:shared_preferences/shared_preferences.dart';

class ScoreManager {
  static const String _highScoreKey = 'high_score';
  static const String _totalCoinsKey = 'total_coins';
  static const String _gamesPlayedKey = 'games_played';

  static Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_highScoreKey) ?? 0;
  }

  static Future<bool> setHighScore(int score) async {
    final current = await getHighScore();
    if (score > current) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_highScoreKey, score);
      return true;
    }
    return false;
  }

  static Future<int> getTotalCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalCoinsKey) ?? 0;
  }

  static Future<void> addCoins(int coins) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_totalCoinsKey) ?? 0;
    await prefs.setInt(_totalCoinsKey, current + coins);
  }

  static Future<int> getGamesPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_gamesPlayedKey) ?? 0;
  }

  static Future<void> incrementGamesPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_gamesPlayedKey) ?? 0;
    await prefs.setInt(_gamesPlayedKey, current + 1);
  }

  static Future<Map<String, int>> getAllStats() async {
    return {
      'highScore': await getHighScore(),
      'totalCoins': await getTotalCoins(),
      'gamesPlayed': await getGamesPlayed(),
    };
  }
}
