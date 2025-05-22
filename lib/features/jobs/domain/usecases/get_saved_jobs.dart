import 'package:dart_either/dart_either.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/job_repository_impl.dart';
import '../entities/job.dart';
import '../repositories/job_repository.dart';

part 'get_saved_jobs.freezed.dart';
part 'get_saved_jobs.g.dart';

/// Parameters for the [GetSavedJobsUseCase].
@freezed
sealed class SavedJobParams with _$SavedJobParams {
  /// Creates [SavedJobParams].
  ///
  /// [page] The page number for pagination.
  /// [limit] The number of items per page.
  const factory SavedJobParams({
    required final int page,
    required final int limit,
  }) = _SavedJobParams;
}

/// Parameters for the [AddSavedJobUseCase].
@freezed
sealed class AddSavedJobParams with _$AddSavedJobParams {
  /// Creates [AddSavedJobParams].
  ///
  /// [jobId] The ID of the job to be saved.
  const factory AddSavedJobParams({
    required final int jobId,
  }) = _AddSavedJobParams;
}

/// Parameters for the [DeleteSavedJobUseCase].
@freezed
sealed class DeleteSavedJobParams with _$DeleteSavedJobParams {
  /// Creates [DeleteSavedJobParams].
  ///
  /// [jobId] The ID of the job to be deleted from saved jobs.
  const factory DeleteSavedJobParams({
    required final int jobId,
  }) = _DeleteSavedJobParams;
}

/// Provides an instance of [GetSavedJobsUseCase].
///
/// This use case is responsible for fetching the list of jobs that the
/// current user has saved.
@riverpod
GetSavedJobsUseCase getSavedJobsUseCase(final Ref ref) {
  final jobRepository = ref.watch(jobRepositoryProvider);
  return GetSavedJobsUseCase(jobRepository);
}

/// Provides an instance of [AddSavedJobUseCase].
///
/// This use case handles the logic for a user saving a job.
@riverpod
AddSavedJobUseCase addSavedJobUseCase(final Ref ref) {
  final jobRepository = ref.watch(jobRepositoryProvider);
  return AddSavedJobUseCase(jobRepository);
}

/// Provides an instance of [DeleteSavedJobUseCase].
///
/// This use case handles the logic for a user removing a job from their
/// saved list.
@riverpod
DeleteSavedJobUseCase deleteSavedJobUseCase(final Ref ref) {
  final jobRepository = ref.watch(jobRepositoryProvider);
  return DeleteSavedJobUseCase(jobRepository);
}

/// Use case for fetching a list of jobs the current user has saved.
///
/// Takes [SavedJobParams] for pagination and returns a list of [Job]
/// entities or a [Failure].
final class GetSavedJobsUseCase implements UseCase<List<Job>, SavedJobParams> {
  /// Creates a [GetSavedJobsUseCase].
  const GetSavedJobsUseCase(this._jobRepository);

  final JobRepository _jobRepository;

  /// Executes the use case to get saved jobs.
  @override
  Future<Either<Failure, List<Job>>> call(final SavedJobParams params) async =>
      _jobRepository.getSavedJobs(page: params.page, limit: params.limit);
}

/// Use case for adding a job to the user's saved list.
///
/// Takes [AddSavedJobParams] containing the job ID and returns [Success]
/// or a [Failure].
final class AddSavedJobUseCase implements UseCase<Success, AddSavedJobParams> {
  /// Creates an [AddSavedJobUseCase].
  const AddSavedJobUseCase(this._jobRepository);

  final JobRepository _jobRepository;

  /// Executes the use case to add a saved job.
  @override
  Future<Either<Failure, Success>> call(final AddSavedJobParams params) async =>
      _jobRepository.addSavedJob(jobId: params.jobId);
}

/// Use case for deleting a job from the user's saved list.
///
/// Takes [DeleteSavedJobParams] containing the job ID and returns [Success]
/// or a [Failure].
// ignore: lines_longer_than_80_chars
final class DeleteSavedJobUseCase implements UseCase<Success, DeleteSavedJobParams> {
  /// Creates a [DeleteSavedJobUseCase].
  const DeleteSavedJobUseCase(this._jobRepository);

  final JobRepository _jobRepository;

  /// Executes the use case to delete a saved job.
  @override
  Future<Either<Failure, Success>> call(
    final DeleteSavedJobParams params,
  ) async => _jobRepository.deleteSavedJob(jobId: params.jobId);
}
