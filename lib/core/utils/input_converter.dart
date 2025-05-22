import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../i18n/strings.g.dart';

/// A utility class for input validation.
///
/// Provides static methods to validate common input fields like email,
/// password, name, phone, etc., using `FormBuilderValidators` and custom
/// validation logic. This class is not meant to be instantiated.
class InputConverter extends Equatable {
  /// Private constructor to prevent instantiation.
  const InputConverter._();

  @override
  List<Object?> get props => [];

  /// Validates an email [input] string.
  ///
  /// Uses a combination of `FormBuilderValidators` and custom checks for
  /// length, format (e.g., presence of '@', no '..', no leading/trailing dots,
  /// local part not all numbers).
  /// Returns an error message string if validation fails, otherwise null.
  /// [context] is used for localized error messages.
  static String? validateEmail(
    final String? input,
    final BuildContext context,
  ) => FormBuilderValidators.compose([
    FormBuilderValidators.required(
      errorText: context.t.validation.required.email,
    ),
    FormBuilderValidators.minLength(
      6,
      errorText: context.t.validation.length.email.min,
    ),
    FormBuilderValidators.maxLength(
      256,
      errorText: context.t.validation.length.email.max,
    ),
    (final String? value) {
      if (value == null || value.isEmpty) {
        return null;
      }
      if (RegExp(r'^[0-9]+$').hasMatch(value.split('@')[0])) {
        return context.t.validation.format.email;
      }
      final index = value.indexOf('@');
      if (index == -1 || index != value.lastIndexOf('@')) {
        return context.t.validation.format.email;
      }
      if (value.contains('..')) {
        return context.t.validation.format.email;
      }
      if (value.startsWith('.') || value.endsWith('.')) {
        return context.t.validation.format.email;
      }
      final parts = value.split('@');
      if (parts.length == 2) {
        if (parts[0].startsWith('.') || parts[0].endsWith('.')) {
          return context.t.validation.format.email;
        }
        if (parts[1].startsWith('.') || parts[1].endsWith('.')) {
          return context.t.validation.format.email;
        }
      }
      if (value.endsWith('@')) {
        return context.t.validation.format.email;
      }
      if (value.contains('-@') || value.contains('@-')) {
        return context.t.validation.format.email;
      }
      return FormBuilderValidators.email(
        errorText: context.t.validation.format.email,
      )(value);
    },
  ])(input);

  /// Validates a password [input] string.
  ///
  /// Checks for required field, min/max length, and presence of at least
  /// one uppercase letter and one number.
  /// Returns an error message string if validation fails, otherwise null.
  /// [context] is used for localized error messages.
  static String? validatePassword(
    final String? input,
    final BuildContext context,
  ) => FormBuilderValidators.compose([
    FormBuilderValidators.required(
      errorText: context.t.validation.required.password,
    ),
    FormBuilderValidators.minLength(
      6,
      errorText: context.t.validation.length.password,
    ),
    FormBuilderValidators.maxLength(
      32,
      errorText: context.t.validation.length.password,
    ),
    (final String? value) {
      if (value == null || value.isEmpty) {
        return null;
      }
      if (!RegExp(r'[A-Z]').hasMatch(value)) {
        return context.t.validation.format.password.uppercase;
      }
      if (!RegExp(r'[0-9]').hasMatch(value)) {
        return context.t.validation.format.password.number;
      }
      return null;
    },
  ])(input);

  /// Validates a confirm password [input] string against a [password].
  ///
  /// Checks for required field, min/max length, presence of at least
  /// one uppercase letter, one number, and if it matches the [password].
  /// Returns an error message string if validation fails, otherwise null.
  /// [context] is used for localized error messages.
  static String? validateConfirmPassword(
    final String? input,
    final BuildContext context,
    final String? password,
  ) => FormBuilderValidators.compose([
    FormBuilderValidators.required(
      errorText: context.t.validation.required.confirmPassword,
    ),
    FormBuilderValidators.minLength(
      6,
      errorText: context.t.validation.length.password,
    ),
    FormBuilderValidators.maxLength(
      32,
      errorText: context.t.validation.length.password,
    ),
    (final String? value) {
      final isValue = value == null || value.isEmpty;
      final isPassword = password == null || password.isEmpty;
      if (isValue || isPassword) {
        return null;
      }
      if (!RegExp(r'[A-Z]').hasMatch(value)) {
        return context.t.validation.format.password.uppercase;
      }
      if (!RegExp(r'[0-9]').hasMatch(value)) {
        return context.t.validation.format.password.number;
      }
      if (value != password) {
        return context.t.validation.format.passwordMismatch;
      }
      return null;
    },
  ])(input);

  /// Validates a first name [input] string.
  ///
  /// Checks for required field, min/max length, and no trailing spaces.
  /// Returns an error message string if validation fails, otherwise null.
  /// [context] is used for localized error messages.
  static String? validateFirstName(
    final String? input,
    final BuildContext context,
  ) => FormBuilderValidators.compose([
    FormBuilderValidators.required(
      errorText: context.t.validation.required.firstName,
    ),
    FormBuilderValidators.minLength(
      2,
      errorText: context.t.validation.length.firstName,
    ),
    FormBuilderValidators.maxLength(
      32,
      errorText: context.t.validation.length.firstName,
    ),
    FormBuilderValidators.match(RegExp(r'^(?!.*\s$)'), errorText: context.t.validation.format.noTrailingSpace),
  ])(input);

  /// Validates a last name [input] string.
  ///
  /// Checks for required field, min/max length, and no trailing spaces.
  /// Returns an error message string if validation fails, otherwise null.
  /// [context] is used for localized error messages.
  static String? validateLastName(
    final String? input,
    final BuildContext context,
  ) => FormBuilderValidators.compose([
    FormBuilderValidators.required(
      errorText: context.t.validation.required.lastName,
    ),
    FormBuilderValidators.minLength(
      2,
      errorText: context.t.validation.length.lastName,
    ),
    FormBuilderValidators.maxLength(
      32,
      errorText: context.t.validation.length.lastName,
    ),
    FormBuilderValidators.match(RegExp(r'^(?!.*\s$)'), errorText: context.t.validation.format.noTrailingSpace),
  ])(input);

  /// Validates a phone number [input] string.
  ///
  /// Checks for required field and min/max length.
  /// Returns an error message string if validation fails, otherwise null.
  /// [context] is used for localized error messages.
  static String? validatePhone(
    final String? input,
    final BuildContext context,
  ) => FormBuilderValidators.compose([
    FormBuilderValidators.required(
      errorText: context.t.validation.required.phone,
    ),
    FormBuilderValidators.minLength(
      8,
      errorText: context.t.validation.length.phone,
    ),
    FormBuilderValidators.maxLength(
      13,
      errorText: context.t.validation.length.phone,
    ),
    (final String? value) {
      if (value == null || value.isEmpty) {
        return null;
      }
      return null;
    },
  ])(input);

  /// Validates an address [input] string.
  ///
  /// Checks for min/max length, disallows certain special characters
  /// ('_', '-', '.', '/'), and no trailing spaces.
  /// Returns an error message string if validation fails, otherwise null.
  /// [context] is used for localized error messages.
  static String? validateAddress(
    final String? input,
    final BuildContext context,
  ) => FormBuilderValidators.compose([
    FormBuilderValidators.minLength(
      8,
      errorText: context.t.validation.length.address,
    ),
    FormBuilderValidators.maxLength(
      255,
      errorText: context.t.validation.length.address,
    ),
    (final String? value) {
      if (value == null || value.isEmpty) {
        return null;
      }
      if (value.contains('_') || value.contains('-') || value.contains('.') || value.contains('/')) {
        return context.t.validation.format.address;
      }
      if (value.endsWith(' ')) {
        return context.t.validation.format.noTrailingSpace;
      }
      return null;
    },
  ])(input);

  /// Validates an OTP (One-Time Password) [input] string.
  ///
  /// Checks for required field and if it's a 6-digit number.
  /// Returns an error message string if validation fails, otherwise null.
  /// Error messages are not localized in this specific validator.
  static String? validateOtp(
    final String? input,
  ) => FormBuilderValidators.compose([
    FormBuilderValidators.required(errorText: 'Please enter an OTP'),
    FormBuilderValidators.match(RegExp(r'^\d{6}$'), errorText: 'Please enter a valid 6-digit OTP'),
  ])(input);
}
