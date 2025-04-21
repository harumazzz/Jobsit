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
  const factory LoginUserParams({
    required String email,
    required String password,
  }) = _LoginUserParams;
}

class LoginUser implements UseCase<User, LoginUserParams> {
  const LoginUser(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Either<Failure, User>> call(LoginUserParams params) async {
    return await _authRepository.loginUser(
      email: params.email,
      password: params.password,
    );
  }
}
