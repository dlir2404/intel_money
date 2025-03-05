class Validation {
  static String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email is required';
    }

    // More comprehensive email regex
    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,}$').hasMatch(email)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return 'Confirm password is required';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateName(String name) {
    if (name.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }
}