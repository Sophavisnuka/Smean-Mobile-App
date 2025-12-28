import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smean_mobile_app/constants/app_colors.dart';

class RecentActivityCard extends StatelessWidget {

  final String title;
  final DateTime createdAt;

  const RecentActivityCard({
    super.key,
    required this.isKhmer,
    required this.title,
    required this.createdAt,
  });

  final bool isKhmer;

  @override
  Widget build(BuildContext context) {
        // Format the date as you like
    String formattedDate = isKhmer
      ? DateFormat('dd/MM/yyyy · HH:mm').format(createdAt)
      : DateFormat('MMM dd, yyyy · HH:mm').format(createdAt);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        onTap: () {
          
        },
        contentPadding: EdgeInsets.all(15),
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          //icon mic
          child: Icon(
            Icons.mic, 
            color: AppColors.primary, 
            size: 24
          ),
        ),
        //title of card
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        // description
        subtitle: Text(
          formattedDate,
          style: TextStyle(fontSize: 14),
        ),
        trailing: Icon(
          Icons.more_vert,
          color: Colors.grey,
          size: 30,
        ),
      ),
    );
  }
}