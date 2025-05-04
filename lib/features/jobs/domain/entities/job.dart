import 'package:freezed_annotation/freezed_annotation.dart';

part 'job.freezed.dart';

@freezed
sealed class Job with _$Job {
  const factory Job({
    required int id,
    required String title,
    required List<Position> positions,
    required List<Major> majors,
    required List<Schedule> schedules,
    required int amount,
    required DateTime postingDate,
    required DateTime applicationDeadline,
    required double minAllowance,
    required double maxAllowance,
    required String description,
    required String requirements,
    required String benefits,
    required String country,
    required String city,
    required String district,
    required String address,
    required bool noAllowance,
    required JobStatus status,
    required Company company,
  }) = _Job;
}

@freezed
sealed class JobStatus with _$JobStatus {
  const factory JobStatus({required int id, required String name}) = _JobStatus;
}

@freezed
sealed class Company with _$Company {
  const factory Company({
    required int id,
    required String logo,
    required String name,
    required String tax,
    required String email,
    required String phone,
    required String personnelSize,
    required String website,
    required String country,
    required String province,
    required String district,
    required String createdDate,
    required String location,
    required JobStatus status,
    required String description,
  }) = _Company;
}

@freezed
sealed class Schedule with _$Schedule {
  const factory Schedule({required int id, required String name}) = _Schedule;
}

@freezed
sealed class Major with _$Major {
  const factory Major({required int id, required String name}) = _Major;
}

@freezed
sealed class Position with _$Position {
  const factory Position({required int id, required String name}) = _Position;
}
