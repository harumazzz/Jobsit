import 'package:dart_either/dart_either.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

part 'login_user.freezed.dart';
part 'login_user.g.dart';

@riverpod
LoginUser loginUser(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return LoginUser(authRepository);
}

@freezed
sealed class LoginUserParams with _$LoginUserParams {
  const factory LoginUserParams({required String email, required String password}) = _LoginUserParams;
}

final class LoginUser implements UseCase<User, LoginUserParams> {
  const LoginUser(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Either<Failure, User>> call(LoginUserParams params) async {
    return await _authRepository.loginUser(email: params.email, password: params.password);
  }
}

@riverpod
ForgotPassword forgotPassword(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return ForgotPassword(authRepository);
}

final class ForgotPassword implements UseCase<Success, String> {
  const ForgotPassword(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Either<Failure, Success>> call(String email) async {
    return await _authRepository.forgotPassword(email: email);
  }
}

@riverpod
VerifyOtp verifyOtp(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return VerifyOtp(authRepository);
}

final class VerifyOtp implements UseCase<String, String> {
  const VerifyOtp(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Either<Failure, String>> call(String otp) async {
    return await _authRepository.verifyOtp(otp: otp);
  }
}

@freezed
sealed class ResetPasswordParams with _$ResetPasswordParams {
  const factory ResetPasswordParams({
    required String resetToken,
    required String password,
    required String confirmPassword,
  }) = _ResetPasswordParams;
}

@riverpod
ResetPassword resetPassword(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return ResetPassword(authRepository);
}

final class ResetPassword implements UseCase<Success, ResetPasswordParams> {
  const ResetPassword(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Either<Failure, Success>> call(ResetPasswordParams params) async {
    return await _authRepository.resetPassword(
      resetToken: params.resetToken,
      password: params.password,
      confirmPassword: params.confirmPassword,
    );
  }
}

@riverpod
GetUserData getUserData(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return GetUserData(authRepository);
}

final class GetUserData implements UseCase<User, int> {
  const GetUserData(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Either<Failure, User>> call(int userId) async {
    return await _authRepository.getUser(userId: userId);
  }
}

@riverpod
UpdateSearchableCandidateUseCase updateSearchableCandidateUseCase(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return UpdateSearchableCandidateUseCase(authRepository);
}

final class UpdateSearchableCandidateUseCase implements UseCase<Success, NoParams> {
  const UpdateSearchableCandidateUseCase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Either<Failure, Success>> call(NoParams params) async {
    return await _authRepository.updateSearchableCandidate();
  }
}

@riverpod
UpdateEmailNotificationUseCase updateEmailNotificationUseCase(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return UpdateEmailNotificationUseCase(authRepository);
}

final class UpdateEmailNotificationUseCase implements UseCase<Success, NoParams> {
  const UpdateEmailNotificationUseCase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Either<Failure, Success>> call(NoParams params) async {
    return await _authRepository.updateEmailNotification();
  }
}

@riverpod
LogOutUseCase logOutUseCase(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return LogOutUseCase(authRepository);
}

final class LogOutUseCase implements UseCase<Success, NoParams> {
  const LogOutUseCase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Either<Failure, Success>> call(NoParams params) async {
    return await _authRepository.logOut();
  }
}

@freezed
sealed class ChangePasswordParams with _$ChangePasswordParams {
  const factory ChangePasswordParams({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) = _ChangePasswordParams;
}

@riverpod
ChangePasswordUseCase changePasswordUseCase(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return ChangePasswordUseCase(authRepository);
}

final class ChangePasswordUseCase implements UseCase<Success, ChangePasswordParams> {
  const ChangePasswordUseCase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Either<Failure, Success>> call(ChangePasswordParams params) async {
    return await _authRepository.changePassword(
      oldPassword: params.oldPassword,
      newPassword: params.newPassword,
      confirmPassword: params.confirmPassword,
    );
  }
}
