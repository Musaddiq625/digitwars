import 'package:flutter/material.dart';

class GameOverDialog extends StatelessWidget {
  final int playerScoreView;
  final int remainingEnemies;
  const GameOverDialog({required this.playerScoreView, required this.remainingEnemies, super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
          title: const Text('Game Over!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your final score: $playerScoreView'),
              Text('Remaining enemies: $remainingEnemies'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Play Again'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
  }
}