// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LoginUserParams {

 String get email; String get password;
/// Create a copy of LoginUserParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginUserParamsCopyWith<LoginUserParams> get copyWith => _$LoginUserParamsCopyWithImpl<LoginUserParams>(this as LoginUserParams, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginUserParams&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password));
}


@override
int get hashCode => Object.hash(runtimeType,email,password);

@override
String toString() {
  return 'LoginUserParams(email: $email, password: $password)';
}


}

/// @nodoc
abstract mixin class $LoginUserParamsCopyWith<$Res>  {
  factory $LoginUserParamsCopyWith(LoginUserParams value, $Res Function(LoginUserParams) _then) = _$LoginUserParamsCopyWithImpl;
@useResult
$Res call({
 String email, String password
});




}
/// @nodoc
class _$LoginUserParamsCopyWithImpl<$Res>
    implements $LoginUserParamsCopyWith<$Res> {
  _$LoginUserParamsCopyWithImpl(this._self, this._then);

  final LoginUserParams _self;
  final $Res Function(LoginUserParams) _then;

/// Create a copy of LoginUserParams
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


class _LoginUserParams implements LoginUserParams {
  const _LoginUserParams({required this.email, required this.password});
  

@override final  String email;
@override final  String password;

/// Create a copy of LoginUserParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginUserParamsCopyWith<_LoginUserParams> get copyWith => __$LoginUserParamsCopyWithImpl<_LoginUserParams>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginUserParams&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password));
}


@override
int get hashCode => Object.hash(runtimeType,email,password);

@override
String toString() {
  return 'LoginUserParams(email: $email, password: $password)';
}


}

/// @nodoc
abstract mixin class _$LoginUserParamsCopyWith<$Res> implements $LoginUserParamsCopyWith<$Res> {
  factory _$LoginUserParamsCopyWith(_LoginUserParams value, $Res Function(_LoginUserParams) _then) = __$LoginUserParamsCopyWithImpl;
@override @useResult
$Res call({
 String email, String password
});




}
/// @nodoc
class __$LoginUserParamsCopyWithImpl<$Res>
    implements _$LoginUserParamsCopyWith<$Res> {
  __$LoginUserParamsCopyWithImpl(this._self, this._then);

  final _LoginUserParams _self;
  final $Res Function(_LoginUserParams) _then;

/// Create a copy of LoginUserParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,}) {
  return _then(_LoginUserParams(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
