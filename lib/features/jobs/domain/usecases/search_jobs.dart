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

/// Provides an instance of [SearchJobsUseCase].
///
/// This use case is responsible for fetching a general list of jobs,
/// typically for an initial display or a broad search.
@riverpod
SearchJobsUseCase searchJobsUseCase(final Ref ref) {
  final jobRepository = ref.watch(jobRepositoryProvider);
  return SearchJobsUseCase(jobRepository);
}

/// Provides an instance of [GetPositionUseCase].
///
/// This use case fetches a list of all available job positions.
@riverpod
GetPositionUseCase getPositionUseCase(final Ref ref) {
  final jobRepository = ref.watch(jobRepositoryProvider);
  return GetPositionUseCase(jobRepository);
}

/// Provides an instance of [GetMajorUseCase].
///
/// This use case fetches a list of all available academic majors.
@riverpod
GetMajorUseCase getMajorUseCase(final Ref ref) {
  final jobRepository = ref.watch(jobRepositoryProvider);
  return GetMajorUseCase(jobRepository);
}

/// Provides an instance of [GetScheduleUseCase].
///
/// This use case fetches a list of all available work schedules/types.
@riverpod
GetScheduleUseCase getScheduleUseCase(final Ref ref) {
  final jobRepository = ref.watch(jobRepositoryProvider);
  return GetScheduleUseCase(jobRepository);
}

/// Provides an instance of [FilterJobUseCase].
///
/// This use case is responsible for fetching a list of jobs based on
/// specified filter criteria.
@riverpod
FilterJobUseCase filterJobUseCase(final Ref ref) {
  final jobRepository = ref.watch(jobRepositoryProvider);
  return FilterJobUseCase(jobRepository);
}

/// Parameters for the [SearchJobsUseCase].
@freezed
sealed class SearchJobsUseCaseParams with _$SearchJobsUseCaseParams {
  /// Creates [SearchJobsUseCaseParams].
  ///
  /// [page] The page number for pagination.
  /// [limit] The number of items per page.
  const factory SearchJobsUseCaseParams({
    required final int page,
    required final int limit,
  }) = _SearchJobsUseCaseParams;
}

/// Use case for fetching a general list of jobs with pagination.
///
/// Takes [SearchJobsUseCaseParams] for pagination and returns a list of [Job]
/// entities or a [Failure].
// ignore: lines_longer_than_80_chars
class SearchJobsUseCase implements UseCase<List<Job>, SearchJobsUseCaseParams> {
  /// Creates a [SearchJobsUseCase].
  const SearchJobsUseCase(this._jobRepository);

  final JobRepository _jobRepository;

  /// Executes the use case to get a list of jobs.
  @override
  Future<Either<Failure, List<Job>>> call(
    final SearchJobsUseCaseParams params,
  ) async => _jobRepository.getJobs(page: params.page, limit: params.limit);
}

/// Use case for fetching a list of all available job positions.
///
/// Takes [NoParams] and returns a list of [Position] entities or a [Failure].
class GetPositionUseCase implements UseCase<List<Position>, NoParams> {
  /// Creates a [GetPositionUseCase].
  const GetPositionUseCase(this._jobRepository);

  final JobRepository _jobRepository;

  /// Executes the use case to get job positions.
  @override
  Future<Either<Failure, List<Position>>> call(
    final NoParams params,
  ) async => _jobRepository.getPositions();
}

/// Use case for fetching a list of all available academic majors.
///
/// Takes [NoParams] and returns a list of [Major] entities or a [Failure].
class GetMajorUseCase implements UseCase<List<Major>, NoParams> {
  /// Creates a [GetMajorUseCase].
  const GetMajorUseCase(this._jobRepository);

  final JobRepository _jobRepository;

  /// Executes the use case to get academic majors.
  @override
  Future<Either<Failure, List<Major>>> call(
    final NoParams params,
  ) async => _jobRepository.getMajors();
}

/// Use case for fetching a list of all available work schedules/types.
///
/// Takes [NoParams] and returns a list of [Schedule] entities or a [Failure].
class GetScheduleUseCase implements UseCase<List<Schedule>, NoParams> {
  /// Creates a [GetScheduleUseCase].
  const GetScheduleUseCase(this._jobRepository);

  final JobRepository _jobRepository;

  /// Executes the use case to get work schedules.
  @override
  Future<Either<Failure, List<Schedule>>> call(
    final NoParams params,
  ) async => _jobRepository.getSchedules();
}

/// Provides an instance of [GetJobDetailUseCase].
///
/// This use case is responsible for fetching the detailed information
/// for a specific job.
@riverpod
GetJobDetailUseCase getJobDetailUseCase(final Ref ref) {
  final jobRepository = ref.watch(jobRepositoryProvider);
  return GetJobDetailUseCase(jobRepository);
}

/// Parameters for the [GetJobDetailUseCase].
@freezed
sealed class GetJobDetailParams with _$GetJobDetailParams {
  /// Creates [GetJobDetailParams].
  ///
  /// [jobId] The ID of the job to fetch details for.
  const factory GetJobDetailParams({
    required final int jobId,
  }) = _GetJobDetailParams;
}

/// Use case for fetching detailed information of a specific job.
///
/// Takes [GetJobDetailParams] containing the job ID and returns a [Job]
/// entity or a [Failure].
class GetJobDetailUseCase implements UseCase<Job, GetJobDetailParams> {
  /// Creates a [GetJobDetailUseCase].
  const GetJobDetailUseCase(this._jobRepository);

  final JobRepository _jobRepository;

  /// Executes the use case to get job details.
  @override
  Future<Either<Failure, Job>> call(
    final GetJobDetailParams params,
  ) async => _jobRepository.getJobById(params.jobId);
}

/// Parameters for the [FilterJobUseCase].
@freezed
sealed class FilterJobUseCaseParams with _$FilterJobUseCaseParams {
  /// Creates [FilterJobUseCaseParams].
  ///
  /// [page] The page number for pagination.
  /// [limit] The number of items per page.
  /// [title] Optional job title keyword to search for.
  /// [schedules] Optional list of [Schedule]s to filter by.
  /// [positions] Optional list of [Position]s to filter by.
  /// [city] Optional [City] to filter by location.
  /// [majors] Optional list of [Major]s to filter by.
  const factory FilterJobUseCaseParams({
    required final int page,
    required final int limit,
    final String? title,
    final List<Schedule>? schedules,
    final List<Position>? positions,
    final City? city,
    final List<Major>? majors,
  }) = _FilterJobUseCaseParams;
}

/// Use case for fetching a list of jobs based on specified filter criteria.
///
/// Takes [FilterJobUseCaseParams] and returns a list of [Job] entities
/// or a [Failure].
// ignore: lines_longer_than_80_chars
class FilterJobUseCase implements UseCase<List<Job>, FilterJobUseCaseParams> {
  /// Creates a [FilterJobUseCase].
  const FilterJobUseCase(this._jobRepository);

  final JobRepository _jobRepository;

  /// Executes the use case to filter jobs.
  @override
  Future<Either<Failure, List<Job>>> call(
    final FilterJobUseCaseParams params,
  ) async => _jobRepository.getFilteredJobs(
    page: params.page,
    limit: params.limit,
    schedules: params.schedules,
    positions: params.positions,
    city: params.city,
    majors: params.majors,
    title: params.title,
  );
}

/// Provides an instance of [GetJobByCompanyUseCase].
///
/// This use case is responsible for fetching jobs associated with a specific
/// company.
@riverpod
GetJobByCompanyUseCase getJobByCompanyUseCase(final Ref ref) {
  final jobRepository = ref.watch(jobRepositoryProvider);
  return GetJobByCompanyUseCase(jobRepository);
}

/// Parameters for the [GetJobByCompanyUseCase].
@freezed
sealed class GetJobByCompanyParams with _$GetJobByCompanyParams {
  /// Creates [GetJobByCompanyParams].
  ///
  /// [company] The [Company] entity for which to fetch jobs.
  /// [page] The page number for pagination.
  /// [limit] The number of items per page.
  const factory GetJobByCompanyParams({
    required final Company company,
    required final int page,
    required final int limit,
  }) = _GetJobByCompanyParams;
}

/// Use case for fetching jobs associated with a specific company.
///
/// Takes [GetJobByCompanyParams] and returns a list of [Job] entities
/// or a [Failure].
// ignore: lines_longer_than_80_chars
class GetJobByCompanyUseCase implements UseCase<List<Job>, GetJobByCompanyParams> {
  /// Creates a [GetJobByCompanyUseCase].
  const GetJobByCompanyUseCase(this._jobRepository);

  final JobRepository _jobRepository;

  /// Executes the use case to get jobs by company.
  @override
  Future<Either<Failure, List<Job>>> call(
    final GetJobByCompanyParams params,
  ) async => _jobRepository.getJobsByCompany(
    company: params.company,
    page: params.page,
    limit: params.limit,
  );
}
