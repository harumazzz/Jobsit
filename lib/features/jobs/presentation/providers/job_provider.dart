import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/job.dart';
import '../../domain/usecases/search_jobs.dart';

part 'job_provider.freezed.dart';
part 'job_provider.g.dart';

@freezed
sealed class SearchJobsState with _$SearchJobsState {
  const factory SearchJobsState.initial() = SearchJobsInitial;
  const factory SearchJobsState.loading() = SearchJobsLoading;
  const factory SearchJobsState.loaded({required List<Job> jobs, required bool finished}) = SearchJobsLoaded;
  const factory SearchJobsState.error(String message) = SearchJobsError;
}

@riverpod
class SearchJobsController extends _$SearchJobsController {
  @override
  SearchJobsState build() {
    return const SearchJobsState.initial();
  }

  Future<void> searchJobs({required int page, required int limit}) async {
    final (currentJobs, finished) = switch (state) {
      SearchJobsLoaded(jobs: final jobs, finished: final finished) => (jobs, finished),
      _ => ([], false),
    };
    if (finished) {
      return;
    }
    state = const SearchJobsState.loading();
    try {
      final searchJobUseCase = ref.read(searchJobsUseCaseProvider);
      final result = await searchJobUseCase(SearchJobsUseCaseParams(page: page, limit: limit));
      state = result.fold(
        ifLeft: (failure) => SearchJobsState.error(failure.message),
        ifRight: (value) => SearchJobsState.loaded(jobs: [...currentJobs, ...value], finished: value.isEmpty),
      );
    } catch (e) {
      state = SearchJobsState.error(e.toString());
    }
  }
}
