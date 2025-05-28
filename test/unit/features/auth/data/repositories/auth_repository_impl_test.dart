import 'package:dart_either/dart_either.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobsit/core/error/failures.dart';
import 'package:jobsit/core/services/shared_prefs_service.dart';
import 'package:jobsit/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:jobsit/features/auth/data/models/user_model.dart';
import 'package:jobsit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:jobsit/features/auth/domain/entities/user.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthStorageService extends Mock implements IAuthStorageService {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthStorageService mockStorageService;
  setUpAll(() {
    registerFallbackValue(
      const RegisterUserRequest(
        user: UserCreationRequest(
          email: 'test@example.com',
          password: 'password123',
          firstName: 'John',
          lastName: 'Doe',
          phone: '1234567890',
        ),
      ),
    );
    registerFallbackValue(
      const LogInRequest(
        email: 'test@example.com',
        password: 'password123',
      ),
    );
  });

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockStorageService = MockAuthStorageService();
    repository = AuthRepositoryImpl(mockRemoteDataSource, mockStorageService);
  });

  group('AuthRepositoryImpl', () {
    group('registerUser', () {
      const tEmail = 'test@example.com';
      const tPassword = 'password123';
      const tFirstName = 'John';
      const tLastName = 'Doe';
      const tPhone = '1234567890';
      const tUserCreationResponse = UserCreationResponse(
        id: 1,
        email: tEmail,
        firstName: tFirstName,
        lastName: tLastName,
        phone: tPhone,
        gender: true,
        birthDate: '1990-01-01',
        address: '123 Main St',
        city: 'Anytown',
        district: 'Downtown',
        mailReceive: true,
        role: RoleResponse(id: 1, name: 'USER'),
        status: StatusResponse(id: 1, name: 'Active'),
      );

      const tRegisterResponse = RegisteredUserResponse(
        id: 1,
        user: tUserCreationResponse,
        jobInfo: JobInformationResponse(
          positions: [],
          majors: [],
          schedules: [],
          searchable: false,
        ),
      );

      const tRegisteredUser = RegisteredUser(
        id: 1,
        email: tEmail,
        firstName: tFirstName,
        lastName: tLastName,
        phone: tPhone,
        role: Role(id: 1, name: 'USER'),
        status: Status(id: 1, name: 'Active'),
      );

      test('should return user when register is successful', () async {
        // Arrange
        when(() => mockRemoteDataSource.registerUser(any())).thenAnswer(
          (_) async => tRegisterResponse,
        );

        // Act
        final result = await repository.registerUser(
          email: tEmail,
          password: tPassword,
          firstName: tFirstName,
          lastName: tLastName,
          phone: tPhone,
        );

        // Assert
        expect(result, const Right(tRegisteredUser));
        verify(() => mockRemoteDataSource.registerUser(any())).called(1);
      });

      test('should return ServerFailure when DioException occurs', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(),
          message: 'Network error',
        );
        when(() => mockRemoteDataSource.registerUser(any())).thenThrow(
          dioException,
        );

        // Act
        final result = await repository.registerUser(
          email: tEmail,
          password: tPassword,
          firstName: tFirstName,
          lastName: tLastName,
          phone: tPhone,
        );

        // Assert
        expect(result, const Left(ServerFailure('Network error')));
        verify(() => mockRemoteDataSource.registerUser(any())).called(1);
      });

      test('should return ServerFailure when unknown fail', () async {
        // Arrange
        when(
          () => mockRemoteDataSource.registerUser(any()),
        ).thenThrow(Exception('Unknown error'));

        // Act
        final result = await repository.registerUser(
          email: tEmail,
          password: tPassword,
          firstName: tFirstName,
          lastName: tLastName,
          phone: tPhone,
        );

        // Assert
        expect(result, const Left(ServerFailure('Exception: Unknown error')));
        verify(() => mockRemoteDataSource.registerUser(any())).called(1);
      });
    });

    group('loginUser', () {
      const tEmail = 'test@example.com';
      const tPassword = 'password123';
      const tToken = 'auth_token_123';
      const tUserId = 1;
      const tLoginResponse = LogInResponse(
        token: tToken,
        userId: tUserId,
        type: 'Bearer',
        email: tEmail,
        role: 'USER',
      );
      const tGetUserResponse = GetUserResponse(
        id: tUserId,
        user: UserCreationResponse(
          id: tUserId,
          email: tEmail,
          firstName: 'John',
          lastName: 'Doe',
          phone: '1234567890',
          gender: true,
          birthDate: '1990-01-01',
          address: '123 Main St',
          city: 'Anytown',
          district: 'Downtown',
          mailReceive: true,
          role: RoleResponse(id: 1, name: 'USER'),
          status: StatusResponse(id: 1, name: 'Active'),
        ),
        jobInfo: JobInformationResponse(
          university: UniversityResponse(id: 1, name: 'University A'),
          referenceLetter: 'reference.pdf',
          positions: [],
          majors: [MajorResponse(id: 1, name: 'Computer Science')],
          schedules: [],
          desiredJob: 'Software Engineer',
          desiredWorkingProvince: 'Province A',
          searchable: false,
          cv: 'cv.pdf',
        ),
      );

      const tUser = User(
        userId: tUserId,
        role: 'USER',
        userInfo: UserInformation(
          firstName: 'John',
          lastName: 'Doe',
          email: tEmail,
          phone: '1234567890',
          address: '123 Main St',
          city: 'Anytown',
          gender: true,
          mailReceive: true,
          birthDate: '1990-01-01',
          district: 'Downtown',
        ),
        jobInfo: JobInformation(
          cv: 'cv.pdf',
          searchable: false,
          referenceLetter: 'reference.pdf',
          desiredJob: 'Software Engineer',
          desiredWorkingProvince: 'Province A',
          majors: [Major(id: 1, name: 'Computer Science')],
          positions: [],
          schedules: [],
          university: University(id: 1, name: 'University A'),
        ),
      );

      test('should return User when login is successful', () async {
        // Arrange
        when(() => mockRemoteDataSource.loginUser(any())).thenAnswer(
          (_) async => tLoginResponse,
        );
        when(() => mockStorageService.saveToken(tToken)).thenAnswer(
          (_) async {},
        );
        when(() => mockStorageService.saveUserId(tUserId)).thenAnswer(
          (_) async {},
        );
        when(() => mockRemoteDataSource.getUser(tUserId)).thenAnswer(
          (_) async => tGetUserResponse,
        );

        // Act
        final result = await repository.loginUser(
          email: tEmail,
          password: tPassword,
        );

        // Assert
        expect(result, const Right(tUser));
        verify(() => mockRemoteDataSource.loginUser(any())).called(1);
        verify(() => mockStorageService.saveToken(tToken)).called(1);
        verify(() => mockStorageService.saveUserId(tUserId)).called(1);
        verify(() => mockRemoteDataSource.getUser(tUserId)).called(1);
      });

      test('should return CacheFailure when failed', () async {
        // Arrange
        when(() => mockRemoteDataSource.loginUser(any())).thenAnswer(
          (_) async => tLoginResponse,
        );
        when(
          () => mockStorageService.saveToken(tToken),
        ).thenThrow(
          PlatformException(
            code: 'STORAGE_ERROR',
            message: 'Storage failed',
          ),
        );

        // Act
        final result = await repository.loginUser(
          email: tEmail,
          password: tPassword,
        );

        // Assert
        expect(result, const Left(CacheFailure('Storage failed')));
        verify(() => mockRemoteDataSource.loginUser(any())).called(1);
        verify(() => mockStorageService.saveToken(tToken)).called(1);
      });

      test('should return ServerFailure when DioException occurs', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(),
          message: 'Login failed',
        );
        when(
          () => mockRemoteDataSource.loginUser(any()),
        ).thenThrow(dioException);

        // Act
        final result = await repository.loginUser(
          email: tEmail,
          password: tPassword,
        );

        // Assert
        expect(result, const Left(ServerFailure('Login failed')));
        verify(() => mockRemoteDataSource.loginUser(any())).called(1);
      });

      test('should return ServerFailure when failed', () async {
        // Arrange
        when(
          () => mockRemoteDataSource.loginUser(any()),
        ).thenThrow(Exception('Unknown error'));

        // Act
        final result = await repository.loginUser(
          email: tEmail,
          password: tPassword,
        );

        // Assert
        expect(result, const Left(ServerFailure('Exception: Unknown error')));
        verify(() => mockRemoteDataSource.loginUser(any())).called(1);
      });
    });

    group('sendMail', () {
      const tEmail = 'test@example.com';

      test('should return Success when sendMail is successful', () async {
        // Arrange
        when(
          () => mockRemoteDataSource.sendMail(tEmail),
        ).thenAnswer((_) async => const SendMailResponse(message: 'Mail sent'));

        // Act
        final result = await repository.sendMail(email: tEmail);

        // Assert
        expect(result, const Right(Success()));
        verify(() => mockRemoteDataSource.sendMail(tEmail)).called(1);
      });

      test('should return ServerFailure when DioException occurs', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(),
          message: 'Send mail failed',
        );
        when(
          () => mockRemoteDataSource.sendMail(tEmail),
        ).thenThrow(dioException);

        // Act
        final result = await repository.sendMail(email: tEmail);

        // Assert
        expect(result, const Left(ServerFailure('Send mail failed')));
        verify(() => mockRemoteDataSource.sendMail(tEmail)).called(1);
      });

      test('should return ServerFailure when failed', () async {
        // Arrange
        when(
          () => mockRemoteDataSource.sendMail(tEmail),
        ).thenThrow(Exception('Unknown error'));

        // Act
        final result = await repository.sendMail(email: tEmail);

        // Assert
        expect(result, const Left(ServerFailure('Exception: Unknown error')));
        verify(() => mockRemoteDataSource.sendMail(tEmail)).called(1);
      });
    });

    group('verifyEmail', () {
      const tOtp = '123456';

      test('should return Success when verifyEmail is successful', () async {
        // Arrange
        when(
          () => mockRemoteDataSource.verifyEmail(tOtp),
        ).thenAnswer(
          (_) async => const VerifyMailResponse(message: 'Email verified'),
        );

        // Act
        final result = await repository.verifyEmail(otp: tOtp);

        // Assert
        expect(result, const Right(Success()));
        verify(() => mockRemoteDataSource.verifyEmail(tOtp)).called(1);
      });

      test('should return ServerFailure when DioException occurs', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(),
          message: 'OTP verification failed',
        );
        when(
          () => mockRemoteDataSource.verifyEmail(tOtp),
        ).thenThrow(dioException);

        // Act
        final result = await repository.verifyEmail(otp: tOtp);

        // Assert
        expect(result, const Left(ServerFailure('OTP verification failed')));
        verify(() => mockRemoteDataSource.verifyEmail(tOtp)).called(1);
      });
    });

    group('checkEmail', () {
      const tEmail = 'test@example.com';
      const tMessage = 'Email is available';

      const tCheckEmailResponse = CheckMailResponse(message: tMessage);

      test('should return message when checkEmail is successful', () async {
        // Arrange
        when(() => mockRemoteDataSource.checkEmail(tEmail)).thenAnswer(
          (_) async => tCheckEmailResponse,
        );

        // Act
        final result = await repository.checkEmail(email: tEmail);

        // Assert
        expect(result, const Right(tMessage));
        verify(() => mockRemoteDataSource.checkEmail(tEmail)).called(1);
      });

      test('should return ServerFailure when DioException occurs', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(),
          message: 'Check email failed',
        );
        when(
          () => mockRemoteDataSource.checkEmail(tEmail),
        ).thenThrow(dioException);

        // Act
        final result = await repository.checkEmail(email: tEmail);

        // Assert
        expect(result, const Left(ServerFailure('Check email failed')));
        verify(() => mockRemoteDataSource.checkEmail(tEmail)).called(1);
      });
    });

    group('forgotPassword', () {
      const tEmail = 'test@example.com';

      test('should return Success when forgotPassword is successful', () async {
        // Arrange
        when(
          () => mockRemoteDataSource.forgotPassword(tEmail),
        ).thenAnswer(
          (_) async => const ForgotPasswordResponse(
            message: 'Password reset email sent',
          ),
        );

        // Act
        final result = await repository.forgotPassword(email: tEmail);

        // Assert
        expect(result, const Right(Success()));
        verify(() => mockRemoteDataSource.forgotPassword(tEmail)).called(1);
      });

      test('should return ServerFailure when DioException occurs', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(),
          message: 'Forgot password failed',
        );
        when(
          () => mockRemoteDataSource.forgotPassword(tEmail),
        ).thenThrow(dioException);

        // Act
        final result = await repository.forgotPassword(email: tEmail);

        // Assert
        expect(result, const Left(ServerFailure('Forgot password failed')));
        verify(() => mockRemoteDataSource.forgotPassword(tEmail)).called(1);
      });
    });
  });
}
