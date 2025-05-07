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

@freezed
sealed class SavedJobParams with _$SavedJobParams {
  const factory SavedJobParams({required int page, required int limit}) = _SavedJobParams;
}

@riverpod
GetSavedJobsUseCase getSavedJobsUseCase(Ref ref) {
  final jobRepository = ref.watch(jobRepositoryProvider);
  return GetSavedJobsUseCase(jobRepository);
}

final class GetSavedJobsUseCase implements UseCase<List<Job>, SavedJobParams> {
  const GetSavedJobsUseCase(this._jobRepository);

  final JobRepository _jobRepository;

  @override
  Future<Either<Failure, List<Job>>> call(SavedJobParams params) async {
    return await _jobRepository.getSavedJobs(page: params.page, limit: params.limit);
  }
}
