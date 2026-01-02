import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smean_mobile_app/core/providers/language_provider.dart';
import 'package:smean_mobile_app/service/auth_service.dart';
import 'package:smean_mobile_app/data/database/database.dart';
import 'package:smean_mobile_app/ui/widgets/language_switcher_button.dart';
import 'package:smean_mobile_app/ui/widgets/profile_card.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late AuthService _auth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final db = Provider.of<AppDatabase>(context, listen: false);
    _auth = AuthService(db);
  }

  Future<void> _handleLogout() async {
    await _auth.logout();
    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';

    return Scaffold(
      appBar: AppBar(
        title: Text(isKhmer ? 'គណនី' : 'Account'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: LanguageSwitcherButton(),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        child: Column(
          children: [
            ProfileCard(isKhmer: isKhmer),
            const SizedBox(height: 24),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(isKhmer ? 'កែប្រែប្រវត្តិ' : 'Edit Profile'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: Text(
                isKhmer ? 'ផ្លាស់ប្តូរពាក្យសម្ងាត់' : 'Change Password',
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(isKhmer ? 'ការកំណត់' : 'Settings'),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(
                isKhmer ? 'ចាកចេញ' : 'Logout',
                style: const TextStyle(color: Colors.red),
              ),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
    );
  }
}
