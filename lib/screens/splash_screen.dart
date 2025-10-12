import 'dart:async';
import 'package:face2feel/screens/camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to LoginScreen after 4 seconds
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CameraScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // dark backdrop looks great with Lottie
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // First animation (e.g. logo animation)
            Lottie.asset(
              'assets/animations/logo1.json', // put your file here
              height: 180,
            ),
            const SizedBox(height: 40),
            // Second animation (e.g. emotion or loading animation)
            Lottie.asset(
              'assets/animations/logo2.json',
              height: 120,
            ),
            const SizedBox(height: 40),
            const Text(
              "FACE2FEEL",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
