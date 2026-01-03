import 'package:flutter/material.dart';

/// A widget that displays an upload progress view
class UploadProgressView extends StatelessWidget {
  const UploadProgressView({super.key, required this.isKhmer});

  final bool isKhmer;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(strokeWidth: 6),
          ),
          const SizedBox(height: 32),
          Text(
            isKhmer
                ? 'កំពុងដំណើរការឯកសាររបស់អ្នក...'
                : 'Processing your file...',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Text(
            isKhmer
                ? 'សូមរង់ចាំបន្តិច នេះនឹងចំណាយពេលពីរបីវិនាទីប៉ុណ្ណោះ'
                : 'Please wait, this will only take a few seconds',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
