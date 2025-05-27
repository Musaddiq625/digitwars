import 'dart:convert';

import 'package:digitwars_io/src/cookies_db/cookies_constants.dart';
import 'package:digitwars_io/src/cookies_db/cookies_controller.dart';
import 'package:digitwars_io/src/models/game_mode.dart';

class ScoreController {
  static final List<Score> _scoreHistory = [];
  static final localDB = PlatformCookies();
  static const splitter = '::';

  static Future<void> init() async {
    final scoreHistoryJson = await localDB.getValue(CookiesConstants.score);
    if (scoreHistoryJson != null) {
      final scoreHistoryList = scoreHistoryJson.split(splitter);
      for (final scoreJson in scoreHistoryList) {
        final score = Score.fromJson(jsonDecode(scoreJson));
        _scoreHistory.add(score);
      }
    }
  }

  // Add score at a specific time
  static Future<void> addScore(
    int score, {
    required DateTime time,
    required EndType endType,
    required int elapsedTime,
    required int remainingTime,
    required GameMode gameMode,
  }) async {
    _scoreHistory.insert(
      0,
      Score(
        score: score,
        time: time,
        endType: endType,
        elapsedTime: elapsedTime,
        remainingTime: remainingTime,
        gameMode: gameMode,
      ),
    );
    await localDB.setValue(
      CookiesConstants.score,
      _scoreHistory.map((e) => jsonEncode(e.toJson())).join(splitter),
    );
  }

  // Get the score history list (unmodifiable)
  static List<Score> get scoreHistory => List.unmodifiable(_scoreHistory);
  static int? getHighestScore() {
    if (_scoreHistory.isEmpty) {
      return null;
    }

    // Sort scores by score value (descending) and elapsed time (ascending)
    final sortedScores = List<Score>.from(_scoreHistory)..sort((a, b) {
      // First compare scores
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;

      // If scores are equal, compare elapsed time
      // Note: Null elapsed times are considered last
      if (a.elapsedTime == null) return 1;
      if (b.elapsedTime == null) return -1;
      return a.elapsedTime!.compareTo(b.elapsedTime!);
    });

    // Return the highest score (which will be the first score after sorting)
    return sortedScores.first.score;
  }

  static Future<void> isHitFirstTime() async {
    await localDB.setValue(CookiesConstants.hitFirstTime, 'true');
  }

  static Future<bool> get getIsHitFirstTimeBool async =>
      await localDB.getValue(CookiesConstants.hitFirstTime) == null;
}

class Score {
  final int score;
  final DateTime time;
  final EndType endType;
  final int? elapsedTime;
  final int? remainingTime;
  final GameMode gameMode;
  Score({
    required this.score,
    required this.time,
    required this.endType,
    required this.gameMode,
    this.elapsedTime,
    this.remainingTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'time': time.toIso8601String(),
      'endType': endType.toString().split('.').last,
      'gameMode': gameMode.toJson(),
      'elapsedTime': elapsedTime,
      'remainingTime': remainingTime,
    };
  }

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      score: json['score'] as int,
      time: DateTime.parse(json['time'] as String),
      endType: EndType.values.firstWhere(
        (e) => e.toString().split('.').last == json['endType'],
      ),
      gameMode: GameMode.fromJson(json['gameMode']),
      elapsedTime: json['elapsedTime'] as int?,
      remainingTime: json['remainingTime'] as int?,
    );
  }
}

enum EndType { timeEnded, victory, defeat }
