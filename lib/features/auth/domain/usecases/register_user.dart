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

/// Provides an instance of [RegisterUser] use case.
@riverpod
RegisterUser registerUser(final Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return RegisterUser(authRepository);
}

/// Parameters for the [RegisterUser] use case.
@freezed
sealed class RegisterUserParams with _$RegisterUserParams {
  /// Creates [RegisterUserParams].
  ///
  /// [email] The user's email.
  /// [password] The user's password.
  /// [firstName] The user's first name.
  /// [lastName] The user's last name.
  /// [phone] The user's phone number.
  const factory RegisterUserParams({
    required final String email,
    required final String password,
    required final String firstName,
    required final String lastName,
    required final String phone,
  }) = _RegisterUserParams;
}

/// Use case for registering a new user.
///
/// Takes [RegisterUserParams] and returns a [RegisteredUser] on success
/// or [Failure].
// ignore: lines_longer_than_80_chars
final class RegisterUser implements UseCase<RegisteredUser, RegisterUserParams> {
  /// Creates a [RegisterUser] use case.
  const RegisterUser(this._authRepository);

  final AuthRepository _authRepository;

  /// Executes the register user use case.
  @override
  Future<Either<Failure, RegisteredUser>> call(
    final RegisterUserParams params,
  ) async {
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

/// Provides an instance of [SendMail] use case.
@riverpod
SendMail sendMail(final Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return SendMail(authRepository);
}

/// Use case for sending a verification or activation email.
///
/// Takes the user's email as a [String] and returns [Success] or [Failure].
final class SendMail implements UseCase<Success, String> {
  /// Creates a [SendMail] use case.
  const SendMail(this._authRepository);

  final AuthRepository _authRepository;

  /// Executes the send mail use case.
  @override
  Future<Either<Failure, Success>> call(final String email) async {
    final result = await _authRepository.sendMail(email: email);
    return result;
  }
}

/// Provides an instance of [VerifyEmail] use case.
@riverpod
VerifyEmail verifyEmail(final Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return VerifyEmail(authRepository);
}

/// Use case for verifying a user's email with an OTP.
///
/// Takes the OTP as a [String] and returns [Success] or [Failure].
final class VerifyEmail implements UseCase<Success, String> {
  /// Creates a [VerifyEmail] use case.
  const VerifyEmail(this._authRepository);

  final AuthRepository _authRepository;

  /// Executes the verify email use case.
  @override
  Future<Either<Failure, Success>> call(final String otp) async {
    final result = await _authRepository.verifyEmail(otp: otp);
    return result;
  }
}

/// Provides an instance of [CheckEmail] use case.
@riverpod
CheckEmail checkEmail(final Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return CheckEmail(authRepository);
}

/// Use case for checking if an email is already registered.
///
/// Takes the email as a [String] and returns a message [String] or [Failure].
final class CheckEmail implements UseCase<String, String> {
  /// Creates a [CheckEmail] use case.
  const CheckEmail(this._authRepository);

  final AuthRepository _authRepository;

  /// Executes the check email use case.
  @override
  Future<Either<Failure, String>> call(final String email) async {
    final result = await _authRepository.checkEmail(email: email);
    return result;
  }
}
