import 'package:equatable/equatable.dart';

class InputConverter extends Equatable {
  const InputConverter._();

  @override
  List<Object?> get props => [];

  static String? validateEmail(String? input) {
    const emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    if (input == null || input.isEmpty) {
      return 'Please enter an email address';
    } else if (!RegExp(emailRegex).hasMatch(input)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? input) {
    if (input == null || input.isEmpty) {
      return 'Please enter a password';
    }
    return null;
  }

  static String? validateConfirmPassword(String? input) {
    if (input == null || input.isEmpty) {
      return 'Please enter a confirm password';
    }
    return null;
  }

  static String? validateName(String? input) {
    if (input == null || input.isEmpty) {
      return 'Please enter a name';
    }
    return null;
  }

  static String? validatePhone(String? input) {
    if (input == null || input.isEmpty) {
      return 'Please enter a phone number';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(input)) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }

  static String? validateAddress(String? input) {
    if (input == null || input.isEmpty) {
      return 'Please enter an address';
    }
    return null;
  }
}
