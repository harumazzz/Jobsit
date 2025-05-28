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

/// Provides an instance of [AuthRepository].
///
/// This repository handles authentication-related operations such as login,
/// registration, and user profile management.
@riverpod
AuthRepository authRepository(final Ref ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final authStorageService = InjectionContainer.get<IAuthStorageService>();
  return AuthRepositoryImpl(remoteDataSource, authStorageService);
}

/// Implementation of the [AuthRepository] interface.
///
/// This class interacts with [AuthRemoteDataSource] for network operations
/// and [IAuthStorageService] for local token and user ID storage.
class AuthRepositoryImpl implements AuthRepository {
  /// Creates an [AuthRepositoryImpl].
  ///
  /// Requires an [AuthRemoteDataSource] and an [IAuthStorageService].
  const AuthRepositoryImpl(
    this._authRemoteDataSource,
    this._authStorageService,
  );

  final AuthRemoteDataSource _authRemoteDataSource;

  final IAuthStorageService _authStorageService;

  @override
  Future<Either<Failure, RegisteredUser>> registerUser({
    required final String email,
    required final String password,
    required final String firstName,
    required final String lastName,
    required final String phone,
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
  Future<Either<Failure, User>> loginUser({
    required final String email,
    required final String password,
  }) async {
    try {
      final result = await _authRemoteDataSource.loginUser(
        LogInRequest(
          email: email,
          password: password,
        ),
      );
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
  Future<Either<Failure, Success>> sendMail({
    required final String email,
  }) async {
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
  Future<Either<Failure, Success>> verifyEmail({
    required final String otp,
  }) async {
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
  Future<Either<Failure, String>> checkEmail({
    required final String email,
  }) async {
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
  Future<Either<Failure, Success>> forgotPassword({
    required final String email,
  }) async {
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
    required final String resetToken,
    required final String password,
    required final String confirmPassword,
  }) async {
    try {
      final _ = await _authRemoteDataSource.resetPassword(
        ResetPasswordRequest(
          resetToken: resetToken,
          password: password,
          confirmPassword: confirmPassword,
        ),
      );
      return const Right(Success());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> verifyOtp({required final String otp}) async {
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
  Future<Either<Failure, User>> getUser({required final int userId}) async {
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
    required final String oldPassword,
    required final String newPassword,
    required final String confirmPassword,
  }) async {
    try {
      await _authRemoteDataSource.changePassword(
        ChangePasswordRequest(
          oldPassword: oldPassword,
          newPassword: newPassword,
          confirmPassword: confirmPassword,
        ),
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
    required final String desiredJob,
    required final String desiredWorkingProvince,
    required final String referenceLetter,
    required final List<Position> positions,
    required final List<Major> majors,
    required final List<Schedule> schedules,
    final FileRequest? cv,
  }) async {
    try {
      final Map<String, dynamic> value = {
        'candidateProfileDTO': jsonEncode({
          'candidateOtherInfoDTO': {
            'desiredJob': desiredJob,
            'desiredWorkingProvince': desiredWorkingProvince,
            'referenceLetter': referenceLetter,
            'positionDTOs': [
              ...positions.map(
                (final e) => PositionRequest(id: e.id).toJson(),
              ),
            ],
            'majorDTOs': [
              ...majors.map(
                (final e) => MajorRequest(id: e.id).toJson(),
              ),
            ],
            'scheduleDTOs': [
              ...schedules.map(
                (final e) => ScheduleRequest(id: e.id).toJson(),
              ),
            ],
          },
        }),
      };
      if (cv != null) {
        value['cv'] = MultipartFile.fromBytes(cv.data, filename: cv.name);
      }
      final result = await _authRemoteDataSource.updateJobInfo(
        FormData.fromMap(value),
      );
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateUserInfo({
    required final String firstName,
    required final String lastName,
    required final String birthDay,
    required final String phone,
    required final int gender,
    required final String location,
    required final String city,
    required final String district,
    required final University university,
    final FileRequest? avatar,
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
        value['avatar'] = MultipartFile.fromBytes(
          avatar.data,
          filename: avatar.name,
        );
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
      return Right(
        result.map((final university) => university.toEntity()).toList(),
      );
    } on DioException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
