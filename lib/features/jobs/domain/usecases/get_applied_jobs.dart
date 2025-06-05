import 'package:dart_either/dart_either.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/file_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/job_repository_impl.dart';
import '../entities/job.dart';
import '../repositories/job_repository.dart';

part 'get_applied_jobs.freezed.dart';
part 'get_applied_jobs.g.dart';

/// Provides an instance of [GetAppliedJobsUseCase].
///
/// This use case is responsible for fetching the list of jobs that the
/// current user has applied for.
@riverpod
GetAppliedJobsUseCase getAppliedJobsUseCase(final Ref ref) {
  final jobRepository = ref.watch(jobRepositoryProvider);
  return GetAppliedJobsUseCase(jobRepository);
}

/// Parameters for the [GetAppliedJobsUseCase].
@freezed
sealed class AppliedJobParams with _$AppliedJobParams {
  /// Creates [AppliedJobParams].
  ///
  /// [page] The page number for pagination.
  /// [limit] The number of items per page.
  const factory AppliedJobParams({
    required final int page,
    required final int limit,
  }) = _AppliedJobParams;
}

/// Use case for fetching a list of jobs the current user has applied for.
///
/// Takes [AppliedJobParams] for pagination and returns a list of [Job]
/// entities or a [Failure].
// ignore: lines_longer_than_80_chars
class GetAppliedJobsUseCase implements UseCase<List<Job>, AppliedJobParams> {
  /// Creates a [GetAppliedJobsUseCase].
  const GetAppliedJobsUseCase(this._jobRepository);

  final JobRepository _jobRepository;

  /// Executes the use case to get applied jobs.
  @override
  Future<Either<Failure, List<Job>>> call(
    final AppliedJobParams params,
  ) async => _jobRepository.getAppliedJob(
    page: params.page,
    limit: params.limit,
  );
}

/// Provides an instance of [ApplyJobUseCase].
///
/// This use case handles the logic for a user applying to a job.
@riverpod
ApplyJobUseCase applyJobUseCase(final Ref ref) {
  final jobRepository = ref.watch(jobRepositoryProvider);
  return ApplyJobUseCase(jobRepository);
}

/// Parameters for the [ApplyJobUseCase].
@freezed
sealed class ApplyJobParams with _$ApplyJobParams {
  /// Creates [ApplyJobParams].
  ///
  /// [jobId] The ID of the job to apply for.
  /// [referenceLetter] The cover letter or reference letter text.
  /// [cv] The [FileRequest] object containing the CV file.
  const factory ApplyJobParams({
    required final int jobId,
    required final String referenceLetter,
    required final FileRequest cv,
  }) = _ApplyJobParams;
}

/// Use case for applying to a job.
///
/// Takes [ApplyJobParams] containing job ID, cover letter, and CV,
/// and returns the [Job] entity of the applied job or a [Failure].
class ApplyJobUseCase implements UseCase<Job, ApplyJobParams> {
  /// Creates an [ApplyJobUseCase].
  const ApplyJobUseCase(this._jobRepository);

  final JobRepository _jobRepository;

  /// Executes the use case to apply for a job.
  @override
  Future<Either<Failure, Job>> call(
    final ApplyJobParams params,
  ) async => _jobRepository.applyJob(
    jobId: params.jobId,
    coverLetter: params.referenceLetter,
    cv: params.cv,
  );
}
