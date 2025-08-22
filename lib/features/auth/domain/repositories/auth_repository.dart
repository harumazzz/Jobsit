import 'package:dart_either/dart_either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/file_service.dart';
import '../entities/user.dart';

/// Abstract repository defining the contract for authentication operations.
///
/// This includes user registration, login, email verification, password
/// management, profile updates, and fetching related data like universities.
abstract class AuthRepository {
  /// Registers a new user with the provided details.
  ///
  /// Returns a [RegisteredUser] on success, or a [Failure] on error.
  Future<Either<Failure, RegisteredUser>> registerUser({
    required final String email,
    required final String password,
    required final String firstName,
    required final String lastName,
    required final String phone,
  });

  /// Logs in an existing user with the given credentials.
  ///
  /// Returns a [User] object on successful login, or a [Failure] on error.
  /// Handles saving the authentication token and user ID.
  Future<Either<Failure, User>> loginUser({
    required final String email,
    required final String password,
  });

  /// Sends a verification or activation email to the specified [email].
  ///
  /// Returns [Success] on successful email dispatch, or a [Failure] on error.
  Future<Either<Failure, Success>> sendMail({required final String email});

  /// Verifies a user's email using the provided One-Time Password [otp].
  ///
  /// Returns [Success] on successful verification, or a [Failure] on error.
  Future<Either<Failure, Success>> verifyEmail({required final String otp});

  /// Checks if the given [email] is already registered or available.
  ///
  /// Returns a message string (e.g., "Email available") on success,
  /// or a [Failure] on error.
  Future<Either<Failure, String>> checkEmail({required final String email});

  /// Initiates the password recovery process for the specified [email].
  ///
  /// Returns [Success] if the request is processed, or a [Failure] on error.
  Future<Either<Failure, Success>> forgotPassword({
    required final String email,
  });

  /// Resets the user's password using a [resetToken].
  ///
  /// Requires the new [password] and [confirmPassword].
  /// Returns [Success] on successful password reset, or a [Failure] on error.
  Future<Either<Failure, Success>> resetPassword({
    required final String resetToken,
    required final String password,
    required final String confirmPassword,
  });

  /// Verifies a One-Time Password [otp], typically for password reset flows.
  ///
  /// Returns a message string on successful OTP verification,
  /// or a [Failure] on error.
  Future<Either<Failure, String>> verifyOtp({required final String otp});

  /// Fetches the full user profile for the given [userId].
  ///
  /// Returns a [User] object on success, or a [Failure] on error.
  Future<Either<Failure, User>> getUser({required final int userId});

  /// Toggles the searchable status of the candidate's profile.
  ///
  /// Returns [Success] on successful update, or a [Failure] on error.
  Future<Either<Failure, Success>> updateSearchableCandidate();

  /// Toggles the email notification preference for the candidate.
  ///
  /// Returns [Success] on successful update, or a [Failure] on error.
  Future<Either<Failure, Success>> updateEmailNotification();

  /// Changes the current user's password.
  ///
  /// Requires [oldPassword], [newPassword], and [confirmPassword].
  /// Returns [Success] on successful password change, or a [Failure] on error.
  Future<Either<Failure, Success>> changePassword({
    required final String oldPassword,
    required final String newPassword,
    required final String confirmPassword,
  });

  /// Logs out the current user.
  ///
  /// Handles token invalidation on the server and local token deletion.
  /// Returns [Success] on successful logout, or a [Failure] on error.
  Future<Either<Failure, Success>> logOut();

  /// Updates the user's personal information.
  ///
  /// [avatar] is an optional [FileRequest] for uploading a new avatar image.
  /// Returns the updated [User] object on success, or a [Failure] on error.
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
  });

  /// Updates the user's job-related information.
  ///
  /// [cv] is an optional [FileRequest] for uploading a new CV.
  /// Returns the updated [User] object on success, or a [Failure] on error.
  Future<Either<Failure, User>> updateJobInfo({
    required final String desiredJob,
    required final String desiredWorkingProvince,
    required final String referenceLetter,
    required final List<Position> positions,
    required final List<Major> majors,
    required final List<Schedule> schedules,
    final FileRequest? cv,
  });

  /// Fetches a list of all available universities.
  ///
  /// Returns a list of [University] objects on success
  /// or a [Failure] on error.
  Future<Either<Failure, List<University>>> getUniversities();
}
