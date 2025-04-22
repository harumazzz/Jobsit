import 'dart:io';

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
  Future<UserCreationResponse> registerUser(UserCreationRequest request);

  Future<UserResponse> loginUser(LogInRequest request);

  Future<Success> sendMail(String email);

  Future<Success> verifyEmail(String otp);

  Future<String> checkEmail(String email);

  Future<Success> forgotPassword(String email);

  Future<Success> resetPassword(ResetPasswordRequest request);

  Future<String> verifyOtp(String otp);
}

final class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<UserCreationResponse> registerUser(UserCreationRequest request) async {
    try {
      final response = await _dio.post(ApiConstant.registerEndpoint, data: {'userCreationDTO': request.toJson()});
      if (response.statusCode == HttpStatus.created) {
        final result = UserCreationResponse.fromJson(response.data['userDTO']);
        return result;
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
  Future<UserResponse> loginUser(LogInRequest request) async {
    try {
      final response = await _dio.post(ApiConstant.loginEndpoint, data: request.toJson());
      if (response.statusCode == HttpStatus.created) {
        final result = UserResponse.fromJson(response.data);
        return result;
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
  Future<Success> sendMail(String email) async {
    try {
      final response = await _dio.get(ApiConstant.sendOtpEndpoint, queryParameters: {'email': email});
      if (response.statusCode == HttpStatus.ok) {
        return const Success();
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
  Future<Success> verifyEmail(String otp) async {
    try {
      final response = await _dio.get(ApiConstant.verifyEmailEndpoint, queryParameters: {'otp': otp});
      if (response.statusCode == HttpStatus.ok) {
        return const Success();
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
  Future<String> checkEmail(String email) async {
    try {
      final response = await _dio.get(ApiConstant.checkEmailEndpoint, queryParameters: {'email': email});
      if (response.statusCode == HttpStatus.ok) {
        return response.data['message'] as String;
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
  Future<Success> forgotPassword(String email) async {
    try {
      final response = await _dio.get(ApiConstant.forgotPasswordEndpoint, queryParameters: {'email': email});
      if (response.statusCode == HttpStatus.ok) {
        return const Success();
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
  Future<Success> resetPassword(ResetPasswordRequest request) async {
    try {
      final response = await _dio.post(ApiConstant.resetPasswordEndpoint, data: request.toJson());
      if (response.statusCode == HttpStatus.ok) {
        return const Success();
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
  Future<String> verifyOtp(String otp) async {
    try {
      final response = await _dio.post(ApiConstant.verifyEmailEndpoint, queryParameters: {'otp': otp});
      if (response.statusCode == HttpStatus.ok) {
        return response.data['message'] as String;
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
