import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/file_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/job.dart';
import '../../domain/usecases/get_applied_jobs.dart';
import '../../domain/usecases/get_saved_jobs.dart';
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

@Riverpod(keepAlive: true)
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
      await ref.read(savedJobControllerProvider.notifier).getSavedJobs();
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

  void update() {
    if (state is SearchJobsLoaded) {
      final (jobs, finished) = switch (state) {
        SearchJobsLoaded(jobs: final jobs, finished: final finished) => (jobs, finished),
        _ => (null, false),
      };
      if (jobs == null) {
        return;
      }
      state = SearchJobsState.loaded(jobs: jobs, finished: finished);
    }
  }

  Future<void> filterJobs({
    required int page,
    required int limit,
    required String title,
    List<Position>? positions,
    List<Schedule>? schedules,
    City? city,
    List<Major>? majors,
  }) async {
    state = const SearchJobsState.loading();
    try {
      final filterJobUseCase = ref.read(filterJobUseCaseProvider);
      final result = await filterJobUseCase(
        FilterJobUseCaseParams(
          page: page,
          limit: limit,
          positions: positions,
          schedules: schedules,
          city: city,
          majors: majors,
          title: title,
        ),
      );
      state = result.fold(
        ifLeft: (failure) => SearchJobsState.error(failure.message),
        ifRight: (value) => SearchJobsState.loaded(jobs: value, finished: false),
      );
    } catch (e) {
      state = SearchJobsState.error(e.toString());
    }
  }
}

@freezed
sealed class SavedJobState with _$SavedJobState {
  const factory SavedJobState.initial() = SavedJobInitial;

  const factory SavedJobState.loading() = SavedJobLoading;

  const factory SavedJobState.loaded({required Map<int, Job> jobs, required bool finished}) = SavedJobLoaded;

  const factory SavedJobState.error(String message) = SavedJobError;
}

@Riverpod(keepAlive: true)
class SavedJobController extends _$SavedJobController {
  @override
  SavedJobState build() {
    return const SavedJobState.initial();
  }

  Future<void> getSavedJobs() async {
    if (state is SavedJobLoaded) {
      return;
    }
    await _getJobs(page: 0, limit: 10);
  }

  bool contains(int jobId) {
    if (state is SavedJobLoaded) {
      return switch (state) {
        SavedJobLoaded(jobs: final jobs) => jobs.containsKey(jobId),
        _ => false,
      };
    }
    return false;
  }

  Future<void> getMoreJob({required int page}) async {
    if (state is! SavedJobLoaded) {
      return;
    }
    await _getJobs(page: page, limit: 10);
  }

  Future<void> resetJobs({required int page}) async {
    if (state is! SavedJobLoaded) {
      return;
    }
    state = const SavedJobLoaded(jobs: {}, finished: false);
    await _getJobs(page: 0, limit: 10);
  }

  Future<void> removeJob({required int jobId}) async {
    if (state is! SavedJobLoaded) {
      return;
    }
    final (jobs, finished) = switch (state) {
      SavedJobLoaded(jobs: final jobs, finished: final finished) => (jobs, finished),
      _ => (null, null),
    };
    if (jobs != null && finished != null) {
      final newJobs = HashMap<int, Job>.from(jobs);
      newJobs.remove(jobId);
      state = SavedJobState.loaded(jobs: newJobs, finished: finished);
      ref.read(searchJobsControllerProvider.notifier).update();
      final deleteSavedJobUseCase = ref.read(deleteSavedJobUseCaseProvider);
      final result = await deleteSavedJobUseCase(DeleteSavedJobParams(jobId: jobId));
      result.fold(ifLeft: (failure) => SavedJobState.error(failure.message), ifRight: (_) => null);
    }
  }

  Future<void> addJob({required Job job}) async {
    if (state is! SavedJobLoaded) {
      return;
    }
    final (jobs, finished) = switch (state) {
      SavedJobLoaded(jobs: final jobs, finished: final finished) => (jobs, finished),
      _ => (null, null),
    };
    if (jobs != null && finished != null) {
      final newJobs = HashMap<int, Job>.from(jobs);
      newJobs[job.id] = job;
      state = SavedJobState.loaded(jobs: newJobs, finished: finished);
      ref.read(searchJobsControllerProvider.notifier).update();
      final addSavedJobUseCase = ref.read(addSavedJobUseCaseProvider);
      final result = await addSavedJobUseCase(AddSavedJobParams(jobId: job.id));
      result.fold(ifLeft: (failure) => SavedJobState.error(failure.message), ifRight: (_) => null);
    }
  }

  Future<void> _getJobs({required int page, required int limit}) async {
    var oldJobs = null as Map<int, Job>?;
    if (state is SavedJobLoaded && (state as SavedJobLoaded).finished) {
      oldJobs = switch (state) {
        SavedJobLoaded(jobs: final jobs) => jobs,
        _ => null,
      };
    }
    state = const SavedJobState.loading();
    try {
      final getSavedJobsUseCase = ref.read(getSavedJobsUseCaseProvider);
      final result = await getSavedJobsUseCase(SavedJobParams(page: page, limit: limit));
      final jobs = HashMap<int, Job>();
      if (oldJobs != null) {
        for (final job in oldJobs.values) {
          jobs[job.id] = job;
        }
      }
      state = result.fold(
        ifLeft: (failure) => SavedJobState.error(failure.message),
        ifRight: (newJobs) {
          return SavedJobState.loaded(
            jobs: jobs..addAll({for (final e in newJobs) e.id: e}),
            finished: newJobs.isEmpty,
          );
        },
      );
    } catch (e) {
      state = SavedJobState.error(e.toString());
    }
  }
}

@freezed
sealed class CitiesState with _$CitiesState {
  const factory CitiesState.initial() = CitiesInitial;

  const factory CitiesState.loading() = CitiesLoading;

  const factory CitiesState.loaded({required List<City> cities}) = CitiesLoaded;

  const factory CitiesState.error(String message) = CitiesError;
}

@Riverpod(keepAlive: true)
class CitiesController extends _$CitiesController {
  @override
  CitiesState build() {
    return const CitiesState.initial();
  }

  Future<void> fetchCities() async {
    if (state is CitiesLoaded) {
      return;
    }
    state = const CitiesState.loading();
    try {
      final searchCitiesUseCase = ref.read(searchCitiesUseCaseProvider);
      final result = await searchCitiesUseCase(const SearchCitiesParams(depth: 1));
      state = result.fold(
        ifLeft: (failure) => CitiesState.error(failure.message),
        ifRight: (cities) => CitiesState.loaded(cities: cities),
      );
    } catch (e) {
      state = CitiesState.error(e.toString());
    }
  }
}

@freezed
sealed class DistrictsState with _$DistrictsState {
  const factory DistrictsState.initial() = DistrictsInitial;

  const factory DistrictsState.loading() = DistrictsLoading;

  const factory DistrictsState.loaded({required List<District> districts}) = DistrictsLoaded;

  const factory DistrictsState.error(String message) = DistrictsError;
}

@Riverpod(keepAlive: true)
class DistrictsController extends _$DistrictsController {
  @override
  DistrictsState build() {
    return const DistrictsState.initial();
  }

  Future<void> getDistricts({required int code}) async {
    state = const DistrictsState.loading();
    try {
      final searchDistrictsUseCase = ref.read(searchDistrictsUseCaseProvider);
      final result = await searchDistrictsUseCase(SearchDistrictsParams(depth: 2, code: code));
      state = result.fold(
        ifLeft: (failure) => DistrictsState.error(failure.message),
        ifRight: (districts) => DistrictsState.loaded(districts: districts),
      );
      debugPrint(state.toString());
    } catch (e) {
      state = DistrictsState.error(e.toString());
    }
  }
}

@freezed
sealed class MajorState with _$MajorState {
  const factory MajorState.initial() = MajorInitial;

  const factory MajorState.loading() = MajorLoading;

  const factory MajorState.loaded({required List<Major> majors}) = MajorLoaded;

  const factory MajorState.error(String message) = MajorError;
}

@Riverpod(keepAlive: true)
class MajorController extends _$MajorController {
  @override
  MajorState build() {
    return const MajorState.initial();
  }

  Future<void> getMajors() async {
    if (state is MajorLoaded) {
      return;
    }
    state = const MajorState.loading();
    try {
      final getMajorUseCase = ref.read(getMajorUseCaseProvider);
      final result = await getMajorUseCase(nil);
      state = result.fold(
        ifLeft: (failure) => MajorState.error(failure.message),
        ifRight: (majors) => MajorState.loaded(majors: majors),
      );
    } catch (e) {
      state = MajorState.error(e.toString());
    }
  }
}

@freezed
sealed class PositionState with _$PositionState {
  const factory PositionState.initial() = PositionInitial;

  const factory PositionState.loading() = PositionLoading;

  const factory PositionState.loaded({required List<Position> positions}) = PositionLoaded;

  const factory PositionState.error(String message) = PositionError;
}

@Riverpod(keepAlive: true)
class PositionController extends _$PositionController {
  @override
  PositionState build() {
    return const PositionState.initial();
  }

  Future<void> getPositions() async {
    if (state is PositionLoaded) {
      return;
    }
    state = const PositionState.loading();
    try {
      final getPositionUseCase = ref.read(getPositionUseCaseProvider);
      final result = await getPositionUseCase(nil);
      state = result.fold(
        ifLeft: (failure) => PositionState.error(failure.message),
        ifRight: (positions) => PositionState.loaded(positions: positions),
      );
    } catch (e) {
      state = PositionState.error(e.toString());
    }
  }
}

@freezed
sealed class ScheduleState with _$ScheduleState {
  const factory ScheduleState.initial() = ScheduleInitial;

  const factory ScheduleState.loading() = ScheduleLoading;

  const factory ScheduleState.loaded({required List<Schedule> schedules}) = ScheduleLoaded;

  const factory ScheduleState.error(String message) = ScheduleError;
}

@Riverpod(keepAlive: true)
class ScheduleController extends _$ScheduleController {
  @override
  ScheduleState build() {
    return const ScheduleState.initial();
  }

  Future<void> getSchedules() async {
    if (state is ScheduleLoaded) {
      return;
    }
    state = const ScheduleState.loading();
    try {
      final getScheduleUseCase = ref.read(getScheduleUseCaseProvider);
      final result = await getScheduleUseCase(nil);
      state = result.fold(
        ifLeft: (failure) => ScheduleState.error(failure.message),
        ifRight: (schedules) => ScheduleState.loaded(schedules: schedules),
      );
    } catch (e) {
      state = ScheduleState.error(e.toString());
    }
  }
}

@freezed
sealed class JobFilterState with _$JobFilterState {
  const factory JobFilterState.initial({
    required Set<int> schedules,
    required Set<int> positions,
    required Set<int> majors,
    required String title,
    City? city,
  }) = JobFilterInitial;

  const factory JobFilterState.onSearch({
    required Set<int> schedules,
    required Set<int> positions,
    required Set<int> majors,
    required String title,
    required City? city,
    required List<Schedule>? schedulesList,
    required List<Position>? positionsList,
    required List<Major>? majorsList,
  }) = JobFilterOnSearch;
}

@Riverpod(keepAlive: true)
class JobFilterController extends _$JobFilterController {
  @override
  JobFilterState build() {
    return JobFilterState.initial(schedules: HashSet(), positions: HashSet(), majors: HashSet(), title: '');
  }

  bool get isEmpty {
    return state is JobFilterInitial;
  }

  Future<void> resetFilter() async {
    state = JobFilterState.initial(schedules: HashSet(), positions: HashSet(), majors: HashSet(), title: '');
  }

  Future<void> saveFilteredJob({
    required Set<int> schedules,
    required Set<int> positions,
    required Set<int> majors,
    required List<Schedule>? schedulesList,
    required List<Position>? positionsList,
    required List<Major>? majorsList,
    required City? city,
    required String title,
  }) async {
    state = JobFilterState.onSearch(
      schedules: schedules,
      positions: positions,
      majors: majors,
      title: title,
      city: city,
      schedulesList: schedulesList,
      positionsList: positionsList,
      majorsList: majorsList,
    );
    await ref
        .read(searchJobsControllerProvider.notifier)
        .filterJobs(
          page: 0,
          limit: 10,
          schedules: schedulesList,
          positions: positionsList,
          majors: majorsList,
          city: city,
          title: title,
        );
  }
}

@freezed
sealed class JobDetailState with _$JobDetailState {
  const factory JobDetailState.initial() = JobDetailInitial;

  const factory JobDetailState.loading() = JobDetailLoading;

  const factory JobDetailState.loaded({required Job job, required List<Job> relatedJobs}) = JobDetailLoaded;

  const factory JobDetailState.error(String message) = JobDetailError;
}

@Riverpod(keepAlive: true)
class JobDetailController extends _$JobDetailController {
  @override
  JobDetailState build() {
    return const JobDetailState.initial();
  }

  Future<void> getJobDetail({required int jobId}) async {
    state = const JobDetailState.loading();
    try {
      final getJobDetailUseCase = ref.read(getJobDetailUseCaseProvider);
      final result = await getJobDetailUseCase(GetJobDetailParams(jobId: jobId));
      var job = null as Job?;
      state = result.fold(
        ifLeft: (failure) => JobDetailState.error(failure.message),
        ifRight: (it) {
          job = it;
          return const JobDetailState.loading();
        },
      );
      if (job == null) {
        return;
      }
      final getJobByCompanyUseCase = ref.read(getJobByCompanyUseCaseProvider);
      final otherJobs = await getJobByCompanyUseCase(GetJobByCompanyParams(company: job!.company, page: 0, limit: 5));
      state = otherJobs.fold(
        ifLeft: (failure) => JobDetailState.error(failure.message),
        ifRight: (jobs) => JobDetailState.loaded(job: job!, relatedJobs: jobs.where((e) => e.id != job!.id).toList()),
      );
    } catch (e) {
      state = JobDetailState.error(e.toString());
    }
  }
}

@freezed
sealed class ApplyJobState with _$ApplyJobState {
  const factory ApplyJobState.initial() = ApplyJobInitial;

  const factory ApplyJobState.loading() = ApplyJobLoading;

  const factory ApplyJobState.loaded({required List<Job> jobs, required bool finished}) = ApplyJobLoaded;

  const factory ApplyJobState.error(String message) = ApplyJobError;
}

@Riverpod(keepAlive: true)
final class ApplyJobController extends _$ApplyJobController {
  @override
  ApplyJobState build() {
    return const ApplyJobState.initial();
  }

  Future<void> getJobApplied({required int page}) async {
    if (state is ApplyJobLoaded && (state as ApplyJobLoaded).finished) {
      return;
    }
    final oldJobs = switch (state) {
      ApplyJobLoaded(jobs: final jobs) => jobs,
      _ => [],
    };
    state = const ApplyJobState.loading();
    try {
      final getAppliedJobsUseCase = ref.read(getAppliedJobsUseCaseProvider);
      final result = await getAppliedJobsUseCase(AppliedJobParams(page: page, limit: 10));
      state = result.fold(
        ifLeft: (failure) => ApplyJobState.error(failure.message),
        ifRight: (value) => ApplyJobState.loaded(jobs: [...oldJobs, ...value], finished: value.isEmpty),
      );
    } catch (e) {
      state = ApplyJobState.error(e.toString());
    }
  }

  Future<void> applyJob({required int jobId, required String referenceLetter, required FileSelectorResult cv}) async {
    final (oldJobs, finished) = switch (state) {
      ApplyJobLoaded(jobs: final jobs, finished: final finished) => (jobs, finished),
      _ => ([], false),
    };
    state = const ApplyJobState.loading();
    try {
      final applyJobUseCase = ref.read(applyJobUseCaseProvider);
      final result = await applyJobUseCase(
        ApplyJobParams(jobId: jobId, referenceLetter: referenceLetter, cv: FileRequest(name: cv.name, data: cv.data)),
      );
      state = result.fold(
        ifLeft: (failure) => ApplyJobState.error(failure.message),
        ifRight: (job) => ApplyJobState.loaded(jobs: [...oldJobs, job], finished: finished),
      );
    } catch (e) {
      state = ApplyJobState.error(e.toString());
    }
  }
}
