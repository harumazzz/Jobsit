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

  Future<void> fetchDistricts({required int code}) async {
    if (state is DistrictsLoaded) {
      return;
    }
    state = const DistrictsState.loading();
    try {
      final searchDistrictsUseCase = ref.read(searchDistrictsUseCaseProvider);
      final result = await searchDistrictsUseCase(SearchDistrictsParams(depth: 1, code: code));
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

  Future<void> fetchMajors() async {
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

  Future<void> fetchPositions() async {
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

  Future<void> fetchSchedules() async {
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
    City? city,
  }) = JobFilterInitial;

  const factory JobFilterState.onSearch({
    required int scheduleIndex,
    required int positionscheduleIndex,
    required int majorIndex,
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
    return const JobFilterState.initial(scheduleIndex: 0, positionscheduleIndex: 0, majorIndex: 0);
  }

  Future<void> saveFilteredJob({
    required int scheduleIndex,
    required int positionscheduleIndex,
    required int majorIndex,
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
    );
  }
}
