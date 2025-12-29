import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smean_mobile_app/providers/language_provider.dart';
import 'package:smean_mobile_app/ui/widgets/language_switcher_button.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: LanguageSwitcherButton(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Avatar
            // CircleAvatar(
            //   radius: 48,
              
            //   backgroundColor: Colors.grey[300],
            //   child: Icon(Icons.person, size: 64, color: Colors.white),
            // ),
            ClipOval(
              child: Image.asset(
                '../../assets/Elite.png',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16),
            // Name
            Text(
              'Tet Elite',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            Divider(),
            // Account Options
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit Profile'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text('Change Password'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}