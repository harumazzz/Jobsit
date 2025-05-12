import 'dart:convert';

import 'package:dart_either/dart_either.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/file_service.dart';
import '../../../../core/services/shared_prefs_service.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

part 'auth_repository_impl.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final authStorageService = InjectionContainer.get<IAuthStorageService>();
  return AuthRepositoryImpl(remoteDataSource, authStorageService);
}

final class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._authRemoteDataSource, this._authStorageService);

  final AuthRemoteDataSource _authRemoteDataSource;

  final IAuthStorageService _authStorageService;

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
      await _authStorageService.saveToken(result.token);
      await _authStorageService.saveUserId(result.userId);
      final user = await _authRemoteDataSource.getUser(result.userId);
      return Right(user.toEntity());
    } on PlatformException catch (e) {
      return Left(CacheFailure(e.message.toString()));
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

  @override
  Future<Either<Failure, User>> getUser({required int userId}) async {
    try {
      final result = await _authRemoteDataSource.getUser(userId);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Success>> updateEmailNotification() async {
    try {
      await _authRemoteDataSource.updateEmailNotification();
      return const Right(Success());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Success>> updateSearchableCandidate() async {
    try {
      await _authRemoteDataSource.updateSearchableCandidate();
      return const Right(Success());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Success>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _authRemoteDataSource.changePassword(
        ChangePasswordRequest(oldPassword: oldPassword, newPassword: newPassword, confirmPassword: confirmPassword),
      );
      return const Right(Success());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Success>> logOut() async {
    try {
      final token = await _authStorageService.getToken();
      if (token == null) {
        return const Left(CacheFailure('Token not found'));
      }
      await _authRemoteDataSource.logOut(token);
      await _authStorageService.deleteToken();
      return const Right(Success());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateJobInfo({
    required String desiredJob,
    required String desiredWorkingProvince,
    required String referenceLetter,
    required List<Position> positions,
    required List<Major> majors,
    required List<Schedule> schedules,
    FileRequest? cv,
  }) async {
    try {
      final Map<String, dynamic> value = {
        'candidateProfileDTO': jsonEncode({
          'desiredJob': desiredJob,
          'desiredWorkingProvince': desiredWorkingProvince,
          'referenceLetter': referenceLetter,
          'positionsDTOs': [...positions.map((e) => PositionRequest(id: e.id))],
          'majorsDTOs': [...majors.map((e) => MajorRequest(id: e.id))],
          'schedulesDTOs': [...schedules.map((e) => ScheduleRequest(id: e.id))],
        }),
      };
      if (cv != null) {
        value['cv'] = MultipartFile.fromBytes(cv.data, filename: cv.name);
      }
      final result = await _authRemoteDataSource.updateJobInfo(FormData.fromMap(value));
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateUserInfo({
    required String firstName,
    required String lastName,
    required String birthDay,
    required String phone,
    required int gender,
    required String location,
    required String city,
    required String district,
    required University university,
    FileRequest? avatar,
  }) async {
    try {
      final Map<String, dynamic> value = {
        'candidateProfileDTO': jsonEncode({
          'userProfileDTO': {
            'firstName': firstName,
            'lastName': lastName,
            'birthDay': birthDay,
            'phone': phone,
            'gender': gender,
            'location': location,
            'city': city,
            'district': district,
          },
          'candidateOtherInfoDTO': {
            'universityDTO': {'id': university.id},
          },
        }),
      };
      if (avatar != null) {
        value['avatar'] = MultipartFile.fromBytes(avatar.data, filename: avatar.name);
      }
      final data = FormData.fromMap(value);
      final result = await _authRemoteDataSource.updateUser(data);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<University>>> getUniversities() async {
    try {
      final result = await _authRemoteDataSource.getUniversities();
      return Right(result.map((university) => university.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
