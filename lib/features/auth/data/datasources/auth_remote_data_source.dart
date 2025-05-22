import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_constant.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

part 'auth_remote_data_source.g.dart';

/// Provides an instance of [AuthRemoteDataSource].
///
/// This data source is responsible for making API calls related to
/// authentication, user management, and profile updates.
@riverpod
AuthRemoteDataSource authRemoteDataSource(final Ref ref) {
  final dio = ref.watch(dioProvider);
  return _AuthRemoteDataSource(dio);
}

/// Abstract class for authentication-related remote data operations.
///
/// Defines the contract for API calls such as registration, login,
/// email verification, password management, user profile updates, etc.
/// Implementations will use a [Dio] client for network requests.
@RestApi()
abstract class AuthRemoteDataSource {
  /// Creates an [AuthRemoteDataSource] instance.
  ///
  /// Typically, this factory will be used by a code generator (like Retrofit)
  /// to create a concrete implementation.
  factory AuthRemoteDataSource(final Dio dio) = _AuthRemoteDataSource;

  /// Registers a new user.
  ///
  /// [request] contains the user's registration details.
  @POST(ApiConstant.registerEndpoint)
  Future<RegisteredUserResponse> registerUser(
    @Body() final RegisterUserRequest request,
  );

  /// Logs in an existing user.
  ///
  /// [request] contains the user's email and password.
  @POST(ApiConstant.loginEndpoint)
  Future<LogInResponse> loginUser(@Body() final LogInRequest request);

  /// Sends an activation or verification email to the user.
  ///
  /// [email] The email address to send the mail to.
  @GET(ApiConstant.sendMailEndpoint)
  Future<SendMailResponse> sendMail(@Query('email') final String email);

  /// Verifies a user's email using an OTP.
  ///
  /// [otp] The One-Time Password received by the user.
  @GET(ApiConstant.verifyEmailEndpoint)
  Future<VerifyMailResponse> verifyEmail(@Query('otp') final String otp);

  /// Checks if an email address is already registered.
  ///
  /// [email] The email address to check.
  @GET(ApiConstant.checkEmailEndpoint)
  Future<CheckMailResponse> checkEmail(@Query('email') final String email);

  /// Initiates the forgot password process for a user.
  ///
  /// [email] The email address of the user who forgot their password.
  @GET(ApiConstant.forgotPasswordEndpoint)
  Future<ForgotPasswordResponse> forgotPassword(
    @Query('email') final String email,
  );

  /// Resets a user's password using a reset token.
  ///
  /// [request] contains the reset token and the new password details.
  @POST(ApiConstant.resetPasswordEndpoint)
  Future<ResetPasswordResponse> resetPassword(
    @Body() final ResetPasswordRequest request,
  );

  /// Verifies an OTP, typically for password reset or other sensitive actions.
  ///
  /// [otp] The One-Time Password to verify.
  @POST(ApiConstant.verifyOtpEndpoint)
  Future<VerifyOtpResponse> verifyOtp(@Query('otp') final String otp);

  /// Fetches user details by their ID.
  ///
  /// [userId] The ID of the user to fetch.
  @GET(ApiConstant.getUserEndpoint)
  Future<GetUserResponse> getUser(@Path() final int userId);

  /// Updates the candidate's searchable status.
  @PUT(ApiConstant.searchableCandidateEndpoint)
  Future<HttpResponse> updateSearchableCandidate();

  /// Updates the candidate's email notification preferences.
  @PUT(ApiConstant.emailNotificationEndpoint)
  Future<HttpResponse> updateEmailNotification();

  /// Changes the current user's password.
  ///
  /// [request] contains the old password and the new password details.
  @PUT(ApiConstant.changePasswordEndpoint)
  Future<HttpResponse> changePassword(
    @Body() final ChangePasswordRequest request,
  );

  /// Logs out the current user by invalidating their token.
  ///
  /// [token] The authentication token of the user to log out.
  @POST(ApiConstant.logOutEndpoint)
  Future<HttpResponse> logOut(@Query('token') final String token);

  /// Updates the user's personal profile information.
  ///
  /// [request] A [FormData] object containing the user's updated details,
  /// potentially including an avatar image.
  @PUT(ApiConstant.candidateUpdateEndpoint)
  Future<GetUserResponse> updateUser(@Body() final FormData request);

  /// Updates the user's job-related profile information.
  ///
  /// [request] A [FormData] object containing the user's updated job
  /// preferences, potentially including a CV file.
  @PUT(ApiConstant.jobUpdateEndpoint)
  Future<GetUserResponse> updateJobInfo(@Body() final FormData request);

  /// Fetches a list of universities.
  @GET(ApiConstant.universityEndpoint)
  Future<List<UniversityResponse>> getUniversities();
}
