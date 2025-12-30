import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smean_mobile_app/constants/app_colors.dart';
import 'package:smean_mobile_app/models/audio_class.dart';
import 'package:smean_mobile_app/ui/screens/audio_details_screen.dart';

class RecentActivityCard extends StatelessWidget {

  final AudioRecord audio;

  final bool isKhmer;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  RecentActivityCard({
    super.key,
    required this.audio,
    required this.isKhmer,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final createdAt = audio.createdAt;
    final title = audio.audioTitle;
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
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AudioDetailsScreen(audios: audio)),
          );
        },
        contentPadding: EdgeInsets.all(15),
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.mic,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          formattedDate,
          style: TextStyle(fontSize: 14),
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: Colors.grey,
            size: 30,
          ),
          onSelected: (value) {
            if (value == 'edit' && onEdit != null) {
              onEdit!();
            } else if (value == 'delete' && onDelete != null) {
              onDelete!();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.black54, size: 20),
                  SizedBox(width: 8),
                  Text(isKhmer ? 'កែប្រែ' : 'Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.redAccent, size: 20),
                  SizedBox(width: 8),
                  Text(isKhmer ? 'លុប' : 'Delete'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}