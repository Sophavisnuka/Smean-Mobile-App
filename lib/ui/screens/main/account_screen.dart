import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smean_mobile_app/core/constants/app_colors.dart';
import 'package:smean_mobile_app/core/providers/language_provider.dart';
import 'package:smean_mobile_app/core/route/app_routes.dart';
import 'package:smean_mobile_app/core/utils/custom_snack_bar.dart';
import 'package:smean_mobile_app/service/auth_service.dart';
import 'package:smean_mobile_app/service/profile_service.dart';
import 'package:smean_mobile_app/data/database/database.dart' hide Card;
import 'package:smean_mobile_app/ui/widgets/language_switcher_button.dart';
import 'package:smean_mobile_app/data/models/user_class.dart';
import 'package:smean_mobile_app/ui/widgets/profile_image_widget.dart';
import 'package:smean_mobile_app/ui/widgets/show_confirm_dialog.dart';
import 'package:smean_mobile_app/ui/widgets/profile_picker_sheet.dart';
import 'package:smean_mobile_app/ui/widgets/profile/profile_header_widget.dart';
import 'package:smean_mobile_app/ui/widgets/profile/settings_section.dart';
import 'package:smean_mobile_app/ui/widgets/dialogs/text_input_dialog.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late AuthService _authService;
  late ProfileService _profileService;
  AppUser? currentUser;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final db = Provider.of<AppDatabase>(context, listen: false);
    _authService = AuthService(db);
    _profileService = ProfileService(db);
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getCurrentUser();
    if (mounted) {
      setState(() {
        currentUser = user;
      });
    }
  }

  Future<void> _handleLogout() async {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ShowConfirmDialog(
        cancelText: isKhmer ? 'បោះបង់' : 'Cancel',
        confirmText: isKhmer ? 'បញ្ជាក់' : 'Confirm',
        titleText: isKhmer
            ? 'តើអ្នកប្រាកដថាចង់ចាកចេញទេ?'
            : 'Are you sure you want to log out?',
      ),
    );

    if (confirmed != true) return;

    await _authService.logout();
    if (!mounted) return;

    CustomSnackBar.success(
      context,
      isKhmer ? 'ចាកចេញបានជោគជ័យ' : 'Log out successful',
    );
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _handleDeleteAccount() async {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ShowConfirmDialog(
        cancelText: isKhmer ? 'បោះបង់' : 'Cancel',
        confirmText: isKhmer ? 'បញ្ជាក់' : 'Confirm',
        titleText: isKhmer
            ? 'តើអ្នកប្រាកដថាចង់លុបគណនីនេះទេ?'
            : 'Are you sure you want to delete this account?',
      ),
    );

    if (confirmed == true) {
      final (ok, message) = await _authService.deleteUserAccount(currentUser!.id);
      
      if (!mounted) return;
      
      if (ok) {
        CustomSnackBar.success(context, message);
        AppRoutes.navigateToLogin(context);
      } else {
        CustomSnackBar.error(context, message);
      }
    }
  }

  Future<void> _editUsername() async {
    if (currentUser == null) return;

    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';

    final newUsername = await TextInputDialog.show(
      context,
      title: isKhmer ? 'កែប្រែឈ្មោះអ្នកប្រើ' : 'Edit Username',
      hintText: isKhmer ? 'បញ្ចូលឈ្មោះថ្មី' : 'Enter a new username',
      initialValue: currentUser!.name,
    );

    if (newUsername != null &&
        newUsername.isNotEmpty &&
        newUsername != currentUser!.name) {
      final success = await _profileService.updateUsername(
        currentUser!.id,
        newUsername,
      );

      if (!mounted) return;

      if (success) {
        await _loadUser();
        if (!mounted) return;

        CustomSnackBar.success(
          context,
          isKhmer ? 'ផ្លាស់ប្តូរឈ្មោះបានជោគជ័យ' : 'Username change successful',
        );
      } else {
        CustomSnackBar.error(
          context,
          isKhmer
              ? 'បរាជ័យក្នុងការផ្លាស់ប្តូរឈ្មោះ សូមព្យាយាមម្តងទៀត!'
              : 'Failed to change username, try again!',
        );
      }
    }
  }

  Future<void> _changeProfilePicture() async {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';
    final hasPhoto = currentUser?.imagePath != null;

    await showModalBottomSheet(
      context: context,
      builder: (context) => ProfilePictureSheet(
        isKhmer: isKhmer,
        hasPhoto: hasPhoto,
        onTakePhoto: () {
          Navigator.pop(context);
          _pickImage(ImageSource.camera);
        },
        onChooseGallery: () {
          Navigator.pop(context);
          _pickImage(ImageSource.gallery);
        },
        onRemovePhoto: () {
          Navigator.pop(context);
          _removeProfilePicture();
        },
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (currentUser == null) return;

    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';

    final result = await _profileService.pickAndSaveImage(
      currentUser!.id,
      source,
    );

    if (!mounted) return;

    if (result.success) {
      
      // Force immediate UI update
      setState(() {
        currentUser = currentUser!.copyWith(imagePath: null);
      });
      
      await _loadUser();
      if (!mounted) return;

      CustomSnackBar.success(
        context,
        isKhmer
            ? 'ធ្វើបច្ចុប្បន្នភាពប្រវត្តិរូបបានជោគជ័យ'
            : 'Profile update successful',
      );
    } else if (!result.cancelled) {
      CustomSnackBar.error(
        context,
        isKhmer
            ? 'បរាជ័យក្នុងការធ្វើបច្ចុប្បន្នភាពប្រវត្តិរូប'
            : 'Failed to update the profile',
      );
    }
  }

  Future<void> _removeProfilePicture() async {
    if (currentUser == null) return;

    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';

    final success = await _profileService.removeProfilePicture(
      currentUser!.id,
      currentUser!.imagePath,
    );

    if (!mounted) return;

    if (success) {
      await _loadUser();
      if (!mounted) return;

      CustomSnackBar.success(
        context,
        isKhmer ? 'យករូបភាពចេញបានជោគជ័យ' : 'Profile removed successfully',
      );
    } else {
      CustomSnackBar.error(
        context,
        isKhmer ? 'មានកំហុស' : 'Error removing profile',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';

    return Scaffold(
      backgroundColor: Color(0xFFF4F6F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: Text(
          isKhmer ? 'ប្រវត្តិរូប' : 'Profile',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: LanguageSwitcherButton(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Picture Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              width: double.infinity,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _changeProfilePicture,
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[200],
                          ),
                          child: ClipOval(
                            child: ProfileImageWidget(
                              imagePath: currentUser?.imagePath,
                              size: 120,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 20,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Personal Info Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isKhmer ? 'ព័ត៌មានផ្ទាល់ខ្លួន' : 'Personal info',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Name field
                  _buildInfoRow(
                    icon: Icons.person_outline,
                    label: isKhmer ? 'ឈ្មោះ' : 'Name',
                    value: currentUser?.name ?? '',
                  ),
                  const SizedBox(height: 16),
                  
                  // Email field
                  _buildInfoRow(
                    icon: Icons.email_outlined,
                    label: isKhmer ? 'អ៊ីមែល' : 'E-mail',
                    value: currentUser?.email ?? '',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Account Actions Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isKhmer ? 'ព័ត៌មានគណនី' : 'Account info',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Edit Username
                  _buildActionTile(
                    icon: Icons.edit_outlined,
                    label: isKhmer ? 'កែប្រែឈ្មោះអ្នកប្រើ' : 'Edit Username',
                    iconColor: AppColors.primary,
                    onTap: _editUsername,
                  ),
                  
                  Divider(height: 1, color: Colors.grey[200]),
                  
                  // Logout
                  _buildActionTile(
                    icon: Icons.logout,
                    label: isKhmer ? 'ចាកចេញ' : 'Logout',
                    iconColor: Colors.orange,
                    onTap: _handleLogout,
                  ),
                  
                  Divider(height: 1, color: Colors.grey[200]),
                  
                  // Delete Account
                  _buildActionTile(
                    icon: Icons.delete_outline,
                    label: isKhmer ? 'លុបគណនី' : 'Delete Account',
                    iconColor: Colors.red,
                    onTap: _handleDeleteAccount,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 24, color: Colors.grey[700]),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 24, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
