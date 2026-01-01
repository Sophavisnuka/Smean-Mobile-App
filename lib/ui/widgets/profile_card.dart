import 'package:flutter/material.dart';
import 'package:smean_mobile_app/constants/app_colors.dart';
import 'package:smean_mobile_app/service/auth_service.dart';
import 'package:smean_mobile_app/ui/screens/account_screen.dart';

class ProfileCard extends StatefulWidget {
  const ProfileCard({
    super.key,
    required this.isKhmer,
  });

  final bool isKhmer;

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  String _name = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService().getCurrentUser();

    setState(() {
      _name = user?.name ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _name.isEmpty
      ? (widget.isKhmer ? 'អ្នកប្រើប្រាស់' : 'User')
      : _name;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.primary,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        splashColor: Colors.white24,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AccountScreen()),
          );
        },
        child: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/Elite.png',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isKhmer
                      ? 'សួស្តី, $displayName'
                      : 'Hello, $displayName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      widget.isKhmer ? 'ចូលមើល' : 'View Profile',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 14,
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
