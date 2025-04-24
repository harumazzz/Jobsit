import 'package:equatable/equatable.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class InputConverter extends Equatable {
  const InputConverter._();

  @override
  List<Object?> get props => [];

  static String? validateEmail(String? input) {
    return FormBuilderValidators.compose([
      FormBuilderValidators.required(errorText: 'Please enter an email address'),
      FormBuilderValidators.email(errorText: 'Please enter a valid email address'),
    ])(input);
  }

  static String? validatePassword(String? input) {
    return FormBuilderValidators.required(errorText: 'Please enter a password')(input);
  }

  static String? validateConfirmPassword(String? input) {
    return FormBuilderValidators.required(errorText: 'Please enter a confirm password')(input);
  }

  static String? validateName(String? input) {
    return FormBuilderValidators.required(errorText: 'Please enter a name')(input);
  }

  static String? validatePhone(String? input) {
    return FormBuilderValidators.compose([
      FormBuilderValidators.required(errorText: 'Please enter a phone number'),
      FormBuilderValidators.match(RegExp(r'^\d{10}$'), errorText: 'Please enter a valid 10-digit phone number'),
    ])(input);
  }

  static String? validateAddress(String? input) {
    return FormBuilderValidators.required(errorText: 'Please enter an address')(input);
  }

  static String? validateOtp(String? input) {
    return FormBuilderValidators.compose([
      FormBuilderValidators.required(errorText: 'Please enter an OTP'),
      FormBuilderValidators.match(RegExp(r'^\d{6}$'), errorText: 'Please enter a valid 6-digit OTP'),
    ])(input);
  }
}
