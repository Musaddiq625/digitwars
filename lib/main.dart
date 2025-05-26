// Import necessary packages
import 'package:digitwars_io/src/start/start_screen.dart'; // We will create this file next
import 'package:flutter/material.dart';

// Main function to run the app
void main() {
  runApp(const MyApp());
}

// MyApp widget, the root of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digit Wars Game',
      theme: ThemeData(
        iconTheme: const IconThemeData(color: Colors.white),
        primaryColor: Colors.white,
        primarySwatch: Colors.blueGrey,
        useMaterial3: true,
        primaryColorLight: Colors.white, // For subtle elements
        colorScheme: const ColorScheme.dark(),
      ),
      debugShowCheckedModeBanner: false, // Remove debug banner
      home: const StartScreen(), // Changed from GameScreen
    );
  }
}
