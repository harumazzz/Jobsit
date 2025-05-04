import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/job.dart';

part 'job_model.freezed.dart';
part 'job_model.g.dart';

@freezed
sealed class JobListResponse with _$JobListResponse {
  const factory JobListResponse({
    required List<JobResponse> contents,
    required int totalPages,
    required int totalItems,
    required int limit,
    required int no,
    required bool last,
    required bool first,
  }) = _JobListResponse;

  factory JobListResponse.fromJson(Map<String, dynamic> json) => _$JobListResponseFromJson(json);
}

@freezed
sealed class JobResponse with _$JobResponse {
  const factory JobResponse({
    required int id,
    required String title,
    @JsonKey(name: 'positionDTOS') required List<PositionResponse> positions,
    @JsonKey(name: 'majorDTOS') required List<MajorResponse> majors,
    @JsonKey(name: 'scheduleDTOS') required List<ScheduleResponse> schedules,
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
    @JsonKey(name: 'companyDTO') required CompanyResponse company,
    @JsonKey(name: 'statusDTO') required JobStatusResponse status,
  }) = _JobResponse;

  factory JobResponse.fromJson(Map<String, dynamic> json) => _$JobResponseFromJson(json);
}

@freezed
sealed class JobStatusResponse with _$JobStatusResponse {
  const factory JobStatusResponse({required int id, required String name}) = _JobStatusResponse;

  factory JobStatusResponse.fromJson(Map<String, dynamic> json) => _$JobStatusResponseFromJson(json);
}

@freezed
sealed class CompanyResponse with _$CompanyResponse {
  const factory CompanyResponse({
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
    @JsonKey(name: 'statusDTO') required JobStatusResponse status,
    String? description,
  }) = _CompanyResponse;

  factory CompanyResponse.fromJson(Map<String, dynamic> json) => _$CompanyResponseFromJson(json);
}

@freezed
sealed class ScheduleResponse with _$ScheduleResponse {
  const factory ScheduleResponse({required int id, required String name}) = _ScheduleResponse;

  factory ScheduleResponse.fromJson(Map<String, dynamic> json) => _$ScheduleResponseFromJson(json);
}

@freezed
sealed class MajorResponse with _$MajorResponse {
  const factory MajorResponse({required int id, required String name}) = _MajorResponse;

  factory MajorResponse.fromJson(Map<String, dynamic> json) => _$MajorResponseFromJson(json);
}

@freezed
sealed class PositionResponse with _$PositionResponse {
  const factory PositionResponse({required int id, required String name}) = _PositionResponse;

  factory PositionResponse.fromJson(Map<String, dynamic> json) => _$PositionResponseFromJson(json);
}

extension JobResponseExtension on JobResponse {
  Job toEntity() {
    return Job(
      id: id,
      title: title,
      positions: positions.map((e) => e.toEntity()).toList(),
      majors: majors.map((e) => e.toEntity()).toList(),
      schedules: schedules.map((e) => e.toEntity()).toList(),
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
}

extension JobStatusResponseExtension on JobStatusResponse {
  JobStatus toEntity() {
    return JobStatus(id: id, name: name);
  }
}

extension CompanyResponseExtension on CompanyResponse {
  Company toEntity() {
    return Company(
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
}

extension ScheduleResponseExtension on ScheduleResponse {
  Schedule toEntity() {
    return Schedule(id: id, name: name);
  }
}

extension MajorResponseExtension on MajorResponse {
  Major toEntity() {
    return Major(id: id, name: name);
  }
}

extension PositionResponseExtension on PositionResponse {
  Position toEntity() {
    return Position(id: id, name: name);
  }
}
