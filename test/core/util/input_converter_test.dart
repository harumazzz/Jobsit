import 'package:flutter_test/flutter_test.dart';
import 'package:jobsit/core/utils/input_converter.dart';

void main() {
  group('InputConverter', () {
    group('Validate Email', () {
      test('should return null for a valid email address', () {
        const validEmail = 'abc@test.com';
        const validEmail2 = 'abc-123@onemicrosoft.com.vn';
        final result1 = InputConverter.validateEmail(validEmail);
        final result2 = InputConverter.validateEmail(validEmail2);
        expect(result1, isNull);
        expect(result2, isNull);
      });
      test('should return error message for null input', () {
        const String? nullInput = null;
        final result = InputConverter.validateEmail(nullInput);
        expect(result, equals('Please enter an email address'));
      });
      test('should return error message for empty input', () {
        const emptyInput = '';
        final result = InputConverter.validateEmail(emptyInput);
        expect(result, equals('Please enter an email address'));
      });
      test('should return error message for invalid email format', () {
        const invalidEmail1 = 'test';
        const invalidEmail2 = 'test@';
        const invalidEmail3 = 'test@domain';
        const invalidEmail4 = '@domain.com';
        const invalidEmail5 = 'test@domain.';
        final result1 = InputConverter.validateEmail(invalidEmail1);
        final result2 = InputConverter.validateEmail(invalidEmail2);
        final result3 = InputConverter.validateEmail(invalidEmail3);
        final result4 = InputConverter.validateEmail(invalidEmail4);
        final result5 = InputConverter.validateEmail(invalidEmail5);
        const expectedError = 'Please enter a valid email address';
        expect(result1, equals(expectedError));
        expect(result2, equals(expectedError));
        expect(result3, equals(expectedError));
        expect(result4, equals(expectedError));
        expect(result5, equals(expectedError));
      });
    });
    group('Validate Password', () {
      test('should return null for a non-empty password', () {
        const nonEmptyPassword = 'password123';
        final result = InputConverter.validatePassword(nonEmptyPassword);
        expect(result, isNull);
      });
      test('should return error message for null input', () {
        const String? nullInput = null;
        final result = InputConverter.validatePassword(nullInput);
        expect(result, equals('Please enter a password'));
      });
      test('should return error message for empty input', () {
        const emptyInput = '';
        final result = InputConverter.validatePassword(emptyInput);
        expect(result, equals('Please enter a password'));
      });
    });
    group('Validate Name', () {
      test('should return null for a non-empty name', () {
        const nonEmptyName = 'Nguyen Van A';
        final result = InputConverter.validateName(nonEmptyName);
        expect(result, isNull);
      });
      test('should return error message for null input', () {
        const String? nullInput = null;
        final result = InputConverter.validateName(nullInput);
        expect(result, equals('Please enter a name'));
      });
      test('should return error message for empty input', () {
        const emptyInput = '';
        final result = InputConverter.validateName(emptyInput);
        expect(result, equals('Please enter a name'));
      });
    });
    group('Validate Phone', () {
      test('should return null for a valid 10-digit phone number', () {
        const validPhone = '1234567890';
        final result = InputConverter.validatePhone(validPhone);
        expect(result, isNull);
      });
      test('should return error message for null input', () {
        const String? nullInput = null;
        final result = InputConverter.validatePhone(nullInput);
        expect(result, equals('Please enter a phone number'));
      });
      test('should return error message for empty input', () {
        const emptyInput = '';
        final result = InputConverter.validatePhone(emptyInput);
        expect(result, equals('Please enter a phone number'));
      });
      test('should return error message for non-10-digit numbers', () {
        const shortPhone = '12345';
        const longPhone = '12345678901';
        const nonDigitPhone = '12345abcde';
        final result1 = InputConverter.validatePhone(shortPhone);
        final result2 = InputConverter.validatePhone(longPhone);
        final result3 = InputConverter.validatePhone(nonDigitPhone);
        const expectedError = 'Please enter a valid 10-digit phone number';
        expect(result1, equals(expectedError));
        expect(result2, equals(expectedError));
        expect(result3, equals(expectedError));
      });
    });
    group('Validate Address', () {
      test('should return null for a non-empty address', () {
        const nonEmptyAddress = '123 Main St, Anytown';
        final result = InputConverter.validateAddress(nonEmptyAddress);
        expect(result, isNull);
      });
      test('should return error message for null input', () {
        const String? nullInput = null;
        final result = InputConverter.validateAddress(nullInput);
        expect(result, equals('Please enter an address'));
      });
      test('should return error message for empty input', () {
        const emptyInput = '';
        final result = InputConverter.validateAddress(emptyInput);
        expect(result, equals('Please enter an address'));
      });
    });
  });
}
