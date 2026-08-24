class AuthValidator {
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name cannot be empty';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email cannot be empty';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number cannot be empty';
    }

    final cleanPhone = value.replaceAll(' ', '');

    final phoneRegex = RegExp(r'^\d{9}$');
    if (!phoneRegex.hasMatch(cleanPhone)) {
      return 'Phone number must be exactly 9 digits';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  static String? validateSignupForm({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) {
    return validateFullName(fullName) ??
        validateEmail(email) ??
        validatePhone(phone) ??
        validatePassword(password);
  }

  static String? validateResetEmail(String email) {
    final normalizedEmail = email.trim();

    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      return 'Please enter a valid email address.';
    }

    return null;
  }

  static String? validateLoginForm({
    required String email,
    required String password,
  }) {
    final normalizedEmail = email.trim();
    final normalizedPassword = password.trim();

    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      return 'Please enter a valid email address.';
    }

    if (normalizedPassword.isEmpty) {
      return 'Please enter your password.';
    }

    return null;
  }
}
