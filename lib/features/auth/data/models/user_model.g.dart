// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserCreationRequest _$UserCreationRequestFromJson(Map<String, dynamic> json) =>
    _UserCreationRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String,
    );

Map<String, dynamic> _$UserCreationRequestToJson(
  _UserCreationRequest instance,
) => <String, dynamic>{
  'email': instance.email,
  'password': instance.password,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'phone': instance.phone,
};

_RoleResponse _$RoleResponseFromJson(Map<String, dynamic> json) =>
    _RoleResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$RoleResponseToJson(_RoleResponse instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

_StatusResponse _$StatusResponseFromJson(Map<String, dynamic> json) =>
    _StatusResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$StatusResponseToJson(_StatusResponse instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

_UserCreationResponse _$UserCreationResponseFromJson(
  Map<String, dynamic> json,
) => _UserCreationResponse(
  id: (json['id'] as num).toInt(),
  email: json['email'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  phone: json['phone'] as String,
  role: RoleResponse.fromJson(json['role'] as Map<String, dynamic>),
  status: StatusResponse.fromJson(json['status'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserCreationResponseToJson(
  _UserCreationResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'phone': instance.phone,
  'role': instance.role,
  'status': instance.status,
};

_UserResponse _$UserResponseFromJson(Map<String, dynamic> json) =>
    _UserResponse(
      token: json['token'] as String,
      type: json['type'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      avatar: json['avatar'] as String,
      idUser: (json['idUser'] as num).toInt(),
    );

Map<String, dynamic> _$UserResponseToJson(_UserResponse instance) =>
    <String, dynamic>{
      'token': instance.token,
      'type': instance.type,
      'email': instance.email,
      'role': instance.role,
      'avatar': instance.avatar,
      'idUser': instance.idUser,
    };

_LogInRequest _$LogInRequestFromJson(Map<String, dynamic> json) =>
    _LogInRequest(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LogInRequestToJson(_LogInRequest instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};
