import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smean_mobile_app/constants/app_colors.dart';
import 'package:smean_mobile_app/providers/language_provider.dart';
import 'package:smean_mobile_app/ui/screens/main_screen.dart';
import 'package:smean_mobile_app/ui/screens/register_login_screen/login_screen.dart';
import 'package:smean_mobile_app/ui/screens/register_login_screen/register_screen.dart';
import 'package:smean_mobile_app/ui/screens/welcome_screen/welcome_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
      ],
      child: DevicePreview(builder: (context) => SmeanApp()),
      // child: SmeanApp(),
    ),
  );
}

class SmeanApp extends StatelessWidget {
  const SmeanApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';
    final currentTextTheme = isKhmer
        ? GoogleFonts.kantumruyProTextTheme(Theme.of(context).textTheme)
        : GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return MaterialApp(
      // Remove initialRoute, let WelcomeScreen handle routing logic
      routes: {
        '/splash': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainScreen(),
      },
      title: "SMEAN",
      debugShowCheckedModeBanner: false,
      locale: languageProvider.currentLocale,
      theme: ThemeData(
        useMaterial3: true,

        // 1. Set the Color Scheme
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: Colors.white,
        ),

        scaffoldBackgroundColor: AppColors.contrast,

        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.contrast,
        ),

        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),

        // 2. Set Default Font (Poppins for English, Kantumruy Pro for Khmer)
        textTheme: currentTextTheme,
      ),
      // Always start with WelcomeScreen, it will decide where to go
      home: const WelcomeScreen(),
    );
  }
}
