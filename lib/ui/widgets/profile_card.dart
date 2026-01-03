import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smean_mobile_app/core/constants/app_colors.dart';
import 'package:smean_mobile_app/service/auth_service.dart';
import 'package:smean_mobile_app/data/database/database.dart';
import 'package:smean_mobile_app/ui/widgets/profile_image_widget.dart';

class ProfileCard extends StatefulWidget {
  const ProfileCard({super.key, required this.isKhmer, this.onTap});

  final bool isKhmer;
  final VoidCallback? onTap;

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  String _name = '';
  String? _imagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void didUpdateWidget(ProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload when widget is rebuilt (e.g., when tab becomes visible)
    _loadUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload when dependencies change (e.g., after database update)
    if (!_isLoading) {
      _loadUser();
    }
  }

  Future<void> _loadUser() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    final db = Provider.of<AppDatabase>(context, listen: false);
    final user = await AuthService(db).getCurrentUser();

    setState(() {
      _name = user?.name ?? '';
      _imagePath = user?.imagePath;
      _isLoading = false;
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
        onTap: widget.onTap,
        child: Row(
          children: [
            ClipOval(
              child: ProfileImageWidget(
                imagePath: _imagePath,
                size: 60,
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
