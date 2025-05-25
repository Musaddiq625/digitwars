import 'dart:convert';

import 'package:digitwars_io/src/cookies_db/cookies_controller.dart';
import 'package:digitwars_io/src/models/game_mode.dart';

class ScoreController {
  static final List<Score> _scoreHistory = [];

  static void init() {
    final scoreHistoryJson = CookiesController.getCookie('score_');
    if (scoreHistoryJson != null) {
      final scoreHistoryList = scoreHistoryJson.split('::');
      for (final scoreJson in scoreHistoryList) {
        print('scoreJson $scoreJson');
        final score = Score.fromJson(jsonDecode(scoreJson));
        _scoreHistory.add(score);
      }
    }
  }

  // Add score at a specific time
  static void addScore(
    int score, {
    required DateTime time,
    required EndType endType,
    required int elapsedTime,
    required int remainingTime,
    required GameMode gameMode,
  }) {
    _scoreHistory.add(
      Score(
        score: score,
        time: time,
        endType: endType,
        elapsedTime: elapsedTime,
        remainingTime: remainingTime,
        gameMode: gameMode,
      ),
    );
    CookiesController.setCookie(
      'score_',
      _scoreHistory.map((e) => jsonEncode(e.toJson())).join('::'),
    );
  }

  // Get the score history list (unmodifiable)
  static List<Score> get scoreHistory => List.unmodifiable(_scoreHistory);

  static int? getHighestScore() {
    if (_scoreHistory.isEmpty) {
      return null;
    }
    return _scoreHistory
        .map((e) => e.score)
        .reduce((value, element) => value > element ? value : element);
  }
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

enum EndType { timeEnded, win, lose }
