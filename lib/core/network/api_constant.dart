import 'package:equatable/equatable.dart';

/// A utility class that holds constant values for API endpoints and base URLs.
///
/// This class is not meant to be instantiated.
final class ApiConstant extends Equatable {
  const ApiConstant._();

  @override
  List<Object?> get props => [];

  /// The base URL for the main application API.
  static const String baseUrl = 'http://192.168.31.122:8085/api/';

  /// The base URL for the provinces API.
  static const String provinceApi = 'https://provinces.open-api.vn/api/';

  /// Endpoint for user login.
  static const String loginEndpoint = '/login';

  /// Endpoint for candidate registration.
  static const String registerEndpoint = '/candidate';

  /// Endpoint for sending an activation email.
  static const String sendMailEndpoint = '/mail/active-user';

  /// Endpoint for verifying a user's email.
  static const String verifyEmailEndpoint = '/active';

  /// Endpoint for initiating the forgot password process.
  static const String forgotPasswordEndpoint = '/user/forgot-password';

  /// Endpoint for resetting a user's password.
  static const String resetPasswordEndpoint = '/user/reset-password';

  /// Endpoint for checking if an email exists.
  static const String checkEmailEndpoint = '/user/check-email';

  /// Endpoint for verifying an OTP.
  static const String verifyOtpEndpoint = '/user/verify-otp';

  /// Endpoint to get user details. Requires `userId`.
  static const String getUserEndpoint = '/candidate/user/{userId}';

  /// Endpoint for listing jobs.
  static const String jobListEndpoint = '/job';

  /// Endpoint for listing jobs by company. Requires `companyId`.
  static const String jobListByCompanyEndpoint = '/job/company/{companyId}';

  /// Endpoint for getting job details. Requires `jobId`.
  static const String jobDetailEndpoint = '/job/{jobId}';

  /// Endpoint for listing majors.
  static const String majorListEndpoint = '/major';

  /// Endpoint for listing positions.
  static const String positionListEndpoint = '/position';

  /// Endpoint for listing schedules.
  static const String scheduleListEndpoint = '/schedule';

  /// Endpoint for filtering jobs.
  static const String jobFilterEndpoint = '/job/filter';

  /// Endpoint for saving a job by a candidate.
  static const String jobSaveEndpoint = '/candidate-job-care';

  /// Endpoint for making a candidate searchable.
  static const String searchableCandidateEndpoint = '/candidate/searchable';

  /// Endpoint for managing email notifications for a candidate.
  static const String emailNotificationEndpoint = '/candidate/email-notification';

  /// Endpoint for changing a user's password.
  static const String changePasswordEndpoint = '/user/change-password';

  /// Endpoint for user logout.
  static const String logOutEndpoint = '/logout';

  /// Endpoint for listing jobs applied by a candidate.
  static const String jobAppliedEndpoint = '/candidate-application';

  /// Endpoint for updating a candidate's personal profile.
  static const String candidateUpdateEndpoint = '/candidate/profile/personal';

  /// Endpoint for updating a candidate's job profile.
  static const String jobUpdateEndpoint = '/candidate/profile/job';

  /// Endpoint for listing universities.
  static const String universityEndpoint = '/university';
}

/// Constructs the full URL for displaying an image.
///
/// [logo] is the filename or identifier of the image.
/// Returns the complete URL to the image resource.
String queryImage(final String logo) => '${ApiConstant.baseUrl}file/display/$logo';
