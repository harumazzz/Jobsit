import 'package:dart_either/dart_either.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/file_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

part 'login_user.freezed.dart';
part 'login_user.g.dart';

/// Provides an instance of [LoginUser] use case.
@riverpod
LoginUser loginUser(final Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return LoginUser(authRepository);
}

/// Parameters for the [LoginUser] use case.
@freezed
sealed class LoginUserParams with _$LoginUserParams {
  /// Creates [LoginUserParams].
  ///
  /// [email] The user's email.
  /// [password] The user's password.
  const factory LoginUserParams({
    required final String email,
    required final String password,
  }) = _LoginUserParams;
}

/// Use case for logging in a user.
///
/// Takes [LoginUserParams] and returns a [User] on success or [Failure].
class LoginUser implements UseCase<User, LoginUserParams> {
  /// Creates a [LoginUser] use case.
  const LoginUser(this._authRepository);

  final AuthRepository _authRepository;

  /// Executes the login user use case.
  @override
  Future<Either<Failure, User>> call(final LoginUserParams params) async =>
      _authRepository.loginUser(email: params.email, password: params.password);
}

/// Provides an instance of [ForgotPassword] use case.
@riverpod
ForgotPassword forgotPassword(final Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return ForgotPassword(authRepository);
}

/// Use case for initiating the forgot password process.
///
/// Takes the user's email as a [String] and returns [Success] or [Failure].
class ForgotPassword implements UseCase<Success, String> {
  /// Creates a [ForgotPassword] use case.
  const ForgotPassword(this._authRepository);

  final AuthRepository _authRepository;

  /// Executes the forgot password use case.
  @override
  Future<Either<Failure, Success>> call(
    final String email,
  ) async => _authRepository.forgotPassword(email: email);
}

/// Provides an instance of [VerifyOtp] use case.
@riverpod
VerifyOtp verifyOtp(final Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return VerifyOtp(authRepository);
}

/// Use case for verifying an OTP.
///
/// Takes the OTP as a [String] and returns a message [String] or [Failure].
class VerifyOtp implements UseCase<String, String> {
  /// Creates a [VerifyOtp] use case.
  const VerifyOtp(this._authRepository);

  final AuthRepository _authRepository;

  /// Executes the verify OTP use case.
  @override
  Future<Either<Failure, String>> call(
    final String otp,
  ) async => _authRepository.verifyOtp(otp: otp);
}

/// Parameters for the [ResetPassword] use case.
@freezed
sealed class ResetPasswordParams with _$ResetPasswordParams {
  /// Creates [ResetPasswordParams].
  ///
  /// [resetToken] The token received for password reset.
  /// [password] The new password.
  /// [confirmPassword] Confirmation of the new password.
  const factory ResetPasswordParams({
    required final String resetToken,
    required final String password,
    required final String confirmPassword,
  }) = _ResetPasswordParams;
}

/// Provides an instance of [ResetPassword] use case.
@riverpod
ResetPassword resetPassword(final Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return ResetPassword(authRepository);
}

/// Use case for resetting a user's password.
///
/// Takes [ResetPasswordParams] and returns [Success] or [Failure].
class ResetPassword implements UseCase<Success, ResetPasswordParams> {
  /// Creates a [ResetPassword] use case.
  const ResetPassword(this._authRepository);

  final AuthRepository _authRepository;

  /// Executes the reset password use case.
  @override
  Future<Either<Failure, Success>> call(
    final ResetPasswordParams params,
  ) async => _authRepository.resetPassword(
    resetToken: params.resetToken,
    password: params.password,
    confirmPassword: params.confirmPassword,
  );
}

/// Provides an instance of [GetUserData] use case.
@riverpod
GetUserData getUserData(final Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return GetUserData(authRepository);
}

/// Use case for fetching user data.
///
/// Takes the user ID as an [int] and returns a [User] or [Failure].
final class GetUserData implements UseCase<User, int> {
  /// Creates a [GetUserData] use case.
  const GetUserData(this._authRepository);

  final AuthRepository _authRepository;

  /// Executes the get user data use case.
  @override
  Future<Either<Failure, User>> call(
    final int userId,
  ) async => _authRepository.getUser(userId: userId);
}

/// Provides an instance of [UpdateSearchableCandidateUseCase].
@riverpod
UpdateSearchableCandidateUseCase updateSearchableCandidateUseCase(
  final Ref ref,
) {
  final authRepository = ref.watch(authRepositoryProvider);
  return UpdateSearchableCandidateUseCase(authRepository);
}

/// Use case for updating the candidate's searchable status.
///
/// Takes [NoParams] and returns [Success] or [Failure].
// ignore: lines_longer_than_80_chars
final class UpdateSearchableCandidateUseCase implements UseCase<Success, NoParams> {
  /// Creates an [UpdateSearchableCandidateUseCase].
  const UpdateSearchableCandidateUseCase(this._authRepository);

  final AuthRepository _authRepository;

  /// Executes the update searchable candidate use case.
  @override
  Future<Either<Failure, Success>> call(
    final NoParams params,
  ) async => _authRepository.updateSearchableCandidate();
}

/// Provides an instance of [UpdateEmailNotificationUseCase].
@riverpod
UpdateEmailNotificationUseCase updateEmailNotificationUseCase(final Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return UpdateEmailNotificationUseCase(authRepository);
}

/// Use case for updating the candidate's email notification preferences.
///
/// Takes [NoParams] and returns [Success] or [Failure].
// ignore: lines_longer_than_80_chars
final class UpdateEmailNotificationUseCase implements UseCase<Success, NoParams> {
  /// Creates an [UpdateEmailNotificationUseCase].
  const UpdateEmailNotificationUseCase(this._authRepository);

  final AuthRepository _authRepository;

  /// Executes the update email notification use case.
  @override
  Future<Either<Failure, Success>> call(
    final NoParams params,
  ) async => _authRepository.updateEmailNotification();
}

/// Provides an instance of [LogOutUseCase].
@riverpod
LogOutUseCase logOutUseCase(final Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return LogOutUseCase(authRepository);
}

/// Use case for logging out a user.
///
/// Takes [NoParams] and returns [Success] or [Failure].
class LogOutUseCase implements UseCase<Success, NoParams> {
  /// Creates a [LogOutUseCase].
  const LogOutUseCase(this._authRepository);

  final AuthRepository _authRepository;

  /// Executes the logout use case.
  @override
  Future<Either<Failure, Success>> call(
    final NoParams params,
  ) async => _authRepository.logOut();
}

/// Parameters for the [ChangePasswordUseCase].
@freezed
sealed class ChangePasswordParams with _$ChangePasswordParams {
  /// Creates [ChangePasswordParams].
  ///
  /// [oldPassword] The user's current password.
  /// [newPassword] The desired new password.
  /// [confirmPassword] Confirmation of the new password.
  const factory ChangePasswordParams({
    required final String oldPassword,
    required final String newPassword,
    required final String confirmPassword,
  }) = _ChangePasswordParams;
}

/// Provides an instance of [ChangePasswordUseCase].
@riverpod
ChangePasswordUseCase changePasswordUseCase(final Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return ChangePasswordUseCase(authRepository);
}

/// Use case for changing a user's password.
///
/// Takes [ChangePasswordParams] and returns [Success] or [Failure].
// ignore: lines_longer_than_80_chars
final class ChangePasswordUseCase implements UseCase<Success, ChangePasswordParams> {
  /// Creates a [ChangePasswordUseCase].
  const ChangePasswordUseCase(this._authRepository);

  final AuthRepository _authRepository;

  /// Executes the change password use case.
  @override
  Future<Either<Failure, Success>> call(
    final ChangePasswordParams params,
  ) async => _authRepository.changePassword(
    oldPassword: params.oldPassword,
    newPassword: params.newPassword,
    confirmPassword: params.confirmPassword,
  );
}

/// Provides an instance of [UpdateUserInfoUseCase].
@riverpod
UpdateUserInfoUseCase updateUserInfoUseCase(final Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return UpdateUserInfoUseCase(authRepository);
}

/// Parameters for the [UpdateUserInfoUseCase].
@freezed
sealed class UpdateUserInfoParams with _$UpdateUserInfoParams {
  /// Creates [UpdateUserInfoParams].
  ///
  /// Contains all fields for updating a user's personal information.
  /// [avatar] is an optional [FileRequest] for the user's avatar.
  const factory UpdateUserInfoParams({
    required final String firstName,
    required final String lastName,
    required final String birthDay,
    required final String phone,
    required final int gender,
    required final String location,
    required final String city,
    required final String district,
    required final University university,
    final FileRequest? avatar,
  }) = _UpdateUserInfoParams;
}

/// Use case for updating a user's personal information.
///
/// Takes [UpdateUserInfoParams] and returns an updated [User] or [Failure].
// ignore: lines_longer_than_80_chars
final class UpdateUserInfoUseCase implements UseCase<User, UpdateUserInfoParams> {
  /// Creates an [UpdateUserInfoUseCase].
  const UpdateUserInfoUseCase(this._authRepository);

  final AuthRepository _authRepository;

  /// Executes the update user info use case.
  @override
  Future<Either<Failure, User>> call(
    final UpdateUserInfoParams params,
  ) async => _authRepository.updateUserInfo(
    firstName: params.firstName,
    lastName: params.lastName,
    birthDay: params.birthDay,
    phone: params.phone,
    gender: params.gender,
    location: params.location,
    avatar: params.avatar,
    city: params.city,
    district: params.district,
    university: params.university,
  );
}

/// Provides an instance of [UpdateJobInfoUseCase].
@riverpod
UpdateJobInfoUseCase updateJobInfoUseCase(final Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return UpdateJobInfoUseCase(authRepository);
}

/// Parameters for the [UpdateJobInfoUseCase].
@freezed
sealed class UpdateJobInfoParams with _$UpdateJobInfoParams {
  /// Creates [UpdateJobInfoParams].
  ///
  /// Contains all fields for updating a user's job-related information.
  /// [cv] is an optional [FileRequest] for the user's CV.
  const factory UpdateJobInfoParams({
    required final String desiredJob,
    required final String desiredWorkingProvince,
    required final String referenceLetter,
    required final List<Position> positions,
    required final List<Major> majors,
    required final List<Schedule> schedules,
    final FileRequest? cv,
  }) = _UpdateJobInfoParams;
}

/// Use case for updating a user's job-related information.
///
/// Takes [UpdateJobInfoParams] and returns an updated [User] or [Failure].
final class UpdateJobInfoUseCase implements UseCase<User, UpdateJobInfoParams> {
  /// Creates an [UpdateJobInfoUseCase].
  const UpdateJobInfoUseCase(this._authRepository);

  final AuthRepository _authRepository;

  /// Executes the update job info use case.
  @override
  Future<Either<Failure, User>> call(
    final UpdateJobInfoParams params,
  ) async => _authRepository.updateJobInfo(
    desiredJob: params.desiredJob,
    desiredWorkingProvince: params.desiredWorkingProvince,
    referenceLetter: params.referenceLetter,
    positions: params.positions,
    majors: params.majors,
    schedules: params.schedules,
    cv: params.cv,
  );
}

/// Provides an instance of [GetUniversityUseCase].
@riverpod
GetUniversityUseCase getUniversityUseCase(final Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return GetUniversityUseCase(authRepository);
}

/// Use case for fetching a list of universities.
///
/// Takes [NoParams] and returns a list of [University] or [Failure].
// ignore: lines_longer_than_80_chars
final class GetUniversityUseCase implements UseCase<List<University>, NoParams> {
  /// Creates a [GetUniversityUseCase].
  const GetUniversityUseCase(this._authRepository);

  final AuthRepository _authRepository;

  /// Executes the get universities use case.
  @override
  Future<Either<Failure, List<University>>> call(
    final NoParams params,
  ) async => _authRepository.getUniversities();
}
