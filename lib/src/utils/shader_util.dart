import 'dart:ui';

class ShaderUtil {
  static FragmentShader? _cloudyShader;

  // Getter that initializes shader if needed
  static Future<FragmentShader> get shader async {
    return _cloudyShader ??= await _loadShader();
  }

  // Private constructor to prevent instantiation
  ShaderUtil._();

  static Future<FragmentShader> _loadShader() async {
    final program = await FragmentProgram.fromAsset('shaders/cloudy.frag');
    return program.fragmentShader();
  }
}
