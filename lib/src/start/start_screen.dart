import 'package:digitwars_io/src/cloudy_shader.dart';
import 'package:digitwars_io/src/game/game_screen.dart';
import 'package:digitwars_io/src/utils/constants.dart';
import 'package:flutter/material.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  int _selectedTheme = 0;
  int _enemiesInput = initialItemsList.first;

  void _handleThemeSelection(int themeIndex) {
    setState(() {
      _selectedTheme = themeIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Positioned.fill(
                child: CloudyCircle(
                  color1: themes[_selectedTheme][0],
                  color2: themes[_selectedTheme][1],
                  size: const Size(400, 400),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Void Core',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 32),
                    const Text('Select the number of enemies:'),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        ...initialItemsList.map(
                          (e) => Expanded(
                            child: ChoiceChip(
                              label: Text('$e'),
                              labelStyle: const TextStyle(color: Colors.white),
                              iconTheme: const IconThemeData(
                                color: Colors.white,
                              ),
                              checkmarkColor: Colors.white,
                              selected: _enemiesInput == e,
                              selectedColor: themes[_selectedTheme][0],
                              onSelected:
                                  (_) => setState(() => _enemiesInput = e),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed:
                          () => Navigator.push(
                            context,
                            IrisTransition(
                              duration: const Duration(milliseconds: 700),
                              child: GameScreen(
                                selectedTheme: _selectedTheme,
                                enemiesInput: _enemiesInput,
                              ),
                            ),
                          ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: const Text(
                        'Play',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Select your Theme:',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < themes.length; i++) ...[
                          GestureDetector(
                            onTap: () => _handleThemeSelection(i),
                            child: _ThemeChip(
                              color1: themes[i][0],
                              color2: themes[i][1],
                              isSelected: _selectedTheme == i,
                            ),
                          ),
                          if (i < themes.length - 1) const SizedBox(width: 16),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final Color color1;
  final Color color2;
  final bool isSelected;

  const _ThemeChip({
    required this.color1,
    required this.color2,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        border:
            isSelected
                ? Border.all(color: Colors.white, width: 2)
                : Border.all(width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CustomPaint(painter: _DiagonalPainter(color1, color2)),
      ),
    );
  }
}

class _DiagonalPainter extends CustomPainter {
  final Color color1;
  final Color color2;

  const _DiagonalPainter(this.color1, this.color2);

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = color1;
    final paint2 = Paint()..color = color2;
    canvas
      ..drawRect(
        Rect.fromPoints(Offset.zero, Offset(size.width, size.height)),
        paint1,
      )
      ..drawPath(
        Path()
          ..moveTo(0, size.height)
          ..lineTo(size.width, 0)
          ..lineTo(size.width, size.height)
          ..close(),
        paint2,
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class IrisTransition extends PageRouteBuilder<dynamic> {
  final Widget child;
  final Duration duration;

  IrisTransition({required this.child, required this.duration})
    : super(
        transitionDuration: duration,
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return ClipPath(
                clipper: CircleRevealClipper(fraction: animation.value * 2),
                child: child,
              );
            },
            child: child,
          );
        },
      );
}

class CircleRevealClipper extends CustomClipper<Path> {
  final double fraction;

  CircleRevealClipper({required this.fraction});

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * fraction;
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
