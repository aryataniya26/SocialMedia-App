class Validators {
  // Email Validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  // Mobile Validation
  static String? validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required';
    }

    if (value.length < 10) {
      return 'Mobile number must be at least 10 digits';
    }

    final mobileRegex = RegExp(r'^[0-9]+$');
    if (!mobileRegex.hasMatch(value)) {
      return 'Please enter only numbers';
    }

    return null;
  }
// Password Validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }
// Username Validation
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }

    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Username can only contain letters, numbers and underscore';
    }

    return null;
  }
// Name Validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    return null;
  }
// OTP Validation
  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }
    if (value.length != 4 && value.length != 6) {
      return 'Please enter valid OTP';
    }

    final otpRegex = RegExp(r'^[0-9]+$');
    if (!otpRegex.hasMatch(value)) {
      return 'OTP must contain only numbers';
    }

    return null;
  }
}
