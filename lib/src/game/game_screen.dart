// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:digitwars_io/src/dialogs/game_over_dialog.dart';
import 'package:digitwars_io/src/dialogs/help_dialog.dart';
import 'package:digitwars_io/src/dialogs/infinity_enemies_dialog_warning.dart';
import 'package:digitwars_io/src/dialogs/life_warning_dialog.dart';
import 'package:digitwars_io/src/dialogs/success_dialog.dart';
import 'package:digitwars_io/src/game/game_screen_ui.dart';
import 'package:digitwars_io/src/game/score_controller.dart';
import 'package:digitwars_io/src/models/game_item.dart';
import 'package:digitwars_io/src/models/game_mode.dart';
import 'package:digitwars_io/src/utils/constants.dart';
import 'package:flutter/material.dart';

// GameScreen widget where the main game play happens
class GameScreen extends StatefulWidget {
  final int selectedTheme;
  final bool isInfiniteGame;
  final GameMode gameMode;

  const GameScreen({
    required this.selectedTheme,
    required this.isInfiniteGame,
    required this.gameMode,
    super.key,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  int _lives = totalLives;
  Timer? _timer;
  int _remainingTime = gameDurationSeconds;
  DateTime _timerPauseTime = DateTime.now(); // Add this line

  // Add these new methods for timer control
  void pauseTimer() {
    if (_timer!.isActive) {
      _timer!.cancel();
      _timerPauseTime = DateTime.now();
    }
  }

  void resumeTimer() {
    if (!_timer!.isActive) {
      final pausedDuration = DateTime.now().difference(_timerPauseTime);
      _remainingTime -= pausedDuration.inSeconds;
      startGameTimer();
    }
  }

  DateTime _lastHitTime = DateTime(1970);
  bool isInvulnerable = false;

  double currentSpeed = 0; // Declared here
  // Adjust this value to change mouse speed (e.g., 1.5, 2.0, 2.5)
  static const double mouseSpeedFactor = 1.5;
  static const double minimapPadding = 16; // Padding from screen edges

  // Player's score
  int _playerScore = 0;
  int _playerScoreView = 0;

  // Player's power level
  int _playerPower =
      smallestItemPoints + 1; // Start with power to eat smallest items

  // Player's hole size (diameter)
  double _playerHoleSize = initialHoleSize;
  double get _playerHoleRadius => _playerHoleSize / 2; // Getter for radius

  // Animation for hole size
  late AnimationController _holeSizeController;
  late Animation<double> _holeSizeAnimation;

  // Player's hole position (world coordinates)
  Offset? _holePosition; // Declared here (Nullable)
  Offset? _lastPanDelta; // To store the direction of movement

  // List of game items (world coordinates)
  final List<GameItem> _items = [];
  final Random _random = Random(); // For generating random positions/sizes

  // Camera and Game World
  Offset _cameraOffset =
      Offset.zero; // Top-left of the camera in world coordinates
  Size _gameWorldSize = Size.zero; // Total size of the game world

  // Define the proportion of the screen that acts as a dead zone margin
  // e.g., 0.2 means a 20% margin from each screen edge, resulting in a 50% wide/high dead zone in the center.
  static const double _cameraDeadZoneFactor = 0.2;
  // Max additional points an item can have over smallestItemPoints (e.g., 0, 1, 2)
  static const int _maxItemPowerOffset = 4; // Changed from 2 to 4
  // Add animation controller for progress indicator
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;
  late final int _enemiesInput = widget.gameMode.enemiesCount;
  bool? isFirstTimeHit;

  @override
  void initState() {
    super.initState();
    // Initialize progress animation controller and animation
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      isFirstTimeHit = await ScoreController.getIsHitFirstTimeBool;
    });
  }

  Future<void> _startGame() async {
    setState(() {
      _lastHitTime = DateTime(1970);
      isInvulnerable = false;
      _remainingTime = gameDurationSeconds;
      _playerScore = 0;
      _playerScoreView = 0;
      _playerPower = smallestItemPoints + 1;
      _playerHoleSize = initialHoleSize;
      _items.clear();
      _holeSizeController = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      );
      _holeSizeAnimation = Tween<double>(
        begin: _playerHoleSize,
        end: _playerHoleSize,
      ).animate(
        CurvedAnimation(parent: _holeSizeController, curve: Curves.easeInOut),
      )..addListener(() {
        if (mounted) {
          setState(() {
            _playerHoleSize = _holeSizeAnimation.value;
          });
        }
      });

      // Reset progress animation
      _progressAnimationController
          .reset(); // Reset the controller to its initial state (value 0.0)
      _progressAnimation = Tween<double>(begin: 0, end: 0).animate(
        // Re-initialize animation to 0 progress
        CurvedAnimation(
          parent: _progressAnimationController,
          curve: Curves.easeInOut,
        ),
      );

      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      _gameWorldSize = Size(screenWidth * 2, screenHeight * 2);
      _holePosition = Offset(
        _gameWorldSize.width / 2,
        _gameWorldSize.height / 2,
      );

      // Initialize camera position to center
      _cameraOffset = Offset(
        _holePosition!.dx - (screenWidth / 2),
        _holePosition!.dy - (screenHeight / 2),
      );

      _spawnItems(_enemiesInput);
    });
    await Future.delayed(const Duration(milliseconds: 500));

    if (widget.isInfiniteGame) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const InfinityEnemiesDialogWarning(),
      );
    }
    await showDialog(
      context: context,
      builder: (context) => const HelpDialog(),
    ).then((_) => startGameTimer());
  }

  // Function to update camera position to follow the hole with a dead zone
  void _updateCameraPosition() {
    if (_holePosition == null ||
        !mounted ||
        _gameWorldSize == Size.zero ||
        !context.mounted) {
      return;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate dead zone boundaries in screen coordinates
    final deadZoneMarginX = screenWidth * _cameraDeadZoneFactor;
    final deadZoneMarginY = screenHeight * _cameraDeadZoneFactor;

    final deadZoneLeft = deadZoneMarginX;
    final deadZoneRight = screenWidth - deadZoneMarginX;
    final deadZoneTop = deadZoneMarginY;
    final deadZoneBottom = screenHeight - deadZoneMarginY;

    // Player's current position on the screen (relative to camera's top-left)
    final playerScreenX = _holePosition!.dx - _cameraOffset.dx;
    final playerScreenY = _holePosition!.dy - _cameraOffset.dy;

    var newCameraDx = _cameraOffset.dx;
    var newCameraDy = _cameraOffset.dy;

    // Adjust camera if player moves out of the dead zone
    if (playerScreenX < deadZoneLeft) {
      newCameraDx = _holePosition!.dx - deadZoneLeft;
    } else if (playerScreenX > deadZoneRight) {
      newCameraDx = _holePosition!.dx - deadZoneRight;
    }

    if (playerScreenY < deadZoneTop) {
      newCameraDy = _holePosition!.dy - deadZoneTop;
    } else if (playerScreenY > deadZoneBottom) {
      newCameraDy = _holePosition!.dy - deadZoneBottom;
    }

    // Clamp camera position to game world boundaries
    // maxCameraX is the maximum X offset the camera can have.
    // If gameWorldSize.width is 2*screenWidth, then maxCameraX is screenWidth.
    final maxCameraX = _gameWorldSize.width - screenWidth;
    final maxCameraY = _gameWorldSize.height - screenHeight;

    // Ensure clamping values are not negative (if game world is smaller than screen)
    final clampedCameraX = newCameraDx.clamp(
      0.0,
      maxCameraX > 0 ? maxCameraX : 0.0,
    );
    final clampedCameraY = newCameraDy.clamp(
      0.0,
      maxCameraY > 0 ? maxCameraY : 0.0,
    );

    if (_cameraOffset.dx != clampedCameraX ||
        _cameraOffset.dy != clampedCameraY) {
      if (mounted) {
        // Check mounted again before calling setState
        setState(() {
          _cameraOffset = Offset(clampedCameraX, clampedCameraY);
        });
      }
    }
  }

  // Function to spawn a given number of items randomly on the screen
  void _spawnItems(int count) {
    if (!mounted || _holePosition == null || _gameWorldSize == Size.zero) {
      return; // Ensure context and screen size are available
    }

    final worldWidth = _gameWorldSize.width;
    final worldHeight = _gameWorldSize.height;
    final newItems = <GameItem>[];

    // Calculate the number of power levels
    const numPowerLevels = _maxItemPowerOffset + 1;

    // Calculate progression tier based on player level
    final currentTier = ((_playerPower - 1) / 2).floor();
    final progressionFactor = currentTier * 0.15; // 15% increase per tier

    // Calculate dynamic weights with progression scaling
    var totalWeight = 0;
    final levelWeights = List.generate(numPowerLevels, (powerOffset) {
      final baseWeight =
          (numPowerLevels - powerOffset) *
          (1 + powerOffset * progressionFactor);
      return baseWeight.toInt();
    });

    totalWeight = levelWeights.reduce((a, b) => a + b);

    var itemIndex = 0;
    for (var powerOffset = 0; powerOffset < numPowerLevels; powerOffset++) {
      // Calculate items for this level using progressive weights
      var itemsThisPower =
          ((count * levelWeights[powerOffset]) / totalWeight).round();

      // Ensure minimum of 2 items for previous tiers
      if (powerOffset <= currentTier + 1) {
        itemsThisPower = itemsThisPower.clamp(2, count);
      }

      //  itemsThisPower = itemsPerPower + (powerOffset < remainder ? 1 : 0);
      final itemPointsValue = smallestItemPoints + powerOffset;

      // Determine item size based on its points
      final sizeFactor =
          numPowerLevels == 1
              ? 0.0
              : powerOffset.toDouble() / _maxItemPowerOffset.toDouble();
      var calculatedItemSize =
          minItemSize +
          (maxItemSize - minItemSize) * sizeFactor * itemPointsValue;
      calculatedItemSize = calculatedItemSize.clamp(minItemSize, maxItemSize);
      // Safety check
      if (calculatedItemSize <= 0) calculatedItemSize = minItemSize;

      for (var j = 0; j < itemsThisPower; j++) {
        // Define edge buffer as 10% of world size
        final edgeBufferX = worldWidth * 0.05;
        final edgeBufferY = worldHeight * 0.05;

        // Generate position within central 80% of the game world
        var validPosition = false;
        var attempts = 0;
        const maxAttempts = 20;
        double x;
        double y;

        do {
          // Generate new position
          x =
              edgeBufferX +
              calculatedItemSize +
              _random.nextDouble() *
                  (worldWidth - 2 * edgeBufferX - calculatedItemSize * 2);
          y =
              edgeBufferY +
              calculatedItemSize +
              _random.nextDouble() *
                  (worldHeight - 2 * edgeBufferY - calculatedItemSize * 2);

          // Check distance from other items
          validPosition = true;
          final newItemRadius = calculatedItemSize;
          const minSpacing = 10.0; // 10px minimum space between items

          // Check against existing items
          for (final existingItem in [..._items, ...newItems]) {
            final distance = (existingItem.position - Offset(x, y)).distance;
            if (distance < (existingItem.size + newItemRadius + minSpacing)) {
              validPosition = false;
              break;
            }
          }

          // Check distance from player start position
          if (_holePosition != null) {
            final distanceToHole = (Offset(x, y) - _holePosition!).distance;
            if (distanceToHole < _playerHoleRadius + newItemRadius + 20) {
              validPosition = false;
            }
          }

          attempts++;
        } while (!validPosition && attempts < maxAttempts);

        // Add item even if position isn't perfect after max attempts
        newItems.add(
          GameItem(
            id: 'item_${DateTime.now().millisecondsSinceEpoch}_${itemIndex++}',
            position: Offset(x, y),
            size: calculatedItemSize,
            points: itemPointsValue,
            color: Colors.primaries[_random.nextInt(Colors.primaries.length)]
                .withValues(alpha: .8),
            verticalOffset: _random.nextDouble() * 2 * pi, // Random start phase
            pulseScale: 0.8 + _random.nextDouble() * 0.4, // Random pulse scale
          ),
        );
      }
    }
    setState(() {
      _items.addAll(newItems);
    });
  }

  void _spawnHigherLevelEnemies() {
    const enemiesPerLevel = 5;
    final newItems = <GameItem>[];

    final worldWidth = _gameWorldSize.width;
    final worldHeight = _gameWorldSize.height;

    // Base new enemies on player's current level +1, with minimum level 3
    var baseLevel = _playerPower + 1;
    if (baseLevel < 3) baseLevel = 3; // Ensure minimum level 3

    for (var i = 0; i < enemiesPerLevel; i++) {
      final itemPoints = baseLevel + i; // Generate sequential levels
      final powerOffset = itemPoints - smallestItemPoints;
      final sizeFactor = powerOffset / _maxItemPowerOffset;
      var calculatedItemSize =
          minItemSize + (maxItemSize - minItemSize) * sizeFactor;
      calculatedItemSize = calculatedItemSize.clamp(minItemSize, maxItemSize);

      var validPosition = false;
      var attempts = 0;
      const maxAttempts = 20;
      double x;
      double y;

      do {
        final edgeBufferX = worldWidth * 0.05;
        final edgeBufferY = worldHeight * 0.05;

        x =
            edgeBufferX +
            calculatedItemSize +
            _random.nextDouble() *
                (worldWidth - 2 * edgeBufferX - calculatedItemSize * 2);
        y =
            edgeBufferY +
            calculatedItemSize +
            _random.nextDouble() *
                (worldHeight - 2 * edgeBufferY - calculatedItemSize * 2);

        validPosition = true;
        final newItemRadius = calculatedItemSize;

        // Check collisions with existing items
        // Create COMPLETE snapshot before checking
        final checkItems = [...List<GameItem>.from(_items), ...newItems];

        for (final existingItem in checkItems) {
          final distance = (existingItem.position - Offset(x, y)).distance;
          if (distance < (existingItem.size + newItemRadius + 10)) {
            validPosition = false;
            break;
          }
        }

        // Check distance from player
        if (_holePosition != null) {
          final distanceToHole = (Offset(x, y) - _holePosition!).distance;
          if (distanceToHole < _playerHoleRadius + newItemRadius + 20) {
            validPosition = false;
          }
        }

        attempts++;
      } while (!validPosition && attempts < maxAttempts);

      newItems.add(
        GameItem(
          id: 'enemy_${DateTime.now().millisecondsSinceEpoch}_$i',
          position: Offset(x, y),
          size: calculatedItemSize,
          points: itemPoints,
          color: Colors.primaries[_random.nextInt(Colors.primaries.length)]
              .withOpacity(0.8),
          verticalOffset: _random.nextDouble() * 2 * pi,
          pulseScale: 0.8 + _random.nextDouble() * 0.4,
        ),
      );
    }

    setState(() => _items.addAll(newItems));
  }

  // Show life warning dialog
  Future<void> _showLifeWarningDialog() async {
    isFirstTimeHit = true;
    setState(() {});
    pauseTimer();
    await showDialog(
      context: context,
      builder: (context) => const LifeWarningDialog(),
    ).then((_) => startGameTimer());
    resumeTimer();
  }

  // Function to check for collisions and consume items
  Future<void> _checkCollisionsAndConsumeItems({
    bool isInfinite = false,
  }) async {
    if (_holePosition == null) return;

    final itemsToRemove = <GameItem>[];
    final now = DateTime.now();

    // Create a snapshot of items to prevent concurrent modification
    final itemsSnapshot = List<GameItem>.from(_items);

    for (final item in itemsSnapshot) {
      if (item.isEaten) continue;
      final distance = (item.position - _holePosition!).distance;
      if (distance < _playerHoleRadius) {
        // Changed from size-based to power-based comparison
        if (item.points >= _playerPower) {
          // Compare points instead of size
          // Handle dangerous collision
          if (now.difference(_lastHitTime).inSeconds >= 2) {
            _lives--;
            _lastHitTime = DateTime.now();
            itemsToRemove.add(item);
            isInvulnerable = true;
            setState(() {});
            if (isFirstTimeHit == null) {
              await _showLifeWarningDialog();
              await ScoreController.isHitFirstTime();
            }

            // This timer is not stored in a variable and will be automatically
            // garbage collected once completed, so no explicit cancellation needed
            Timer(const Duration(milliseconds: invulnerabilityTimeInMs), () {
              if (mounted && isInvulnerable) {
                setState(() => isInvulnerable = false);
              }
            });
            if (_lives <= 0) {
              endGame();
            }
          }
          return;
        }
        // ——————————————— Eat the item ———————————————
        item.isEaten = true;
        itemsToRemove.add(item);
        _playerScore += item.points;
        _playerScoreView += item.points;
        setState(() {});

        // ————————————— New threshold: score, not count —————————————
        final requiredScoreToGrow = getRequiredScoreToGrow(
          _playerPower,
          item.points,
        );

        if (_playerScore >= requiredScoreToGrow) {
          // Subtract the threshold so any overflow carries over
          _playerScore -= requiredScoreToGrow;
          _playerPower++;

          final targetSize = getHoleSizeForLevel(_playerPower);
          _holeSizeAnimation = Tween<double>(
            begin: _playerHoleSize,
            end: targetSize,
          ).animate(
            CurvedAnimation(
              parent: _holeSizeController,
              curve: Curves.easeOutBack,
            ),
          )..addListener(() {
            if (mounted) {
              if (_playerHoleSize != _holeSizeAnimation.value) {
                setState(() {
                  _playerHoleSize = _holeSizeAnimation.value;
                });
              }
            }
          });
          await _holeSizeController.forward(from: 0);
          // Add new enemies when leveling up
          if (isInfinite) _spawnHigherLevelEnemies();
          dev.log(
            'Leveled UP! New Power: $_playerPower, '
            'Remaining Score: $_playerScore, '
            'Next Threshold: ${getRequiredScoreToGrow(_playerPower, item.points)}',
          );
        }
      }
    }

    if (itemsToRemove.isNotEmpty) {
      setState(() {
        _items.removeWhere(itemsToRemove.contains);
        final newProgress = (_playerScore /
                getRequiredScoreToGrow(_playerPower, 1))
            .clamp(0.0, 1.0);
        _progressAnimation = Tween<double>(
          begin: _progressAnimation.value,
          end: newProgress,
        ).animate(
          CurvedAnimation(
            parent: _progressAnimationController,
            curve: Curves.easeInOut,
          ),
        );
        _progressAnimationController.forward(from: 0);
      });
    }
  }

  int getRequiredScoreToGrow(int playerPower, int itemLevel) {
    return 5 * (playerPower - 1);
  }

  int get remainingEnemies => _items.where((item) => !item.isEaten).length;

  // Function to start the game timer
  void startGameTimer() {
    // Remove the timer start from _startGame and only start after dialog
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        // If time is remaining, decrement it
        setState(() {
          _remainingTime--;
        });
        final allEnemiesEaten = remainingEnemies == 0;
        if (allEnemiesEaten) {
          _timer!.cancel();
          endGameWithVictory();
        }
      } else {
        // If time is up, stop the timer and end the game
        _timer!.cancel();
        try {
          endGame();
        } catch (e) {
          dev.log(e.toString());
        }
      }
    });
  }

  void endGameWithVictory() {
    // Save score as a victory
    ScoreController.addScore(
      _playerScoreView,
      time: DateTime.now(),
      endType: EndType.victory,
      elapsedTime: gameDurationSeconds - _remainingTime,
      remainingTime: _remainingTime,
      gameMode: widget.gameMode,
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SuccessDialog(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            // _startGame();
          },
        );
      },
    );
  }

  void endGame() {
    pauseTimer();
    // Save score as a loss or time ended
    final endType = _remainingTime <= 0 ? EndType.timeEnded : EndType.defeat;
    ScoreController.addScore(
      _playerScoreView,
      time: DateTime.now(),
      endType: endType,
      elapsedTime: gameDurationSeconds - _remainingTime,
      remainingTime: _remainingTime,
      gameMode: widget.gameMode,
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return GameOverDialog(
          playerScoreView: _playerScoreView,
          remainingEnemies: remainingEnemies,
        );
      },
    );
  }

  // Function to reset game state for a new game
  void resetGame() {
    setState(() {
      _remainingTime = gameDurationSeconds;
      _playerScore = 0;
      _playerPower = smallestItemPoints + 1; // Reset player power
      _playerHoleSize = initialHoleSize; // Reset to initial size
      _items.clear(); // Clear existing items

      // Reset animation controller and update animation to current size
      _holeSizeController.reset();
      _holeSizeAnimation = Tween<double>(
        begin: _playerHoleSize,
        end: _playerHoleSize,
      ).animate(
        CurvedAnimation(parent: _holeSizeController, curve: Curves.easeInOut),
      )..addListener(() {
        if (mounted) {
          setState(() {
            _playerHoleSize = _holeSizeAnimation.value;
          });
        }
      });

      if (context.mounted) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        // Re-initialize game world size
        _gameWorldSize = Size(screenWidth * 2, screenHeight * 2);
        _holePosition = Offset(
          _gameWorldSize.width / 2,
          _gameWorldSize.height / 2,
        );
        _spawnItems(_enemiesInput); // Spawn new items
        _updateCameraPosition(); // Reset camera position
      }
    });
    startGameTimer(); // Restart the timer
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    // Cancel the timer when the widget is disposed to prevent memory leaks
    _timer!.cancel();
    super.dispose();
  }

  // Function to format remaining time into MM:SS string
  String getFormattedTime() {
    final minutes = _remainingTime ~/ 60; // Integer division for minutes
    final seconds = _remainingTime % 60; // Modulo for seconds
    final minutesStr = minutes.toString().padLeft(
      2,
      '0',
    ); // Pad with leading zero if needed
    final secondsStr = seconds.toString().padLeft(
      2,
      '0',
    ); // Pad with leading zero if needed
    return '$minutesStr:$secondsStr';
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_timer == null ||
        _holePosition == null ||
        _gameWorldSize == Size.zero) {
      return;
    }
    // Apply the speed factor to the delta
    final scaledDelta = details.delta.scale(mouseSpeedFactor, mouseSpeedFactor);
    _lastPanDelta = scaledDelta; // Store the scaled movement delta

    // Update hole position based on drag delta (in world coordinates)
    setState(() {
      final newHoleDx = _holePosition!.dx + scaledDelta.dx;
      final newHoleDy = _holePosition!.dy + scaledDelta.dy;

      // Clamp hole position to game world boundaries
      _holePosition = Offset(
        newHoleDx.clamp(
          _playerHoleRadius,
          _gameWorldSize.width - _playerHoleRadius,
        ),
        newHoleDy.clamp(
          _playerHoleRadius,
          _gameWorldSize.height - _playerHoleRadius,
        ),
      );

      _updateCameraPosition(); // Update camera based on new hole position
      _checkCollisionsAndConsumeItems(
        isInfinite: widget.isInfiniteGame,
      ); // Check for collisions after moving
    });
  }

  // Add this new method to handle pan end
  void _handlePanEnd(DragEndDetails details) {
    setState(() {
      _lastPanDelta = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GameScreenUI(
      parentContext: context,
      getFormattedTime: getFormattedTime,
      playerScoreView: _playerScoreView,
      holePosition: _holePosition,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd, // Add this line
      progressAnimationController: _progressAnimationController,
      progressAnimation: _progressAnimation,
      items: _items,
      cameraOffset: _cameraOffset,
      gameWorldSize: _gameWorldSize,
      lastPanDelta: _lastPanDelta,
      playerHoleRadius: _playerHoleRadius,
      playerPower: _playerPower,
      enemiesInput: _enemiesInput,
      selectedTheme: widget.selectedTheme,
      onStartGamePressed: (enemiesCount) {
        _startGame();
      },
      minimapSize: minimapSize,
      minimapPadding: minimapPadding,
      lives: _lives,
      isInvulnerable: isInvulnerable,
      pauseTimer: pauseTimer,
      resumeTimer: resumeTimer,
    );
  }
}

// Add this function to _GameScreenState
double getHoleSizeForLevel(int level) {
  // You can tweak these constants as needed
  const baseSize = 32.0; // Minimum hole size (diameter)
  const sizeIncrement = 10.0; // How much size increases per level
  return baseSize + (level - 1) * sizeIncrement;
}
