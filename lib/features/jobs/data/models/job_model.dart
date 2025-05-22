import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/services/file_service.dart';
import '../../../auth/data/models/user_model.dart' as auth_user_model; // aliased
import '../../domain/entities/job.dart';

part 'job_model.freezed.dart';
part 'job_model.g.dart';

/// Represents a generic HTTP response from the API, typically for operations
/// that don't return specific data models but indicate success/failure.
@freezed
sealed class HttpResponse with _$HttpResponse {
  /// Creates an [HttpResponse].
  ///
  /// [httpCode] The HTTP status code.
  /// [message] A descriptive message from the API.
  /// [path] The API endpoint path that was called.
  const factory HttpResponse({
    required final int httpCode,
    required final String message,
    required final String path,
  }) = _HttpResponse;

  /// Creates an [HttpResponse] from a JSON map.
  factory HttpResponse.fromJson(
    final Map<String, dynamic> json,
  ) => _$HttpResponseFromJson(json);
}

/// API response model for a paginated list of jobs.
@freezed
sealed class JobListResponse with _$JobListResponse {
  /// Creates a [JobListResponse].
  ///
  /// [contents] The list of [JobResponse] objects for the current page.
  /// [totalPages] The total number of pages available.
  /// [totalItems] The total number of jobs available across all pages.
  /// [limit] The number of items per page.
  /// [no] The current page number (0-indexed).
  /// [last] Whether this is the last page.
  /// [first] Whether this is the first page.
  const factory JobListResponse({
    required final List<JobResponse> contents,
    required final int totalPages,
    required final int totalItems,
    required final int limit,
    required final int no,
    required final bool last,
    required final bool first,
  }) = _JobListResponse;

  /// Creates a [JobListResponse] from a JSON map.
  factory JobListResponse.fromJson(
    final Map<String, dynamic> json,
  ) => _$JobListResponseFromJson(json);
}

/// API response model for a paginated list of saved jobs.
@freezed
sealed class SavedJobListResponse with _$SavedJobListResponse {
  /// Creates a [SavedJobListResponse].
  ///
  /// [contents] The list of [SavedJobResponse] objects for the current page.
  /// [totalPages] The total number of pages available.
  /// [totalItems] The total number of saved jobs available.
  /// [limit] The number of items per page.
  /// [no] The current page number (0-indexed).
  /// [last] Whether this is the last page.
  /// [first] Whether this is the first page.
  const factory SavedJobListResponse({
    required final List<SavedJobResponse> contents,
    required final int totalPages,
    required final int totalItems,
    required final int limit,
    required final int no,
    required final bool last,
    required final bool first,
  }) = _SavedJobListResponse;

  /// Creates a [SavedJobListResponse] from a JSON map.
  factory SavedJobListResponse.fromJson(
    final Map<String, dynamic> json,
  ) => _$SavedJobListResponseFromJson(json);
}

/// API response model for a single saved job, linking to the job details.
@freezed
sealed class SavedJobResponse with _$SavedJobResponse {
  /// Creates a [SavedJobResponse].
  ///
  /// [id] The ID of the saved job record.
  /// [job] The detailed [JobResponse] object.
  const factory SavedJobResponse({
    required final int id,
    @JsonKey(name: 'jobDTO') required final JobResponse job,
  }) = _SavedJobResponse;

  /// Creates a [SavedJobResponse] from a JSON map.
  factory SavedJobResponse.fromJson(
    final Map<String, dynamic> json,
  ) => _$SavedJobResponseFromJson(json);
}

/// API response model for detailed job information.
@freezed
sealed class JobResponse with _$JobResponse {
  /// Creates a [JobResponse].
  const factory JobResponse({
    required final int id,
    required final String title,
    // ignore: lines_longer_than_80_chars
    @JsonKey(name: 'positionDTOS') required final List<PositionResponse> positions,
    @JsonKey(name: 'majorDTOS') required final List<MajorResponse> majors,
    // ignore: lines_longer_than_80_chars
    @JsonKey(name: 'scheduleDTOS') required final List<ScheduleResponse> schedules,
    required final int amount, // Number of vacancies
    required final DateTime postingDate,
    required final DateTime applicationDeadline,
    required final double minAllowance,
    required final double maxAllowance,
    required final String description,
    required final String requirements,
    required final String benefits,
    required final String country,
    required final String city,
    required final String district,
    required final String address,
    required final bool noAllowance, // True if salary is not disclosed/negotiable
    @JsonKey(name: 'companyDTO') required final CompanyResponse company,
    @JsonKey(name: 'statusDTO') required final JobStatusResponse status,
  }) = _JobResponse;

  /// Creates a [JobResponse] from a JSON map.
  factory JobResponse.fromJson(
    final Map<String, dynamic> json,
  ) => _$JobResponseFromJson(json);
}

/// API response model for the status of a job (e.g., active, expired).
@freezed
sealed class JobStatusResponse with _$JobStatusResponse {
  /// Creates a [JobStatusResponse].
  ///
  /// [id] The ID of the job status.
  /// [name] The name of the job status.
  const factory JobStatusResponse({
    required final int id,
    required final String name,
  }) = _JobStatusResponse;

  /// Creates a [JobStatusResponse] from a JSON map.
  factory JobStatusResponse.fromJson(
    final Map<String, dynamic> json,
  ) => _$JobStatusResponseFromJson(json);
}

/// API response model for company information.
@freezed
sealed class CompanyResponse with _$CompanyResponse {
  /// Creates a [CompanyResponse].
  const factory CompanyResponse({
    required final int id,
    final String? logo,
    final String? name,
    final String? tax,
    final String? email,
    final String? phone,
    final String? personnelSize,
    final String? website,
    final String? country,
    final String? province,
    final String? district,
    final String? createdDate,
    final String? location,
    @JsonKey(name: 'statusDTO') required final JobStatusResponse status,
    final String? description,
  }) = _CompanyResponse;

  /// Creates a [CompanyResponse] from a JSON map.
  factory CompanyResponse.fromJson(
    final Map<String, dynamic> json,
  ) => _$CompanyResponseFromJson(json);
}

/// API response model for a work schedule/type (e.g., full-time, part-time).
/// This is specific to the jobs context.
@freezed
sealed class ScheduleResponse with _$ScheduleResponse {
  /// Creates a [ScheduleResponse].
  ///
  /// [id] The ID of the schedule.
  /// [name] The name of the schedule.
  const factory ScheduleResponse({
    required final int id,
    required final String name,
  }) = _ScheduleResponse;

  /// Creates a [ScheduleResponse] from a JSON map.
  factory ScheduleResponse.fromJson(
    final Map<String, dynamic> json,
  ) => _$ScheduleResponseFromJson(json);
}

/// API response model for an academic major or field of study.
/// This is specific to the jobs context.
@freezed
sealed class MajorResponse with _$MajorResponse {
  /// Creates a [MajorResponse].
  ///
  /// [id] The ID of the major.
  /// [name] The name of the major.
  const factory MajorResponse({
    required final int id,
    required final String name,
  }) = _MajorResponse;

  /// Creates a [MajorResponse] from a JSON map.
  factory MajorResponse.fromJson(
    final Map<String, dynamic> json,
  ) => _$MajorResponseFromJson(json);
}

/// API response model for a job position or title.
/// This is specific to the jobs context.
@freezed
sealed class PositionResponse with _$PositionResponse {
  /// Creates a [PositionResponse].
  ///
  /// [id] The ID of the position.
  /// [name] The name of the position.
  const factory PositionResponse({
    required final int id,
    required final String name,
  }) = _PositionResponse;

  /// Creates a [PositionResponse] from a JSON map.
  factory PositionResponse.fromJson(
    final Map<String, dynamic> json,
  ) => _$PositionResponseFromJson(json);
}

/// Extension methods for [JobResponse] to convert to domain entity [Job].
extension JobResponseExtension on JobResponse {
  /// Converts a [JobResponse] API model to a [Job] domain entity.
  Job toEntity() => Job(
    id: id,
    title: title,
    positions: positions.map((final e) => e.toEntity()).toList(),
    majors: majors.map((final e) => e.toEntity()).toList(),
    schedules: schedules.map((final e) => e.toEntity()).toList(),
    amount: amount,
    postingDate: postingDate,
    applicationDeadline: applicationDeadline,
    minAllowance: minAllowance,
    maxAllowance: maxAllowance,
    description: description,
    requirements: requirements,
    benefits: benefits,
    country: country,
    city: city,
    district: district,
    address: address,
    noAllowance: noAllowance,
    company: company.toEntity(),
    status: status.toEntity(),
  );
}

/// Extension methods for [JobStatusResponse] to convert to domain entity.
extension JobStatusResponseExtension on JobStatusResponse {
  /// Converts a [JobStatusResponse] API model to a [JobStatus] domain entity.
  JobStatus toEntity() => JobStatus(id: id, name: name);
}

/// Extension methods for [CompanyResponse] to convert to domain entity.
extension CompanyResponseExtension on CompanyResponse {
  /// Converts a [CompanyResponse] API model to a [Company] domain entity.
  Company toEntity() => Company(
    id: id,
    logo: logo,
    name: name,
    tax: tax,
    email: email,
    phone: phone,
    personnelSize: personnelSize,
    website: website,
    country: country,
    province: province,
    district: district,
    createdDate: createdDate,
    location: location,
    status: status.toEntity(),
    description: description,
  );
}

/// Extension methods for [ScheduleResponse] to convert to entity.
extension ScheduleResponseExtension on ScheduleResponse {
  /// Converts a [ScheduleResponse] API model to a [Schedule] domain entity.
  Schedule toEntity() => Schedule(id: id, name: name);
}

/// Extension methods for [MajorResponse] to convert to domain entity.
extension MajorResponseExtension on MajorResponse {
  /// Converts a [MajorResponse] API model to a [Major] domain entity.
  Major toEntity() => Major(id: id, name: name);
}

/// Extension methods for [PositionResponse] to convert to domain entity.
extension PositionResponseExtension on PositionResponse {
  /// Converts a [PositionResponse] API model to a [Position] domain entity.
  Position toEntity() => Position(id: id, name: name);
}

/// Extension methods for to convert to a list of domain entities [Job].
extension SavedJobListResponseExtension on SavedJobListResponse {
  /// Converts the  to a list of [Job] domain entities.
  List<Job> toEntity() => contents.map((final e) => e.job.toEntity()).toList();
}

/// Extension methods for [SavedJobResponse] to convert to domain entity [Job].
extension SavedJobResponseExtension on SavedJobResponse {
  /// Converts a [SavedJobResponse] API model to a [Job] domain entity.
  Job toEntity() => job.toEntity();
}

/// Request model for operations requiring a job ID (e.g., save, apply).
@freezed
sealed class JobRequest with _$JobRequest {
  /// Creates a [JobRequest].
  ///
  /// [id] The ID of the job.
  const factory JobRequest({
    required final int id,
  }) = _JobRequest;

  /// Creates a [JobRequest] from a JSON map.
  factory JobRequest.fromJson(
    final Map<String, dynamic> json,
  ) => _$JobRequestFromJson(json);

  /// Converts this [JobRequest] to a JSON map.
  @override
  Map<String, dynamic> toJson();
}

/// Request model for a candidate's job application.
///
/// This class seems to be for internal structuring or a specific type
/// of request not directly sent as a whole JSON body in typical REST APIs.
/// If it's part of a FormData, individual fields are usually set.
@freezed
sealed class CandidateApplicationRequest with _$CandidateApplicationRequest {
  /// Creates a [CandidateApplicationRequest].
  ///
  /// [candidateApplication] The job being applied for, as a [JobRequest].
  /// [fileCV] The CV file for the application.
  const factory CandidateApplicationRequest({
    required final JobRequest candidateApplication,
    required final FileRequest fileCV,
  }) = _CandidateApplicationRequest;
  // No fromJson/toJson implies this might not be a direct API model
  // or is handled differently (e.g. part of FormData).
}

/// API response model for a job application submission.
@freezed
sealed class AppliedJobResponse with _$AppliedJobResponse {
  /// Creates an [AppliedJobResponse].
  const factory AppliedJobResponse({
    required final int id, // ID of the application record
    @JsonKey(name: 'jobDTO') required final JobResponse job,
    // ignore: lines_longer_than_80_chars
    @JsonKey(name: 'candidateDTO') required final auth_user_model.GetUserResponse candidate,
    required final String appliedDate,
    required final String referenceLetter,
    required final String email,
    required final String fullName,
    required final String phone,
    required final String cv, // Path or identifier for the CV
  }) = _AppliedJobResponse;

  /// Creates an [AppliedJobResponse] from a JSON map.
  factory AppliedJobResponse.fromJson(
    final Map<String, dynamic> json,
  ) => _$AppliedJobResponseFromJson(json);
}

/// Extension methods for [AppliedJobResponse] to convert to domain entity.
extension AppliedJobResponseExtension on AppliedJobResponse {
  /// Converts an [AppliedJobResponse] API model to a [Job] domain entity,
  /// extracting the job details.
  Job toEntity() => job.toEntity();
}
