import 'package:digitwars_io/src/utils/constants.dart';
import 'package:flutter/material.dart';

class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('How to Play Digit Wars'),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎯 Game Objective:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Grow your Digit Wars by consuming smaller energy nodes while avoiding larger ones!',
            ),

            SizedBox(height: 16),
            Text(
              '⌛ Time Limit:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '• Each game lasts $gameDurationSeconds seconds\n'
              '• Make the most of your time to achieve the highest score!',
            ),

            SizedBox(height: 16),
            Text('🕹 Controls:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
              '• Click, hold and drag to move your Core\n'
              '• Release to stop movement\n'
              '• Camera follows your movement automatically',
            ),

            SizedBox(height: 16),
            Text(
              '💪 Power System:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '• Consume items smaller than your current power level\n'
              '• Earn points to grow bigger and access new items',
            ),

            SizedBox(height: 16),
            Text(
              '❤️ Lives System:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '• Start with $totalLives lives\n'
              '• Watch out! Collisions with bigger nodes cost 1 life\n'
              '• Game overs when lives hit zero\n'
              '• After getting hit, 1.5s invincibility mode activates!',
            ),

            SizedBox(height: 16),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Start'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
