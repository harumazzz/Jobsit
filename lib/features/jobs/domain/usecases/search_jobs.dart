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
