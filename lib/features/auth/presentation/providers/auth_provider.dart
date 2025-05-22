import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/services/file_service.dart';
import '../../../../core/usecases/usecase.dart';
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

  const factory AuthState.verified() = AuthVerified;

  const factory AuthState.forgotPassword() = AuthForgotPassword;

  const factory AuthState.verifiedOtp(String resetToken) = AuthVerifiedOtp;

  const factory AuthState.resetPassword() = AuthResetPassword;

  const factory AuthState.sendedMail() = AuthSendedMail;

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

  Future<void> sendMail({required String email}) async {
    state = const AuthState.loading();
    try {
      final sendMailUseCase = ref.read(sendMailProvider);
      final result = await sendMailUseCase(email);
      state = result.fold(ifRight: (_) => const AuthState.sendedMail(), ifLeft: (e) => AuthState.error(e.message));
    } on ServerException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> resendMail({required String email}) async {
    return await sendMail(email: email);
  }

  Future<void> verifyEmail({required String otp}) async {
    try {
      final verifyEmailUseCase = ref.read(verifyEmailProvider);
      final result = await verifyEmailUseCase(otp);
      state = result.fold(ifRight: (_) => const AuthState.verified(), ifLeft: (e) => AuthState.error(e.message));
    } on ServerException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> forgotPassword({required String email}) async {
    try {
      final forgotPasswordUsecase = ref.read(forgotPasswordProvider);
      final result = await forgotPasswordUsecase(email);
      state = result.fold(ifRight: (_) => const AuthState.forgotPassword(), ifLeft: (e) => AuthState.error(e.message));
    } on ServerException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> verifyOtp({required String otp}) async {
    try {
      final verifyOtpUseCase = ref.read(verifyOtpProvider);
      final result = await verifyOtpUseCase(otp);
      state = result.fold(ifRight: AuthState.verifiedOtp, ifLeft: (e) => AuthState.error(e.message));
    } on ServerException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> logOut() async {
    try {
      final logOutUseCase = ref.read(logOutUseCaseProvider);
      final result = await logOutUseCase(const NoParams());
      state = result.fold(ifRight: (_) => const AuthState.initial(), ifLeft: (e) => AuthState.error(e.message));
    } on ServerException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final changePasswordUseCase = ref.read(changePasswordUseCaseProvider);
      final result = await changePasswordUseCase(
        ChangePasswordParams(oldPassword: oldPassword, newPassword: newPassword, confirmPassword: confirmPassword),
      );
      state = result.fold(ifRight: (_) => const AuthState.initial(), ifLeft: (e) => AuthState.error(e.message));
    } on ServerException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> resetPassword({
    required String resetToken,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final resetPasswordUseCase = ref.read(resetPasswordProvider);
      final result = await resetPasswordUseCase(
        ResetPasswordParams(resetToken: resetToken, password: password, confirmPassword: confirmPassword),
      );
      state = result.fold(ifRight: (_) => const AuthState.resetPassword(), ifLeft: (e) => AuthState.error(e.message));
    } on ServerException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<String> checkEmailExists(String email) async {
    try {
      final checkEmailUseCase = ref.read(checkEmailProvider);
      final result = await checkEmailUseCase(email);
      return result.fold(ifRight: (e) => e, ifLeft: (e) => e.message);
    } on ServerException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  void reset() {
    state = const AuthState.initial();
  }

  Future<void> getCandidateData(int userId) async {
    assert(state is AuthInitial, 'State must be initialized to get candidate data');
    try {
      final checkEmailUseCase = ref.read(getUserDataProvider);
      final result = await checkEmailUseCase(userId);
      state = result.fold(ifRight: AuthState.authorized, ifLeft: (e) => AuthState.error(e.message));
    } on ServerException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> updateSearchable({required bool searchable}) async {
    if (state is AuthAuthorized) {
      final currentState = state as AuthAuthorized;
      state = currentState.copyWith(
        user: currentState.user.copyWith(jobInfo: currentState.user.jobInfo.copyWith(searchable: searchable)),
      );
      final updateSearchableCandidateUseCase = ref.read(updateSearchableCandidateUseCaseProvider);
      final result = await updateSearchableCandidateUseCase(const NoParams());
      result.fold(ifRight: (_) => null, ifLeft: (e) => state = AuthState.error(e.message));
    }
  }

  Future<void> updateMailReceive({required bool mailReceive}) async {
    if (state is AuthAuthorized) {
      final currentState = state as AuthAuthorized;
      state = currentState.copyWith(
        user: currentState.user.copyWith(userInfo: currentState.user.userInfo.copyWith(mailReceive: mailReceive)),
      );
      final updateEmailNotificationUseCase = ref.read(updateEmailNotificationUseCaseProvider);
      final result = await updateEmailNotificationUseCase(const NoParams());
      result.fold(ifRight: (_) => null, ifLeft: (e) => state = AuthState.error(e.message));
    }
  }

  Future<void> updateUserInfo({
    required String firstName,
    required String lastName,
    required String birthDay,
    required String phone,
    required int gender,
    required String location,
    required String city,
    required String district,
    required University university,
    FileSelectorResult? avatar,
  }) async {
    if (state is AuthAuthorized) {
      final updateUserInfoUseCase = ref.read(updateUserInfoUseCaseProvider);
      final result = await updateUserInfoUseCase(
        UpdateUserInfoParams(
          firstName: firstName,
          lastName: lastName,
          birthDay: birthDay,
          phone: phone,
          gender: gender,
          location: location,
          city: city,
          district: district,
          university: university,
          avatar: avatar != null ? FileRequest(name: avatar.name, data: avatar.data) : null,
        ),
      );
      state = result.fold(ifRight: AuthState.authorized, ifLeft: (e) => state = AuthState.error(e.message));
    }
  }

  Future<void> updateJobInfo({
    required String desiredJob,
    required String desiredWorkingProvince,
    required String referenceLetter,
    required List<Position> positions,
    required List<Major> majors,
    required List<Schedule> schedules,
    FileSelectorResult? cv,
  }) async {
    if (state is AuthAuthorized) {
      final updateJobInfoUseCase = ref.read(updateJobInfoUseCaseProvider);
      final result = await updateJobInfoUseCase(
        UpdateJobInfoParams(
          desiredJob: desiredJob,
          desiredWorkingProvince: desiredWorkingProvince,
          referenceLetter: referenceLetter,
          positions: positions,
          majors: majors,
          schedules: schedules,
          cv: cv != null ? FileRequest(name: cv.name, data: cv.data) : null,
        ),
      );
      state = result.fold(ifRight: AuthState.authorized, ifLeft: (e) => state = AuthState.error(e.message));
    }
  }
}

@freezed
sealed class UniversityState with _$UniversityState {
  const factory UniversityState.initial() = UniversityInitial;

  const factory UniversityState.loading() = UniversityLoading;

  const factory UniversityState.loaded(List<University> universities) = UniversityLoaded;

  const factory UniversityState.error(String message) = UniversityError;
}

@Riverpod(keepAlive: true)
class UniversityController extends _$UniversityController {
  @override
  UniversityState build() {
    return const UniversityState.initial();
  }

  Future<void> getUniversities() async {
    if (state is UniversityLoaded) {
      return;
    }
    state = const UniversityState.loading();
    try {
      final getUniversityUseCase = ref.read(getUniversityUseCaseProvider);
      final result = await getUniversityUseCase(const NoParams());
      state = result.fold(ifRight: UniversityState.loaded, ifLeft: (e) => UniversityState.error(e.message));
    } on ServerException catch (e) {
      state = UniversityState.error(e.message);
    } catch (e) {
      state = UniversityState.error(e.toString());
    }
  }
}
