import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

/// Represents a user status (e.g., active, inactive).
@freezed
sealed class Status with _$Status {
  /// Creates a [Status] instance.
  ///
  /// [id] The unique identifier for the status.
  /// [name] The display name of the status.
  const factory Status({
    required final int id,
    required final String name,
  }) = _Status;
}

/// Represents a user role (e.g., candidate, employer).
@freezed
sealed class Role with _$Role {
  /// Creates a [Role] instance.
  ///
  /// [id] The unique identifier for the role.
  /// [name] The display name of the role.
  const factory Role({
    required final int id,
    required final String name,
  }) = _Role;
}

/// Represents a university or educational institution.
@freezed
sealed class University with _$University {
  /// Creates a [University] instance.
  ///
  /// [id] The unique identifier for the university.
  /// [name] The name of the university.
  const factory University({
    required final int id,
    required final String name,
  }) = _University;
}

/// Represents a user who has completed the initial registration process.
@freezed
sealed class RegisteredUser with _$RegisteredUser {
  /// Creates a [RegisteredUser] instance.
  ///
  /// Contains basic information captured during registration.
  const factory RegisteredUser({
    required final int id,
    required final String email,
    required final String firstName,
    required final String lastName,
    required final String phone,
    required final Status status,
    required final Role role,
  }) = _RegisteredUser;
}

/// Represents detailed personal information about a user.
@freezed
sealed class UserInformation with _$UserInformation {
  /// Creates a [UserInformation] instance.
  ///
  /// Contains fields like contact details, demographics, and preferences.
  const factory UserInformation({
    required final String email,
    required final String firstName,
    required final String lastName,
    required final String phone,
    required final bool gender,
    required final bool mailReceive,
    final String? city,
    final String? district,
    final String? birthDate,
    final String? address,
    final String? avatar,
  }) = _UserInformation;
}

/// Represents an academic major or field of study.
@freezed
sealed class Major with _$Major {
  /// Creates a [Major] instance.
  ///
  /// [id] The unique identifier for the major.
  /// [name] The name of the major.
  const factory Major({
    required final int id,
    required final String name,
  }) = _Major;
}

/// Represents a job position or title.
@freezed
sealed class Position with _$Position {
  /// Creates a [Position] instance.
  ///
  /// [id] The unique identifier for the position.
  /// [name] The name of the position.
  const factory Position({
    required final int id,
    required final String name,
  }) = _Position;
}

/// Represents a work schedule or employment type (e.g., full-time, part-time).
@freezed
sealed class Schedule with _$Schedule {
  /// Creates a [Schedule] instance.
  ///
  /// [id] The unique identifier for the schedule type.
  /// [name] The name of the schedule type.
  const factory Schedule({
    required final int id,
    required final String name,
  }) = _Schedule;
}

/// Represents a user's job-related information and preferences.
@freezed
sealed class JobInformation with _$JobInformation {
  /// Creates a [JobInformation] instance.
  ///
  /// Contains details like desired job, work location, CV, and skills.
  const factory JobInformation({
    final University? university,
    final String? referenceLetter,
    required final List<Position> positions,
    required final List<Major> majors,
    required final List<Schedule> schedules,
    required final bool searchable,
    final String? desiredJob,
    final String? desiredWorkingProvince,
    final String? cv,
  }) = _JobInformation;
}

/// Represents a comprehensive user profile.
@freezed
sealed class User with _$User {
  /// Creates a [User] instance.
  ///
  /// [userId] The unique identifier for the user.
  /// [role] The user's role within the application.
  /// [userInfo] The user's personal information.
  /// [jobInfo] The user's job-related information.
  const factory User({
    required final int userId,
    required final String role,
    required final UserInformation userInfo,
    required final JobInformation jobInfo,
  }) = _User;
}
