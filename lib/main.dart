import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import './ui/home_screen.dart';

void main() {
  runApp(
    DevicePreview(
      builder: (context) => MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen()
    );
  }
}
