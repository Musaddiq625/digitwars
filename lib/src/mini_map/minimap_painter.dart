import 'package:digitwars_io/src/models/game_item.dart'; // Assuming GameItem has an Offset 'position'
import 'package:flutter/material.dart';

class MinimapPainter extends CustomPainter {
  final Offset playerPosition;
  final int playerLevel;
  final List<GameItem> items;
  final Size gameWorldSize;
  final double minimapSize;
  final Offset cameraOffset;
  final Size screenSize;

  MinimapPainter({
    required this.playerPosition,
    required this.playerLevel,
    required this.items,
    required this.gameWorldSize,
    required this.cameraOffset,
    required this.screenSize,
    this.minimapSize = 100.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 'size' here is the size of the CustomPaint widget itself
    if (gameWorldSize == Size.zero) return;

    // Minimap background
    final bgPaint = Paint()..color = Colors.black.withValues(alpha: 0.6);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Minimap border
    final borderPaint =
        Paint()
          ..color = Colors.white54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);

    // Calculate scale factors to map game world coordinates to minimap coordinates
    final scaleX = size.width / gameWorldSize.width;
    final scaleY = size.height / gameWorldSize.height;

    // Draw enemies (items)
    const enemyDotRadius = 2.0;
    for (final item in items) {
      if (!item.isEaten) {
        // Only draw items that haven't been eaten
        final minimapItemX = item.position.dx * scaleX;
        final minimapItemY = item.position.dy * scaleY;
        final enemyPaint =
            Paint()
              ..color = item.points >= playerLevel ? Colors.red : Colors.green;
        canvas.drawCircle(
          Offset(minimapItemX, minimapItemY),
          enemyDotRadius,
          enemyPaint,
        );
      }
    }

    // Draw player
    final playerPaint = Paint()..color = Colors.black;
    const playerDotRadius = 3.0;
    final minimapPlayerX = playerPosition.dx * scaleX;
    final minimapPlayerY = playerPosition.dy * scaleY;
    canvas.drawCircle(
      Offset(minimapPlayerX, minimapPlayerY),
      playerDotRadius,
      playerPaint,
    );

    // Add viewport rectangle drawing
    final viewportPaint =
        Paint()
          ..color = Colors.white54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    final viewportFillPaint =
        Paint()
          ..color = Colors.white12
          ..style = PaintingStyle.fill;

    // Calculate viewport rectangle in minimap coordinates
    final viewportRect = Rect.fromLTWH(
      cameraOffset.dx * scaleX,
      cameraOffset.dy * scaleY,
      screenSize.width * scaleX,
      screenSize.height * scaleY,
    );

    canvas
      ..drawRect(viewportRect, viewportFillPaint)
      ..drawRect(viewportRect, viewportPaint);
  }

  @override
  bool shouldRepaint(covariant MinimapPainter oldDelegate) {
    return oldDelegate.playerPosition != playerPosition ||
        oldDelegate.items != items ||
        oldDelegate.gameWorldSize != gameWorldSize ||
        oldDelegate.cameraOffset != cameraOffset ||
        oldDelegate.screenSize != screenSize;
  }
}
