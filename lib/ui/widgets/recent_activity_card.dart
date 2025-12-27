import 'package:flutter/material.dart';
import 'package:smean_mobile_app/constants/app_colors.dart';

class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard({
    super.key,
    required this.isKhmer,
  });

  final bool isKhmer;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to detail page
        // Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage()));
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            SizedBox(width: 15),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Project Updates',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    isKhmer ? 'ម្សិលមិញ ម៉ោង ១២:៣០' : 'Yesterday · 12:30',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // More options icon
            Icon(
              Icons.more_vert,
              color: Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}