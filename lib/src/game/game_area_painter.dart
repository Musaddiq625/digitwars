// CustomPainter to draw the game area, including the player's hole
// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'dart:ui';

import 'package:digitwars_io/src/models/game_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GameAreaPainter extends CustomPainter {
  // Add these new properties
  final FragmentShader? shader;
  final double timeValue;
  final Offset holePosition;
  final double holeRadius;
  final int playerPower;
  final double powerUpProgress;
  final List<GameItem> items;
  final Offset cameraOffset;
  final Size gameWorldSize;
  final Offset? movementDelta;
  final List<Color> backgroundColor;
  final bool isInvulnerable;
  final BuildContext context;

  GameAreaPainter({
    required this.holePosition,
    required this.holeRadius,
    required this.playerPower,
    required this.powerUpProgress,
    required this.items,
    required this.cameraOffset,
    required this.gameWorldSize,
    required this.backgroundColor,
    required this.shader,
    required this.timeValue,
    required this.context,
    this.movementDelta,
    this.isInvulnerable = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final scaledWidth = size.width * devicePixelRatio / (kIsWeb ? 2 : 1);
    final scaledHeight = size.height * devicePixelRatio / 2;

    if (shader != null) {
      // Set shader parameters
      shader!
        ..setFloat(0, timeValue * 200)
        ..setFloat(1, scaledWidth)
        ..setFloat(2, scaledHeight)
        ..setFloat(3, backgroundColor[0].red / 255.0)
        ..setFloat(4, backgroundColor[0].green / 255.0)
        ..setFloat(5, backgroundColor[0].blue / 255.0)
        ..setFloat(6, backgroundColor[1].red / 255.0)
        ..setFloat(7, backgroundColor[1].green / 255.0)
        ..setFloat(8, backgroundColor[1].blue / 255.0);

      final paint = Paint()..shader = shader;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    } else {
      // Fallback to solid background color
      final bgPaint = Paint()..color = backgroundColor[0];
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
    }
    // Clamp hole radius to never exceed half the game world size
    final safeRadius = holeRadius.clamp(
      0.0,
      min(gameWorldSize.width, gameWorldSize.height) / 2,
    );

    // Clamp hole position so the entire hole always stays within the game world
    final safeHolePosition = Offset(
      holePosition.dx.clamp(safeRadius, gameWorldSize.width - safeRadius),
      holePosition.dy.clamp(safeRadius, gameWorldSize.height - safeRadius),
    );

    // canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Draw items, but only if they're within the visible canvas
    for (final item in items) {
      final itemScreenPos = item.position - cameraOffset;
      if (itemScreenPos.dx + item.size < 0 ||
          itemScreenPos.dy + item.size < 0 ||
          itemScreenPos.dx - item.size > size.width ||
          itemScreenPos.dy - item.size > size.height) {
        continue; // Skip drawing items outside the canvas
      }
      final borderPaint =
          Paint()
            ..color = Colors.black
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0;
      canvas.drawCircle(itemScreenPos, item.size, borderPaint);

      final itemPaint = Paint()..color = item.color;
      canvas.drawCircle(itemScreenPos, item.size, itemPaint);

      // Draw enemy hole score (if you treat items as enemy holes)
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${item.points}',
          style: TextStyle(
            color: Colors.white,
            fontSize: item.size * 0.9,
            fontWeight: FontWeight.bold,
            shadows: const [Shadow(blurRadius: 4, offset: Offset(1, 1))],
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter
        ..layout()
        ..paint(
          canvas,
          itemScreenPos - Offset(textPainter.width / 2, textPainter.height / 2),
        );
    }

    // Draw the player's hole, but only if it's within the visible canvas
    final holeScreenPos = safeHolePosition - cameraOffset;
    if (holeScreenPos.dx + safeRadius >= 0 &&
        holeScreenPos.dy + safeRadius >= 0 &&
        holeScreenPos.dx - safeRadius <= size.width &&
        holeScreenPos.dy - safeRadius <= size.height) {
      final holePaint =
          Paint()
            ..color = Colors.black.withValues(alpha: isInvulnerable ? 0.3 : 1);
      canvas.drawCircle(holeScreenPos, safeRadius, holePaint);

      // --- ARROW FOR USER'S HOLE ---
      if (movementDelta != null && movementDelta!.distance > 0.1) {
        // Normalize the movement direction
        final direction = movementDelta!.direction;
        final arrowLength =
            safeRadius * 1.2; // Not too long, just outside the hole
        final arrowStart =
            holeScreenPos +
            Offset(cos(direction), sin(direction)) * (safeRadius + 4);
        final arrowEnd =
            arrowStart + Offset(cos(direction), sin(direction)) * arrowLength;

        final arrowPaint =
            Paint()
              ..color = Colors.orangeAccent
              ..strokeWidth = 5
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round;

        // Draw main arrow line
        canvas.drawLine(arrowStart, arrowEnd, arrowPaint);

        // Draw arrow head
        const arrowHeadSize = 12.0;
        const arrowAngle = pi / 7;
        final leftHead =
            arrowEnd +
            Offset(
                  cos(direction - pi + arrowAngle),
                  sin(direction - pi + arrowAngle),
                ) *
                arrowHeadSize;
        final rightHead =
            arrowEnd +
            Offset(
                  cos(direction - pi - arrowAngle),
                  sin(direction - pi - arrowAngle),
                ) *
                arrowHeadSize;
        canvas
          ..drawLine(arrowEnd, leftHead, arrowPaint)
          ..drawLine(arrowEnd, rightHead, arrowPaint);
      }
      // --- END ARROW ---

      // Draw circular progress indicator around the player's hole
      final progressPaint =
          Paint()
            ..color = Colors.blueAccent
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5.0;

      final progressRect = Rect.fromCircle(
        center: holeScreenPos,
        radius: safeRadius + 8,
      );
      canvas.drawArc(
        progressRect,
        -pi / 2,
        2 * pi * powerUpProgress,
        false,
        progressPaint,
      );
    }
    // Draw player's score on the hole
    final scorePainter = TextPainter(
      text: TextSpan(
        text: '$playerPower',
        style: TextStyle(
          color: Colors.white,
          fontSize: safeRadius * 0.9,
          fontWeight: FontWeight.bold,
          shadows: const [Shadow(blurRadius: 4, offset: Offset(1, 1))],
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    scorePainter
      ..layout()
      ..paint(
        canvas,
        holeScreenPos - Offset(scorePainter.width / 2, scorePainter.height / 2),
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Helper function for comparing lists (or use foundation.dart's listEquals)
// This is the existing helper from your file.
bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
