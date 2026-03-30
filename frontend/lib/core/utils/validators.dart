/// Form validation utilities
class Validators {
  /// Validate email format
  static String? email(String? value) {
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

  /// Validate required field
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Validate minimum length
  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    
    if (value.length < min) {
      return '${fieldName ?? 'This field'} must be at least $min characters';
    }
    
    return null;
  }

  /// Validate maximum length
  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value != null && value.length > max) {
      return '${fieldName ?? 'This field'} must be at most $max characters';
    }
    return null;
  }

  /// Validate password
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }

  /// Validate strong password
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    
    return null;
  }

  /// Validate password confirmation
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  /// Validate phone number
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
    
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  /// Validate number
  static String? number(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    
    return null;
  }

  /// Validate positive number
  static String? positiveNumber(String? value, {String? fieldName}) {
    final numberError = number(value, fieldName: fieldName);
    if (numberError != null) return numberError;
    
    final num = double.parse(value!);
    if (num <= 0) {
      return '${fieldName ?? 'This field'} must be greater than 0';
    }
    
    return null;
  }

  /// Validate number range
  static String? numberRange(
    String? value,
    double min,
    double max, {
    String? fieldName,
  }) {
    final numberError = number(value, fieldName: fieldName);
    if (numberError != null) return numberError;
    
    final num = double.parse(value!);
    if (num < min || num > max) {
      return '${fieldName ?? 'This field'} must be between $min and $max';
    }
    
    return null;
  }

  /// Validate URL
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }

  /// Combine multiple validators
  static FormFieldValidator<String> combine(
    List<FormFieldValidator<String>> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}

typedef FormFieldValidator<T> = String? Function(T? value);

// Backwards-compatible alias expected by older code
class AppValidators {
  static String? email(String? value) => Validators.email(value);
  static String? required(String? value, {String? fieldName}) => Validators.required(value, fieldName: fieldName);
  static String? minLength(String? value, int min, {String? fieldName}) => Validators.minLength(value, min, fieldName: fieldName);
  static String? maxLength(String? value, int max, {String? fieldName}) => Validators.maxLength(value, max, fieldName: fieldName);
  static String? password(String? value) => Validators.password(value);
  static String? strongPassword(String? value) => Validators.strongPassword(value);
  static String? confirmPassword(String? value, String? password) => Validators.confirmPassword(value, password);
  static String? phone(String? value) => Validators.phone(value);
  static String? number(String? value, {String? fieldName}) => Validators.number(value, fieldName: fieldName);
  static String? positiveNumber(String? value, {String? fieldName}) => Validators.positiveNumber(value, fieldName: fieldName);
  static String? numberRange(String? value, double min, double max, {String? fieldName}) => Validators.numberRange(value, min, max, fieldName: fieldName);
  static String? url(String? value) => Validators.url(value);
  static FormFieldValidator<String> combine(List<FormFieldValidator<String>> validators) => Validators.combine(validators);
}

