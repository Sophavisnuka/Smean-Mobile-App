import 'package:flutter/material.dart';
import 'package:smean_mobile_app/theme/app_colors.dart';
import 'package:smean_mobile_app/ui/home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              '../assets/Smean-Logo.png',
              width: 150,
              height: 150,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => HomeScreen()
                  )
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.textColorWhite,
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
              ),
              child: Text('Get Start', style: TextStyle(color: AppColors.textColorWhite)),
            )
          ],
        ),
      ),
    );
  }
}