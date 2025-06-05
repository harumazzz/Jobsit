import 'dart:collection';

import 'package:dart_either/dart_either.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/file_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/job.dart';
import '../../domain/usecases/get_applied_jobs.dart';
import '../../domain/usecases/get_saved_jobs.dart';
import '../../domain/usecases/search_jobs.dart';

part 'job_provider.freezed.dart';
part 'job_provider.g.dart';

/// Represents the state of the job search operation.
@freezed
sealed class SearchJobsState with _$SearchJobsState {
  /// The initial state before any search is performed.
  const factory SearchJobsState.initial() = SearchJobsInitial;

  /// State indicating that a job search is in progress.
  const factory SearchJobsState.loading() = SearchJobsLoading;

  /// State when jobs have been successfully loaded.
  ///
  /// [jobs] The list of loaded jobs.
  /// [finished] True if there are no more jobs to load (pagination ended).
  const factory SearchJobsState.loaded({
    required final List<Job> jobs,
    required final bool finished,
  }) = SearchJobsLoaded;

  /// State representing an error during the job search.
  ///
  /// [message] The error message.
  const factory SearchJobsState.error(final String message) = SearchJobsError;
}

/// Controller for managing the state of job searching and filtering.
@Riverpod(keepAlive: true)
class SearchJobsController extends _$SearchJobsController {
  @override
  SearchJobsState build() => const SearchJobsState.initial();

  /// Resets the search state to loaded with an empty list of jobs.
  Future<void> reset() async {
    state = const SearchJobsState.loaded(jobs: <Job>[], finished: false);
  }

  /// Searches for jobs with pagination.
  ///
  /// Appends new results to existing ones if the state is already
  /// [SearchJobsLoaded].
  ///
  /// [page] The page number to fetch.
  /// [limit] The number of jobs per page.
  Future<void> searchJobs({
    required final int page,
    required final int limit,
  }) async {
    final (List<Job> currentJobs, bool finished) = switch (state) {
      SearchJobsLoaded(
        jobs: final List<Job> jobs,
        finished: final bool finished,
      ) =>
        (jobs, finished),
      _ => (<Job>[], false),
    };
    if (finished) {
      return;
    }
    state = const SearchJobsState.loading();
    try {
      await ref.read(savedJobControllerProvider.notifier).getSavedJobs();
      final SearchJobsUseCase searchJobUseCase = ref.read(
        searchJobsUseCaseProvider,
      );
      final Either<Failure, List<Job>> result = await searchJobUseCase(
        SearchJobsUseCaseParams(page: page, limit: limit),
      );
      state = result.fold(
        ifLeft:
            (final Failure failure) => SearchJobsState.error(
              failure.message,
            ),
        ifRight:
            (final List<Job> value) => SearchJobsState.loaded(
              jobs: <Job>[...currentJobs, ...value],
              finished: value.isEmpty,
            ),
      );
    } catch (e) {
      state = SearchJobsState.error(e.toString());
    }
  }

  /// Forces an update of the [SearchJobsLoaded] state.
  ///
  /// This can be used to re-trigger UI updates if the underlying job data
  /// (e.g., saved status) has changed elsewhere.
  void update() {
    if (state is SearchJobsLoaded) {
      final (List<Job>? jobs, bool finished) = switch (state) {
        SearchJobsLoaded(
          jobs: final List<Job> jobs,
          finished: final bool finished,
        ) =>
          (jobs, finished),
        _ => (null, false),
      };
      if (jobs == null) {
        return;
      }
      state = SearchJobsState.loaded(jobs: jobs, finished: finished);
    }
  }

  /// Filters jobs based on various criteria.
  ///
  /// [page] The page number for pagination.
  /// [limit] The number of jobs per page.
  /// [title] The job title to search for.
  /// [positions] A list of [Position]s to filter by.
  /// [schedules] A list of [Schedule]s to filter by.
  /// [city] The [City] to filter by.
  /// [majors] A list of [Major]s to filter by.
  Future<void> filterJobs({
    required final int page,
    required final int limit,
    required final String title,
    final List<Position>? positions,
    final List<Schedule>? schedules,
    final City? city,
    final List<Major>? majors,
  }) async {
    state = const SearchJobsState.loading();
    try {
      final FilterJobUseCase filterJobUseCase = ref.read(
        filterJobUseCaseProvider,
      );
      final Either<Failure, List<Job>> result = await filterJobUseCase(
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
        ifLeft:
            (final Failure failure) => SearchJobsState.error(
              failure.message,
            ),
        ifRight:
            (final List<Job> value) => SearchJobsState.loaded(
              jobs: value,
              finished: false,
            ),
      );
    } catch (e) {
      state = SearchJobsState.error(e.toString());
    }
  }
}

/// Represents the state of saved jobs.
@freezed
sealed class SavedJobState with _$SavedJobState {
  /// The initial state before saved jobs are loaded.
  const factory SavedJobState.initial() = SavedJobInitial;

  /// State indicating that saved jobs are being loaded.
  const factory SavedJobState.loading() = SavedJobLoading;

  /// State when saved jobs have been successfully loaded.
  ///
  /// [jobs] A map of job IDs to [Job] objects.
  /// [finished] True if there are no more saved jobs to load.
  const factory SavedJobState.loaded({
    required final Map<int, Job> jobs,
    required final bool finished,
  }) = SavedJobLoaded;

  /// State representing an error during loading saved jobs.
  ///
  /// [message] The error message.
  const factory SavedJobState.error(final String message) = SavedJobError;
}

/// Controller for managing the state of saved jobs.
@Riverpod(keepAlive: true)
class SavedJobController extends _$SavedJobController {
  @override
  SavedJobState build() => const SavedJobState.initial();

  /// Fetches the initial list of saved jobs.
  ///
  /// Does nothing if jobs are already loaded.
  Future<void> getSavedJobs() async {
    if (state is SavedJobLoaded) {
      return;
    }
    await _getJobs(page: 0, limit: 10);
  }

  /// Checks if a job with the given [jobId] is currently in the saved list.
  bool contains(final int jobId) {
    if (state is SavedJobLoaded) {
      return switch (state) {
        SavedJobLoaded(
          jobs: final Map<int, Job> jobs,
        ) =>
          jobs.containsKey(jobId),
        _ => false,
      };
    }
    return false;
  }

  /// Fetches more saved jobs for pagination.
  ///
  /// [page] The page number to fetch.
  Future<void> getMoreJob({required final int page}) async {
    if (state is! SavedJobLoaded) {
      return;
    }
    await _getJobs(page: page, limit: 10);
  }

  /// Resets the saved jobs list and fetches the first page.
  ///
  /// [page] The initial page to fetch after reset (usually 0).
  Future<void> resetJobs({required final int page}) async {
    if (state is! SavedJobLoaded) {
      return;
    }
    state = const SavedJobLoaded(jobs: <int, Job>{}, finished: false);
    await _getJobs(page: 0, limit: 10);
  }

  /// Removes a job from the saved list.
  ///
  /// [jobId] The ID of the job to remove.
  /// Also updates the [SearchJobsController] to reflect the change.
  Future<void> removeJob({required final int jobId}) async {
    if (state is! SavedJobLoaded) {
      return;
    }
    final (Map<int, Job>? jobs, bool? finished) = switch (state) {
      SavedJobLoaded(
        jobs: final Map<int, Job> jobs,
        finished: final bool finished,
      ) =>
        (jobs, finished),
      _ => (null, null),
    };
    if (jobs != null && finished != null) {
      final HashMap<int, Job> newJobs = HashMap<int, Job>.from(jobs)..remove(
        jobId,
      );
      state = SavedJobState.loaded(jobs: newJobs, finished: finished);
      ref.read(searchJobsControllerProvider.notifier).update();
      final DeleteSavedJobUseCase deleteSavedJobUseCase = ref.read(
        deleteSavedJobUseCaseProvider,
      );
      final Either<Failure, Success> result = await deleteSavedJobUseCase(
        DeleteSavedJobParams(jobId: jobId),
      );
      result.fold(
        ifLeft: (final Failure failure) => SavedJobState.error(failure.message),
        ifRight: (_) => null,
      );
    }
  }

  /// Adds a job to the saved list.
  ///
  /// [job] The [Job] object to add.
  /// Also updates the [SearchJobsController] to reflect the change.
  Future<void> addJob({required final Job job}) async {
    if (state is! SavedJobLoaded) {
      return;
    }
    final (Map<int, Job>? jobs, bool? finished) = switch (state) {
      SavedJobLoaded(
        jobs: final Map<int, Job> jobs,
        finished: final bool finished,
      ) =>
        (jobs, finished),
      _ => (null, null),
    };
    if (jobs != null && finished != null) {
      final HashMap<int, Job> newJobs = HashMap<int, Job>.from(jobs);
      newJobs[job.id] = job;
      state = SavedJobState.loaded(jobs: newJobs, finished: finished);
      ref.read(searchJobsControllerProvider.notifier).update();
      final AddSavedJobUseCase addSavedJobUseCase = ref.read(
        addSavedJobUseCaseProvider,
      );
      final Either<Failure, Success> result = await addSavedJobUseCase(
        AddSavedJobParams(jobId: job.id),
      );
      result.fold(
        ifLeft: (final Failure failure) => SavedJobState.error(failure.message),
        ifRight: (_) => null,
      );
    }
  }

  /// Internal helper to fetch saved jobs with pagination.
  Future<void> _getJobs({
    required final int page,
    required final int limit,
  }) async {
    Map<int, Job>? oldJobs = null as Map<int, Job>?;
    if (state is SavedJobLoaded && (state as SavedJobLoaded).finished) {
      oldJobs = switch (state) {
        SavedJobLoaded(jobs: final Map<int, Job> jobs) => jobs,
        _ => null,
      };
    }
    state = const SavedJobState.loading();
    try {
      final GetSavedJobsUseCase getSavedJobsUseCase = ref.read(
        getSavedJobsUseCaseProvider,
      );
      final Either<Failure, List<Job>> result = await getSavedJobsUseCase(
        SavedJobParams(page: page, limit: limit),
      );
      final HashMap<int, Job> jobs = HashMap<int, Job>();
      if (oldJobs != null) {
        for (final Job job in oldJobs.values) {
          jobs[job.id] = job;
        }
      }
      state = result.fold(
        ifLeft: (final Failure failure) => SavedJobState.error(failure.message),
        ifRight:
            (final List<Job> newJobs) => SavedJobState.loaded(
              jobs:
                  jobs..addAll(
                    <int, Job>{for (final Job e in newJobs) e.id: e},
                  ),
              finished: newJobs.isEmpty,
            ),
      );
    } catch (e) {
      state = SavedJobState.error(e.toString());
    }
  }
}

/// Represents the state of fetching cities for location filtering.
@freezed
sealed class CitiesState with _$CitiesState {
  /// The initial state before cities are fetched.
  const factory CitiesState.initial() = CitiesInitial;

  /// State indicating that cities are being loaded.
  const factory CitiesState.loading() = CitiesLoading;

  /// State when cities have been successfully loaded.
  ///
  /// [cities] The list of loaded [City] objects.
  const factory CitiesState.loaded({
    required final List<City> cities,
  }) = CitiesLoaded;

  /// State representing an error during city fetching.
  ///
  /// [message] The error message.
  const factory CitiesState.error(final String message) = CitiesError;
}

/// Controller for managing the state of city data, used for location filters.
@Riverpod(keepAlive: true)
class CitiesController extends _$CitiesController {
  @override
  CitiesState build() => const CitiesState.initial();

  /// Fetches the list of cities.
  ///
  /// Does nothing if cities are already loaded.
  Future<void> fetchCities() async {
    if (state is CitiesLoaded) {
      return;
    }
    state = const CitiesState.loading();
    try {
      final SearchCitiesUseCase searchCitiesUseCase = ref.read(
        searchCitiesUseCaseProvider,
      );
      final Either<Failure, List<City>> result = await searchCitiesUseCase(
        const SearchCitiesParams(depth: 1),
      );
      state = result.fold(
        ifLeft: (final Failure failure) => CitiesState.error(failure.message),
        ifRight:
            (final List<City> cities) => CitiesState.loaded(
              cities: cities,
            ),
      );
    } catch (e) {
      state = CitiesState.error(e.toString());
    }
  }
}

/// Represents the state of fetching districts for a selected city.
@freezed
sealed class DistrictsState with _$DistrictsState {
  /// The initial state before districts are fetched.
  const factory DistrictsState.initial() = DistrictsInitial;

  /// State indicating that districts are being loaded.
  const factory DistrictsState.loading() = DistrictsLoading;

  /// State when districts have been successfully loaded.
  ///
  /// [districts] The list of loaded [District] objects.
  const factory DistrictsState.loaded({
    required final List<District> districts,
  }) = DistrictsLoaded;

  /// State representing an error during district fetching.
  ///
  /// [message] The error message.
  const factory DistrictsState.error(final String message) = DistrictsError;
}

/// Controller for managing the state of district data, used for location
/// filters.
@Riverpod(keepAlive: true)
class DistrictsController extends _$DistrictsController {
  @override
  DistrictsState build() => const DistrictsState.initial();

  /// Resets the districts state to loading, typically before fetching new ones.
  Future<void> reset() async {
    state = const DistrictsState.loading();
  }

  /// Fetches districts for a given city [code].
  Future<void> getDistricts({required final int code}) async {
    state = const DistrictsState.loading();
    try {
      final SearchDistrictsUseCase searchDistrictsUseCase = ref.read(
        searchDistrictsUseCaseProvider,
      );
      final result = await searchDistrictsUseCase(
        SearchDistrictsParams(depth: 2, code: code),
      );
      state = result.fold(
        ifLeft:
            (final Failure failure) => DistrictsState.error(
              failure.message,
            ),
        ifRight:
            (final List<District> districts) => DistrictsState.loaded(
              districts: districts,
            ),
      );
      debugPrint(state.toString());
    } catch (e) {
      state = DistrictsState.error(e.toString());
    }
  }
}

/// Represents the state of fetching academic majors.
@freezed
sealed class MajorState with _$MajorState {
  /// The initial state before majors are fetched.
  const factory MajorState.initial() = MajorInitial;

  /// State indicating that majors are being loaded.
  const factory MajorState.loading() = MajorLoading;

  /// State when majors have been successfully loaded.
  ///
  /// [majors] The list of loaded [Major] objects.
  const factory MajorState.loaded({
    required final List<Major> majors,
  }) = MajorLoaded;

  /// State representing an error during major fetching.
  ///
  /// [message] The error message.
  const factory MajorState.error(final String message) = MajorError;
}

/// Controller for managing the state of academic major data, used for job
/// filters.
@Riverpod(keepAlive: true)
class MajorController extends _$MajorController {
  @override
  MajorState build() => const MajorState.initial();

  /// Fetches the list of academic majors.
  ///
  /// Does nothing if majors are already loaded.
  Future<void> getMajors() async {
    if (state is MajorLoaded) {
      return;
    }
    state = const MajorState.loading();
    try {
      final GetMajorUseCase getMajorUseCase = ref.read(getMajorUseCaseProvider);
      final Either<Failure, List<Major>> result = await getMajorUseCase(nil);
      state = result.fold(
        ifLeft: (final Failure failure) => MajorState.error(failure.message),
        ifRight:
            (final List<Major> majors) => MajorState.loaded(
              majors: majors,
            ),
      );
    } catch (e) {
      state = MajorState.error(e.toString());
    }
  }
}

/// Represents the state of fetching job positions.
@freezed
sealed class PositionState with _$PositionState {
  /// The initial state before positions are fetched.
  const factory PositionState.initial() = PositionInitial;

  /// State indicating that positions are being loaded.
  const factory PositionState.loading() = PositionLoading;

  /// State when positions have been successfully loaded.
  ///
  /// [positions] The list of loaded [Position] objects.
  const factory PositionState.loaded({
    required final List<Position> positions,
  }) = PositionLoaded;

  /// State representing an error during position fetching.
  ///
  /// [message] The error message.
  const factory PositionState.error(final String message) = PositionError;
}

/// Controller for managing the state of job position data, used for job
/// filters.
@Riverpod(keepAlive: true)
class PositionController extends _$PositionController {
  @override
  PositionState build() => const PositionState.initial();

  /// Fetches the list of job positions.
  ///
  /// Does nothing if positions are already loaded.
  Future<void> getPositions() async {
    if (state is PositionLoaded) {
      return;
    }
    state = const PositionState.loading();
    try {
      final GetPositionUseCase getPositionUseCase = ref.read(
        getPositionUseCaseProvider,
      );
      final result = await getPositionUseCase(nil);
      state = result.fold(
        ifLeft: (final Failure failure) => PositionState.error(failure.message),
        ifRight:
            (final List<Position> positions) => PositionState.loaded(
              positions: positions,
            ),
      );
    } catch (e) {
      state = PositionState.error(e.toString());
    }
  }
}

/// Represents the state of fetching work schedules/types.
@freezed
sealed class ScheduleState with _$ScheduleState {
  /// The initial state before schedules are fetched.
  const factory ScheduleState.initial() = ScheduleInitial;

  /// State indicating that schedules are being loaded.
  const factory ScheduleState.loading() = ScheduleLoading;

  /// State when schedules have been successfully loaded.
  ///
  /// [schedules] The list of loaded [Schedule] objects.
  const factory ScheduleState.loaded({
    required final List<Schedule> schedules,
  }) = ScheduleLoaded;

  /// State representing an error during schedule fetching.
  ///
  /// [message] The error message.
  const factory ScheduleState.error(final String message) = ScheduleError;
}

/// Controller for managing the state of work schedule data, used for job
/// filters.
@Riverpod(keepAlive: true)
class ScheduleController extends _$ScheduleController {
  @override
  ScheduleState build() => const ScheduleState.initial();

  /// Fetches the list of work schedules.
  ///
  /// Does nothing if schedules are already loaded.
  Future<void> getSchedules() async {
    if (state is ScheduleLoaded) {
      return;
    }
    state = const ScheduleState.loading();
    try {
      final GetScheduleUseCase getScheduleUseCase = ref.read(
        getScheduleUseCaseProvider,
      );
      final result = await getScheduleUseCase(nil);
      state = result.fold(
        ifLeft: (final Failure failure) => ScheduleState.error(failure.message),
        ifRight:
            (final List<Schedule> schedules) => ScheduleState.loaded(
              schedules: schedules,
            ),
      );
    } catch (e) {
      state = ScheduleState.error(e.toString());
    }
  }
}

/// Represents the state of job filtering criteria.
@freezed
sealed class JobFilterState with _$JobFilterState {
  /// The initial filter state, typically empty.
  ///
  /// [schedules] Set of selected schedule IDs.
  /// [positions] Set of selected position IDs.
  /// [majors] Set of selected major IDs.
  /// [title] The current search title.
  /// [city] The selected city for filtering.
  const factory JobFilterState.initial({
    required final Set<int> schedules,
    required final Set<int> positions,
    required final Set<int> majors,
    required final String title,
    final City? city,
  }) = JobFilterInitial;

  /// State representing active filter criteria being used for a search.
  ///
  /// Includes both IDs and the corresponding entity lists for convenience.
  ///
  /// [schedules] Set of selected schedule IDs.
  /// [positions] Set of selected position IDs.
  /// [majors] Set of selected major IDs.
  /// [title] The current search title.
  /// [city] The selected city for filtering.
  /// [schedulesList] List of selected [Schedule] entities.
  /// [positionsList] List of selected [Position] entities.
  /// [majorsList] List of selected [Major] entities.
  const factory JobFilterState.onSearch({
    required final Set<int> schedules,
    required final Set<int> positions,
    required final Set<int> majors,
    required final String title,
    required final City? city,
    required final List<Schedule>? schedulesList,
    required final List<Position>? positionsList,
    required final List<Major>? majorsList,
  }) = JobFilterOnSearch;
}

/// Controller for managing the currently applied job filters.
@Riverpod(keepAlive: true)
class JobFilterController extends _$JobFilterController {
  @override
  JobFilterState build() => JobFilterState.initial(
    schedules: HashSet(),
    positions: HashSet(),
    majors: HashSet(),
    title: '',
  );

  /// Returns true if the current filter state is initial (no filters applied).
  bool isEmpty() => state is JobFilterInitial;

  /// Resets all filters to their initial empty state.
  Future<void> resetFilter() async {
    state = JobFilterState.initial(
      schedules: HashSet(),
      positions: HashSet(),
      majors: HashSet(),
      title: '',
    );
  }

  /// Saves the selected filter criteria and triggers a filtered job search.
  Future<void> saveFilteredJob({
    required final Set<int> schedules,
    required final Set<int> positions,
    required final Set<int> majors,
    required final List<Schedule>? schedulesList,
    required final List<Position>? positionsList,
    required final List<Major>? majorsList,
    required final City? city,
    required final String title,
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

/// Represents the state of fetching job details.
@freezed
sealed class JobDetailState with _$JobDetailState {
  /// The initial state before job details are fetched.
  const factory JobDetailState.initial() = JobDetailInitial;

  /// State indicating that job details are being loaded.
  const factory JobDetailState.loading() = JobDetailLoading;

  /// State when job details have been successfully loaded.
  ///
  /// [job] The loaded [Job] object.
  /// [relatedJobs] A list of jobs related to the main [job].
  const factory JobDetailState.loaded({
    required final Job job,
    required final List<Job> relatedJobs,
  }) = JobDetailLoaded;

  /// State representing an error during job detail fetching.
  ///
  /// [message] The error message.
  const factory JobDetailState.error(final String message) = JobDetailError;
}

/// Controller for managing the state of fetching and displaying job details.
@Riverpod(keepAlive: true)
class JobDetailController extends _$JobDetailController {
  @override
  JobDetailState build() => const JobDetailState.initial();

  /// Fetches the details for a specific job and its related jobs.
  ///
  /// [jobId] The ID of the job to fetch.
  Future<void> getJobDetail({required final int jobId}) async {
    state = const JobDetailState.loading();
    try {
      final GetJobDetailUseCase getJobDetailUseCase = ref.read(
        getJobDetailUseCaseProvider,
      );
      final Either<Failure, Job> result = await getJobDetailUseCase(
        GetJobDetailParams(jobId: jobId),
      );
      Job? job = null as Job?;
      state = result.fold(
        ifLeft:
            (final Failure failure) => JobDetailState.error(
              failure.message,
            ),
        ifRight: (final Job it) {
          job = it;
          return const JobDetailState.loading();
        },
      );
      if (job == null) {
        return;
      }
      final GetJobByCompanyUseCase getJobByCompanyUseCase = ref.read(
        getJobByCompanyUseCaseProvider,
      );
      final Either<Failure, List<Job>> otherJobs = await getJobByCompanyUseCase(
        GetJobByCompanyParams(company: job!.company, page: 0, limit: 5),
      );
      state = otherJobs.fold(
        ifLeft:
            (final Failure failure) => JobDetailState.error(
              failure.message,
            ),
        ifRight:
            (final List<Job> jobs) => JobDetailState.loaded(
              job: job!,
              relatedJobs: [...jobs.where((final Job e) => e.id != job!.id)],
            ),
      );
    } catch (e) {
      state = JobDetailState.error(e.toString());
    }
  }
}

/// Represents the state of applying for a job and fetching applied jobs.
@freezed
sealed class ApplyJobState with _$ApplyJobState {
  /// The initial state.
  const factory ApplyJobState.initial() = ApplyJobInitial;

  /// State indicating an operation (applying or fetching) is in progress.
  const factory ApplyJobState.loading() = ApplyJobLoading;

  /// State when applied jobs are loaded or a job application is successful.
  ///
  /// [jobs] The list of jobs the user has applied for.
  /// [finished] True if there are no more applied jobs to load.
  const factory ApplyJobState.loaded({
    required final List<Job> jobs,
    required final bool finished,
  }) = ApplyJobLoaded;

  /// State representing an error during an operation.
  ///
  /// [message] The error message.
  const factory ApplyJobState.error(final String message) = ApplyJobError;
}

/// Controller for managing job applications and fetching applied jobs.
@Riverpod(keepAlive: true)
final class ApplyJobController extends _$ApplyJobController {
  @override
  ApplyJobState build() => const ApplyJobState.initial();

  /// Fetches the list of jobs the current user has applied for, with
  /// pagination.
  ///
  /// [page] The page number to fetch.
  Future<void> getJobApplied({required final int page}) async {
    if (state is ApplyJobLoaded && (state as ApplyJobLoaded).finished) {
      return;
    }
    final List<Job> oldJobs = switch (state) {
      ApplyJobLoaded(jobs: final List<Job> jobs) => jobs,
      _ => <Job>[],
    };
    state = const ApplyJobState.loading();
    try {
      final GetAppliedJobsUseCase getAppliedJobsUseCase = ref.read(
        getAppliedJobsUseCaseProvider,
      );
      final Either<Failure, List<Job>> result = await getAppliedJobsUseCase(
        AppliedJobParams(page: page, limit: 10),
      );
      state = result.fold(
        ifLeft: (final Failure failure) => ApplyJobState.error(failure.message),
        ifRight:
            (final List<Job> value) => ApplyJobState.loaded(
              jobs: <Job>[...oldJobs, ...value],
              finished: value.isEmpty,
            ),
      );
    } catch (e) {
      state = ApplyJobState.error(e.toString());
    }
  }

  /// Applies for a job on behalf of the current user.
  ///
  /// [jobId] The ID of the job to apply for.
  /// [referenceLetter] The cover letter text.
  /// [cv] The [FileSelectorResult] containing the CV file.
  Future<void> applyJob({
    required final int jobId,
    required final String referenceLetter,
    required final FileSelectorResult cv,
  }) async {
    final (List<Job> oldJobs, bool finished) = switch (state) {
      ApplyJobLoaded(
        jobs: final List<Job> jobs,
        finished: final bool finished,
      ) =>
        (jobs, finished),
      _ => (<Job>[], false),
    };
    state = const ApplyJobState.loading();
    try {
      final ApplyJobUseCase applyJobUseCase = ref.read(applyJobUseCaseProvider);
      final Either<Failure, Job> result = await applyJobUseCase(
        ApplyJobParams(
          jobId: jobId,
          referenceLetter: referenceLetter,
          cv: FileRequest(name: cv.name, data: cv.data),
        ),
      );
      state = result.fold(
        ifLeft: (final Failure failure) => ApplyJobState.error(failure.message),
        ifRight:
            (final Job job) => ApplyJobState.loaded(
              jobs: <Job>[...oldJobs, job],
              finished: finished,
            ),
      );
    } catch (e) {
      state = ApplyJobState.error(e.toString());
    }
  }
}
