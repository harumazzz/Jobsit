import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
sealed class Status with _$Status {
  const factory Status({required int id, required String name}) = _Status;
}

@freezed
sealed class Role with _$Role {
  const factory Role({required int id, required String name}) = _Role;
}

@freezed
sealed class RegisteredUser with _$RegisteredUser {
  const factory RegisteredUser({
    required int id,
    required String email,
    required String firstName,
    required String lastName,
    required String phone,
    required Status status,
    required Role role,
  }) = _RegisteredUser;
}

@freezed
sealed class User with _$User {
  const factory User({required int userId, required String email, required String role, String? avatar}) = _User;
}
