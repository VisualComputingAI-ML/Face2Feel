import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dummy App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Hello Flutter"),
          backgroundColor: Colors.blue,
        ),
        body: const Center(
          child: Text(
            "It works! 🎉",
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
