import 'package:dart_either/dart_either.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
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
