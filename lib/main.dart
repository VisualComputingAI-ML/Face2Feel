import 'package:flutter/material.dart';
import 'screens/permission_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face2Feel - Real-time Emotional Support',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const PermissionScreen(), // Start with permission screen
      debugShowCheckedModeBanner: false,
    );
  }
}