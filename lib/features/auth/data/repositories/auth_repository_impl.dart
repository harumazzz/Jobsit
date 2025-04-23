import 'package:dart_either/dart_either.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

part 'auth_repository_impl.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource);
}

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._authRemoteDataSource);

  final AuthRemoteDataSource _authRemoteDataSource;

  @override
  Future<Either<Failure, RegisteredUser>> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    try {
      final result = await _authRemoteDataSource.registerUser(
        RegisterUserRequest(
          user: UserCreationRequest(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
            phone: phone,
          ),
        ),
      );
      return Right(result.user.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> loginUser({required String email, required String password}) async {
    try {
      final result = await _authRemoteDataSource.loginUser(LogInRequest(email: email, password: password));
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Success>> sendMail({required String email}) async {
    try {
      final _ = await _authRemoteDataSource.sendMail(email);
      return const Right(Success());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Success>> verifyEmail({required String otp}) async {
    try {
      final _ = await _authRemoteDataSource.verifyEmail(otp);
      return const Right(Success());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> checkEmail({required String email}) async {
    try {
      final result = await _authRemoteDataSource.checkEmail(email);
      return Right(result.message);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Success>> forgotPassword({required String email}) async {
    try {
      final _ = await _authRemoteDataSource.forgotPassword(email);
      return const Right(Success());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Success>> resetPassword({
    required String resetToken,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final _ = await _authRemoteDataSource.resetPassword(
        ResetPasswordRequest(resetToken: resetToken, password: password, confirmPassword: confirmPassword),
      );
      return const Right(Success());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> verifyOtp({required String otp}) async {
    try {
      final result = await _authRemoteDataSource.verifyOtp(otp);
      return Right(result.message);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
