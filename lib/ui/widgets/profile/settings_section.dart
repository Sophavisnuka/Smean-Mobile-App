import 'package:flutter/material.dart';
import 'package:smean_mobile_app/ui/widgets/build_menu_item.dart';

/// A widget that displays a settings section with title and menu items
class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, required this.title, required this.items});

  final String title;
  final List<SettingsMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),

          // Build menu items with dividers
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

            return Column(
              children: [
                BuildMenuItem(
                  icon: item.icon,
                  title: item.title,
                  iconColor: item.iconColor,
                  onTap: item.onTap,
                ),
                if (index < items.length - 1) const Divider(height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }
}

/// Data class for settings menu item
class SettingsMenuItem {
  final IconData icon;
  final String title;
  final Color iconColor;
  final VoidCallback onTap;

  SettingsMenuItem({
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.onTap,
  });
}
