import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';

part 'auth_provider.freezed.dart';
part 'auth_provider.g.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;

  const factory AuthState.loading() = _Loading;

  const factory AuthState.registered(RegisteredUser user) = _Registered;

  const factory AuthState.authorized(User user) = _Authorized;

  const factory AuthState.error(String message) = _Error;
}

@riverpod
class AuthController extends _$AuthController {
  @override
  AuthState build() {
    return const AuthState.initial();
  }

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    state = const AuthState.loading();
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
      ifLeft: (r) => AuthState.error(r.message),
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = const AuthState.loading();
    final loginUseCase = ref.read(loginUserProvider);
    final result = await loginUseCase(
      LoginUserParams(email: email, password: password),
    );
    state = result.fold(
      ifRight: AuthState.authorized,
      ifLeft: (e) => AuthState.error(e.message),
    );
  }
}
