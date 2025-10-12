import 'package:face2feel/screens/camera_screen.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const Face2FeelApp());
}

class Face2FeelApp extends StatelessWidget {
  const Face2FeelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CameraScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
