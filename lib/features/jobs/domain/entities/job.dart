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
    String? logo,
    String? name,
    String? tax,
    String? email,
    String? phone,
    String? personnelSize,
    String? website,
    String? country,
    String? province,
    String? district,
    String? createdDate,
    String? location,
    required JobStatus status,
    String? description,
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

extension JobExtension on Job {
  String get minInUSD {
    return _formatCurrency(minAllowance);
  }

  String get maxInUSD {
    return _formatCurrency(maxAllowance);
  }
}

String _formatCurrency(double value) {
  final formattedValue = (value / 24.500).round();
  if (formattedValue > 1000) {
    return '${formattedValue / 1000}k';
  }
  return formattedValue.toString();
}

@freezed
sealed class SavedJob with _$SavedJob {
  const factory SavedJob({required int id, required Job job}) = _SavedJob;
}
