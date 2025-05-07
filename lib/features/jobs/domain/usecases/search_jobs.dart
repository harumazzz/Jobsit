import 'package:dart_either/dart_either.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/job_repository_impl.dart';
import '../entities/job.dart';
import '../repositories/job_repository.dart';

part 'search_jobs.freezed.dart';
part 'search_jobs.g.dart';

@riverpod
SearchJobsUseCase searchJobsUseCase(Ref ref) {
  final jobRepository = ref.watch(jobRepositoryProvider);
  return SearchJobsUseCase(jobRepository);
}

@riverpod
GetPositionUseCase getPositionUseCase(Ref ref) {
  final jobRepository = ref.watch(jobRepositoryProvider);
  return GetPositionUseCase(jobRepository);
}

@riverpod
GetMajorUseCase getMajorUseCase(Ref ref) {
  final jobRepository = ref.watch(jobRepositoryProvider);
  return GetMajorUseCase(jobRepository);
}

@riverpod
GetScheduleUseCase getScheduleUseCase(Ref ref) {
  final jobRepository = ref.watch(jobRepositoryProvider);
  return GetScheduleUseCase(jobRepository);
}

@riverpod
FilterJobUseCase filterJobUseCase(Ref ref) {
  final jobRepository = ref.watch(jobRepositoryProvider);
  return FilterJobUseCase(jobRepository);
}

@freezed
sealed class SearchJobsUseCaseParams with _$SearchJobsUseCaseParams {
  const factory SearchJobsUseCaseParams({required int page, required int limit}) = _SearchJobsUseCaseParams;
}

final class SearchJobsUseCase implements UseCase<List<Job>, SearchJobsUseCaseParams> {
  const SearchJobsUseCase(this._jobRepository);

  final JobRepository _jobRepository;

  @override
  Future<Either<Failure, List<Job>>> call(SearchJobsUseCaseParams params) async {
    return await _jobRepository.getJobs(page: params.page, limit: params.limit);
  }
}

final class GetPositionUseCase implements UseCase<List<Position>, NoParams> {
  const GetPositionUseCase(this._jobRepository);

  final JobRepository _jobRepository;

  @override
  Future<Either<Failure, List<Position>>> call(NoParams params) async {
    return await _jobRepository.getPositions();
  }
}

final class GetMajorUseCase implements UseCase<List<Major>, NoParams> {
  const GetMajorUseCase(this._jobRepository);

  final JobRepository _jobRepository;

  @override
  Future<Either<Failure, List<Major>>> call(NoParams params) async {
    return await _jobRepository.getMajors();
  }
}

final class GetScheduleUseCase implements UseCase<List<Schedule>, NoParams> {
  const GetScheduleUseCase(this._jobRepository);

  final JobRepository _jobRepository;

  @override
  Future<Either<Failure, List<Schedule>>> call(NoParams params) async {
    return await _jobRepository.getSchedules();
  }
}

@riverpod
GetJobDetailUseCase getJobDetailUseCase(Ref ref) {
  final jobRepository = ref.watch(jobRepositoryProvider);
  return GetJobDetailUseCase(jobRepository);
}

@freezed
sealed class GetJobDetailParams with _$GetJobDetailParams {
  const factory GetJobDetailParams({required int jobId}) = _GetJobDetailParams;
}

final class GetJobDetailUseCase implements UseCase<Job, GetJobDetailParams> {
  const GetJobDetailUseCase(this._jobRepository);

  final JobRepository _jobRepository;

  @override
  Future<Either<Failure, Job>> call(GetJobDetailParams params) async {
    return await _jobRepository.getJobById(params.jobId);
  }
}

@freezed
sealed class FilterJobUseCaseParams with _$FilterJobUseCaseParams {
  const factory FilterJobUseCaseParams({
    required int page,
    required int limit,
    String? title,
    Schedule? schedule,
    Position? position,
    City? city,
    Major? major,
  }) = _FilterJobUseCaseParams;
}

final class FilterJobUseCase implements UseCase<List<Job>, FilterJobUseCaseParams> {
  const FilterJobUseCase(this._jobRepository);

  final JobRepository _jobRepository;

  @override
  Future<Either<Failure, List<Job>>> call(FilterJobUseCaseParams params) async {
    return await _jobRepository.getFilteredJobs(
      page: params.page,
      limit: params.limit,
      schedule: params.schedule,
      position: params.position,
      city: params.city,
      major: params.major,
      title: params.title,
    );
  }
}

@riverpod
GetJobByCompanyUseCase getJobByCompanyUseCase(Ref ref) {
  final jobRepository = ref.watch(jobRepositoryProvider);
  return GetJobByCompanyUseCase(jobRepository);
}

@freezed
sealed class GetJobByCompanyParams with _$GetJobByCompanyParams {
  const factory GetJobByCompanyParams({required Company company, required int page, required int limit}) =
      _GetJobByCompanyParams;
}

final class GetJobByCompanyUseCase implements UseCase<List<Job>, GetJobByCompanyParams> {
  const GetJobByCompanyUseCase(this._jobRepository);

  final JobRepository _jobRepository;

  @override
  Future<Either<Failure, List<Job>>> call(GetJobByCompanyParams params) async {
    return await _jobRepository.getJobsByCompany(company: params.company, page: params.page, limit: params.limit);
  }
}
