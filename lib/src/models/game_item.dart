import 'package:flutter/material.dart';

// Represents a single consumable item in the game
class GameItem {
  final String id; // Unique identifier for the item
  Offset position; // Current position of the item on the screen
  final double size; // Radius of the item
  final int points; // Points awarded for consuming this item
  final Color color; // Color of the item
  bool isEaten; // Flag to mark if the item has been consumed
  double verticalOffset;
  double pulseScale;

  GameItem({
    required this.id,
    required this.position,
    required this.size,
    required this.points,
    required this.color,
    this.isEaten = false,
    this.verticalOffset = 0.0,
    this.pulseScale = 1.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'position': position,
      'size': size,
      'points': points,
      'color': color,
      'isEaten': isEaten,
    };
  }
}
