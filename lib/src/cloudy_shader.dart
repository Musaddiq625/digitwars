// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:digitwars_io/src/utils/shader_util.dart';
import 'package:flutter/material.dart';

class CloudyCircle extends StatefulWidget {
  final Color color1;
  final Color color2;
  final Size size;
  final bool isCircleShape;

  const CloudyCircle({
    required this.color1,
    required this.color2,
    super.key,
    this.size = const Size(100, 100),
    this.isCircleShape = false,
  });

  @override
  State<CloudyCircle> createState() => _CloudyCircleState();
}

class _CloudyCircleState extends State<CloudyCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  FragmentShader? shader;

  @override
  void initState() {
    super.initState();
    _loadShader();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 100),
    )..repeat();
  }

  Future<void> _loadShader() async {
    shader = await ShaderUtil.shader;
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (shader == null) return const SizedBox();

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final time = _controller.value * 200;
        final width = widget.size.width;
        final height = widget.size.height;

        // Convert Flutter Colors to normalized floats (0-1)
        final r1 = widget.color1.red / 255.0;
        final g1 = widget.color1.green / 255.0;
        final b1 = widget.color1.blue / 255.0;

        final r2 = widget.color2.red / 255.0;
        final g2 = widget.color2.green / 255.0;
        final b2 = widget.color2.blue / 255.0;

        shader!
          ..setFloat(0, time) // uTime
          ..setFloat(1, width) // uResolution.x
          ..setFloat(2, height) // uResolution.y
          // uColor1 (vec3)
          ..setFloat(3, r1)
          ..setFloat(4, g1)
          ..setFloat(5, b1)
          // uColor2 (vec3)
          ..setFloat(6, r2)
          ..setFloat(7, g2)
          ..setFloat(8, b2);
        final paint = CustomPaint(
          size: Size(width, height),
          painter: _ShaderPainter(shader!),
        );
        return widget.isCircleShape ? ClipOval(child: paint) : paint;
      },
    );
  }
}

class _ShaderPainter extends CustomPainter {
  final FragmentShader shader;

  _ShaderPainter(this.shader);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
