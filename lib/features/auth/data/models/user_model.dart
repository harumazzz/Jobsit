import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
sealed class UserCreationRequest with _$UserCreationRequest {
  const factory UserCreationRequest({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) = _UserCreationRequest;

  factory UserCreationRequest.fromJson(Map<String, dynamic> json) => _$UserCreationRequestFromJson(json);
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
    @JsonKey(name: 'roleDTO') required RoleResponse role,
    @JsonKey(name: 'statusDTO') required StatusResponse status,
  }) = _UserCreationResponse;

  factory UserCreationResponse.fromJson(Map<String, dynamic> json) => _$UserCreationResponseFromJson(json);
}

@freezed
abstract class UserResponse with _$UserResponse {
  const factory UserResponse({
    required String token,
    required String type,
    required String email,
    required String role,
    String? avatar,
    required int idUser,
  }) = _UserResponse;

  factory UserResponse.fromJson(Map<String, dynamic> json) => _$UserResponseFromJson(json);
}

@freezed
abstract class LogInRequest with _$LogInRequest {
  const factory LogInRequest({required String email, required String password}) = _LogInRequest;

  factory LogInRequest.fromJson(Map<String, dynamic> json) => _$LogInRequestFromJson(json);
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

extension UserResponseMapper on UserResponse {
  User toEntity() {
    return User(idUser: idUser, email: email, role: role, avatar: avatar);
  }
}
