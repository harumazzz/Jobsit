import 'package:equatable/equatable.dart';

final class ApiConstant extends Equatable {
  const ApiConstant._();

  @override
  List<Object?> get props => [];

  static const String baseUrl = 'http://192.168.31.122:8085/api/';

  static const String provinceApi = 'https://provinces.open-api.vn/api/';

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

  static const String jobListByCompanyEndpoint = '/job/company/{companyId}';

  static const String jobDetailEndpoint = '/job/{jobId}';

  static const String majorListEndpoint = '/major';

  static const String positionListEndpoint = '/position';

  static const String scheduleListEndpoint = '/schedule';

  static const String jobFilterEndpoint = '/job/filter';

  static const String jobSaveEndpoint = '/candidate-job-care';

  static const String searchableCandidateEndpoint = '/candidate/searchable';

  static const String emailNotificationEndpoint = '/candidate/email-notification';

  static const String changePasswordEndpoint = '/user/change-password';

  static const String logOutEndpoint = '/logout';

  static const String jobAppliedEndpoint = '/candidate-application';

  static const String candidateUpdateEndpoint = '/candidate/profile/personal';

  static const String jobUpdateEndpoint = '/candidate/profile/job';

  static const String universityEndpoint = '/university';
}

String queryImage(String logo) {
  return '${ApiConstant.baseUrl}file/display/$logo';
}