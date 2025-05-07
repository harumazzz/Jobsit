import 'package:dart_either/dart_either.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/job_repository_impl.dart';
import '../entities/job.dart';
import '../repositories/job_repository.dart';

part 'get_applied_jobs.freezed.dart';
part 'get_applied_jobs.g.dart';

@riverpod
GetAppliedJobsUseCase getAppliedJobsUseCase(Ref ref) {
  final jobRepository = ref.watch(jobRepositoryProvider);
  return GetAppliedJobsUseCase(jobRepository);
}

@freezed
sealed class AppliedJobParams with _$AppliedJobParams {
  const factory AppliedJobParams({required int page, required int limit}) = _AppliedJobParams;
}

final class GetAppliedJobsUseCase implements UseCase<List<Job>, AppliedJobParams> {
  const GetAppliedJobsUseCase(this._jobRepository);

  final JobRepository _jobRepository;

  @override
  Future<Either<Failure, List<Job>>> call(AppliedJobParams params) async {
    return await _jobRepository.getAppliedJob(page: params.page, limit: params.limit);
  }
}
