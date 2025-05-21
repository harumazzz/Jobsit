import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../i18n/strings.g.dart';

class InputConverter extends Equatable {
  const InputConverter._();

  @override
  List<Object?> get props => [];

  static String? validateEmail(String? input, BuildContext context) {
    return FormBuilderValidators.compose([
      FormBuilderValidators.required(errorText: context.t.validation.required.email),
      FormBuilderValidators.minLength(6, errorText: context.t.validation.length.email.min),
      FormBuilderValidators.maxLength(256, errorText: context.t.validation.length.email.max),
      (String? value) {
        if (value == null || value.isEmpty) {
          return null;
        }
        if (RegExp(r'^[0-9]+$').hasMatch(value.split('@')[0])) {
          return context.t.validation.format.email;
        }
        if (!value.contains('@') || value.indexOf('@') != value.lastIndexOf('@')) {
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
        return FormBuilderValidators.email(errorText: context.t.validation.format.email)(value);
      },
    ])(input);
  }

  static String? validatePassword(String? input, BuildContext context) {
    return FormBuilderValidators.compose([
      FormBuilderValidators.required(errorText: context.t.validation.required.password),
      FormBuilderValidators.minLength(6, errorText: context.t.validation.length.password),
      FormBuilderValidators.maxLength(32, errorText: context.t.validation.length.password),
      (String? value) {
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
  }

  static String? validateConfirmPassword(String? input, BuildContext context, String? password) {
    return FormBuilderValidators.compose([
      FormBuilderValidators.required(errorText: context.t.validation.required.confirmPassword),
      FormBuilderValidators.minLength(6, errorText: context.t.validation.length.password),
      FormBuilderValidators.maxLength(32, errorText: context.t.validation.length.password),
      (String? value) {
        if (value == null || value.isEmpty || password == null || password.isEmpty) {
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
  }

  static String? validateFirstName(String? input, BuildContext context) {
    return FormBuilderValidators.compose([
      FormBuilderValidators.required(errorText: context.t.validation.required.firstName),
      FormBuilderValidators.minLength(2, errorText: context.t.validation.length.firstName),
      FormBuilderValidators.maxLength(32, errorText: context.t.validation.length.firstName),
      FormBuilderValidators.match(RegExp(r'^(?!.*\s$)'), errorText: context.t.validation.format.noTrailingSpace),
    ])(input);
  }

  static String? validateLastName(String? input, BuildContext context) {
    return FormBuilderValidators.compose([
      FormBuilderValidators.required(errorText: context.t.validation.required.lastName),
      FormBuilderValidators.minLength(2, errorText: context.t.validation.length.lastName),
      FormBuilderValidators.maxLength(32, errorText: context.t.validation.length.lastName),
      FormBuilderValidators.match(RegExp(r'^(?!.*\s$)'), errorText: context.t.validation.format.noTrailingSpace),
    ])(input);
  }

  static String? validatePhone(String? input, BuildContext context) {
    return FormBuilderValidators.compose([
      FormBuilderValidators.required(errorText: context.t.validation.required.phone),
      FormBuilderValidators.minLength(8, errorText: context.t.validation.length.phone),
      FormBuilderValidators.maxLength(13, errorText: context.t.validation.length.phone),
      (String? value) {
        if (value == null || value.isEmpty) {
          return null;
        }
        return null;
      },
    ])(input);
  }

  static String? validateAddress(String? input, BuildContext context) {
    return FormBuilderValidators.compose([
      FormBuilderValidators.minLength(8, errorText: context.t.validation.length.address),
      FormBuilderValidators.maxLength(255, errorText: context.t.validation.length.address),
      (String? value) {
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
  }

  static String? validateOtp(String? input) {
    return FormBuilderValidators.compose([
      FormBuilderValidators.required(errorText: 'Please enter an OTP'),
      FormBuilderValidators.match(RegExp(r'^\d{6}$'), errorText: 'Please enter a valid 6-digit OTP'),
    ])(input);
  }
}
