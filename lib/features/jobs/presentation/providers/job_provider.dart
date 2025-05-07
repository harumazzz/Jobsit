import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/location_service.dart';
import '../../../../core/usecases/usecase.dart';
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

  Future<void> filterJobs({
    required int page,
    required int limit,
    required String title,
    Position? position,
    Schedule? schedule,
    City? city,
    Major? major,
  }) async {
    state = const SearchJobsState.loading();
    try {
      final filterJobUseCase = ref.read(filterJobUseCaseProvider);
      final result = await filterJobUseCase(
        FilterJobUseCaseParams(
          page: page,
          limit: limit,
          position: position,
          schedule: schedule,
          city: city,
          major: major,
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
    if (state is DistrictsLoaded) {
      return;
    }
    state = const DistrictsState.loading();
    try {
      final searchDistrictsUseCase = ref.read(searchDistrictsUseCaseProvider);
      final result = await searchDistrictsUseCase(SearchDistrictsParams(depth: 2, code: code));
      state = result.fold(
        ifLeft: (failure) => DistrictsState.error(failure.message),
        ifRight: (districts) => DistrictsState.loaded(districts: districts),
      );
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
    required int scheduleIndex,
    required int positionscheduleIndex,
    required int majorIndex,
    required String title,
    City? city,
  }) = JobFilterInitial;

  const factory JobFilterState.onSearch({
    required int scheduleIndex,
    required int positionscheduleIndex,
    required int majorIndex,
    required String title,
    Schedule? schedule,
    Position? position,
    City? city,
    Major? major,
  }) = JobFilterOnSearch;
}

@Riverpod(keepAlive: true)
class JobFilterController extends _$JobFilterController {
  @override
  JobFilterState build() {
    return const JobFilterState.initial(scheduleIndex: 0, positionscheduleIndex: 0, majorIndex: 0, title: '');
  }

  bool get isEmpty {
    return state is JobFilterInitial;
  }

  Future<void> resetFilter() async {
    state = const JobFilterState.initial(scheduleIndex: 0, positionscheduleIndex: 0, majorIndex: 0, title: '');
  }

  Future<void> saveFilteredJob({
    required int scheduleIndex,
    required int positionscheduleIndex,
    required int majorIndex,
    required String title,
    Schedule? schedule,
    Position? position,
    City? city,
    Major? major,
  }) async {
    state = JobFilterState.onSearch(
      scheduleIndex: scheduleIndex,
      positionscheduleIndex: positionscheduleIndex,
      majorIndex: majorIndex,
      schedule: schedule,
      position: position,
      city: city,
      major: major,
      title: title,
    );
    await ref
        .read(searchJobsControllerProvider.notifier)
        .filterJobs(page: 0, limit: 10, schedule: schedule, position: position, city: city, major: major, title: title);
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
        ifRight: (jobs) => JobDetailState.loaded(job: job!, relatedJobs: jobs),
      );
    } catch (e) {
      state = JobDetailState.error(e.toString());
    }
  }
}
