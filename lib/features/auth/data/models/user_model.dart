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
abstract class UserCreationResponse with _$UserCreationResponse {
  const factory UserCreationResponse({
    required int id,
    required String email,
    required String firstName,
    required String lastName,
    required String phone,
    String? avatar,
    @JsonKey(name: 'roleDTO') required RoleResponse role,
    @JsonKey(name: 'statusDTO') required StatusResponse status,
  }) = _UserCreationResponse;

  factory UserCreationResponse.fromJson(Map<String, dynamic> json) => _$UserCreationResponseFromJson(json);
}

@freezed
abstract class RegisteredUserResponse with _$RegisteredUserResponse {
  const factory RegisteredUserResponse({
    required int id,
    @JsonKey(name: 'userDTO') required UserCreationResponse user,
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
  const factory GetUserResponse({required int id, @JsonKey(name: 'userDTO') required UserCreationResponse user}) =
      _GetUserResponse;

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

extension RoleResponseMapper on RoleResponse {
  Role toEntity() {
    return Role(id: id, name: name);
  }
}

extension StatusResponseMapper on StatusResponse {
  Status toEntity() {
    return Status(id: id, name: name);
  }
}

extension UserResponseMapper on LogInResponse {
  User toEntity() {
    return User(userId: userId, email: email, role: role, avatar: avatar);
  }
}

extension GetUserResponseMapper on GetUserResponse {
  User toEntity() {
    return User(userId: user.id, email: user.email, role: user.role.name, avatar: user.avatar);
  }
}
