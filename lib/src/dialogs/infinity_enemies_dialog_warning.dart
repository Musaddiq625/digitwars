import 'package:flutter/material.dart';

class InfinityEnemiesDialogWarning extends StatelessWidget {
  const InfinityEnemiesDialogWarning({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Extreme Mode Warning!'),
      content: const SizedBox(
        width: 350,
        child: Text(
          '🎯 Higher level enemies will spawn as you conquer each level\n'
          '⚠️ Time is still limited!',
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Challenge Accepted'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
