/// A utility class for validating form fields.
class CustomValidator {
  /// Private constructor to prevent instantiation.
  CustomValidator._();

  /// Validates that a text field is not empty.
  static String? validateEmptyText(String? fieldName, String? value) {
    if (value == null || value.length < 3) {
      return '$fieldName is required';
    }

    return null;
  }

  /// Validates an email address format.
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required.';
    }

    // Regular expression for email validation
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegExp.hasMatch(value)) {
      return 'Invalid email address.';
    }

    return null;
  }

  /// Validates a password based on common security criteria.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }

    // Check for minimum password length
    if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }

    // Check for uppercase letters
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter.';
    }

    // Check for numbers
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number.';
    }

    // Check for special characters
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character.';
    }

    // Check for present of whitespace
    if (value.contains(RegExp(r'\s'))) {
      return 'Password cannot contain whteapace';
    }

    return null;
  }

  /// Validate if both password and confirm password matches
  static String? confirmPassword(String? value, String password) {
    if (value != password) {
      return 'Password does not match';
    }
    return null;
  }
}
