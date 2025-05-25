import 'package:flutter/material.dart';

class LifeWarningDialog extends StatelessWidget {
  const LifeWarningDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Watch Out!'),
      content: const Text(
        '💔 Collisions with bigger nodes cost 1 life\n\nIf you lose all your lives, the game is over',
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
