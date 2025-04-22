import 'package:dart_either/dart_either.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

part 'register_user.freezed.dart';
part 'register_user.g.dart';

@riverpod
RegisterUser registerUser(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return RegisterUser(authRepository);
}

@freezed
sealed class RegisterUserParams with _$RegisterUserParams {
  const factory RegisterUserParams({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) = _RegisterUserParams;
}

final class RegisterUser implements UseCase<RegisteredUser, RegisterUserParams> {
  const RegisterUser(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Either<Failure, RegisteredUser>> call(RegisterUserParams params) async {
    final result = await _authRepository.registerUser(
      email: params.email,
      password: params.password,
      firstName: params.firstName,
      lastName: params.lastName,
      phone: params.phone,
    );
    return result;
  }
}

@riverpod
SendMail sendMail(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return SendMail(authRepository);
}

final class SendMail implements UseCase<Success, String> {
  const SendMail(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Either<Failure, Success>> call(String email) async {
    final result = await _authRepository.sendMail(email: email);
    return result;
  }
}

@riverpod
VerifyEmail verifyEmail(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return VerifyEmail(authRepository);
}

final class VerifyEmail implements UseCase<Success, String> {
  const VerifyEmail(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Either<Failure, Success>> call(String otp) async {
    final result = await _authRepository.verifyEmail(otp: otp);
    return result;
  }
}

@riverpod
CheckEmail checkEmail(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return CheckEmail(authRepository);
}

final class CheckEmail implements UseCase<String, String> {
  const CheckEmail(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Either<Failure, String>> call(String email) async {
    final result = await _authRepository.checkEmail(email: email);
    return result;
  }
}
