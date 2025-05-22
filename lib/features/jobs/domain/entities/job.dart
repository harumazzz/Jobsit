import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../auth/domain/entities/user.dart' as user;

part 'job.freezed.dart';

/// Represents a job listing with all its details.
@freezed
sealed class Job with _$Job {
  /// Creates a [Job] instance.
  const factory Job({
    required final int id,
    required final String title,
    required final List<Position> positions,
    required final List<Major> majors,
    required final List<Schedule> schedules,
    required final int amount, // Number of open positions
    required final DateTime postingDate,
    required final DateTime applicationDeadline,
    required final double minAllowance, // Minimum salary/allowance
    required final double maxAllowance, // Maximum salary/allowance
    required final String description,
    required final String requirements,
    required final String benefits,
    required final String country,
    required final String city,
    required final String district,
    required final String address,
    required final bool noAllowance, // True if salary is not disclosed
    required final JobStatus status,
    required final Company company,
  }) = _Job;
}

/// Represents the status of a job (e.g., active, expired, filled).
@freezed
sealed class JobStatus with _$JobStatus {
  /// Creates a [JobStatus] instance.
  ///
  /// [id] The unique identifier for the job status.
  /// [name] The display name of the job status.
  const factory JobStatus({
    required final int id,
    required final String name,
  }) = _JobStatus;
}

/// Represents a company that posts jobs.
@freezed
sealed class Company with _$Company {
  /// Creates a [Company] instance.
  const factory Company({
    required final int id,
    final String? logo,
    final String? name,
    final String? tax, // Tax identification number
    final String? email,
    final String? phone,
    final String? personnelSize, // Company size (e.g., "100-500 employees")
    final String? website,
    final String? country,
    final String? province,
    final String? district,
    final String? createdDate,
    final String? location, // Full address
    required final JobStatus status, // Status of the company profile
    final String? description,
  }) = _Company;
}

/// Represents a work schedule or employment type (e.g., full-time, part-time).
/// This entity is specific to the jobs domain.
@freezed
sealed class Schedule with _$Schedule {
  /// Creates a [Schedule] instance.
  ///
  /// [id] The unique identifier for the schedule type.
  /// [name] The name of the schedule type.
  const factory Schedule({
    required final int id,
    required final String name,
  }) = _Schedule;
}

/// Represents an academic major or field of study relevant to jobs.
/// This entity is specific to the jobs domain.
@freezed
sealed class Major with _$Major {
  /// Creates a [Major] instance.
  ///
  /// [id] The unique identifier for the major.
  /// [name] The name of the major.
  const factory Major({
    required final int id,
    required final String name,
  }) = _Major;
}

/// Represents a job position or title.
/// This entity is specific to the jobs domain.
@freezed
sealed class Position with _$Position {
  /// Creates a [Position] instance.
  ///
  /// [id] The unique identifier for the position.
  /// [name] The name of the position.
  const factory Position({
    required final int id,
    required final String name,
  }) = _Position;
}

/// Extension methods for the [Position] entity (jobs domain).
extension PositionExtension on Position {
  /// Converts this job-specific [Position] to an auth-domain [user.Position].
  user.Position toAuth() => user.Position(id: id, name: name);
}

/// Extension methods for the [Major] entity (jobs domain).
extension MajorExtension on Major {
  /// Converts this job-specific [Major] to an auth-domain [user.Major].
  user.Major toAuth() => user.Major(id: id, name: name);
}

/// Extension methods for the [Schedule] entity (jobs domain).
extension ScheduleExtension on Schedule {
  /// Converts this job-specific [Schedule] to an auth-domain [user.Schedule].
  user.Schedule toAuth() => user.Schedule(id: id, name: name);
}

/// Extension methods for the [Job] entity.
extension JobExtension on Job {
  /// Gets the minimum allowance formatted as a string in USD (approximated).
  ///
  /// Example: "1k" for 1000 USD, "500" for 500 USD.
  String get minInUSD => _formatCurrency(minAllowance);

  /// Gets the maximum allowance formatted as a string in USD (approximated).
  ///
  /// Example: "2k" for 2000 USD, "800" for 800 USD.
  String get maxInUSD => _formatCurrency(maxAllowance);
}

/// Formats a currency [value] (assumed to be in a local currency)
/// into an approximated USD string.
///
/// Divides by an assumed exchange rate (24.500) and rounds.
/// If the result is over 1000, it's formatted with a 'k' suffix (e.g., "1.5k").
String _formatCurrency(final double value) {
  final formattedValue = (value / 24.500).round();
  if (formattedValue > 1000) {
    return '${formattedValue / 1000}k';
  }
  return formattedValue.toString();
}

/// Represents a job that has been saved by a user.
@freezed
sealed class SavedJob with _$SavedJob {
  /// Creates a [SavedJob] instance.
  ///
  /// [id] The unique identifier of the saved job entry.
  /// [job] The actual [Job] entity that was saved.
  const factory SavedJob({
    required final int id,
    required final Job job,
  }) = _SavedJob;
}
