import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smean_mobile_app/core/constants/app_colors.dart';
import 'package:smean_mobile_app/core/providers/language_provider.dart';
import 'package:smean_mobile_app/core/route/app_routes.dart';
import 'package:smean_mobile_app/data/database/database.dart';

void main() async {
  // Ensure Flutter bindings are initialized first
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        // Provide the database instance globally (lazy creation)
        Provider<AppDatabase>(
          create: (_) => AppDatabase(),
          dispose: (_, db) => db.close(),
        ),
        ChangeNotifierProvider(
          create: (context) => LanguageProvider(context.read<AppDatabase>()),
        ),
      ],
      child: const SmeanApp(),
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
      title: "SMEAN",
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
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
    );
  }
}
