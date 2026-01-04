import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:smean_mobile_app/core/constants/app_colors.dart';
import 'package:smean_mobile_app/core/providers/language_provider.dart';
import 'package:smean_mobile_app/core/route/app_routes.dart';
import 'package:smean_mobile_app/core/utils/custom_snack_bar.dart';
import 'package:smean_mobile_app/service/auth_service.dart';
import 'package:smean_mobile_app/data/database/database.dart' hide Card;
import 'package:smean_mobile_app/ui/widgets/build_menu_item.dart';
import 'package:smean_mobile_app/ui/widgets/language_switcher_button.dart';
import 'package:smean_mobile_app/data/models/user_class.dart';
import 'package:smean_mobile_app/ui/widgets/show_confirm_dialog.dart';
import 'package:smean_mobile_app/ui/widgets/profile_picker_sheet.dart';
import 'package:smean_mobile_app/ui/widgets/profile_image_widget.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late AuthService _auth;
  String username = '';
  String email = '';
  AppUser? currentUser; 

  @override
  void didChangeDependencies() {
    final db = Provider.of<AppDatabase>(context, listen: false);
    super.didChangeDependencies();
    _auth = AuthService(db);
    _loadUser();
  }

  Future<void> _loadUser() async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final user = await AuthService(db).getCurrentUser();

    setState(() {
      currentUser = user;
      username = user?.name ?? '';
      email = user?.email ?? ''; 
    });
  }

  Future<void> _handleLogout() async {

    final onConfirm = await showDialog<bool>(
      context: context, 
      builder: (builder) => ShowConfirmDialog(
        cancelText: 'Cancel', 
        confirmText: 'Confirm', 
        titleText: 'Are you sure you want to log out?'
      )
    );
    if (onConfirm != true) return;
    await _auth.logout();
    if (!mounted) return;
    CustomSnackBar.success(context, 'Log out successful');
    AppRoutes.navigateToLogin(context);
  }

  Future<void> _handleDeleteAccount() async {
    if (currentUser == null) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ShowConfirmDialog(
        cancelText: 'Cancel', 
        confirmText: 'Confirm', 
        titleText: 'Are you sure you want to delete this account?'
      )
    );

    if (confirmed == true) {
      final (ok, message) = await _auth.deleteUserAccount(currentUser!.id);
      
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
    
    final newUsername = await showDialog<String>(
      context: context,
      builder: (_) => ShowInputDialog(
        titleText: 'Edit Username', 
        hintText: 'Enter a new username',
        initialValue: currentUser!.name,
      ),
    );

    if (newUsername != null && newUsername.isNotEmpty && newUsername != currentUser!.name) {
      try {
        final db = Provider.of<AppDatabase>(context, listen: false);
        await AuthService(db).repo.editUsername(currentUser!.id, newUsername);
        
        setState(() {
          username = newUsername;
        });

        if (!mounted) return;
        CustomSnackBar.success(context, 'Username change successful');
      } catch (e) {
        if (!mounted) return;
        CustomSnackBar.error(context, 'Failed to change username, try again!');
      }
    }
  }

  Future<void> changeProfilePicture() async {
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';
    final hasPhoto = currentUser?.imagePath != null;

    await showModalBottomSheet(
      context: context, 
      builder: (context) => ProfilePictureSheet(
        isKhmer: isKhmer, 
        hasPhoto: hasPhoto, 
        onTakePhoto: () {
          Navigator.pop(context);
          pickImage(ImageSource.camera);
        },
        onChooseGallery: () {
          Navigator.pop(context);
          pickImage(ImageSource.gallery);
        },
        onRemovePhoto: () {
          Navigator.pop(context);
          _removeProfilePicture();
        },
      )
    );
  }
  
  Future<void> _removeProfilePicture() async {
    try {
      // Delete file if exists (mobile only)
      if (!kIsWeb && currentUser?.imagePath != null) {
        final imagePath = currentUser!.imagePath!;
        if (!imagePath.startsWith('data:image')) {
          final file = File(imagePath);
          if (await file.exists()) {
            await file.delete();
          }
        }
      }

      // Update database - set to null to remove
      final db = Provider.of<AppDatabase>(context, listen: false);
      await AuthService(db).repo.editProfile(currentUser!.id, null);
      
      // Force immediate UI update
      setState(() {
        currentUser = currentUser!.copyWith(imagePath: null);
      });
      
      await _loadUser();

      if (!mounted) return;
      CustomSnackBar.success(context, 'Profile Remove');
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.error(context, 'Error: $e');
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
        source: source
      );
      
      if (pickedFile == null) {
        // User cancelled - this is normal, don't show error
        return;
      }
      
      String imageData;

      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        imageData = 'data:image/${pickedFile.path.split('.').last};base64,${base64Encode(bytes)}';
      } else {
        // Save to app directory
        final appDir = await getApplicationDocumentsDirectory();
        final profileDir = Directory('${appDir.path}/profile_pictures');
        if (!await profileDir.exists()) {
          await profileDir.create(recursive: true);
        }
        final fileName = 'profile_${currentUser!.id}${path.extension(pickedFile.path)}';
        final saveImage = File('${profileDir.path}/$fileName');
        await File(pickedFile.path).copy(saveImage.path);
        imageData = saveImage.path;
      }
      
      final db = Provider.of<AppDatabase>(context, listen: false);
      await AuthService(db).repo.editProfile(currentUser!.id, imageData);
      
      // Force immediate UI update
      setState(() {
        currentUser = currentUser!.copyWith(imagePath: imageData);
      });
      
      await _loadUser(); // Reload user data from database

      if (!mounted) return;
      CustomSnackBar.success(context, 'Profile update successful');
    } catch (e) {
      if (!mounted) return;
      print('Error picking image: $e'); // For debugging
      CustomSnackBar.error(context, 'Failed to update the profile');
    }
  }

  LanguageProvider get languageProvider => Provider.of<LanguageProvider>(context, listen: false);

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
            const SizedBox(height: 40),
            
            // Profile Picture
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 3,
                ),
              ),
              child: GestureDetector(
                onTap: changeProfilePicture,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: ProfileImageWidget(
                          imagePath: currentUser?.imagePath,
                          size: 100,
                        ),
                      )
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        radius: 18,
                        child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
            ),
            
            const SizedBox(height: 16),
            
            // Username
            Text(
              username,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Email
            Text(
              email,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Account Settings Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      isKhmer ? 'ការកំណត់គណនី' : 'Account Settings',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  
                  // Edit Profile
                  BuildMenuItem(
                    icon: Icons.edit_outlined,
                    title: isKhmer ? 'កែប្រែប្រវត្តិ' : 'Edit Username',
                    iconColor: AppColors.primary,
                    onTap: _editUsername,
                  ),
                  
                  const Divider(height: 1),
                  
                  // Logout
                  BuildMenuItem(
                    icon: Icons.logout,
                    title: isKhmer ? 'ចាកចេញ' : 'Logout',
                    iconColor: Colors.orange,
                    onTap: _handleLogout,
                  ),
                  
                  const Divider(height: 1),
                  
                  // Delete Account
                  BuildMenuItem(
                    icon: Icons.delete_outline,
                    title: isKhmer ? 'លុបគណនី' : 'Delete Account',
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
}
