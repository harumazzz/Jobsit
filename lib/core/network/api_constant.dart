import 'package:equatable/equatable.dart';

final class ApiConstant extends Equatable {
  const ApiConstant._();

  @override
  List<Object?> get props => [];

  static const String baseUrl = 'http://192.168.31.122:8085/api/';

  static const String loginEndpoint = '/login';

  static const String registerEndpoint = '/candidate';

  static const String sendMailEndpoint = '/mail/active-user';

  static const String verifyEmailEndpoint = '/active';

  static const String forgotPasswordEndpoint = '/user/forgot-password';

  static const String resetPasswordEndpoint = '/user/reset-password';

  static const String checkEmailEndpoint = '/user/check-email';

  static const String verifyOtpEndpoint = '/user/verify-otp';

  static const String getUserEndpoint = '/candidate/user/{userId}';

  static const String jobListEndpoint = '/job';

  static const String jobDetailEndpoint = '/job/{jobId}';
}
