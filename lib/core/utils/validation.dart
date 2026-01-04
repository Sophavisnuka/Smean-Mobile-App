class Validation {
  /// Validator for email TextFormField - returns null if valid, error message if invalid
  /// Validates if the email has correct format and ends with @gmail.com
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    final email = value.trim();
    
    if (!email.contains('@')) {
      return 'Email must contain @';
    }
    
    if (!email.endsWith('@gmail.com')) {
      return 'Incorrect Gmail Format';
    }
    
    // Basic email format check
    final emailRegex = RegExp(r'^[\w-\.]+@gmail\.com$');
    if (!emailRegex.hasMatch(email)) {
      return 'Invalid email format';
    }
    
    return null;
  }

  /// Validator for password TextFormField - returns null if valid, error message if invalid
  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  /// Validator for name/username TextFormField - returns null if valid, error message if invalid
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }
}
