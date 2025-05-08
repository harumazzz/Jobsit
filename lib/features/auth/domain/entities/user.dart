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
sealed class University with _$University {
  const factory University({required int id, required String name}) = _University;
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
sealed class UserInformation with _$UserInformation {
  const factory UserInformation({
    required String email,
    required String firstName,
    required String lastName,
    required String phone,
    required bool gender,
    required bool mailReceive,
    String? birthDate,
    String? address,
    String? avatar,
  }) = _UserInformation;
}

@freezed
sealed class Major with _$Major {
  const factory Major({required int id, required String name}) = _Major;
}

@freezed
sealed class Position with _$Position {
  const factory Position({required int id, required String name}) = _Position;
}

@freezed
sealed class Schedule with _$Schedule {
  const factory Schedule({required int id, required String name}) = _Schedule;
}

@freezed
sealed class JobInformation with _$JobInformation {
  const factory JobInformation({
    University? university,
    String? referenceLetter,
    required List<Position> positions,
    required List<Major> majors,
    required List<Schedule> schedules,
    required bool searchable,
    String? desiredJob,
    String? desiredWorkingProvince,
    String? cv,
  }) = _JobInformation;
}

@freezed
sealed class User with _$User {
  const factory User({
    required int userId,
    required String role,
    required UserInformation userInfo,
    required JobInformation jobInfo,
  }) = _User;
}
