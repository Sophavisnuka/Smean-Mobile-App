/// Result object for profile image operations
class ProfileImageResult {
  final bool success;
  final bool cancelled;
  final String? imagePath;
  final String? error;

  ProfileImageResult({
    required this.success,
    this.cancelled = false,
    this.imagePath,
    this.error,
  });
}
