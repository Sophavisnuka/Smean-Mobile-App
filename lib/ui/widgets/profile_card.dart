import 'package:flutter/material.dart';
import 'package:smean_mobile_app/constants/app_colors.dart';
import 'package:smean_mobile_app/ui/screens/account_screen.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.isKhmer,
  });

  final bool isKhmer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.primary
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        splashColor: Colors.white24,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AccountScreen()),
          );
        },
        child: Row(
          children: [
            ClipOval(
              child: Image.asset(
                '../../assets/Elite.png',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isKhmer ? 'សួស្តី, ទិត្យ អេលីត' : 'Hello, Tet Elite', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Text(isKhmer ? 'ចូលមេីល' : 'View Profile', style: TextStyle(color: Colors.white)),
                    SizedBox(width: 5),
                    Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
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
