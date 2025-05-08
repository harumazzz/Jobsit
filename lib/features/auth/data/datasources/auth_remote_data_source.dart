import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_constant.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

part 'auth_remote_data_source.g.dart';

@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  final dio = ref.watch(dioProvider);
  return _AuthRemoteDataSource(dio);
}

@RestApi()
abstract class AuthRemoteDataSource {
  factory AuthRemoteDataSource(Dio dio) = _AuthRemoteDataSource;

  @POST(ApiConstant.registerEndpoint)
  Future<RegisteredUserResponse> registerUser(@Body() RegisterUserRequest request);

  @POST(ApiConstant.loginEndpoint)
  Future<LogInResponse> loginUser(@Body() LogInRequest request);

  @GET(ApiConstant.sendMailEndpoint)
  Future<SendMailResponse> sendMail(@Query('email') String email);

  @GET(ApiConstant.verifyEmailEndpoint)
  Future<VerifyMailResponse> verifyEmail(@Query('otp') String otp);

  @GET(ApiConstant.checkEmailEndpoint)
  Future<CheckMailResponse> checkEmail(@Query('email') String email);

  @GET(ApiConstant.forgotPasswordEndpoint)
  Future<ForgotPasswordResponse> forgotPassword(@Query('email') String email);

  @POST(ApiConstant.resetPasswordEndpoint)
  Future<ResetPasswordResponse> resetPassword(@Body() ResetPasswordRequest request);

  @POST(ApiConstant.verifyOtpEndpoint)
  Future<VerifyOtpResponse> verifyOtp(@Query('otp') String otp);

  @GET(ApiConstant.getUserEndpoint)
  Future<GetUserResponse> getUser(@Path() int userId);

  @PUT(ApiConstant.searchableCandidateEndpoint)
  Future<HttpResponse> updateSearchableCandidate();

  @PUT(ApiConstant.emailNotificationEndpoint)
  Future<HttpResponse> updateEmailNotification();

  @PUT(ApiConstant.changePasswordEndpoint)
  Future<HttpResponse> changePassword(@Body() ChangePasswordRequest request);

  @POST(ApiConstant.logOutEndpoint)
  Future<HttpResponse> logOut(@Query('token') String token);

  @PUT(ApiConstant.candidateUpdateEndpoint)
  Future<GetUserResponse> updateUser(@Body() FormData request);

  @PUT(ApiConstant.jobUpdateEndpoint)
  Future<GetUserResponse> updateJobInfo(@Body() FormData request);

  @GET(ApiConstant.universityEndpoint)
  Future<List<UniversityResponse>> getUniversities();
}
