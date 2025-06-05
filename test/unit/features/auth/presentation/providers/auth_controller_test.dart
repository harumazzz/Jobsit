import 'package:dart_either/dart_either.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobsit/core/error/exceptions.dart';
import 'package:jobsit/core/error/failures.dart';
import 'package:jobsit/core/usecases/usecase.dart';
import 'package:jobsit/features/auth/domain/entities/user.dart';
import 'package:jobsit/features/auth/domain/usecases/login_user.dart';
import 'package:jobsit/features/auth/domain/usecases/register_user.dart';
import 'package:jobsit/features/auth/presentation/providers/auth_provider.dart';
import 'package:mocktail/mocktail.dart';

// Mock use cases
class MockRegisterUser extends Mock implements RegisterUser {}

class MockLoginUser extends Mock implements LoginUser {}

class MockSendMail extends Mock implements SendMail {}

class MockVerifyEmail extends Mock implements VerifyEmail {}

class MockForgotPassword extends Mock implements ForgotPassword {}

class MockVerifyOtp extends Mock implements VerifyOtp {}

class MockLogOutUseCase extends Mock implements LogOutUseCase {}

class MockResetPassword extends Mock implements ResetPassword {}

class MockCheckEmail extends Mock implements CheckEmail {}

void main() {
  group('AuthController Riverpod Tests', () {
    late ProviderContainer container;
    late MockRegisterUser mockRegisterUser;
    late MockLoginUser mockLoginUser;
    late MockSendMail mockSendMail;
    late MockVerifyEmail mockVerifyEmail;
    late MockForgotPassword mockForgotPassword;
    late MockVerifyOtp mockVerifyOtp;
    late MockLogOutUseCase mockLogOutUseCase;
    late MockResetPassword mockResetPassword;
    late MockCheckEmail mockCheckEmail;

    setUpAll(() {
      // Register fallback values for Mocktail any() matcher
      registerFallbackValue(
        const RegisterUserParams(
          email: 'test@example.com',
          password: 'password123',
          firstName: 'John',
          lastName: 'Doe',
          phone: '1234567890',
        ),
      );

      registerFallbackValue(
        const LoginUserParams(
          email: 'test@example.com',
          password: 'password123',
        ),
      );

      registerFallbackValue(
        const ResetPasswordParams(
          resetToken: 'reset_token_123',
          password: 'newPassword123',
          confirmPassword: 'newPassword123',
        ),
      );

      registerFallbackValue(
        const ChangePasswordParams(
          oldPassword: 'oldPassword123',
          newPassword: 'newPassword123',
          confirmPassword: 'newPassword123',
        ),
      );

      registerFallbackValue(
        const UpdateUserInfoParams(
          firstName: 'John',
          lastName: 'Doe',
          birthDay: '1990-01-01',
          phone: '1234567890',
          gender: 1,
          location: '123 Main St',
          city: 'Anytown',
          district: 'Downtown',
          university: University(id: 1, name: 'University A'),
        ),
      );

      registerFallbackValue(
        const UpdateJobInfoParams(
          desiredJob: 'Software Engineer',
          desiredWorkingProvince: 'Province A',
          referenceLetter: 'reference letter',
          positions: [],
          majors: [],
          schedules: [],
        ),
      );

      registerFallbackValue(const NoParams());

      // Register String fallback for email, OTP, and other string parameters
      registerFallbackValue('fallback_string');
    });

    setUp(() {
      mockRegisterUser = MockRegisterUser();
      mockLoginUser = MockLoginUser();
      mockSendMail = MockSendMail();
      mockVerifyEmail = MockVerifyEmail();
      mockForgotPassword = MockForgotPassword();
      mockVerifyOtp = MockVerifyOtp();
      mockLogOutUseCase = MockLogOutUseCase();
      mockResetPassword = MockResetPassword();
      mockCheckEmail = MockCheckEmail();

      container = ProviderContainer(
        overrides: [
          registerUserProvider.overrideWithValue(mockRegisterUser),
          loginUserProvider.overrideWithValue(mockLoginUser),
          sendMailProvider.overrideWithValue(mockSendMail),
          verifyEmailProvider.overrideWithValue(mockVerifyEmail),
          forgotPasswordProvider.overrideWithValue(mockForgotPassword),
          verifyOtpProvider.overrideWithValue(mockVerifyOtp),
          logOutUseCaseProvider.overrideWithValue(mockLogOutUseCase),
          resetPasswordProvider.overrideWithValue(mockResetPassword),
          checkEmailProvider.overrideWithValue(mockCheckEmail),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Initial State', () {
      test('should start with initial state', () {
        final state = container.read(authControllerProvider);
        expect(state, const AuthState.initial());
      });
    });

    group('Register User', () {
      const tEmail = 'test@example.com';
      const tPassword = 'password123';
      const tFirstName = 'John';
      const tLastName = 'Doe';
      const tPhone = '1234567890';
      const tRegisteredUser = RegisteredUser(
        id: 1,
        email: tEmail,
        firstName: tFirstName,
        lastName: tLastName,
        phone: tPhone,
        role: Role(id: 1, name: 'USER'),
        status: Status(id: 1, name: 'Active'),
      );

      test('should emit when registration is successful', () async {
        // Arrange
        when(() => mockRegisterUser.call(any())).thenAnswer(
          (_) async => const Right(tRegisteredUser),
        );

        final controller = container.read(authControllerProvider.notifier);
        final states = <AuthState>[];

        // Listen to state changes
        final subscription = container.listen(
          authControllerProvider,
          (final previous, final next) => states.add(next),
        );

        // Act
        await controller.register(
          email: tEmail,
          password: tPassword,
          firstName: tFirstName,
          lastName: tLastName,
          phone: tPhone,
        );

        // Assert
        expect(states, [
          const AuthState.loading(),
          const AuthState.registered(tRegisteredUser),
        ]);

        verify(() => mockRegisterUser.call(any())).called(1);
        subscription.close();
      });

      test('should emit when registration fails', () async {
        // Arrange
        const tError = 'Email already exists';
        when(() => mockRegisterUser.call(any())).thenAnswer(
          (_) async => const Left(ServerFailure(tError)),
        );

        final controller = container.read(authControllerProvider.notifier);
        final states = <AuthState>[];

        final subscription = container.listen(
          authControllerProvider,
          (final previous, final next) => states.add(next),
        );

        // Act
        await controller.register(
          email: tEmail,
          password: tPassword,
          firstName: tFirstName,
          lastName: tLastName,
          phone: tPhone,
        );

        // Assert
        expect(states, [
          const AuthState.loading(),
          const AuthState.error(tError),
        ]);

        verify(() => mockRegisterUser.call(any())).called(1);
        subscription.close();
      });

      test('should emit when exception is thrown', () async {
        // Arrange
        const tError = 'Server error';
        when(() => mockRegisterUser.call(any())).thenThrow(
          const ServerException(tError),
        );

        final controller = container.read(authControllerProvider.notifier);
        final states = <AuthState>[];

        final subscription = container.listen(
          authControllerProvider,
          (final previous, final next) => states.add(next),
        );

        // Act
        await controller.register(
          email: tEmail,
          password: tPassword,
          firstName: tFirstName,
          lastName: tLastName,
          phone: tPhone,
        );

        // Assert
        expect(states, [
          const AuthState.loading(),
          const AuthState.error(tError),
        ]);

        verify(() => mockRegisterUser.call(any())).called(1);
        subscription.close();
      });
    });

    group('Login User', () {
      const tEmail = 'test@example.com';
      const tPassword = 'password123';
      const tUser = User(
        userId: 1,
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

      test('should emit when login is successful', () async {
        // Arrange
        when(() => mockLoginUser.call(any())).thenAnswer(
          (_) async => const Right(tUser),
        );

        final controller = container.read(authControllerProvider.notifier);
        final states = <AuthState>[];

        final subscription = container.listen(
          authControllerProvider,
          (final previous, final next) => states.add(next),
        );

        // Act
        await controller.login(email: tEmail, password: tPassword);

        // Assert
        expect(states, [
          const AuthState.loading(),
          const AuthState.authorized(tUser),
        ]);

        verify(() => mockLoginUser.call(any())).called(1);
        subscription.close();
      });

      test('should emit when login fails', () async {
        // Arrange
        const tError = 'Invalid credentials';
        when(() => mockLoginUser.call(any())).thenAnswer(
          (_) async => const Left(ServerFailure(tError)),
        );

        final controller = container.read(authControllerProvider.notifier);
        final states = <AuthState>[];

        final subscription = container.listen(
          authControllerProvider,
          (final previous, final next) => states.add(next),
        );

        // Act
        await controller.login(email: tEmail, password: tPassword);

        // Assert
        expect(states, [
          const AuthState.loading(),
          const AuthState.error(tError),
        ]);

        verify(() => mockLoginUser.call(any())).called(1);
        subscription.close();
      });
    });

    group('Send Mail', () {
      const tEmail = 'test@example.com';

      test('should emit when send mail is successful', () async {
        // Arrange
        when(() => mockSendMail.call(any())).thenAnswer(
          (_) async => const Right(Success()),
        );

        final controller = container.read(authControllerProvider.notifier);
        final states = <AuthState>[];

        final subscription = container.listen(
          authControllerProvider,
          (final previous, final next) => states.add(next),
        );

        // Act
        await controller.sendMail(email: tEmail);

        // Assert
        expect(states, [
          const AuthState.loading(),
          const AuthState.sendedMail(),
        ]);

        verify(() => mockSendMail.call(tEmail)).called(1);
        subscription.close();
      });

      test('should emit when send mail fails', () async {
        // Arrange
        const tError = 'Failed to send email';
        when(() => mockSendMail.call(any())).thenAnswer(
          (_) async => const Left(ServerFailure(tError)),
        );

        final controller = container.read(authControllerProvider.notifier);
        final states = <AuthState>[];

        final subscription = container.listen(
          authControllerProvider,
          (final previous, final next) => states.add(next),
        );

        // Act
        await controller.sendMail(email: tEmail);

        // Assert
        expect(states, [
          const AuthState.loading(),
          const AuthState.error(tError),
        ]);

        verify(() => mockSendMail.call(tEmail)).called(1);
        subscription.close();
      });
    });

    group('Verify Email', () {
      const tOtp = '123456';

      test('should emit when email verification is successful', () async {
        // Arrange
        when(() => mockVerifyEmail.call(any())).thenAnswer(
          (_) async => const Right(Success()),
        );

        final controller = container.read(authControllerProvider.notifier);
        final states = <AuthState>[];

        final subscription = container.listen(
          authControllerProvider,
          (final previous, final next) => states.add(next),
        );

        // Act
        await controller.verifyEmail(otp: tOtp);

        // Assert
        expect(states, [const AuthState.verified()]);

        verify(() => mockVerifyEmail.call(tOtp)).called(1);
        subscription.close();
      });

      test('should emit [error] when email verification fails', () async {
        // Arrange
        const tError = 'Invalid OTP';
        when(() => mockVerifyEmail.call(any())).thenAnswer(
          (_) async => const Left(ServerFailure(tError)),
        );

        final controller = container.read(authControllerProvider.notifier);
        final states = <AuthState>[];

        final subscription = container.listen(
          authControllerProvider,
          (final previous, final next) => states.add(next),
        );

        // Act
        await controller.verifyEmail(otp: tOtp);

        // Assert
        expect(states, [const AuthState.error(tError)]);

        verify(() => mockVerifyEmail.call(tOtp)).called(1);
        subscription.close();
      });
    });

    group('Forgot Password', () {
      const tEmail = 'test@example.com';

      test('should emit when forgot password is successful', () async {
        // Arrange
        when(() => mockForgotPassword.call(any())).thenAnswer(
          (_) async => const Right(Success()),
        );

        final controller = container.read(authControllerProvider.notifier);
        final states = <AuthState>[];

        final subscription = container.listen(
          authControllerProvider,
          (final previous, final next) => states.add(next),
        );

        // Act
        await controller.forgotPassword(email: tEmail);

        // Assert
        expect(states, [const AuthState.forgotPassword()]);

        verify(() => mockForgotPassword.call(tEmail)).called(1);
        subscription.close();
      });

      test('should emit [error] when forgot password fails', () async {
        // Arrange
        const tError = 'Email not found';
        when(() => mockForgotPassword.call(any())).thenAnswer(
          (_) async => const Left(ServerFailure(tError)),
        );

        final controller = container.read(authControllerProvider.notifier);
        final states = <AuthState>[];

        final subscription = container.listen(
          authControllerProvider,
          (final previous, final next) => states.add(next),
        );

        // Act
        await controller.forgotPassword(email: tEmail);

        // Assert
        expect(states, [const AuthState.error(tError)]);

        verify(() => mockForgotPassword.call(tEmail)).called(1);
        subscription.close();
      });
    });

    group('Verify OTP', () {
      const tOtp = '123456';
      const tResetToken = 'reset_token_123';

      test('should emit when OTP verification is successful', () async {
        // Arrange
        when(() => mockVerifyOtp.call(any())).thenAnswer(
          (_) async => const Right(tResetToken),
        );

        final controller = container.read(authControllerProvider.notifier);
        final states = <AuthState>[];

        final subscription = container.listen(
          authControllerProvider,
          (final previous, final next) => states.add(next),
        );

        // Act
        await controller.verifyOtp(otp: tOtp);

        // Assert
        expect(states, [const AuthState.verifiedOtp(tResetToken)]);

        verify(() => mockVerifyOtp.call(tOtp)).called(1);
        subscription.close();
      });

      test('should emit [error] when OTP verification fails', () async {
        // Arrange
        const tError = 'Invalid OTP';
        when(() => mockVerifyOtp.call(any())).thenAnswer(
          (_) async => const Left(ServerFailure(tError)),
        );

        final controller = container.read(authControllerProvider.notifier);
        final states = <AuthState>[];

        final subscription = container.listen(
          authControllerProvider,
          (final previous, final next) => states.add(next),
        );

        // Act
        await controller.verifyOtp(otp: tOtp);

        // Assert
        expect(states, [const AuthState.error(tError)]);

        verify(() => mockVerifyOtp.call(tOtp)).called(1);
        subscription.close();
      });
    });

    group('Logout', () {
      test('should emit [initial] when logout is successful', () async {
        // Arrange
        when(() => mockLogOutUseCase.call(any())).thenAnswer(
          (_) async => const Right(Success()),
        );

        final controller = container.read(authControllerProvider.notifier);
        final states = <AuthState>[];

        final subscription = container.listen(
          authControllerProvider,
          (final previous, final next) => states.add(next),
        );

        // Act
        await controller.logOut();

        // Assert
        expect(states, [
          const AuthState.loading(),
          const AuthState.initial(),
        ]);

        verify(() => mockLogOutUseCase.call(const NoParams())).called(1);
        subscription.close();
      });
      test('should emit [error] when logout fails', () async {
        // Arrange
        const tError = 'Logout failed';
        when(() => mockLogOutUseCase.call(any())).thenAnswer(
          (_) async => const Left(ServerFailure(tError)),
        );

        final controller = container.read(authControllerProvider.notifier);
        final states = <AuthState>[];

        final subscription = container.listen(
          authControllerProvider,
          (final previous, final next) => states.add(next),
        );

        // Act
        await controller.logOut();

        // Assert
        expect(states, [
          const AuthState.loading(),
          const AuthState.error(tError),
        ]);

        verify(() => mockLogOutUseCase.call(const NoParams())).called(1);
        subscription.close();
      });
    });

    group('Reset Password', () {
      const tResetToken = 'reset_token_123';
      const tPassword = 'newPassword123';
      const tConfirmPassword = 'newPassword123';

      test('should emit when reset password is successful', () async {
        // Arrange
        when(() => mockResetPassword.call(any())).thenAnswer(
          (_) async => const Right(Success()),
        );

        final controller = container.read(authControllerProvider.notifier);
        final states = <AuthState>[];

        final subscription = container.listen(
          authControllerProvider,
          (final previous, final next) => states.add(next),
        );

        // Act
        await controller.resetPassword(
          resetToken: tResetToken,
          password: tPassword,
          confirmPassword: tConfirmPassword,
        );

        // Assert
        expect(states, [const AuthState.resetPassword()]);

        verify(() => mockResetPassword.call(any())).called(1);
        subscription.close();
      });

      test('should emit [error] when reset password fails', () async {
        // Arrange
        const tError = 'Invalid reset token';
        when(() => mockResetPassword.call(any())).thenAnswer(
          (_) async => const Left(ServerFailure(tError)),
        );

        final controller = container.read(authControllerProvider.notifier);
        final states = <AuthState>[];

        final subscription = container.listen(
          authControllerProvider,
          (final previous, final next) => states.add(next),
        );

        // Act
        await controller.resetPassword(
          resetToken: tResetToken,
          password: tPassword,
          confirmPassword: tConfirmPassword,
        );

        // Assert
        expect(states, [const AuthState.error(tError)]);

        verify(() => mockResetPassword.call(any())).called(1);
        subscription.close();
      });
    });

    group('Check Email', () {
      const tEmail = 'test@example.com';
      const tMessage = 'Email is available';

      test('should emit message when email check is success', () async {
        // Arrange
        when(() => mockCheckEmail.call(any())).thenAnswer(
          (_) async => const Right(tMessage),
        );

        final controller = container.read(authControllerProvider.notifier);

        // Act
        final result = await controller.checkEmailExists(tEmail);

        // Assert
        expect(result, tMessage);
        verify(() => mockCheckEmail.call(tEmail)).called(1);
      });

      test('should return error message when email check fails', () async {
        // Arrange
        const tError = 'Email already exists';
        when(() => mockCheckEmail.call(any())).thenAnswer(
          (_) async => const Left(ServerFailure(tError)),
        );

        final controller = container.read(authControllerProvider.notifier);

        // Act
        final result = await controller.checkEmailExists(tEmail);

        // Assert
        expect(result, tError);
        verify(() => mockCheckEmail.call(tEmail)).called(1);
      });
    });

    group('Provider Dependencies', () {
      test('should properly inject use case dependencies', () {
        // Test that the controller can access all required providers
        final controller = container.read(authControllerProvider.notifier);
        expect(controller, isNotNull);

        // Verify all providers are accessible
        expect(() => container.read(registerUserProvider), returnsNormally);
        expect(() => container.read(loginUserProvider), returnsNormally);
        expect(() => container.read(sendMailProvider), returnsNormally);
        expect(() => container.read(verifyEmailProvider), returnsNormally);
        expect(() => container.read(forgotPasswordProvider), returnsNormally);
        expect(() => container.read(verifyOtpProvider), returnsNormally);
        expect(() => container.read(logOutUseCaseProvider), returnsNormally);
        expect(() => container.read(resetPasswordProvider), returnsNormally);
        expect(() => container.read(checkEmailProvider), returnsNormally);
      });
    });

    group('State Persistence', () {
      test('should maintain state across multiple operations', () async {
        // Arrange
        const tUser = User(
          userId: 1,
          role: 'USER',
          userInfo: UserInformation(
            firstName: 'John',
            lastName: 'Doe',
            email: 'test@example.com',
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

        when(() => mockLoginUser.call(any())).thenAnswer(
          (_) async => const Right(tUser),
        );

        final controller = container.read(authControllerProvider.notifier);

        // Act - Login
        await controller.login(email: 'test@example.com', password: 'password');

        // Assert - State should be authorized
        expect(
          container.read(authControllerProvider),
          const AuthState.authorized(tUser),
        );

        // Act - Read state again
        final currentState = container.read(authControllerProvider);

        // Assert - State should persist
        expect(currentState, const AuthState.authorized(tUser));
      });
    });

    group('Error Handling', () {
      test('should handle generic exceptions properly', () async {
        // Arrange
        const tError = 'Unexpected error occurred';
        when(() => mockRegisterUser.call(any())).thenThrow(
          Exception(tError),
        );

        final controller = container.read(authControllerProvider.notifier);
        final states = <AuthState>[];

        final subscription = container.listen(
          authControllerProvider,
          (final previous, final next) => states.add(next),
        );

        // Act
        await controller.register(
          email: 'test@example.com',
          password: 'password',
          firstName: 'John',
          lastName: 'Doe',
          phone: '1234567890',
        );

        // Assert
        expect(states, [
          const AuthState.loading(),
          const AuthState.error('Exception: $tError'),
        ]);

        subscription.close();
      });
    });
  });
}
