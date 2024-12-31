class InputValidator {
  static String? validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return 'Username cannot be empty';
    } else if (!RegExp(r'^[A-Za-z]+(?: [A-Za-z]+)*$').hasMatch(username)) {
      return 'Username must consists letters and spaces';
    }
    return null;
  }

  /// Validate email
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email cannot be empty';
    } else if (!RegExp(r'^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validate password (minimum 8 characters, at least one letter and one number)
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password cannot be empty';
    } else if (password.length < 8) {
      return 'Password must be at least 8 characters ';
    }
    return null;
  }

  /// Confirm password matches
  static String? confirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    } else if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validate mobile number (10 digits, allows optional country code)
  static String? validateMobile(String? mobile) {
    if (mobile == null || mobile.isEmpty) {
      return 'Mobile number cannot be empty';
    } else if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(mobile)) {
      return 'Enter a valid mobile number';
    }
    return null;
  }
}
