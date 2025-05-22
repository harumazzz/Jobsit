import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Represents a generic HTTP response from the API.
@freezed
sealed class HttpResponse with _$HttpResponse {
  /// Creates an [HttpResponse].
  ///
  /// [httpCode] The HTTP status code of the response.
  /// [message] A message associated with the response.
  /// [path] The API path that was called.
  const factory HttpResponse({
    required final int httpCode,
    required final String message,
    required final String path,
  }) = _HttpResponse;

  /// Creates an [HttpResponse] from a JSON map.
  factory HttpResponse.fromJson(
    final Map<String, dynamic> json,
  ) => _$HttpResponseFromJson(json);
}

/// Request model for changing a user's password.
@freezed
sealed class ChangePasswordRequest with _$ChangePasswordRequest {
  /// Creates a [ChangePasswordRequest].
  ///
  /// [oldPassword] The user's current password.
  /// [newPassword] The desired new password.
  /// [confirmPassword] Confirmation of the new password.
  const factory ChangePasswordRequest({
    required final String oldPassword,
    required final String newPassword,
    required final String confirmPassword,
  }) = _ChangePasswordRequest;

  /// Creates a [ChangePasswordRequest] from a JSON map.
  factory ChangePasswordRequest.fromJson(
    final Map<String, dynamic> json,
  ) => _$ChangePasswordRequestFromJson(json);

  /// Converts this [ChangePasswordRequest] to a JSON map.
  @override
  Map<String, dynamic> toJson();
}

/// Request model for creating a new user.
@freezed
abstract class UserCreationRequest with _$UserCreationRequest {
  /// Creates a [UserCreationRequest].
  ///
  /// Contains basic information required for user registration.
  const factory UserCreationRequest({
    required final String email,
    required final String password,
    required final String firstName,
    required final String lastName,
    required final String phone,
  }) = _UserCreationRequest;

  /// Creates a [UserCreationRequest] from a JSON map.
  factory UserCreationRequest.fromJson(
    final Map<String, dynamic> json,
  ) => _$UserCreationRequestFromJson(json);

  /// Converts this [UserCreationRequest] to a JSON map.
  @override
  Map<String, dynamic> toJson();
}

/// Request model for registering a user, wrapping [UserCreationRequest].
@freezed
abstract class RegisterUserRequest with _$RegisterUserRequest {
  /// Creates a [RegisterUserRequest].
  ///
  /// [user] The user creation details.
  const factory RegisterUserRequest({
    @JsonKey(name: 'userCreationDTO') required final UserCreationRequest user,
  }) = _RegisterUserRequest;

  /// Creates a [RegisterUserRequest] from a JSON map.
  factory RegisterUserRequest.fromJson(
    final Map<String, dynamic> json,
  ) => _$RegisterUserRequestFromJson(json);

  /// Converts this [RegisterUserRequest] to a JSON map.
  @override
  Map<String, dynamic> toJson();
}

/// API response model for a user role.
@freezed
abstract class RoleResponse with _$RoleResponse {
  /// Creates a [RoleResponse].
  ///
  /// [id] The ID of the role.
  /// [name] The name of the role.
  const factory RoleResponse({
    required final int id,
    required final String name,
  }) = _RoleResponse;

  /// Creates a [RoleResponse] from a JSON map.
  factory RoleResponse.fromJson(
    final Map<String, dynamic> json,
  ) => _$RoleResponseFromJson(json);
}

/// API response model for a user status.
@freezed
abstract class StatusResponse with _$StatusResponse {
  /// Creates a [StatusResponse].
  ///
  /// [id] The ID of the status.
  /// [name] The name of the status.
  const factory StatusResponse({
    required final int id,
    required final String name,
  }) = _StatusResponse;

  /// Creates a [StatusResponse] from a JSON map.
  factory StatusResponse.fromJson(
    final Map<String, dynamic> json,
  ) => _$StatusResponseFromJson(json);
}

/// API response model for a university.
@freezed
sealed class UniversityResponse with _$UniversityResponse {
  /// Creates a [UniversityResponse].
  ///
  /// [id] The ID of the university.
  /// [name] The name of the university.
  const factory UniversityResponse({
    required final int id,
    required final String name,
  }) = _UniversityResponse;

  /// Creates a [UniversityResponse] from a JSON map.
  factory UniversityResponse.fromJson(
    final Map<String, dynamic> json,
  ) => _$UniversityResponseFromJson(json);
}

/// API response model for user creation details.
@freezed
abstract class UserCreationResponse with _$UserCreationResponse {
  /// Creates a [UserCreationResponse].
  ///
  /// Contains detailed information about a newly created or fetched user.
  const factory UserCreationResponse({
    required final int id,
    required final String email,
    required final String firstName,
    required final String lastName,
    required final String phone,
    @JsonKey(name: 'gender') final bool? gender,
    @JsonKey(name: 'birthDay') final String? birthDate,
    @JsonKey(name: 'avatar') final String? avatar,
    @JsonKey(name: 'location') final String? address,
    @JsonKey(name: 'city') final String? city,
    @JsonKey(name: 'district') final String? district,
    @JsonKey(name: 'mailReceive') required final bool mailReceive,
    @JsonKey(name: 'roleDTO') required final RoleResponse role,
    @JsonKey(name: 'statusDTO') required final StatusResponse status,
  }) = _UserCreationResponse;

  /// Creates a [UserCreationResponse] from a JSON map.
  factory UserCreationResponse.fromJson(
    final Map<String, dynamic> json,
  ) => _$UserCreationResponseFromJson(json);
}

/// API response model for a major.
@freezed
sealed class MajorResponse with _$MajorResponse {
  /// Creates a [MajorResponse].
  ///
  /// [id] The ID of the major.
  /// [name] The name of the major.
  const factory MajorResponse({
    required final int id,
    required final String? name,
  }) = _MajorResponse;

  /// Creates a [MajorResponse] from a JSON map.
  factory MajorResponse.fromJson(
    final Map<String, dynamic> json,
  ) => _$MajorResponseFromJson(json);
}

/// API response model for a job position.
@freezed
sealed class PositionResponse with _$PositionResponse {
  /// Creates a [PositionResponse].
  ///
  /// [id] The ID of the position.
  /// [name] The name of the position.
  const factory PositionResponse({
    required final int id,
    required final String? name,
  }) = _PositionResponse;

  /// Creates a [PositionResponse] from a JSON map.
  factory PositionResponse.fromJson(
    final Map<String, dynamic> json,
  ) => _$PositionResponseFromJson(json);
}

/// API response model for a work schedule/type.
@freezed
sealed class ScheduleResponse with _$ScheduleResponse {
  /// Creates a [ScheduleResponse].
  ///
  /// [id] The ID of the schedule.
  /// [name] The name of the schedule.
  const factory ScheduleResponse({
    required final int id,
    required final String? name,
  }) = _ScheduleResponse;

  /// Creates a [ScheduleResponse] from a JSON map.
  factory ScheduleResponse.fromJson(
    final Map<String, dynamic> json,
  ) => _$ScheduleResponseFromJson(json);
}

/// API response model for a user's job-related information.
@freezed
sealed class JobInformationResponse with _$JobInformationResponse {
  /// Creates a [JobInformationResponse].
  ///
  /// Contains details about a user's professional background and preferences.
  const factory JobInformationResponse({
    @JsonKey(name: 'universityDTO') final UniversityResponse? university,
    @JsonKey(name: 'referenceLetter') final String? referenceLetter,
    // ignore: lines_longer_than_80_chars
    @JsonKey(name: 'positionDTOs') required final List<PositionResponse> positions,
    @JsonKey(name: 'majorDTOs') required final List<MajorResponse> majors,
    // ignore: lines_longer_than_80_chars
    @JsonKey(name: 'scheduleDTOs') required final List<ScheduleResponse> schedules,
    @JsonKey(name: 'desiredJob') final String? desiredJob,
    // ignore: lines_longer_than_80_chars
    @JsonKey(name: 'desiredWorkingProvince') final String? desiredWorkingProvince,
    @JsonKey(name: 'searchable') required final bool searchable,
    @JsonKey(name: 'cv') final String? cv,
  }) = _JobInformationResponse;

  /// Creates a [JobInformationResponse] from a JSON map.
  factory JobInformationResponse.fromJson(
    final Map<String, dynamic> json,
  ) => _$JobInformationResponseFromJson(json);
}

/// API response model for a registered user, combining user and job info.
@freezed
abstract class RegisteredUserResponse with _$RegisteredUserResponse {
  /// Creates a [RegisteredUserResponse].
  ///
  /// [id] The candidate's ID.
  /// [user] The core user details.
  /// [jobInfo] The user's job-related information.
  const factory RegisteredUserResponse({
    required final int id,
    @JsonKey(name: 'userDTO') required final UserCreationResponse user,
    // ignore: lines_longer_than_80_chars
    @JsonKey(name: 'candidateOtherInfoDTO') required final JobInformationResponse jobInfo,
  }) = _RegisteredUserResponse;

  /// Creates a [RegisteredUserResponse] from a JSON map.
  factory RegisteredUserResponse.fromJson(
    final Map<String, dynamic> json,
  ) => _$RegisteredUserResponseFromJson(json);
}

/// API response model for a successful login.
@freezed
abstract class LogInResponse with _$LogInResponse {
  /// Creates a [LogInResponse].
  ///
  /// [token] The authentication token.
  /// [type] The token type (e.g., "Bearer").
  /// [email] The user's email.
  /// [role] The user's role.
  /// [avatar] URL to the user's avatar, if available.
  /// [userId] The user's ID.
  const factory LogInResponse({
    required final String token,
    required final String type,
    required final String email,
    required final String role,
    final String? avatar,
    @JsonKey(name: 'idUser') required final int userId,
  }) = _LogInResponse;

  /// Creates a [LogInResponse] from a JSON map.
  factory LogInResponse.fromJson(
    final Map<String, dynamic> json,
  ) => _$LogInResponseFromJson(json);
}

/// Request model for user login.
@freezed
abstract class LogInRequest with _$LogInRequest {
  /// Creates a [LogInRequest].
  ///
  /// [email] The user's email.
  /// [password] The user's password.
  const factory LogInRequest({
    required final String email,
    required final String password,
  }) = _LogInRequest;

  /// Creates a [LogInRequest] from a JSON map.
  factory LogInRequest.fromJson(
    final Map<String, dynamic> json,
  ) => _$LogInRequestFromJson(json);

  /// Converts this [LogInRequest] to a JSON map.
  @override
  Map<String, dynamic> toJson();
}

/// Request model for resetting a user's password.
@freezed
abstract class ResetPasswordRequest with _$ResetPasswordRequest {
  /// Creates a [ResetPasswordRequest].
  ///
  /// [resetToken] The token received for password reset.
  /// [password] The new password.
  /// [confirmPassword] Confirmation of the new password.
  const factory ResetPasswordRequest({
    required final String resetToken,
    required final String password,
    required final String confirmPassword,
  }) = _ResetPasswordRequest;

  /// Creates a [ResetPasswordRequest] from a JSON map.
  factory ResetPasswordRequest.fromJson(
    final Map<String, dynamic> json,
  ) => _$ResetPasswordRequestFromJson(json);

  /// Converts this [ResetPasswordRequest] to a JSON map.
  @override
  Map<String, dynamic> toJson();
}

/// API response model for a send mail operation (e.g., email verification).
@freezed
abstract class SendMailResponse with _$SendMailResponse {
  /// Creates a [SendMailResponse].
  ///
  /// [message] A message indicating the result of the operation.
  const factory SendMailResponse({
    required final String message,
  }) = _SendMailResponse;

  /// Creates a [SendMailResponse] from a JSON map.
  factory SendMailResponse.fromJson(
    final Map<String, dynamic> json,
  ) => _$SendMailResponseFromJson(json);
}

/// API response model for an email verification operation.
@freezed
abstract class VerifyMailResponse with _$VerifyMailResponse {
  /// Creates a [VerifyMailResponse].
  ///
  /// [message] A message indicating the result of the verification.
  const factory VerifyMailResponse({
    required final String message,
  }) = _VerifyMailResponse;

  /// Creates a [VerifyMailResponse] from a JSON map.
  factory VerifyMailResponse.fromJson(
    final Map<String, dynamic> json,
  ) => _$VerifyMailResponseFromJson(json);
}

/// API response model for fetching user details.
@freezed
abstract class GetUserResponse with _$GetUserResponse {
  /// Creates a [GetUserResponse].
  ///
  /// [id] The candidate's ID.
  /// [user] The core user details.
  /// [jobInfo] The user's job-related information.
  const factory GetUserResponse({
    required final int id,
    @JsonKey(name: 'userDTO') required final UserCreationResponse user,
    // ignore: lines_longer_than_80_chars
    @JsonKey(name: 'candidateOtherInfoDTO') required final JobInformationResponse jobInfo,
  }) = _GetUserResponse;

  /// Creates a [GetUserResponse] from a JSON map.
  factory GetUserResponse.fromJson(
    final Map<String, dynamic> json,
  ) => _$GetUserResponseFromJson(json);
}

/// API response model for checking if an email exists.
@freezed
abstract class CheckMailResponse with _$CheckMailResponse {
  /// Creates a [CheckMailResponse].
  ///
  /// [message] A message indicating the result of the email check.
  const factory CheckMailResponse({
    required final String message,
  }) = _CheckMailResponse;

  /// Creates a [CheckMailResponse] from a JSON map.
  factory CheckMailResponse.fromJson(
    final Map<String, dynamic> json,
  ) => _$CheckMailResponseFromJson(json);
}

/// API response model for a forgot password request.
@freezed
abstract class ForgotPasswordResponse with _$ForgotPasswordResponse {
  /// Creates a [ForgotPasswordResponse].
  ///
  /// [message] A message indicating the result of the request.
  const factory ForgotPasswordResponse({
    required final String message,
  }) = _ForgotPasswordResponse;

  /// Creates a [ForgotPasswordResponse] from a JSON map.
  factory ForgotPasswordResponse.fromJson(
    final Map<String, dynamic> json,
  ) => _$ForgotPasswordResponseFromJson(json);
}

/// API response model for a password reset operation.
@freezed
abstract class ResetPasswordResponse with _$ResetPasswordResponse {
  /// Creates a [ResetPasswordResponse].
  ///
  /// [message] A message indicating the result of the password reset.
  const factory ResetPasswordResponse({
    required final String message,
  }) = _ResetPasswordResponse;

  /// Creates a [ResetPasswordResponse] from a JSON map.
  factory ResetPasswordResponse.fromJson(
    final Map<String, dynamic> json,
  ) => _$ResetPasswordResponseFromJson(json);
}

/// API response model for an OTP verification operation.
@freezed
abstract class VerifyOtpResponse with _$VerifyOtpResponse {
  /// Creates a [VerifyOtpResponse].
  ///
  /// [message] A message indicating the result of the OTP verification.
  const factory VerifyOtpResponse({
    required final String message,
  }) = _VerifyOtpResponse;

  /// Creates a [VerifyOtpResponse] from a JSON map.
  factory VerifyOtpResponse.fromJson(
    final Map<String, dynamic> json,
  ) => _$VerifyOtpResponseFromJson(json);
}

/// Extension methods for [UserCreationResponse].
extension UserCreationResponseMapper on UserCreationResponse {
  /// Converts a [UserCreationResponse] to a [RegisteredUser] entity.
  RegisteredUser toEntity() => RegisteredUser(
    id: id,
    email: email,
    firstName: firstName,
    lastName: lastName,
    phone: phone,
    status: status.toEntity(),
    role: role.toEntity(),
  );
}

/// Extension methods for [MajorResponse].
extension MajorResponseMapper on MajorResponse {
  /// Converts a [MajorResponse] to a [Major] entity.
  Major toEntity() => Major(id: id, name: name ?? '');
}

/// Extension methods for [PositionResponse].
extension PositionResponseMapper on PositionResponse {
  /// Converts a [PositionResponse] to a [Position] entity.
  Position toEntity() => Position(id: id, name: name ?? '');
}

/// Extension methods for [ScheduleResponse].
extension ScheduleResponseMapper on ScheduleResponse {
  /// Converts a [ScheduleResponse] to a [Schedule] entity.
  Schedule toEntity() => Schedule(id: id, name: name ?? '');
}

/// Extension methods for [RoleResponse].
extension RoleResponseMapper on RoleResponse {
  /// Converts a [RoleResponse] to a [Role] entity.
  Role toEntity() => Role(id: id, name: name);
}

/// Extension methods for [UniversityResponse].
extension UniversityResponseMapper on UniversityResponse {
  /// Converts a [UniversityResponse] to a [University] entity.
  University toEntity() => University(id: id, name: name);
}

/// Extension methods for [StatusResponse].
extension StatusResponseMapper on StatusResponse {
  /// Converts a [StatusResponse] to a [Status] entity.
  Status toEntity() => Status(id: id, name: name);
}

/// Extension methods for [GetUserResponse].
extension GetUserResponseMapper on GetUserResponse {
  /// Converts a [GetUserResponse] to a [User] entity.
  User toEntity() => User(
    userId: user.id,
    role: user.role.name,
    userInfo: UserInformation(
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      phone: user.phone,
      avatar: user.avatar,
      gender: user.gender ?? false,
      birthDate: user.birthDate,
      address: user.address,
      mailReceive: user.mailReceive,
      city: user.city,
      district: user.district,
    ),
    jobInfo: JobInformation(
      university: jobInfo.university?.toEntity(),
      referenceLetter: jobInfo.referenceLetter,
      positions: [
        ...jobInfo.positions.map((final position) => position.toEntity()),
      ],
      majors: [
        ...jobInfo.majors.map((final major) => major.toEntity()),
      ],
      schedules: [
        ...jobInfo.schedules.map((final schedule) => schedule.toEntity()),
      ],
      desiredJob: jobInfo.desiredJob,
      desiredWorkingProvince: jobInfo.desiredWorkingProvince,
      cv: jobInfo.cv,
      searchable: jobInfo.searchable,
    ),
  );
}

/// Request model for specifying a university by ID.
@freezed
sealed class UniversityRequest with _$UniversityRequest {
  /// Creates a [UniversityRequest].
  ///
  /// [id] The ID of the university.
  const factory UniversityRequest({
    required final int id,
  }) = _UniversityRequest;

  /// Creates a [UniversityRequest] from a JSON map.
  factory UniversityRequest.fromJson(
    final Map<String, dynamic> json,
  ) => _$UniversityRequestFromJson(json);

  /// Converts this [UniversityRequest] to a JSON map.
  @override
  Map<String, dynamic> toJson();
}

/// Request model for updating user information.
@freezed
sealed class UserUpdateRequest with _$UserUpdateRequest {
  /// Creates a [UserUpdateRequest].
  ///
  /// Contains fields for updating a user's personal details.
  const factory UserUpdateRequest({
    required final String firstName,
    required final String lastName,
    required final String birthDay,
    required final String phone,
    required final int gender,
    required final String location,
  }) = _UserUpdateRequest;

  /// Creates a [UserUpdateRequest] from a JSON map.
  factory UserUpdateRequest.fromJson(
    final Map<String, dynamic> json,
  ) => _$UserUpdateRequestFromJson(json);

  /// Converts this [UserUpdateRequest] to a JSON map.
  @override
  Map<String, dynamic> toJson();
}

/// Request model for specifying a job position by ID.
@freezed
sealed class PositionRequest with _$PositionRequest {
  /// Creates a [PositionRequest].
  ///
  /// [id] The ID of the position.
  const factory PositionRequest({
    required final int id,
  }) = _PositionRequest;

  /// Creates a [PositionRequest] from a JSON map.
  factory PositionRequest.fromJson(
    final Map<String, dynamic> json,
  ) => _$PositionRequestFromJson(json);

  /// Converts this [PositionRequest] to a JSON map.
  @override
  Map<String, dynamic> toJson();
}

/// Request model for specifying a major by ID.
@freezed
sealed class MajorRequest with _$MajorRequest {
  /// Creates a [MajorRequest].
  ///
  /// [id] The ID of the major.
  const factory MajorRequest({
    required final int id,
  }) = _MajorRequest;

  /// Creates a [MajorRequest] from a JSON map.
  factory MajorRequest.fromJson(
    final Map<String, dynamic> json,
  ) => _$MajorRequestFromJson(json);

  /// Converts this [MajorRequest] to a JSON map.
  @override
  Map<String, dynamic> toJson();
}

/// Request model for specifying a schedule by ID.
@freezed
sealed class ScheduleRequest with _$ScheduleRequest {
  /// Creates a [ScheduleRequest].
  ///
  /// [id] The ID of the schedule.
  const factory ScheduleRequest({
    required final int id,
  }) = _ScheduleRequest;

  /// Creates a [ScheduleRequest] from a JSON map.
  factory ScheduleRequest.fromJson(
    final Map<String, dynamic> json,
  ) => _$ScheduleRequestFromJson(json);

  /// Converts this [ScheduleRequest] to a JSON map.
  @override
  Map<String, dynamic> toJson();
}

/// Request model for updating a user's other (job-related) information.
@freezed
sealed class OtherInfoRequest with _$OtherInfoRequest {
  /// Creates an [OtherInfoRequest].
  ///
  /// Contains fields for updating a user's job preferences and professional
  /// details.
  const factory OtherInfoRequest({
    required final String desiredJob,
    required final String desiredWorkingProvince,
    required final String referenceLetter,
    required final List<PositionRequest> positionDTOs,
    required final List<MajorRequest> majorDTOs,
    required final List<ScheduleRequest> scheduleDTOs,
  }) = _OtherInfoRequest;

  /// Creates an [OtherInfoRequest] from a JSON map.
  factory OtherInfoRequest.fromJson(
    final Map<String, dynamic> json,
  ) => _$OtherInfoRequestFromJson(json);

  /// Converts this [OtherInfoRequest] to a JSON map.
  @override
  Map<String, dynamic> toJson();
}
