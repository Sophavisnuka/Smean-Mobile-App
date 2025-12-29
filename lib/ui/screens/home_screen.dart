import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smean_mobile_app/providers/language_provider.dart';
import 'package:smean_mobile_app/ui/widgets/language_switcher_button.dart';
import 'package:smean_mobile_app/ui/widgets/profile_card.dart';
import 'package:smean_mobile_app/ui/widgets/recent_activity_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/Smean-Logo.png', height: 50),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: LanguageSwitcherButton(),
          ),
        ],
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //profile card
              ProfileCard(isKhmer: isKhmer),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isKhmer ? 'សកម្មភាពថ្មីៗ' : 'Recent Activities', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Text('Sort By', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      SizedBox(width: 5),
                      Icon(Icons.sort, color: Colors.black, size: 17),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 15),
              // recent voice card
              Expanded(
                child: ListView.separated(
                  itemCount: 10,
                  separatorBuilder:(context, index) => SizedBox(height: 15),
                  itemBuilder: (context, index) {
                    return RecentActivityCard(isKhmer: isKhmer);
                  },
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}