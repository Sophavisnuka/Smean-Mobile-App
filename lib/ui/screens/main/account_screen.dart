import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smean_mobile_app/core/constants/app_colors.dart';
import 'package:smean_mobile_app/core/providers/language_provider.dart';
import 'package:smean_mobile_app/core/utils/custom_snack_bar.dart';
import 'package:smean_mobile_app/service/auth_service.dart';
import 'package:smean_mobile_app/service/profile_service.dart';
import 'package:smean_mobile_app/data/database/database.dart' hide Card;
import 'package:smean_mobile_app/ui/widgets/language_switcher_button.dart';
import 'package:smean_mobile_app/data/models/user_class.dart';
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
      // TODO: Implement delete account logic
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
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
      await _loadUser();
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
      appBar: AppBar(
        centerTitle: false,
        title: Text(isKhmer ? 'គណនី' : 'Account'),
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
            // Profile Header
            ProfileHeaderWidget(
              imagePath: currentUser?.imagePath,
              username: currentUser?.name ?? '',
              email: currentUser?.email ?? '',
              onImageTap: _changeProfilePicture,
            ),

            // Account Settings Section
            SettingsSection(
              title: isKhmer ? 'ការកំណត់គណនី' : 'Account Settings',
              items: [
                SettingsMenuItem(
                  icon: Icons.edit_outlined,
                  title: isKhmer ? 'កែប្រែប្រវត្តិ' : 'Edit Username',
                  iconColor: AppColors.primary,
                  onTap: _editUsername,
                ),
                SettingsMenuItem(
                  icon: Icons.logout,
                  title: isKhmer ? 'ចាកចេញ' : 'Logout',
                  iconColor: Colors.orange,
                  onTap: _handleLogout,
                ),
                SettingsMenuItem(
                  icon: Icons.delete_outline,
                  title: isKhmer ? 'លុបគណនី' : 'Delete Account',
                  iconColor: Colors.red,
                  onTap: _handleDeleteAccount,
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
