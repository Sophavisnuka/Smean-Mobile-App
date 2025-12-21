import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:smean_mobile_app/theme/app_colors.dart';
import 'ui/welcome_screen.dart';

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
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.backgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.backgroundColor,
          foregroundColor: AppColors.textColorWhite,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white
        )
      ),
      home: WelcomeScreen()
    );
  }
}
