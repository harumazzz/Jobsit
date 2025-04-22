import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';

part 'auth_provider.freezed.dart';
part 'auth_provider.g.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;

  const factory AuthState.loading() = AuthLoading;

  const factory AuthState.registered(RegisteredUser user) = AuthRegistered;

  const factory AuthState.authorized(User user) = AuthAuthorized;

  const factory AuthState.error(String message) = AuthError;
}

@Riverpod(keepAlive: true)
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
    try {
      final registerUseCase = ref.read(registerUserProvider);
      final result = await registerUseCase(
        RegisterUserParams(email: email, password: password, firstName: firstName, lastName: lastName, phone: phone),
      );
      state = result.fold(ifRight: AuthState.registered, ifLeft: (e) => AuthState.error(e.message));
    } on ServerException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AuthState.loading();
    try {
      final loginUseCase = ref.read(loginUserProvider);
      final result = await loginUseCase(LoginUserParams(email: email, password: password));
      state = result.fold(ifRight: AuthState.authorized, ifLeft: (e) => AuthState.error(e.message));
    } on ServerException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
}
