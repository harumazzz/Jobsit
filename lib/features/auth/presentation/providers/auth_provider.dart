import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/services/file_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';

part 'auth_provider.freezed.dart';
part 'auth_provider.g.dart';

/// Represents the different states of the authentication process.
@freezed
sealed class AuthState with _$AuthState {
  /// The initial state before any authentication action has been taken.
  const factory AuthState.initial() = AuthInitial;

  /// State indicating that an authentication operation is in progress.
  const factory AuthState.loading() = AuthLoading;

  /// State after a user has successfully registered.
  /// Contains the [RegisteredUser] data.
  const factory AuthState.registered(
    final RegisteredUser user,
  ) = AuthRegistered;

  /// State when a user is successfully authenticated and authorized.
  /// Contains the full [User] data.
  const factory AuthState.authorized(final User user) = AuthAuthorized;

  /// State indicating that an email or OTP verification was successful.
  const factory AuthState.verified() = AuthVerified;

  /// State indicating that the forgot password process has been initiated.
  const factory AuthState.forgotPassword() = AuthForgotPassword;

  /// State after an OTP for password reset has been successfully verified.
  /// Contains the [resetToken] needed for the password reset.
  const factory AuthState.verifiedOtp(
    final String resetToken,
  ) = AuthVerifiedOtp;

  /// State indicating that a password reset operation was successful.
  const factory AuthState.resetPassword() = AuthResetPassword;

  /// State indicating that an email (e.g., verification, OTP) has been sent.
  const factory AuthState.sendedMail() = AuthSendedMail;

  /// State representing an error during an authentication operation.
  /// Contains an error [message].
  const factory AuthState.error(final String message) = AuthError;
}

/// Controller for managing authentication state and operations.
///
/// This Riverpod provider handles user registration, login, email verification,
/// password management, profile updates, and logout. It interacts with
/// various authentication-related use cases.
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  AuthState build() => const AuthState.initial();

  /// Registers a new user with the provided credentials.
  Future<void> register({
    required final String email,
    required final String password,
    required final String firstName,
    required final String lastName,
    required final String phone,
  }) async {
    state = const AuthState.loading();
    try {
      final registerUseCase = ref.read(registerUserProvider);
      final result = await registerUseCase(
        RegisterUserParams(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
          phone: phone,
        ),
      );
      state = result.fold(
        ifRight: AuthState.registered,
        ifLeft: (final e) => AuthState.error(e.message),
      );
    } on ServerException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Logs in an existing user with the given email and password.
  Future<void> login({
    required final String email,
    required final String password,
  }) async {
    state = const AuthState.loading();
    try {
      final loginUseCase = ref.read(loginUserProvider);
      final result = await loginUseCase(
        LoginUserParams(email: email, password: password),
      );
      state = result.fold(
        ifRight: AuthState.authorized,
        ifLeft: (final e) => AuthState.error(e.message),
      );
    } on ServerException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Sends a verification or activation email to the specified [email].
  Future<void> sendMail({required final String email}) async {
    state = const AuthState.loading();
    try {
      final sendMailUseCase = ref.read(sendMailProvider);
      final result = await sendMailUseCase(email);
      state = result.fold(
        ifRight: (_) => const AuthState.sendedMail(),
        ifLeft: (final e) => AuthState.error(e.message),
      );
    } on ServerException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Resends the verification or activation email to the specified [email].
  /// This is typically an alias for [sendMail].
  Future<void> resendMail({
    required final String email,
  }) async => sendMail(email: email);

  /// Verifies a user's email using the provided One-Time Password [otp].
  Future<void> verifyEmail({required final String otp}) async {
    try {
      final verifyEmailUseCase = ref.read(verifyEmailProvider);
      final result = await verifyEmailUseCase(otp);
      state = result.fold(
        ifRight: (_) => const AuthState.verified(),
        ifLeft: (final e) => AuthState.error(e.message),
      );
    } on ServerException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Initiates the password recovery process for the specified [email].
  Future<void> forgotPassword({
    required final String email,
  }) async {
    try {
      final forgotPasswordUsecase = ref.read(forgotPasswordProvider);
      final result = await forgotPasswordUsecase(email);
      state = result.fold(
        ifRight: (_) => const AuthState.forgotPassword(),
        ifLeft: (final e) => AuthState.error(e.message),
      );
    } on ServerException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Verifies a One-Time Password [otp], typically for password reset flows.
  Future<void> verifyOtp({required final String otp}) async {
    try {
      final verifyOtpUseCase = ref.read(verifyOtpProvider);
      final result = await verifyOtpUseCase(otp);
      state = result.fold(
        ifRight: AuthState.verifiedOtp,
        ifLeft: (final e) => AuthState.error(e.message),
      );
    } on ServerException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Logs out the current user.
  ///
  /// Clears authentication state and any stored tokens.
  Future<void> logOut() async {
    try {
      final logOutUseCase = ref.read(logOutUseCaseProvider);
      final result = await logOutUseCase(const NoParams());
      state = result.fold(
        ifRight: (_) => const AuthState.initial(),
        ifLeft: (final e) => AuthState.error(e.message),
      );
    } on ServerException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Changes the current user's password.
  Future<void> changePassword({
    required final String oldPassword,
    required final String newPassword,
    required final String confirmPassword,
  }) async {
    try {
      final changePasswordUseCase = ref.read(changePasswordUseCaseProvider);
      final result = await changePasswordUseCase(
        ChangePasswordParams(
          oldPassword: oldPassword,
          newPassword: newPassword,
          confirmPassword: confirmPassword,
        ),
      );
      state = result.fold(
        ifRight: (_) => const AuthState.initial(),
        ifLeft: (final e) => AuthState.error(e.message),
      );
    } on ServerException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Resets the user's password using a [resetToken].
  Future<void> resetPassword({
    required final String resetToken,
    required final String password,
    required final String confirmPassword,
  }) async {
    try {
      final resetPasswordUseCase = ref.read(resetPasswordProvider);
      final result = await resetPasswordUseCase(
        ResetPasswordParams(
          resetToken: resetToken,
          password: password,
          confirmPassword: confirmPassword,
        ),
      );
      state = result.fold(
        ifRight: (_) => const AuthState.resetPassword(),
        ifLeft: (final e) => AuthState.error(e.message),
      );
    } on ServerException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Checks if the given [email] is already registered or available.
  ///
  /// Returns a message string indicating the status or an error message.
  Future<String> checkEmailExists(final String email) async {
    try {
      final checkEmailUseCase = ref.read(checkEmailProvider);
      final result = await checkEmailUseCase(email);
      return result.fold(
        ifRight: (final e) => e,
        ifLeft: (final e) => e.message,
      );
    } on ServerException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  /// Resets the authentication state to its initial value.
  void reset() {
    state = const AuthState.initial();
  }

  /// Fetches and sets the candidate data if the user is already authenticated
  /// (e.g., from a stored session).
  ///
  /// Requires [userId] to fetch the specific candidate's data.
  /// Asserts that the current state is [AuthInitial] before proceeding.
  Future<void> getCandidateData(final int userId) async {
    assert(
      state is AuthInitial,
      'State must be initialized to get candidate data',
    );
    try {
      final checkEmailUseCase = ref.read(getUserDataProvider);
      final result = await checkEmailUseCase(userId);
      state = result.fold(
        ifRight: AuthState.authorized,
        ifLeft: (final e) => AuthState.error(e.message),
      );
    } on ServerException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Updates the searchable status of the currently authorized candidate.
  ///
  /// [searchable] The new searchable status.
  Future<void> updateSearchable({required final bool searchable}) async {
    if (state is AuthAuthorized) {
      final currentState = state as AuthAuthorized;
      state = currentState.copyWith(
        user: currentState.user.copyWith(
          jobInfo: currentState.user.jobInfo.copyWith(searchable: searchable),
        ),
      );
      final updateSearchableCandidateUseCase = ref.read(
        updateSearchableCandidateUseCaseProvider,
      );
      final result = await updateSearchableCandidateUseCase(const NoParams());
      result.fold(
        ifRight: (_) => null,
        ifLeft: (final e) => state = AuthState.error(e.message),
      );
    }
  }

  /// Updates the email receiving preference of the currently authorized.
  ///
  /// [mailReceive] The new email receiving preference.
  Future<void> updateMailReceive({required final bool mailReceive}) async {
    if (state is AuthAuthorized) {
      final currentState = state as AuthAuthorized;
      state = currentState.copyWith(
        user: currentState.user.copyWith(
          userInfo: currentState.user.userInfo.copyWith(
            mailReceive: mailReceive,
          ),
        ),
      );
      final updateEmailNotificationUseCase = ref.read(
        updateEmailNotificationUseCaseProvider,
      );
      final result = await updateEmailNotificationUseCase(const NoParams());
      result.fold(
        ifRight: (_) => null,
        ifLeft: (final e) => state = AuthState.error(e.message),
      );
    }
  }

  /// Updates the personal information of the currently authorized user.
  ///
  /// [avatar] is an optional [FileSelectorResult] for the new avatar.
  Future<void> updateUserInfo({
    required final String firstName,
    required final String lastName,
    required final String birthDay,
    required final String phone,
    required final int gender,
    required final String location,
    required final String city,
    required final String district,
    required final University university,
    final FileSelectorResult? avatar,
  }) async {
    if (state is AuthAuthorized) {
      final updateUserInfoUseCase = ref.read(updateUserInfoUseCaseProvider);
      final result = await updateUserInfoUseCase(
        UpdateUserInfoParams(
          firstName: firstName,
          lastName: lastName,
          birthDay: birthDay,
          phone: phone,
          gender: gender,
          location: location,
          city: city,
          district: district,
          university: university,
          // ignore: lines_longer_than_80_chars
          avatar: avatar != null ? FileRequest(name: avatar.name, data: avatar.data) : null,
        ),
      );
      state = result.fold(
        ifRight: AuthState.authorized,
        ifLeft: (final e) => state = AuthState.error(e.message),
      );
    }
  }

  /// Updates the job-related information of the currently authorized user.
  ///
  /// [cv] is an optional [FileSelectorResult] for the new CV.
  Future<void> updateJobInfo({
    required final String desiredJob,
    required final String desiredWorkingProvince,
    required final String referenceLetter,
    required final List<Position> positions,
    required final List<Major> majors,
    required final List<Schedule> schedules,
    final FileSelectorResult? cv,
  }) async {
    if (state is AuthAuthorized) {
      final updateJobInfoUseCase = ref.read(updateJobInfoUseCaseProvider);
      final result = await updateJobInfoUseCase(
        UpdateJobInfoParams(
          desiredJob: desiredJob,
          desiredWorkingProvince: desiredWorkingProvince,
          referenceLetter: referenceLetter,
          positions: positions,
          majors: majors,
          schedules: schedules,
          cv: cv != null ? FileRequest(name: cv.name, data: cv.data) : null,
        ),
      );
      state = result.fold(
        ifRight: AuthState.authorized,
        ifLeft: (final e) => state = AuthState.error(e.message),
      );
    }
  }
}

/// Represents the different states for fetching university data.
@freezed
sealed class UniversityState with _$UniversityState {
  /// The initial state before any university data fetching has occurred.
  const factory UniversityState.initial() = UniversityInitial;

  /// State indicating that university data is currently being loaded.
  const factory UniversityState.loading() = UniversityLoading;

  /// State when university data has been successfully loaded.
  /// Contains a list of [universities].
  const factory UniversityState.loaded(
    final List<University> universities,
  ) = UniversityLoaded;

  /// State representing an error during university data fetching.
  /// Contains an error [message].
  const factory UniversityState.error(final String message) = UniversityError;
}

/// Controller for managing the state and fetching of university data.
///
/// This Riverpod provider handles fetching a list of universities and
/// caching the result to avoid redundant API calls.
@Riverpod(keepAlive: true)
class UniversityController extends _$UniversityController {
  @override
  UniversityState build() => const UniversityState.initial();

  /// Fetches the list of universities.
  ///
  /// If universities are already loaded, this method does nothing.
  /// Otherwise, it sets the state to loading, fetches data, and updates
  /// the state to loaded or error.
  Future<void> getUniversities() async {
    if (state is UniversityLoaded) {
      return;
    }
    state = const UniversityState.loading();
    try {
      final getUniversityUseCase = ref.read(getUniversityUseCaseProvider);
      final result = await getUniversityUseCase(const NoParams());
      state = result.fold(
        ifRight: UniversityState.loaded,
        ifLeft: (final e) => UniversityState.error(e.message),
      );
    } on ServerException catch (e) {
      state = UniversityState.error(e.message);
    } catch (e) {
      state = UniversityState.error(e.toString());
    }
  }
}
