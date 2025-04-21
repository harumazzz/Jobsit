import 'dart:io';

import 'package:dart_either/dart_either.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_constant.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

part 'auth_remote_data_source.g.dart';

@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  final dio = ref.watch(dioProvider);
  return AuthRemoteDataSourceImpl(dio);
}

abstract class AuthRemoteDataSource {
  Future<Either<Failure, UserCreationResponse>> registerUser(
    UserCreationRequest request,
  );

  Future<Either<Failure, UserResponse>> loginUser(LogInRequest request);
}

final class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<Either<Failure, UserCreationResponse>> registerUser(
    UserCreationRequest request,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstant.registerEndpoint,
        data: {'userCreationDTO': request.toJson()},
      );
      if (response.statusCode == HttpStatus.created) {
        final result = UserCreationResponse.fromJson(response.data['userDTO']);
        return Right(result);
      } else {
        throw ServerException(response.data['message']);
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message']);
    } catch (e) {
      throw SystemException(e.toString());
    }
  }

  @override
  Future<Either<Failure, UserResponse>> loginUser(LogInRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstant.loginEndpoint,
        data: request.toJson(),
      );
      if (response.statusCode == HttpStatus.created) {
        final result = UserResponse.fromJson(response.data);
        return Right(result);
      } else {
        throw ServerException(response.data['message']);
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message']);
    } catch (e) {
      throw SystemException(e.toString());
    }
  }
}
