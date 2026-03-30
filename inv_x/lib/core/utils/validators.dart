class Validators {
  Validators._();

  /// Validates that the field is not empty.
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates email format.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final regex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validates phone number format.
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final regex = RegExp(r'^[+]?[\d\s\-()]{7,15}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  /// Validates that value is a positive number.
  static String? positiveNumber(String? value,
      [String fieldName = 'Value']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final number = num.tryParse(value.trim());
    if (number == null) {
      return 'Enter a valid number';
    }
    if (number <= 0) {
      return '$fieldName must be greater than zero';
    }
    return null;
  }

  /// Validates a price (positive number with up to 2 decimals).
  static String? price(String? value, [String fieldName = 'Price']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final number = double.tryParse(value.trim());
    if (number == null) {
      return 'Enter a valid price';
    }
    if (number < 0) {
      return '$fieldName cannot be negative';
    }
    // Check max 2 decimal places
    final parts = value.trim().split('.');
    if (parts.length == 2 && parts[1].length > 2) {
      return 'Maximum 2 decimal places allowed';
    }
    return null;
  }

  /// Validates that value is a non-negative integer (quantity).
  static String? quantity(String? value, [String fieldName = 'Quantity']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final number = int.tryParse(value.trim());
    if (number == null) {
      return 'Enter a whole number';
    }
    if (number < 0) {
      return '$fieldName cannot be negative';
    }
    return null;
  }

  /// Validates minimum length.
  static String? minLength(String? value, int min,
      [String fieldName = 'This field']) {
    if (value == null || value.trim().length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }

  /// Validates maximum length.
  static String? maxLength(String? value, int max,
      [String fieldName = 'This field']) {
    if (value != null && value.trim().length > max) {
      return '$fieldName must be at most $max characters';
    }
    return null;
  }

  /// Composes multiple validators. Returns the first error, or null.
  static String? Function(String?) compose(
      List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
