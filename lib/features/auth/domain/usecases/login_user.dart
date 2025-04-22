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
