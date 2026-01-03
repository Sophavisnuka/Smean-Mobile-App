import 'package:flutter/material.dart';

/// Reusable search bar widget that navigates to search screen
class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    required this.onTap,
    required this.hintText,
  });

  final VoidCallback onTap;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            const Icon(Icons.search),
            const SizedBox(width: 10),
            Text(hintText, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
