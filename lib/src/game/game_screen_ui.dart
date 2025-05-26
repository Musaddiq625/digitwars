import 'dart:ui';

import 'package:digitwars_io/src/game/game_area_painter.dart';
import 'package:digitwars_io/src/dialogs/help_dialog.dart';
import 'package:digitwars_io/src/mini_map/minimap_painter.dart';
import 'package:digitwars_io/src/models/game_item.dart';
import 'package:digitwars_io/src/utils/constants.dart';
import 'package:digitwars_io/src/utils/shader_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GameScreenUI extends StatefulWidget {
  final BuildContext parentContext; // To access MediaQuery, Theme, etc.
  final String Function() getFormattedTime;
  final int playerScoreView;
  final Offset? holePosition;
  final void Function(DragUpdateDetails) onPanUpdate;
  final void Function(DragEndDetails) onPanEnd;
  final AnimationController progressAnimationController;
  final Animation<double> progressAnimation;
  final List<GameItem> items;
  final Offset cameraOffset;
  final Size gameWorldSize;
  final Offset? lastPanDelta;
  final double playerHoleRadius;
  final int playerPower;
  final int enemiesInput;
  final int selectedTheme;
  final void Function(int) onStartGamePressed;
  final double minimapSize;
  final double minimapPadding;
  final int lives;
  final bool isInvulnerable;
  final void Function() pauseTimer;
  final void Function() resumeTimer;

  const GameScreenUI({
    required this.parentContext,
    required this.getFormattedTime,
    required this.playerScoreView,
    required this.holePosition,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.progressAnimationController,
    required this.progressAnimation,
    required this.items,
    required this.cameraOffset,
    required this.gameWorldSize,
    required this.lastPanDelta,
    required this.playerHoleRadius,
    required this.playerPower,
    required this.enemiesInput,
    required this.selectedTheme,
    required this.onStartGamePressed,
    required this.minimapSize,
    required this.minimapPadding,
    required this.lives,
    required this.isInvulnerable,
    required this.pauseTimer,
    required this.resumeTimer,
    super.key,
  });

  @override
  State<GameScreenUI> createState() => _GameScreenUIState();
}

class _GameScreenUIState extends State<GameScreenUI>
    with SingleTickerProviderStateMixin {
  late AnimationController _shaderController;
  late final int _selectedTheme = widget.selectedTheme;
  FragmentShader? shader;

  Future<void> _loadShader() async {
    shader = await ShaderUtil.shader;
    setState(() {});
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _shaderController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 100),
      )..repeat();
      _loadShader();
      widget.onStartGamePressed(widget.enemiesInput);
    });
    super.initState();
  }

  @override
  void dispose() {
    _shaderController.dispose();
    super.dispose();
  }

  Widget livesWidget() {
    return Row(
      children:
          List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                widget.lives < index + 1
                    ? Icons.favorite_border
                    : Icons.favorite,
                color: Colors.red,
              ),
            ),
          ).reversed.toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use parentContext for MediaQuery and Theme to ensure they are from _GameScreenState's context
    final mediaQuery = MediaQuery.of(widget.parentContext);

    return Scaffold(
      appBar: AppBar(
        title: !kIsWeb ? null : const Text('Void Core Game'),
        centerTitle: false,
        backgroundColor: themes[_selectedTheme][0],
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              widget.pauseTimer();
              showDialog(
                context: widget.parentContext,
                builder: (context) => const HelpDialog(),
              ).then((_) => widget.resumeTimer());
            },
          ),
          // Add this new Row for hearts
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              spacing: 16,
              children: [
                if (kIsWeb) livesWidget(),
                Text(
                  'Time: ${widget.getFormattedTime()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Score: ${widget.playerScoreView}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          if (widget.holePosition != null)
            Positioned.fill(
              child: GestureDetector(
                onPanUpdate: widget.onPanUpdate,
                onPanEnd: widget.onPanEnd,
                child: AnimatedBuilder(
                  animation: widget.progressAnimationController,
                  builder: (context, child) {
                    return AnimatedBuilder(
                      animation: _shaderController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: GameAreaPainter(
                            holePosition: widget.holePosition!,
                            holeRadius: widget.playerHoleRadius,
                            playerPower: widget.playerPower,
                            powerUpProgress: widget.progressAnimation.value,
                            items: widget.items,
                            cameraOffset: widget.cameraOffset,
                            gameWorldSize: widget.gameWorldSize,
                            movementDelta: widget.lastPanDelta,
                            backgroundColor: themes[_selectedTheme],
                            shader: shader,
                            timeValue: _shaderController.value,
                            isInvulnerable: widget.isInvulnerable,
                            context: context,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          // Add CloudyCircle visualization at player position
          // if (widget.holePosition != null)
          //   Positioned(
          //     left:
          //         widget.holePosition!.dx -
          //         widget.playerHoleRadius -
          //         widget.cameraOffset.dx,
          //     top:
          //         widget.holePosition!.dy -
          //         widget.playerHoleRadius -
          //         widget.cameraOffset.dy,
          //     child: Stack(
          //       alignment: Alignment.center,
          //       children: [
          //         // CloudyCircle(
          //         //   color1: themes[_selectedTheme][0],
          //         //   color2: themes[_selectedTheme][1],
          //         //   size: Size(
          //         //     widget.playerHoleRadius * 2,
          //         //     widget.playerHoleRadius * 2,
          //         //   ),
          //         //   isCircleShape: true,
          //         // ),
          //         Text(
          //           '${widget.playerPower}',
          //           style: TextStyle(
          //             color: Colors.white,
          //             fontSize: widget.playerHoleRadius.clamp(
          //               0.0,
          //               min(
          //                     widget.gameWorldSize.width,
          //                     widget.gameWorldSize.height,
          //                   ) /
          //                   2,
          //             ),
          //             fontWeight: FontWeight.bold,
          //             shadows: [
          //               Shadow(
          //                 blurRadius: 4,
          //                 color: Colors.black,
          //                 offset: Offset(1, 1),
          //               ),
          //             ],
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          if (!kIsWeb)
            Positioned(
              top: widget.minimapPadding,
              left: 10,
              child: livesWidget(),
            ),
          // Keep existing UI elements like minimap and text
          if (widget.holePosition != null && widget.gameWorldSize != Size.zero)
            Positioned(
              top: widget.minimapPadding,
              right: widget.minimapPadding,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                child: SizedBox(
                  width: widget.minimapSize,
                  height: widget.minimapSize,
                  child: CustomPaint(
                    painter: MinimapPainter(
                      playerPosition: widget.holePosition!,
                      playerLevel: widget.playerPower,
                      items: widget.items,
                      gameWorldSize: widget.gameWorldSize,
                      cameraOffset: widget.cameraOffset,
                      screenSize: mediaQuery.size,
                    ),
                    size: Size(widget.minimapSize, widget.minimapSize),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
