// Duration of the game in seconds
import 'package:digitwars_io/src/models/game_mode.dart';
import 'package:flutter/material.dart';

const int gameDurationSeconds = 120;

// Initial size of the player's hole (diameter)
const double initialHoleSize = 40;

// Smallest item point value
const int smallestItemPoints = 1;

// total lives
const int totalLives = 3;

// invulnerability time in milliseconds
const int invulnerabilityTimeInMs = 1500;

// Item related constants
 final List<GameMode> initialItemsList = [
  GameMode(name: 'Easy', enemiesCount: 30),
  GameMode(name: 'Medium', enemiesCount: 50),
  GameMode(name: 'Hard', enemiesCount: 70),
  GameMode(name: 'Infinite', enemiesCount: 50),
];
List<List<Color>> themes = [
  // Cosmic nebula
  [const Color(0xFF8A2BE2), const Color(0xFFE6C3FF)],
  // Deep ocean
  [const Color(0xFF00688B), const Color(0xFFB2E6FF)],
  // Sunset paradise
  [const Color.fromARGB(255, 101, 87, 87), const Color(0xFFFFE4E4)],
  // Northern lights
  [const Color(0xFF3CB371), const Color(0xFFCFFEE3)],
  // Desert dusk
  [const Color(0xFFE67E22), const Color(0xFFFFE5CC)],
];

// Minimum radius of an item - Increased from 5.0
const double minItemSize = 8;

// Maximum radius of an item - Increased from 15.0
const double maxItemSize = 25;
// You can adjust this
const double minimapSize = 120;
