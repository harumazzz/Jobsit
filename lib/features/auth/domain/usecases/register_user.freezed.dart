// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RegisterUserParams {

 String get email; String get password; String get firstName; String get lastName; String get phone;
/// Create a copy of RegisterUserParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterUserParamsCopyWith<RegisterUserParams> get copyWith => _$RegisterUserParamsCopyWithImpl<RegisterUserParams>(this as RegisterUserParams, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterUserParams&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.phone, phone) || other.phone == phone));
}


@override
int get hashCode => Object.hash(runtimeType,email,password,firstName,lastName,phone);

@override
String toString() {
  return 'RegisterUserParams(email: $email, password: $password, firstName: $firstName, lastName: $lastName, phone: $phone)';
}


}

/// @nodoc
abstract mixin class $RegisterUserParamsCopyWith<$Res>  {
  factory $RegisterUserParamsCopyWith(RegisterUserParams value, $Res Function(RegisterUserParams) _then) = _$RegisterUserParamsCopyWithImpl;
@useResult
$Res call({
 String email, String password, String firstName, String lastName, String phone
});




}
/// @nodoc
class _$RegisterUserParamsCopyWithImpl<$Res>
    implements $RegisterUserParamsCopyWith<$Res> {
  _$RegisterUserParamsCopyWithImpl(this._self, this._then);

  final RegisterUserParams _self;
  final $Res Function(RegisterUserParams) _then;

/// Create a copy of RegisterUserParams
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


class _RegisterUserParams implements RegisterUserParams {
  const _RegisterUserParams({required this.email, required this.password, required this.firstName, required this.lastName, required this.phone});
  

@override final  String email;
@override final  String password;
@override final  String firstName;
@override final  String lastName;
@override final  String phone;

/// Create a copy of RegisterUserParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterUserParamsCopyWith<_RegisterUserParams> get copyWith => __$RegisterUserParamsCopyWithImpl<_RegisterUserParams>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterUserParams&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.phone, phone) || other.phone == phone));
}


@override
int get hashCode => Object.hash(runtimeType,email,password,firstName,lastName,phone);

@override
String toString() {
  return 'RegisterUserParams(email: $email, password: $password, firstName: $firstName, lastName: $lastName, phone: $phone)';
}


}

/// @nodoc
abstract mixin class _$RegisterUserParamsCopyWith<$Res> implements $RegisterUserParamsCopyWith<$Res> {
  factory _$RegisterUserParamsCopyWith(_RegisterUserParams value, $Res Function(_RegisterUserParams) _then) = __$RegisterUserParamsCopyWithImpl;
@override @useResult
$Res call({
 String email, String password, String firstName, String lastName, String phone
});




}
/// @nodoc
class __$RegisterUserParamsCopyWithImpl<$Res>
    implements _$RegisterUserParamsCopyWith<$Res> {
  __$RegisterUserParamsCopyWithImpl(this._self, this._then);

  final _RegisterUserParams _self;
  final $Res Function(_RegisterUserParams) _then;

/// Create a copy of RegisterUserParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,Object? firstName = null,Object? lastName = null,Object? phone = null,}) {
  return _then(_RegisterUserParams(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
