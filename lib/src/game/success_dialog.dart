import 'package:flutter/material.dart';

class SuccessDialog extends StatefulWidget {
  final VoidCallback onPressed;

  const SuccessDialog({required this.onPressed, super.key});

  @override
  State<SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AlertDialog(
          title: const Text(
            'VICTORY!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'You devoured all enemies!',
            style: TextStyle(fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: widget.onPressed,
              child: const Text('Play Again'),
            ),
          ],
        ),
      ],
    );
  }
}
