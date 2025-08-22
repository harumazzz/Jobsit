import 'package:dart_either/dart_either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobsit/core/error/failures.dart';
import 'package:jobsit/features/auth/domain/entities/user.dart';
import 'package:jobsit/features/auth/domain/repositories/auth_repository.dart';
import 'package:jobsit/features/auth/domain/usecases/register_user.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthRepository mockAuthRepository;
  setUpAll(() {
    mockAuthRepository = MockAuthRepository();
  });
  group('Register User Use Case', () {
    const tEmail = 'abc@gmail.com';
    const tPassword = 'abc123';
    const tFirstName = 'Test';
    const tLastName = 'User';
    const tPhone = '0123456789';
    const tParams = RegisterUserParams(
      email: tEmail,
      firstName: tFirstName,
      lastName: tLastName,
      password: tPassword,
      phone: tPhone,
    );
    const tUser = RegisteredUser(
      id: 1,
      email: tEmail,
      firstName: tFirstName,
      lastName: tLastName,
      phone: tPhone,
      role: Role(id: 1, name: 'USER'),
      status: Status(id: 1, name: 'Active'),
    );
    test('should success when register an user is success', () async {
      when(
        () => mockAuthRepository.registerUser(
          email: tEmail,
          firstName: tFirstName,
          lastName: tLastName,
          password: tPassword,
          phone: tPhone,
        ),
      ).thenAnswer((_) async => const Right(tUser));
      final result = await RegisterUser(mockAuthRepository).call(tParams);
      expect(result, const Right(tUser));
      verify(
        () => mockAuthRepository.registerUser(
          email: tEmail,
          firstName: tFirstName,
          lastName: tLastName,
          password: tPassword,
          phone: tPhone,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
    test('should fail when register an user is failed', () async {
      const tError = 'Email already exists';
      when(
        () => mockAuthRepository.registerUser(
          email: tEmail,
          firstName: tFirstName,
          lastName: tLastName,
          password: tPassword,
          phone: tPhone,
        ),
      ).thenAnswer((_) async => const Left(ServerFailure(tError)));
      final result = await RegisterUser(mockAuthRepository).call(tParams);
      expect(result, const Left(ServerFailure(tError)));
      verify(
        () => mockAuthRepository.registerUser(
          email: tEmail,
          firstName: tFirstName,
          lastName: tLastName,
          password: tPassword,
          phone: tPhone,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
  group('Verify mail Use case', () {
    const tOtp = '123456';
    test('should success when verify mail is successful', () async {
      when(
        () => mockAuthRepository.verifyEmail(otp: tOtp),
      ).thenAnswer((_) async => const Right(Success()));
      final result = await VerifyEmail(mockAuthRepository).call(tOtp);
      expect(result, const Right(Success()));
      verify(() => mockAuthRepository.verifyEmail(otp: tOtp)).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
    test('should fail when verify mail is failed', () async {
      const tError = 'Not available';
      when(
        () => mockAuthRepository.verifyEmail(otp: tOtp),
      ).thenAnswer((_) async => const Left(ServerFailure(tError)));
      final result = await VerifyEmail(mockAuthRepository).call(tOtp);
      expect(result, const Left(ServerFailure(tError)));
      verify(() => mockAuthRepository.verifyEmail(otp: tOtp)).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
  group('Send mail Use case', () {
    const tEmail = 'abc@gmail.com';
    test('should success when send mail is successful', () async {
      when(
        () => mockAuthRepository.sendMail(email: tEmail),
      ).thenAnswer((_) async => const Right(Success()));
      final result = await SendMail(mockAuthRepository).call(tEmail);
      expect(result, const Right(Success()));
      verify(() => mockAuthRepository.sendMail(email: tEmail)).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
    test('should fail when verify mail is failed', () async {
      const tError = 'Not available';
      when(
        () => mockAuthRepository.sendMail(email: tEmail),
      ).thenAnswer((_) async => const Left(ServerFailure(tError)));
      final result = await SendMail(mockAuthRepository).call(tEmail);
      expect(result, const Left(ServerFailure(tError)));
      verify(() => mockAuthRepository.sendMail(email: tEmail)).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
