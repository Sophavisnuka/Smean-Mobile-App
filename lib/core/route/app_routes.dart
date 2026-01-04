import 'package:flutter/material.dart';
import 'package:smean_mobile_app/ui/screens/welcome_screen/welcome_screen.dart';
import 'package:smean_mobile_app/ui/screens/register_login_screen/login_screen.dart';
import 'package:smean_mobile_app/ui/screens/register_login_screen/register_screen.dart';
import 'package:smean_mobile_app/ui/screens/main/main_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';

  // Route map
  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const WelcomeScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    main: (context) => const MainScreen(),
  };

  // Navigation helper methods
  static void navigateToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, login);
  }

  static void navigateToRegister(BuildContext context) {
    Navigator.pushReplacementNamed(context, register);
  }

  static void navigateToMain(BuildContext context) {
    Navigator.pushReplacementNamed(context, main);
  }

  static void navigateToSplash(BuildContext context) {
    Navigator.pushReplacementNamed(context, splash);
  }
}
