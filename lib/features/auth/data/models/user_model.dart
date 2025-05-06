import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserCreationRequest with _$UserCreationRequest {
  const factory UserCreationRequest({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) = _UserCreationRequest;

  factory UserCreationRequest.fromJson(Map<String, dynamic> json) => _$UserCreationRequestFromJson(json);

  @override
  Map<String, dynamic> toJson();
}

@freezed
abstract class RegisterUserRequest with _$RegisterUserRequest {
  const factory RegisterUserRequest({@JsonKey(name: 'userCreationDTO') required UserCreationRequest user}) =
      _RegisterUserRequest;

  factory RegisterUserRequest.fromJson(Map<String, dynamic> json) => _$RegisterUserRequestFromJson(json);

  @override
  Map<String, dynamic> toJson();
}

@freezed
abstract class RoleResponse with _$RoleResponse {
  const factory RoleResponse({required int id, required String name}) = _RoleResponse;
  factory RoleResponse.fromJson(Map<String, dynamic> json) => _$RoleResponseFromJson(json);
}

@freezed
abstract class StatusResponse with _$StatusResponse {
  const factory StatusResponse({required int id, required String name}) = _StatusResponse;
  factory StatusResponse.fromJson(Map<String, dynamic> json) => _$StatusResponseFromJson(json);
}

@freezed
sealed class UniversityResponse with _$UniversityResponse {
  const factory UniversityResponse({required int id, required String name}) = _UniversityResponse;
  factory UniversityResponse.fromJson(Map<String, dynamic> json) => _$UniversityResponseFromJson(json);
}

@freezed
abstract class UserCreationResponse with _$UserCreationResponse {
  const factory UserCreationResponse({
    required int id,
    required String email,
    required String firstName,
    required String lastName,
    required String phone,
    @JsonKey(name: 'gender') bool? gender,
    @JsonKey(name: 'birthDay') String? birthDate,
    @JsonKey(name: 'avatar') String? avatar,
    @JsonKey(name: 'location') String? address,
    @JsonKey(name: 'mailReceive') required bool mailReceive,
    @JsonKey(name: 'roleDTO') required RoleResponse role,
    @JsonKey(name: 'statusDTO') required StatusResponse status,
  }) = _UserCreationResponse;

  factory UserCreationResponse.fromJson(Map<String, dynamic> json) => _$UserCreationResponseFromJson(json);
}

@freezed
sealed class MajorResponse with _$MajorResponse {
  const factory MajorResponse({required int id, required String name}) = _MajorResponse;
  factory MajorResponse.fromJson(Map<String, dynamic> json) => _$MajorResponseFromJson(json);
}

@freezed
sealed class PositionResponse with _$PositionResponse {
  const factory PositionResponse({required int id, required String name}) = _PositionResponse;
  factory PositionResponse.fromJson(Map<String, dynamic> json) => _$PositionResponseFromJson(json);
}

@freezed
sealed class ScheduleResponse with _$ScheduleResponse {
  const factory ScheduleResponse({required int id, required String name}) = _ScheduleResponse;
  factory ScheduleResponse.fromJson(Map<String, dynamic> json) => _$ScheduleResponseFromJson(json);
}

@freezed
sealed class JobInformationResponse with _$JobInformationResponse {
  const factory JobInformationResponse({
    @JsonKey(name: 'universityDTO') UniversityResponse? university,
    @JsonKey(name: 'referenceLetter') String? referenceLetter,
    @JsonKey(name: 'positionDTOs') required List<PositionResponse> positions,
    @JsonKey(name: 'majorDTOs') required List<MajorResponse> majors,
    @JsonKey(name: 'scheduleDTOs') required List<ScheduleResponse> schedules,
    @JsonKey(name: 'desiredJob') String? desiredJob,
    @JsonKey(name: 'desiredWorkingProvince') String? desiredWorkingProvince,
    @JsonKey(name: 'searchable') required bool searchable,
    @JsonKey(name: 'cv') String? cv,
  }) = _JobInformationResponse;

  factory JobInformationResponse.fromJson(Map<String, dynamic> json) => _$JobInformationResponseFromJson(json);
}

@freezed
abstract class RegisteredUserResponse with _$RegisteredUserResponse {
  const factory RegisteredUserResponse({
    required int id,
    @JsonKey(name: 'userDTO') required UserCreationResponse user,
    @JsonKey(name: 'candidateOtherInfoDTO') required JobInformationResponse jobInfo,
  }) = _RegisteredUserResponse;

  factory RegisteredUserResponse.fromJson(Map<String, dynamic> json) => _$RegisteredUserResponseFromJson(json);
}

@freezed
abstract class LogInResponse with _$LogInResponse {
  const factory LogInResponse({
    required String token,
    required String type,
    required String email,
    required String role,
    String? avatar,
    @JsonKey(name: 'idUser') required int userId,
  }) = _LogInResponse;

  factory LogInResponse.fromJson(Map<String, dynamic> json) => _$LogInResponseFromJson(json);
}

@freezed
abstract class LogInRequest with _$LogInRequest {
  const factory LogInRequest({required String email, required String password}) = _LogInRequest;

  factory LogInRequest.fromJson(Map<String, dynamic> json) => _$LogInRequestFromJson(json);

  @override
  Map<String, dynamic> toJson();
}

@freezed
abstract class ResetPasswordRequest with _$ResetPasswordRequest {
  const factory ResetPasswordRequest({
    required String resetToken,
    required String password,
    required String confirmPassword,
  }) = _ResetPasswordRequest;

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) => _$ResetPasswordRequestFromJson(json);

  @override
  Map<String, dynamic> toJson();
}

@freezed
abstract class SendMailResponse with _$SendMailResponse {
  const factory SendMailResponse({required String message}) = _SendMailResponse;

  factory SendMailResponse.fromJson(Map<String, dynamic> json) => _$SendMailResponseFromJson(json);
}

@freezed
abstract class VerifyMailResponse with _$VerifyMailResponse {
  const factory VerifyMailResponse({required String message}) = _VerifyMailResponse;

  factory VerifyMailResponse.fromJson(Map<String, dynamic> json) => _$VerifyMailResponseFromJson(json);
}

@freezed
abstract class GetUserResponse with _$GetUserResponse {
  const factory GetUserResponse({
    required int id,
    @JsonKey(name: 'userDTO') required UserCreationResponse user,
    @JsonKey(name: 'candidateOtherInfoDTO') required JobInformationResponse jobInfo,
  }) = _GetUserResponse;

  factory GetUserResponse.fromJson(Map<String, dynamic> json) => _$GetUserResponseFromJson(json);
}

@freezed
abstract class CheckMailResponse with _$CheckMailResponse {
  const factory CheckMailResponse({required String message}) = _CheckMailResponse;

  factory CheckMailResponse.fromJson(Map<String, dynamic> json) => _$CheckMailResponseFromJson(json);
}

@freezed
abstract class ForgotPasswordResponse with _$ForgotPasswordResponse {
  const factory ForgotPasswordResponse({required String message}) = _ForgotPasswordResponse;

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) => _$ForgotPasswordResponseFromJson(json);
}

@freezed
abstract class ResetPasswordResponse with _$ResetPasswordResponse {
  const factory ResetPasswordResponse({required String message}) = _ResetPasswordResponse;

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) => _$ResetPasswordResponseFromJson(json);
}

@freezed
abstract class VerifyOtpResponse with _$VerifyOtpResponse {
  const factory VerifyOtpResponse({required String message}) = _VerifyOtpResponse;

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) => _$VerifyOtpResponseFromJson(json);
}

extension UserCreationResponseMapper on UserCreationResponse {
  RegisteredUser toEntity() {
    return RegisteredUser(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      status: status.toEntity(),
      role: role.toEntity(),
    );
  }
}

extension MajorResponseMapper on MajorResponse {
  Major toEntity() {
    return Major(id: id, name: name);
  }
}

extension PositionResponseMapper on PositionResponse {
  Position toEntity() {
    return Position(id: id, name: name);
  }
}

extension ScheduleResponseMapper on ScheduleResponse {
  Schedule toEntity() {
    return Schedule(id: id, name: name);
  }
}

extension RoleResponseMapper on RoleResponse {
  Role toEntity() {
    return Role(id: id, name: name);
  }
}

extension UniversityResponseMapper on UniversityResponse {
  University toEntity() {
    return University(id: id, name: name);
  }
}

extension StatusResponseMapper on StatusResponse {
  Status toEntity() {
    return Status(id: id, name: name);
  }
}

extension GetUserResponseMapper on GetUserResponse {
  User toEntity() {
    return User(
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
      ),
      jobInfo: JobInformation(
        university: jobInfo.university?.toEntity(),
        referenceLetter: jobInfo.referenceLetter,
        positions: jobInfo.positions.map((position) => position.toEntity()).toList(),
        majors: jobInfo.majors.map((major) => major.toEntity()).toList(),
        schedules: jobInfo.schedules.map((schedule) => schedule.toEntity()).toList(),
        desiredJob: jobInfo.desiredJob,
        desiredWorkingProvince: jobInfo.desiredWorkingProvince,
        cv: jobInfo.cv,
        searchable: jobInfo.searchable,
      ),
    );
  }
}
