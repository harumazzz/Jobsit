import 'package:dart_either/dart_either.dart';
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
    final result = await _authRemoteDataSource.registerUser(
      UserCreationRequest(email: email, password: password, firstName: firstName, lastName: lastName, phone: phone),
    );
    return result.fold(ifLeft: Left.new, ifRight: (e) => Right(e.toEntity()));
  }

  @override
  Future<Either<Failure, User>> loginUser({required String email, required String password}) async {
    final result = await _authRemoteDataSource.loginUser(LogInRequest(email: email, password: password));
    return result.fold(ifLeft: Left.new, ifRight: (e) => Right(e.toEntity()));
  }

  @override
  Future<Either<Failure, Success>> sendMail({required String email}) async {
    final result = await _authRemoteDataSource.sendMail(email);
    return result.fold(ifLeft: Left.new, ifRight: (e) => const Right(Success()));
  }

  @override
  Future<Either<Failure, Success>> verifyOtp({required String otp}) async {
    final result = await _authRemoteDataSource.verifyOTP(otp);
    return result.fold(ifLeft: Left.new, ifRight: (e) => const Right(Success()));
  }
}
