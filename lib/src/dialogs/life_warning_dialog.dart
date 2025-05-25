import 'package:flutter/material.dart';

class LifeWarningDialog extends StatelessWidget {
  const LifeWarningDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Watch Out!'),
      content: const Text(
        '💔 Collisions with bigger nodes cost 1 life\n'
        'If you lose all your lives, the game is over\n\n'
        'After each collision, you have 1.5 seconds of invulnerability\n',
        
      ),
      actions: [
        TextButton(
          child: const Text('Got it'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
