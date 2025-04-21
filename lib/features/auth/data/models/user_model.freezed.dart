// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserCreationRequest {

 String get email; String get password; String get firstName; String get lastName; String get phone;
/// Create a copy of UserCreationRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCreationRequestCopyWith<UserCreationRequest> get copyWith => _$UserCreationRequestCopyWithImpl<UserCreationRequest>(this as UserCreationRequest, _$identity);

  /// Serializes this UserCreationRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserCreationRequest&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.phone, phone) || other.phone == phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,password,firstName,lastName,phone);

@override
String toString() {
  return 'UserCreationRequest(email: $email, password: $password, firstName: $firstName, lastName: $lastName, phone: $phone)';
}


}

/// @nodoc
abstract mixin class $UserCreationRequestCopyWith<$Res>  {
  factory $UserCreationRequestCopyWith(UserCreationRequest value, $Res Function(UserCreationRequest) _then) = _$UserCreationRequestCopyWithImpl;
@useResult
$Res call({
 String email, String password, String firstName, String lastName, String phone
});




}
/// @nodoc
class _$UserCreationRequestCopyWithImpl<$Res>
    implements $UserCreationRequestCopyWith<$Res> {
  _$UserCreationRequestCopyWithImpl(this._self, this._then);

  final UserCreationRequest _self;
  final $Res Function(UserCreationRequest) _then;

/// Create a copy of UserCreationRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? password = null,Object? firstName = null,Object? lastName = null,Object? phone = null,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _UserCreationRequest implements UserCreationRequest {
  const _UserCreationRequest({required this.email, required this.password, required this.firstName, required this.lastName, required this.phone});
  factory _UserCreationRequest.fromJson(Map<String, dynamic> json) => _$UserCreationRequestFromJson(json);

@override final  String email;
@override final  String password;
@override final  String firstName;
@override final  String lastName;
@override final  String phone;

/// Create a copy of UserCreationRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCreationRequestCopyWith<_UserCreationRequest> get copyWith => __$UserCreationRequestCopyWithImpl<_UserCreationRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserCreationRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserCreationRequest&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.phone, phone) || other.phone == phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,password,firstName,lastName,phone);

@override
String toString() {
  return 'UserCreationRequest(email: $email, password: $password, firstName: $firstName, lastName: $lastName, phone: $phone)';
}


}

/// @nodoc
abstract mixin class _$UserCreationRequestCopyWith<$Res> implements $UserCreationRequestCopyWith<$Res> {
  factory _$UserCreationRequestCopyWith(_UserCreationRequest value, $Res Function(_UserCreationRequest) _then) = __$UserCreationRequestCopyWithImpl;
@override @useResult
$Res call({
 String email, String password, String firstName, String lastName, String phone
});




}
/// @nodoc
class __$UserCreationRequestCopyWithImpl<$Res>
    implements _$UserCreationRequestCopyWith<$Res> {
  __$UserCreationRequestCopyWithImpl(this._self, this._then);

  final _UserCreationRequest _self;
  final $Res Function(_UserCreationRequest) _then;

/// Create a copy of UserCreationRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,Object? firstName = null,Object? lastName = null,Object? phone = null,}) {
  return _then(_UserCreationRequest(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RoleResponse {

 int get id; String get name;
/// Create a copy of RoleResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoleResponseCopyWith<RoleResponse> get copyWith => _$RoleResponseCopyWithImpl<RoleResponse>(this as RoleResponse, _$identity);

  /// Serializes this RoleResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoleResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'RoleResponse(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $RoleResponseCopyWith<$Res>  {
  factory $RoleResponseCopyWith(RoleResponse value, $Res Function(RoleResponse) _then) = _$RoleResponseCopyWithImpl;
@useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class _$RoleResponseCopyWithImpl<$Res>
    implements $RoleResponseCopyWith<$Res> {
  _$RoleResponseCopyWithImpl(this._self, this._then);

  final RoleResponse _self;
  final $Res Function(RoleResponse) _then;

/// Create a copy of RoleResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _RoleResponse implements RoleResponse {
  const _RoleResponse({required this.id, required this.name});
  factory _RoleResponse.fromJson(Map<String, dynamic> json) => _$RoleResponseFromJson(json);

@override final  int id;
@override final  String name;

/// Create a copy of RoleResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoleResponseCopyWith<_RoleResponse> get copyWith => __$RoleResponseCopyWithImpl<_RoleResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoleResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoleResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'RoleResponse(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$RoleResponseCopyWith<$Res> implements $RoleResponseCopyWith<$Res> {
  factory _$RoleResponseCopyWith(_RoleResponse value, $Res Function(_RoleResponse) _then) = __$RoleResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class __$RoleResponseCopyWithImpl<$Res>
    implements _$RoleResponseCopyWith<$Res> {
  __$RoleResponseCopyWithImpl(this._self, this._then);

  final _RoleResponse _self;
  final $Res Function(_RoleResponse) _then;

/// Create a copy of RoleResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_RoleResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$StatusResponse {

 int get id; String get name;
/// Create a copy of StatusResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatusResponseCopyWith<StatusResponse> get copyWith => _$StatusResponseCopyWithImpl<StatusResponse>(this as StatusResponse, _$identity);

  /// Serializes this StatusResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatusResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'StatusResponse(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $StatusResponseCopyWith<$Res>  {
  factory $StatusResponseCopyWith(StatusResponse value, $Res Function(StatusResponse) _then) = _$StatusResponseCopyWithImpl;
@useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class _$StatusResponseCopyWithImpl<$Res>
    implements $StatusResponseCopyWith<$Res> {
  _$StatusResponseCopyWithImpl(this._self, this._then);

  final StatusResponse _self;
  final $Res Function(StatusResponse) _then;

/// Create a copy of StatusResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _StatusResponse implements StatusResponse {
  const _StatusResponse({required this.id, required this.name});
  factory _StatusResponse.fromJson(Map<String, dynamic> json) => _$StatusResponseFromJson(json);

@override final  int id;
@override final  String name;

/// Create a copy of StatusResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatusResponseCopyWith<_StatusResponse> get copyWith => __$StatusResponseCopyWithImpl<_StatusResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatusResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatusResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'StatusResponse(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$StatusResponseCopyWith<$Res> implements $StatusResponseCopyWith<$Res> {
  factory _$StatusResponseCopyWith(_StatusResponse value, $Res Function(_StatusResponse) _then) = __$StatusResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class __$StatusResponseCopyWithImpl<$Res>
    implements _$StatusResponseCopyWith<$Res> {
  __$StatusResponseCopyWithImpl(this._self, this._then);

  final _StatusResponse _self;
  final $Res Function(_StatusResponse) _then;

/// Create a copy of StatusResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_StatusResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$UserCreationResponse {

 int get id; String get email; String get firstName; String get lastName; String get phone; RoleResponse get role; StatusResponse get status;
/// Create a copy of UserCreationResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCreationResponseCopyWith<UserCreationResponse> get copyWith => _$UserCreationResponseCopyWithImpl<UserCreationResponse>(this as UserCreationResponse, _$identity);

  /// Serializes this UserCreationResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserCreationResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,firstName,lastName,phone,role,status);

@override
String toString() {
  return 'UserCreationResponse(id: $id, email: $email, firstName: $firstName, lastName: $lastName, phone: $phone, role: $role, status: $status)';
}


}

/// @nodoc
abstract mixin class $UserCreationResponseCopyWith<$Res>  {
  factory $UserCreationResponseCopyWith(UserCreationResponse value, $Res Function(UserCreationResponse) _then) = _$UserCreationResponseCopyWithImpl;
@useResult
$Res call({
 int id, String email, String firstName, String lastName, String phone, RoleResponse role, StatusResponse status
});


$RoleResponseCopyWith<$Res> get role;$StatusResponseCopyWith<$Res> get status;

}
/// @nodoc
class _$UserCreationResponseCopyWithImpl<$Res>
    implements $UserCreationResponseCopyWith<$Res> {
  _$UserCreationResponseCopyWithImpl(this._self, this._then);

  final UserCreationResponse _self;
  final $Res Function(UserCreationResponse) _then;

/// Create a copy of UserCreationResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? firstName = null,Object? lastName = null,Object? phone = null,Object? role = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as RoleResponse,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StatusResponse,
  ));
}
/// Create a copy of UserCreationResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RoleResponseCopyWith<$Res> get role {
  
  return $RoleResponseCopyWith<$Res>(_self.role, (value) {
    return _then(_self.copyWith(role: value));
  });
}/// Create a copy of UserCreationResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StatusResponseCopyWith<$Res> get status {
  
  return $StatusResponseCopyWith<$Res>(_self.status, (value) {
    return _then(_self.copyWith(status: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _UserCreationResponse implements UserCreationResponse {
  const _UserCreationResponse({required this.id, required this.email, required this.firstName, required this.lastName, required this.phone, required this.role, required this.status});
  factory _UserCreationResponse.fromJson(Map<String, dynamic> json) => _$UserCreationResponseFromJson(json);

@override final  int id;
@override final  String email;
@override final  String firstName;
@override final  String lastName;
@override final  String phone;
@override final  RoleResponse role;
@override final  StatusResponse status;

/// Create a copy of UserCreationResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCreationResponseCopyWith<_UserCreationResponse> get copyWith => __$UserCreationResponseCopyWithImpl<_UserCreationResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserCreationResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserCreationResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,firstName,lastName,phone,role,status);

@override
String toString() {
  return 'UserCreationResponse(id: $id, email: $email, firstName: $firstName, lastName: $lastName, phone: $phone, role: $role, status: $status)';
}


}

/// @nodoc
abstract mixin class _$UserCreationResponseCopyWith<$Res> implements $UserCreationResponseCopyWith<$Res> {
  factory _$UserCreationResponseCopyWith(_UserCreationResponse value, $Res Function(_UserCreationResponse) _then) = __$UserCreationResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, String email, String firstName, String lastName, String phone, RoleResponse role, StatusResponse status
});


@override $RoleResponseCopyWith<$Res> get role;@override $StatusResponseCopyWith<$Res> get status;

}
/// @nodoc
class __$UserCreationResponseCopyWithImpl<$Res>
    implements _$UserCreationResponseCopyWith<$Res> {
  __$UserCreationResponseCopyWithImpl(this._self, this._then);

  final _UserCreationResponse _self;
  final $Res Function(_UserCreationResponse) _then;

/// Create a copy of UserCreationResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? firstName = null,Object? lastName = null,Object? phone = null,Object? role = null,Object? status = null,}) {
  return _then(_UserCreationResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as RoleResponse,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StatusResponse,
  ));
}

/// Create a copy of UserCreationResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RoleResponseCopyWith<$Res> get role {
  
  return $RoleResponseCopyWith<$Res>(_self.role, (value) {
    return _then(_self.copyWith(role: value));
  });
}/// Create a copy of UserCreationResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StatusResponseCopyWith<$Res> get status {
  
  return $StatusResponseCopyWith<$Res>(_self.status, (value) {
    return _then(_self.copyWith(status: value));
  });
}
}


/// @nodoc
mixin _$UserResponse {

 String get token; String get type; String get email; String get role; String get avatar; int get idUser;
/// Create a copy of UserResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserResponseCopyWith<UserResponse> get copyWith => _$UserResponseCopyWithImpl<UserResponse>(this as UserResponse, _$identity);

  /// Serializes this UserResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserResponse&&(identical(other.token, token) || other.token == token)&&(identical(other.type, type) || other.type == type)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.idUser, idUser) || other.idUser == idUser));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,type,email,role,avatar,idUser);

@override
String toString() {
  return 'UserResponse(token: $token, type: $type, email: $email, role: $role, avatar: $avatar, idUser: $idUser)';
}


}

/// @nodoc
abstract mixin class $UserResponseCopyWith<$Res>  {
  factory $UserResponseCopyWith(UserResponse value, $Res Function(UserResponse) _then) = _$UserResponseCopyWithImpl;
@useResult
$Res call({
 String token, String type, String email, String role, String avatar, int idUser
});




}
/// @nodoc
class _$UserResponseCopyWithImpl<$Res>
    implements $UserResponseCopyWith<$Res> {
  _$UserResponseCopyWithImpl(this._self, this._then);

  final UserResponse _self;
  final $Res Function(UserResponse) _then;

/// Create a copy of UserResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? type = null,Object? email = null,Object? role = null,Object? avatar = null,Object? idUser = null,}) {
  return _then(_self.copyWith(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,avatar: null == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String,idUser: null == idUser ? _self.idUser : idUser // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _UserResponse implements UserResponse {
  const _UserResponse({required this.token, required this.type, required this.email, required this.role, required this.avatar, required this.idUser});
  factory _UserResponse.fromJson(Map<String, dynamic> json) => _$UserResponseFromJson(json);

@override final  String token;
@override final  String type;
@override final  String email;
@override final  String role;
@override final  String avatar;
@override final  int idUser;

/// Create a copy of UserResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserResponseCopyWith<_UserResponse> get copyWith => __$UserResponseCopyWithImpl<_UserResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserResponse&&(identical(other.token, token) || other.token == token)&&(identical(other.type, type) || other.type == type)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.idUser, idUser) || other.idUser == idUser));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,type,email,role,avatar,idUser);

@override
String toString() {
  return 'UserResponse(token: $token, type: $type, email: $email, role: $role, avatar: $avatar, idUser: $idUser)';
}


}

/// @nodoc
abstract mixin class _$UserResponseCopyWith<$Res> implements $UserResponseCopyWith<$Res> {
  factory _$UserResponseCopyWith(_UserResponse value, $Res Function(_UserResponse) _then) = __$UserResponseCopyWithImpl;
@override @useResult
$Res call({
 String token, String type, String email, String role, String avatar, int idUser
});




}
/// @nodoc
class __$UserResponseCopyWithImpl<$Res>
    implements _$UserResponseCopyWith<$Res> {
  __$UserResponseCopyWithImpl(this._self, this._then);

  final _UserResponse _self;
  final $Res Function(_UserResponse) _then;

/// Create a copy of UserResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? type = null,Object? email = null,Object? role = null,Object? avatar = null,Object? idUser = null,}) {
  return _then(_UserResponse(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,avatar: null == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String,idUser: null == idUser ? _self.idUser : idUser // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$LogInRequest {

 String get email; String get password;
/// Create a copy of LogInRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LogInRequestCopyWith<LogInRequest> get copyWith => _$LogInRequestCopyWithImpl<LogInRequest>(this as LogInRequest, _$identity);

  /// Serializes this LogInRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LogInRequest&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,password);

@override
String toString() {
  return 'LogInRequest(email: $email, password: $password)';
}


}

/// @nodoc
abstract mixin class $LogInRequestCopyWith<$Res>  {
  factory $LogInRequestCopyWith(LogInRequest value, $Res Function(LogInRequest) _then) = _$LogInRequestCopyWithImpl;
@useResult
$Res call({
 String email, String password
});




}
/// @nodoc
class _$LogInRequestCopyWithImpl<$Res>
    implements $LogInRequestCopyWith<$Res> {
  _$LogInRequestCopyWithImpl(this._self, this._then);

  final LogInRequest _self;
  final $Res Function(LogInRequest) _then;

/// Create a copy of LogInRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? password = null,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _LogInRequest implements LogInRequest {
  const _LogInRequest({required this.email, required this.password});
  factory _LogInRequest.fromJson(Map<String, dynamic> json) => _$LogInRequestFromJson(json);

@override final  String email;
@override final  String password;

/// Create a copy of LogInRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LogInRequestCopyWith<_LogInRequest> get copyWith => __$LogInRequestCopyWithImpl<_LogInRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LogInRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LogInRequest&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,password);

@override
String toString() {
  return 'LogInRequest(email: $email, password: $password)';
}


}

/// @nodoc
abstract mixin class _$LogInRequestCopyWith<$Res> implements $LogInRequestCopyWith<$Res> {
  factory _$LogInRequestCopyWith(_LogInRequest value, $Res Function(_LogInRequest) _then) = __$LogInRequestCopyWithImpl;
@override @useResult
$Res call({
 String email, String password
});




}
/// @nodoc
class __$LogInRequestCopyWithImpl<$Res>
    implements _$LogInRequestCopyWith<$Res> {
  __$LogInRequestCopyWithImpl(this._self, this._then);

  final _LogInRequest _self;
  final $Res Function(_LogInRequest) _then;

/// Create a copy of LogInRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,}) {
  return _then(_LogInRequest(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
