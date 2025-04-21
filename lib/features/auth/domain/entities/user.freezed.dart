// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Status {

 int get id; String get name;
/// Create a copy of Status
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatusCopyWith<Status> get copyWith => _$StatusCopyWithImpl<Status>(this as Status, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Status&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'Status(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $StatusCopyWith<$Res>  {
  factory $StatusCopyWith(Status value, $Res Function(Status) _then) = _$StatusCopyWithImpl;
@useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class _$StatusCopyWithImpl<$Res>
    implements $StatusCopyWith<$Res> {
  _$StatusCopyWithImpl(this._self, this._then);

  final Status _self;
  final $Res Function(Status) _then;

/// Create a copy of Status
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


class _Status implements Status {
  const _Status({required this.id, required this.name});
  

@override final  int id;
@override final  String name;

/// Create a copy of Status
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatusCopyWith<_Status> get copyWith => __$StatusCopyWithImpl<_Status>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Status&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'Status(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$StatusCopyWith<$Res> implements $StatusCopyWith<$Res> {
  factory _$StatusCopyWith(_Status value, $Res Function(_Status) _then) = __$StatusCopyWithImpl;
@override @useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class __$StatusCopyWithImpl<$Res>
    implements _$StatusCopyWith<$Res> {
  __$StatusCopyWithImpl(this._self, this._then);

  final _Status _self;
  final $Res Function(_Status) _then;

/// Create a copy of Status
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_Status(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$Role {

 int get id; String get name;
/// Create a copy of Role
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoleCopyWith<Role> get copyWith => _$RoleCopyWithImpl<Role>(this as Role, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Role&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'Role(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $RoleCopyWith<$Res>  {
  factory $RoleCopyWith(Role value, $Res Function(Role) _then) = _$RoleCopyWithImpl;
@useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class _$RoleCopyWithImpl<$Res>
    implements $RoleCopyWith<$Res> {
  _$RoleCopyWithImpl(this._self, this._then);

  final Role _self;
  final $Res Function(Role) _then;

/// Create a copy of Role
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


class _Role implements Role {
  const _Role({required this.id, required this.name});
  

@override final  int id;
@override final  String name;

/// Create a copy of Role
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoleCopyWith<_Role> get copyWith => __$RoleCopyWithImpl<_Role>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Role&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'Role(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$RoleCopyWith<$Res> implements $RoleCopyWith<$Res> {
  factory _$RoleCopyWith(_Role value, $Res Function(_Role) _then) = __$RoleCopyWithImpl;
@override @useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class __$RoleCopyWithImpl<$Res>
    implements _$RoleCopyWith<$Res> {
  __$RoleCopyWithImpl(this._self, this._then);

  final _Role _self;
  final $Res Function(_Role) _then;

/// Create a copy of Role
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_Role(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$RegisteredUser {

 int get id; String get email; String get firstName; String get lastName; String get phone; Status get status; Role get role;
/// Create a copy of RegisteredUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisteredUserCopyWith<RegisteredUser> get copyWith => _$RegisteredUserCopyWithImpl<RegisteredUser>(this as RegisteredUser, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisteredUser&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.status, status) || other.status == status)&&(identical(other.role, role) || other.role == role));
}


@override
int get hashCode => Object.hash(runtimeType,id,email,firstName,lastName,phone,status,role);

@override
String toString() {
  return 'RegisteredUser(id: $id, email: $email, firstName: $firstName, lastName: $lastName, phone: $phone, status: $status, role: $role)';
}


}

/// @nodoc
abstract mixin class $RegisteredUserCopyWith<$Res>  {
  factory $RegisteredUserCopyWith(RegisteredUser value, $Res Function(RegisteredUser) _then) = _$RegisteredUserCopyWithImpl;
@useResult
$Res call({
 int id, String email, String firstName, String lastName, String phone, Status status, Role role
});


$StatusCopyWith<$Res> get status;$RoleCopyWith<$Res> get role;

}
/// @nodoc
class _$RegisteredUserCopyWithImpl<$Res>
    implements $RegisteredUserCopyWith<$Res> {
  _$RegisteredUserCopyWithImpl(this._self, this._then);

  final RegisteredUser _self;
  final $Res Function(RegisteredUser) _then;

/// Create a copy of RegisteredUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? firstName = null,Object? lastName = null,Object? phone = null,Object? status = null,Object? role = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as Status,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role,
  ));
}
/// Create a copy of RegisteredUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StatusCopyWith<$Res> get status {
  
  return $StatusCopyWith<$Res>(_self.status, (value) {
    return _then(_self.copyWith(status: value));
  });
}/// Create a copy of RegisteredUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RoleCopyWith<$Res> get role {
  
  return $RoleCopyWith<$Res>(_self.role, (value) {
    return _then(_self.copyWith(role: value));
  });
}
}


/// @nodoc


class _RegisteredUser implements RegisteredUser {
  const _RegisteredUser({required this.id, required this.email, required this.firstName, required this.lastName, required this.phone, required this.status, required this.role});
  

@override final  int id;
@override final  String email;
@override final  String firstName;
@override final  String lastName;
@override final  String phone;
@override final  Status status;
@override final  Role role;

/// Create a copy of RegisteredUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisteredUserCopyWith<_RegisteredUser> get copyWith => __$RegisteredUserCopyWithImpl<_RegisteredUser>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisteredUser&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.status, status) || other.status == status)&&(identical(other.role, role) || other.role == role));
}


@override
int get hashCode => Object.hash(runtimeType,id,email,firstName,lastName,phone,status,role);

@override
String toString() {
  return 'RegisteredUser(id: $id, email: $email, firstName: $firstName, lastName: $lastName, phone: $phone, status: $status, role: $role)';
}


}

/// @nodoc
abstract mixin class _$RegisteredUserCopyWith<$Res> implements $RegisteredUserCopyWith<$Res> {
  factory _$RegisteredUserCopyWith(_RegisteredUser value, $Res Function(_RegisteredUser) _then) = __$RegisteredUserCopyWithImpl;
@override @useResult
$Res call({
 int id, String email, String firstName, String lastName, String phone, Status status, Role role
});


@override $StatusCopyWith<$Res> get status;@override $RoleCopyWith<$Res> get role;

}
/// @nodoc
class __$RegisteredUserCopyWithImpl<$Res>
    implements _$RegisteredUserCopyWith<$Res> {
  __$RegisteredUserCopyWithImpl(this._self, this._then);

  final _RegisteredUser _self;
  final $Res Function(_RegisteredUser) _then;

/// Create a copy of RegisteredUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? firstName = null,Object? lastName = null,Object? phone = null,Object? status = null,Object? role = null,}) {
  return _then(_RegisteredUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as Status,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role,
  ));
}

/// Create a copy of RegisteredUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StatusCopyWith<$Res> get status {
  
  return $StatusCopyWith<$Res>(_self.status, (value) {
    return _then(_self.copyWith(status: value));
  });
}/// Create a copy of RegisteredUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RoleCopyWith<$Res> get role {
  
  return $RoleCopyWith<$Res>(_self.role, (value) {
    return _then(_self.copyWith(role: value));
  });
}
}

/// @nodoc
mixin _$User {

 int get idUser; String get email; String get role; String get avatar;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.idUser, idUser) || other.idUser == idUser)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.avatar, avatar) || other.avatar == avatar));
}


@override
int get hashCode => Object.hash(runtimeType,idUser,email,role,avatar);

@override
String toString() {
  return 'User(idUser: $idUser, email: $email, role: $role, avatar: $avatar)';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
 int idUser, String email, String role, String avatar
});




}
/// @nodoc
class _$UserCopyWithImpl<$Res>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idUser = null,Object? email = null,Object? role = null,Object? avatar = null,}) {
  return _then(_self.copyWith(
idUser: null == idUser ? _self.idUser : idUser // ignore: cast_nullable_to_non_nullable
as int,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,avatar: null == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc


class _User implements User {
  const _User({required this.idUser, required this.email, required this.role, required this.avatar});
  

@override final  int idUser;
@override final  String email;
@override final  String role;
@override final  String avatar;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCopyWith<_User> get copyWith => __$UserCopyWithImpl<_User>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.idUser, idUser) || other.idUser == idUser)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.avatar, avatar) || other.avatar == avatar));
}


@override
int get hashCode => Object.hash(runtimeType,idUser,email,role,avatar);

@override
String toString() {
  return 'User(idUser: $idUser, email: $email, role: $role, avatar: $avatar)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
 int idUser, String email, String role, String avatar
});




}
/// @nodoc
class __$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idUser = null,Object? email = null,Object? role = null,Object? avatar = null,}) {
  return _then(_User(
idUser: null == idUser ? _self.idUser : idUser // ignore: cast_nullable_to_non_nullable
as int,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,avatar: null == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
