import 'dart:typed_data';

import 'package:dart_either/dart_either.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobsit/core/error/failures.dart';
import 'package:jobsit/core/services/file_service.dart';
import 'package:jobsit/core/services/location_service.dart';
import 'package:jobsit/core/usecases/usecase.dart';
import 'package:jobsit/features/jobs/domain/entities/job.dart';
import 'package:jobsit/features/jobs/domain/usecases/get_applied_jobs.dart';
import 'package:jobsit/features/jobs/domain/usecases/get_saved_jobs.dart';
import 'package:jobsit/features/jobs/domain/usecases/search_jobs.dart';
import 'package:jobsit/features/jobs/presentation/providers/job_provider.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes for use cases
class MockSearchJobsUseCase extends Mock implements SearchJobsUseCase {}

class MockFilterJobUseCase extends Mock implements FilterJobUseCase {}

class MockGetSavedJobsUseCase extends Mock implements GetSavedJobsUseCase {}

class MockSearchCitiesUseCase extends Mock implements SearchCitiesUseCase {}

// ignore: lines_longer_than_80_chars
class MockSearchDistrictsUseCase extends Mock implements SearchDistrictsUseCase {}

class MockGetMajorUseCase extends Mock implements GetMajorUseCase {}

class MockGetPositionUseCase extends Mock implements GetPositionUseCase {}

class MockGetScheduleUseCase extends Mock implements GetScheduleUseCase {}

class MockGetJobDetailUseCase extends Mock implements GetJobDetailUseCase {}

// ignore: lines_longer_than_80_chars
class MockGetJobByCompanyUseCase extends Mock implements GetJobByCompanyUseCase {}

class MockGetAppliedJobsUseCase extends Mock implements GetAppliedJobsUseCase {}

class MockApplyJobUseCase extends Mock implements ApplyJobUseCase {}

// Mock listener class
class MockListener<T> extends Mock {
  void call(final T? previous, final T next);
}

void main() {
  // Register fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(const SearchJobsUseCaseParams(page: 0, limit: 10));
    registerFallbackValue(const FilterJobUseCaseParams(page: 0, limit: 10));
    registerFallbackValue(const SavedJobParams(page: 0, limit: 10));
    registerFallbackValue(const AddSavedJobParams(jobId: 1));
    registerFallbackValue(const DeleteSavedJobParams(jobId: 1));
    registerFallbackValue(const SearchCitiesParams(depth: 1));
    registerFallbackValue(const SearchDistrictsParams(depth: 1, code: 1));
    registerFallbackValue(const GetJobDetailParams(jobId: 1));
    registerFallbackValue(
      const GetJobByCompanyParams(
        company: Company(
          id: 1,
          name: 'Test Company',
          logo: 'test.png',
          status: JobStatus(id: 1, name: 'Active'),
        ),
        page: 0,
        limit: 10,
      ),
    );
    registerFallbackValue(const AppliedJobParams(page: 0, limit: 10));
    registerFallbackValue(
      ApplyJobParams(
        jobId: 1,
        referenceLetter: 'Test letter',
        cv: FileRequest(name: 'test.pdf', data: Uint8List(0)),
      ),
    );
    registerFallbackValue(const NoParams());
  });

  // Test data setup
  const tServerFailure = ServerFailure('Server Error');
  const tPage = 0;
  const tLimit = 10;
  const tJobTitle = 'Software Developer';

  final tJob = Job(
    id: 1,
    title: 'Test Job',
    description: 'Test Description',
    address: 'Test Address',
    amount: 1,
    benefits: 'None',
    city: 'Test City',
    applicationDeadline: DateTime(2025, 12, 31),
    country: 'Test Country',
    requirements: 'Test Requirements',
    noAllowance: false,
    postingDate: DateTime(2025),
    district: 'Test District',
    maxAllowance: 100,
    minAllowance: 50,
    company: const Company(
      id: 1,
      name: 'Test Company',
      logo: 'test_logo.png',
      status: JobStatus(id: 1, name: 'Active'),
    ),
    majors: const [Major(id: 1, name: 'Computer Science')],
    schedules: const [Schedule(id: 1, name: 'Full-time')],
    positions: const [Position(id: 1, name: 'Developer')],
    status: const JobStatus(id: 1, name: 'Active'),
  );

  final tJobList = [tJob];

  const tCity = City(
    code: 1,
    name: 'Test City',
    codename: 'test-city',
    divisionType: 'city',
    phoneCode: 123,
    districts: [],
  );

  const tDistrict = District(
    code: 1,
    name: 'Test District',
    codename: 'test-district',
    divisionType: 'district',
    provinceCode: 1,
    wards: [],
  );

  const tMajor = Major(id: 1, name: 'Computer Science');
  const tPosition = Position(id: 1, name: 'Developer');
  const tSchedule = Schedule(id: 1, name: 'Full-time');

  group('SearchJobsController', () {
    late MockSearchJobsUseCase mockSearchJobsUseCase;
    late MockFilterJobUseCase mockFilterJobUseCase;
    late MockGetSavedJobsUseCase mockGetSavedJobsUseCase;

    setUp(() {
      mockSearchJobsUseCase = MockSearchJobsUseCase();
      mockFilterJobUseCase = MockFilterJobUseCase();
      mockGetSavedJobsUseCase = MockGetSavedJobsUseCase();
    });

    group('build', () {
      testWidgets('should return initial state', (final tester) async {
        final container = ProviderContainer(
          overrides: [
            searchJobsUseCaseProvider.overrideWithValue(mockSearchJobsUseCase),
          ],
        );

        final controller = container.read(searchJobsControllerProvider);

        expect(controller, equals(const SearchJobsState.initial()));
        container.dispose();
      });
    });

    group('reset', () {
      testWidgets('should set state to loaded with empty jobs list', (
        final tester,
      ) async {
        final container = ProviderContainer(
          overrides: [
            searchJobsUseCaseProvider.overrideWithValue(mockSearchJobsUseCase),
          ],
        );

        final controller = container.read(
          searchJobsControllerProvider.notifier,
        );

        await controller.reset();

        final state = container.read(searchJobsControllerProvider);
        expect(
          state,
          equals(
            const SearchJobsState.loaded(jobs: [], finished: false),
          ),
        );
        container.dispose();
      });
    });

    group('searchJobs', () {
      testWidgets('should emit loading then loaded when successful', (
        final tester,
      ) async {
        when(() => mockSearchJobsUseCase(any())).thenAnswer(
          (_) async => Right(tJobList),
        );
        when(() => mockGetSavedJobsUseCase(any())).thenAnswer(
          (_) async => Right(tJobList),
        );

        final container = ProviderContainer(
          overrides: [
            searchJobsUseCaseProvider.overrideWithValue(mockSearchJobsUseCase),
            getSavedJobsUseCaseProvider.overrideWithValue(
              mockGetSavedJobsUseCase,
            ),
          ],
        );

        final controller = container.read(
          searchJobsControllerProvider.notifier,
        );
        final listener = MockListener<SearchJobsState>();

        container.listen(
          searchJobsControllerProvider,
          listener.call,
          fireImmediately: true,
        );

        await controller.searchJobs(page: tPage, limit: tLimit);

        verifyInOrder([
          () => listener(null, const SearchJobsState.initial()),
          () => listener(any(), const SearchJobsState.loading()),
          () => listener(
            any(),
            SearchJobsState.loaded(
              jobs: tJobList,
              finished: false,
            ),
          ),
        ]);

        verify(
          () => mockSearchJobsUseCase(
            const SearchJobsUseCaseParams(page: tPage, limit: tLimit),
          ),
        ).called(1);

        container.dispose();
      });

      testWidgets('should emit loading then error when use case fails', (
        final tester,
      ) async {
        when(() => mockSearchJobsUseCase(any())).thenAnswer(
          (_) async => const Left(tServerFailure),
        );
        when(() => mockGetSavedJobsUseCase(any())).thenAnswer(
          (_) async => Right(tJobList),
        );

        final container = ProviderContainer(
          overrides: [
            searchJobsUseCaseProvider.overrideWithValue(mockSearchJobsUseCase),
            getSavedJobsUseCaseProvider.overrideWithValue(
              mockGetSavedJobsUseCase,
            ),
          ],
        );

        final controller = container.read(
          searchJobsControllerProvider.notifier,
        );
        final listener = MockListener<SearchJobsState>();

        container.listen(
          searchJobsControllerProvider,
          listener.call,
          fireImmediately: true,
        );

        await controller.searchJobs(page: tPage, limit: tLimit);

        verifyInOrder([
          () => listener(null, const SearchJobsState.initial()),
          () => listener(any(), const SearchJobsState.loading()),
          () => listener(any(), const SearchJobsState.error('Server Error')),
        ]);

        container.dispose();
      });

      testWidgets('should not search when finished is true', (
        final tester,
      ) async {
        final container = ProviderContainer(
          overrides: [
            searchJobsUseCaseProvider.overrideWithValue(mockSearchJobsUseCase),
          ],
        );

        final controller = container.read(searchJobsControllerProvider.notifier)
          ..state = const SearchJobsState.loaded(
            jobs: [],
            finished: true,
          );

        await controller.searchJobs(page: tPage, limit: tLimit);

        verifyNever(() => mockSearchJobsUseCase(any()));

        container.dispose();
      });
    });

    group('filterJobs', () {
      testWidgets('should emit loading then loaded when successful', (
        final tester,
      ) async {
        when(() => mockFilterJobUseCase(any())).thenAnswer(
          (_) async => Right(tJobList),
        );

        final container = ProviderContainer(
          overrides: [
            filterJobUseCaseProvider.overrideWithValue(mockFilterJobUseCase),
          ],
        );

        final controller = container.read(
          searchJobsControllerProvider.notifier,
        );
        final listener = MockListener<SearchJobsState>();

        container.listen(
          searchJobsControllerProvider,
          listener.call,
          fireImmediately: true,
        );

        await controller.filterJobs(
          page: tPage,
          limit: tLimit,
          title: tJobTitle,
          positions: [tPosition],
          schedules: [tSchedule],
          city: tCity,
          majors: [tMajor],
        );

        verifyInOrder([
          () => listener(null, const SearchJobsState.initial()),
          () => listener(any(), const SearchJobsState.loading()),
          () => listener(
            any(),
            SearchJobsState.loaded(jobs: tJobList, finished: false),
          ),
        ]);

        verify(
          () => mockFilterJobUseCase(
            const FilterJobUseCaseParams(
              page: tPage,
              limit: tLimit,
              positions: [tPosition],
              schedules: [tSchedule],
              city: tCity,
              majors: [tMajor],
              title: tJobTitle,
            ),
          ),
        ).called(1);

        container.dispose();
      });

      testWidgets('should emit loading then error when use case fails', (
        final tester,
      ) async {
        when(() => mockFilterJobUseCase(any())).thenAnswer(
          (_) async => const Left(tServerFailure),
        );

        final container = ProviderContainer(
          overrides: [
            filterJobUseCaseProvider.overrideWithValue(mockFilterJobUseCase),
          ],
        );

        final controller = container.read(
          searchJobsControllerProvider.notifier,
        );
        final listener = MockListener<SearchJobsState>();

        container.listen(
          searchJobsControllerProvider,
          listener.call,
          fireImmediately: true,
        );

        await controller.filterJobs(
          page: tPage,
          limit: tLimit,
          title: tJobTitle,
        );

        verifyInOrder([
          () => listener(null, const SearchJobsState.initial()),
          () => listener(any(), const SearchJobsState.loading()),
          () => listener(any(), const SearchJobsState.error('Server Error')),
        ]);

        container.dispose();
      });
    });

    group('update', () {
      testWidgets('should update state when currently loaded', (
        final tester,
      ) async {
        final container = ProviderContainer();
        final controller = container.read(
            searchJobsControllerProvider.notifier,
          )
          ..state = SearchJobsState.loaded(
            jobs: tJobList,
            finished: false,
          );

        final listener = MockListener<SearchJobsState>();
        container.listen(
          searchJobsControllerProvider,
          listener.call,
          fireImmediately: true,
        );

        controller.update();

        verify(
          () => listener(
            any(),
            SearchJobsState.loaded(jobs: tJobList, finished: false),
          ),
        ).called(2); // Once for initial state, once for update

        container.dispose();
      });

      testWidgets('should not update when state is not loaded', (
        final tester,
      ) async {
        final container = ProviderContainer();
        final controller = container.read(
          searchJobsControllerProvider.notifier,
        );

        final listener = MockListener<SearchJobsState>();
        container.listen(
          searchJobsControllerProvider,
          listener.call,
          fireImmediately: true,
        );

        controller.update();

        verify(() => listener(null, const SearchJobsState.initial())).called(1);
        verifyNoMoreInteractions(listener);

        container.dispose();
      });
    });
  });

  group('SavedJobController', () {
    late MockGetSavedJobsUseCase mockGetSavedJobsUseCase;

    setUp(() {
      mockGetSavedJobsUseCase = MockGetSavedJobsUseCase();
    });

    group('build', () {
      testWidgets('should return initial state', (final tester) async {
        final container = ProviderContainer();

        final controller = container.read(savedJobControllerProvider);

        expect(controller, equals(const SavedJobState.initial()));
        container.dispose();
      });
    });

    group('getSavedJobs', () {
      testWidgets('should fetch jobs when state is initial', (
        final tester,
      ) async {
        when(() => mockGetSavedJobsUseCase(any())).thenAnswer(
          (_) async => Right(tJobList),
        );

        final container = ProviderContainer(
          overrides: [
            getSavedJobsUseCaseProvider.overrideWithValue(
              mockGetSavedJobsUseCase,
            ),
          ],
        );

        final controller = container.read(savedJobControllerProvider.notifier);
        final listener = MockListener<SavedJobState>();

        container.listen(
          savedJobControllerProvider,
          listener.call,
          fireImmediately: true,
        );

        await controller.getSavedJobs();

        verifyInOrder([
          () => listener(null, const SavedJobState.initial()),
          () => listener(any(), const SavedJobState.loading()),
          () => listener(
            any(),
            SavedJobState.loaded(jobs: {1: tJob}, finished: false),
          ),
        ]);

        verify(
          () => mockGetSavedJobsUseCase(
            const SavedJobParams(page: 0, limit: 10),
          ),
        ).called(1);

        container.dispose();
      });

      testWidgets('should not fetch jobs when already loaded', (
        final tester,
      ) async {
        final container = ProviderContainer(
          overrides: [
            getSavedJobsUseCaseProvider.overrideWithValue(
              mockGetSavedJobsUseCase,
            ),
          ],
        );

        final controller = container.read(savedJobControllerProvider.notifier)
          ..state = SavedJobState.loaded(
            jobs: {1: tJob},
            finished: false,
          );

        await controller.getSavedJobs();

        verifyNever(() => mockGetSavedJobsUseCase(any()));

        container.dispose();
      });

      testWidgets('should emit loading then error when use case fails', (
        final tester,
      ) async {
        when(() => mockGetSavedJobsUseCase(any())).thenAnswer(
          (_) async => const Left(tServerFailure),
        );

        final container = ProviderContainer(
          overrides: [
            getSavedJobsUseCaseProvider.overrideWithValue(
              mockGetSavedJobsUseCase,
            ),
          ],
        );

        final controller = container.read(savedJobControllerProvider.notifier);
        final listener = MockListener<SavedJobState>();

        container.listen(
          savedJobControllerProvider,
          listener.call,
          fireImmediately: true,
        );

        await controller.getSavedJobs();

        verifyInOrder([
          () => listener(null, const SavedJobState.initial()),
          () => listener(any(), const SavedJobState.loading()),
          () => listener(any(), const SavedJobState.error('Server Error')),
        ]);

        container.dispose();
      });
    });
  });

  group('CitiesController', () {
    late MockSearchCitiesUseCase mockSearchCitiesUseCase;

    setUp(() {
      mockSearchCitiesUseCase = MockSearchCitiesUseCase();
    });

    group('fetchCities', () {
      testWidgets('should emit loading then loaded when successful', (
        final tester,
      ) async {
        final cityList = [tCity];

        when(() => mockSearchCitiesUseCase(any())).thenAnswer(
          (_) async => Right(cityList),
        );

        final container = ProviderContainer(
          overrides: [
            searchCitiesUseCaseProvider.overrideWithValue(
              mockSearchCitiesUseCase,
            ),
          ],
        );

        final controller = container.read(citiesControllerProvider.notifier);
        final listener = MockListener<CitiesState>();

        container.listen(
          citiesControllerProvider,
          listener.call,
          fireImmediately: true,
        );

        await controller.fetchCities();

        verifyInOrder([
          () => listener(null, const CitiesState.initial()),
          () => listener(any(), const CitiesState.loading()),
          () => listener(any(), CitiesState.loaded(cities: cityList)),
        ]);

        verify(
          () => mockSearchCitiesUseCase(
            const SearchCitiesParams(depth: 1),
          ),
        ).called(1);

        container.dispose();
      });

      testWidgets('should not fetch cities when already loaded', (
        final tester,
      ) async {
        final container = ProviderContainer(
          overrides: [
            searchCitiesUseCaseProvider.overrideWithValue(
              mockSearchCitiesUseCase,
            ),
          ],
        );

        final controller = container.read(citiesControllerProvider.notifier)
          ..state = const CitiesState.loaded(
            cities: [tCity],
          );

        await controller.fetchCities();

        verifyNever(() => mockSearchCitiesUseCase(any()));

        container.dispose();
      });

      testWidgets('should emit loading then error when use case fails', (
        final tester,
      ) async {
        when(() => mockSearchCitiesUseCase(any())).thenAnswer(
          (_) async => const Left(
            tServerFailure,
          ),
        );

        final container = ProviderContainer(
          overrides: [
            searchCitiesUseCaseProvider.overrideWithValue(
              mockSearchCitiesUseCase,
            ),
          ],
        );

        final controller = container.read(citiesControllerProvider.notifier);
        final listener = MockListener<CitiesState>();

        container.listen(
          citiesControllerProvider,
          listener.call,
          fireImmediately: true,
        );

        await controller.fetchCities();

        verifyInOrder([
          () => listener(null, const CitiesState.initial()),
          () => listener(any(), const CitiesState.loading()),
          () => listener(any(), const CitiesState.error('Server Error')),
        ]);

        container.dispose();
      });
    });
  });

  group('DistrictsController', () {
    late MockSearchDistrictsUseCase mockSearchDistrictsUseCase;

    setUp(() {
      mockSearchDistrictsUseCase = MockSearchDistrictsUseCase();
    });

    group('getDistricts', () {
      testWidgets('should emit loading then loaded when successful', (
        final tester,
      ) async {
        final districtList = [tDistrict];

        when(() => mockSearchDistrictsUseCase(any())).thenAnswer(
          (_) async => Right(
            districtList,
          ),
        );

        final container = ProviderContainer(
          overrides: [
            searchDistrictsUseCaseProvider.overrideWithValue(
              mockSearchDistrictsUseCase,
            ),
          ],
        );

        final controller = container.read(districtsControllerProvider.notifier);
        final listener = MockListener<DistrictsState>();

        container.listen(
          districtsControllerProvider,
          listener.call,
          fireImmediately: true,
        );

        await controller.getDistricts(code: 1);

        verifyInOrder([
          () => listener(null, const DistrictsState.initial()),
          () => listener(any(), const DistrictsState.loading()),
          () => listener(any(), DistrictsState.loaded(districts: districtList)),
        ]);

        verify(
          () => mockSearchDistrictsUseCase(
            const SearchDistrictsParams(depth: 2, code: 1),
          ),
        ).called(1);

        container.dispose();
      });

      testWidgets('should emit loading then error when use case fails', (
        final tester,
      ) async {
        when(() => mockSearchDistrictsUseCase(any())).thenAnswer(
          (_) async => const Left(tServerFailure),
        );

        final container = ProviderContainer(
          overrides: [
            searchDistrictsUseCaseProvider.overrideWithValue(
              mockSearchDistrictsUseCase,
            ),
          ],
        );

        final controller = container.read(districtsControllerProvider.notifier);
        final listener = MockListener<DistrictsState>();

        container.listen(
          districtsControllerProvider,
          listener.call,
          fireImmediately: true,
        );

        await controller.getDistricts(code: 1);

        verifyInOrder([
          () => listener(null, const DistrictsState.initial()),
          () => listener(any(), const DistrictsState.loading()),
          () => listener(any(), const DistrictsState.error('Server Error')),
        ]);

        container.dispose();
      });
    });

    group('reset', () {
      testWidgets('should set state to loading', (final tester) async {
        final container = ProviderContainer();
        final controller = container.read(districtsControllerProvider.notifier);
        final listener = MockListener<DistrictsState>();

        container.listen(
          districtsControllerProvider,
          listener.call,
          fireImmediately: true,
        );

        await controller.reset();

        verifyInOrder([
          () => listener(null, const DistrictsState.initial()),
          () => listener(any(), const DistrictsState.loading()),
        ]);

        container.dispose();
      });
    });
  });

  group('MajorController', () {
    late MockGetMajorUseCase mockGetMajorUseCase;

    setUp(() {
      mockGetMajorUseCase = MockGetMajorUseCase();
    });

    group('getMajors', () {
      testWidgets('should emit loading then loaded when successful', (
        final tester,
      ) async {
        final majorList = [tMajor];

        when(() => mockGetMajorUseCase(any())).thenAnswer(
          (_) async => Right(
            majorList,
          ),
        );

        final container = ProviderContainer(
          overrides: [
            getMajorUseCaseProvider.overrideWithValue(mockGetMajorUseCase),
          ],
        );

        final controller = container.read(majorControllerProvider.notifier);
        final listener = MockListener<MajorState>();

        container.listen(
          majorControllerProvider,
          listener.call,
          fireImmediately: true,
        );

        await controller.getMajors();

        verifyInOrder([
          () => listener(null, const MajorState.initial()),
          () => listener(any(), const MajorState.loading()),
          () => listener(any(), MajorState.loaded(majors: majorList)),
        ]);

        verify(() => mockGetMajorUseCase(const NoParams())).called(1);

        container.dispose();
      });

      testWidgets('should not fetch majors when already loaded', (
        final tester,
      ) async {
        final container = ProviderContainer(
          overrides: [
            getMajorUseCaseProvider.overrideWithValue(mockGetMajorUseCase),
          ],
        );

        final controller = container.read(majorControllerProvider.notifier)
          ..state = const MajorState.loaded(majors: [tMajor]);

        await controller.getMajors();

        verifyNever(() => mockGetMajorUseCase(any()));

        container.dispose();
      });

      testWidgets('should emit loading then error when use case fails', (
        final tester,
      ) async {
        when(() => mockGetMajorUseCase(any())).thenAnswer(
          (_) async => const Left(tServerFailure),
        );

        final container = ProviderContainer(
          overrides: [
            getMajorUseCaseProvider.overrideWithValue(mockGetMajorUseCase),
          ],
        );

        final controller = container.read(majorControllerProvider.notifier);
        final listener = MockListener<MajorState>();

        container.listen(
          majorControllerProvider,
          listener.call,
          fireImmediately: true,
        );

        await controller.getMajors();

        verifyInOrder([
          () => listener(null, const MajorState.initial()),
          () => listener(any(), const MajorState.loading()),
          () => listener(any(), const MajorState.error('Server Error')),
        ]);

        container.dispose();
      });
    });
  });

  group('PositionController', () {
    late MockGetPositionUseCase mockGetPositionUseCase;

    setUp(() {
      mockGetPositionUseCase = MockGetPositionUseCase();
    });

    group('getPositions', () {
      testWidgets('should emit loading then loaded when successful', (
        final tester,
      ) async {
        final positionList = [tPosition];

        when(() => mockGetPositionUseCase(any())).thenAnswer(
          (_) async => Right(
            positionList,
          ),
        );

        final container = ProviderContainer(
          overrides: [
            getPositionUseCaseProvider.overrideWithValue(
              mockGetPositionUseCase,
            ),
          ],
        );

        final controller = container.read(positionControllerProvider.notifier);
        final listener = MockListener<PositionState>();

        container.listen(
          positionControllerProvider,
          listener.call,
          fireImmediately: true,
        );

        await controller.getPositions();

        verifyInOrder([
          () => listener(null, const PositionState.initial()),
          () => listener(any(), const PositionState.loading()),
          () => listener(any(), PositionState.loaded(positions: positionList)),
        ]);

        verify(() => mockGetPositionUseCase(const NoParams())).called(1);

        container.dispose();
      });

      testWidgets('should not fetch positions when already loaded', (
        final tester,
      ) async {
        final container = ProviderContainer(
          overrides: [
            getPositionUseCaseProvider.overrideWithValue(
              mockGetPositionUseCase,
            ),
          ],
        );

        final controller = container.read(positionControllerProvider.notifier)
          ..state = const PositionState.loaded(positions: [tPosition]);

        await controller.getPositions();

        verifyNever(() => mockGetPositionUseCase(any()));

        container.dispose();
      });

      testWidgets('should emit loading then error when use case fails', (
        final tester,
      ) async {
        when(() => mockGetPositionUseCase(any())).thenAnswer(
          (_) async => const Left(tServerFailure),
        );

        final container = ProviderContainer(
          overrides: [
            getPositionUseCaseProvider.overrideWithValue(
              mockGetPositionUseCase,
            ),
          ],
        );

        final controller = container.read(positionControllerProvider.notifier);
        final listener = MockListener<PositionState>();

        container.listen(
          positionControllerProvider,
          listener.call,
          fireImmediately: true,
        );

        await controller.getPositions();

        verifyInOrder([
          () => listener(null, const PositionState.initial()),
          () => listener(any(), const PositionState.loading()),
          () => listener(any(), const PositionState.error('Server Error')),
        ]);

        container.dispose();
      });
    });
  });

  group('ScheduleController', () {
    late MockGetScheduleUseCase mockGetScheduleUseCase;

    setUp(() {
      mockGetScheduleUseCase = MockGetScheduleUseCase();
    });

    group('getSchedules', () {
      testWidgets('should emit loading then loaded when successful', (
        final tester,
      ) async {
        final scheduleList = [tSchedule];

        when(() => mockGetScheduleUseCase(any())).thenAnswer(
          (_) async => Right(scheduleList),
        );

        final container = ProviderContainer(
          overrides: [
            getScheduleUseCaseProvider.overrideWithValue(
              mockGetScheduleUseCase,
            ),
          ],
        );

        final controller = container.read(scheduleControllerProvider.notifier);
        final listener = MockListener<ScheduleState>();

        container.listen(
          scheduleControllerProvider,
          listener.call,
          fireImmediately: true,
        );

        await controller.getSchedules();

        verifyInOrder([
          () => listener(null, const ScheduleState.initial()),
          () => listener(any(), const ScheduleState.loading()),
          () => listener(any(), ScheduleState.loaded(schedules: scheduleList)),
        ]);

        verify(() => mockGetScheduleUseCase(const NoParams())).called(1);

        container.dispose();
      });

      testWidgets('should not fetch schedules when already loaded', (
        final tester,
      ) async {
        final container = ProviderContainer(
          overrides: [
            getScheduleUseCaseProvider.overrideWithValue(
              mockGetScheduleUseCase,
            ),
          ],
        );

        final controller = container.read(scheduleControllerProvider.notifier)
          ..state = const ScheduleState.loaded(
            schedules: [tSchedule],
          );

        await controller.getSchedules();

        verifyNever(() => mockGetScheduleUseCase(any()));

        container.dispose();
      });

      testWidgets('should emit loading then error when use case fails', (
        final tester,
      ) async {
        when(() => mockGetScheduleUseCase(any())).thenAnswer(
          (_) async => const Left(
            tServerFailure,
          ),
        );

        final container = ProviderContainer(
          overrides: [
            getScheduleUseCaseProvider.overrideWithValue(
              mockGetScheduleUseCase,
            ),
          ],
        );

        final controller = container.read(scheduleControllerProvider.notifier);
        final listener = MockListener<ScheduleState>();

        container.listen(
          scheduleControllerProvider,
          listener.call,
          fireImmediately: true,
        );

        await controller.getSchedules();

        verifyInOrder([
          () => listener(null, const ScheduleState.initial()),
          () => listener(any(), const ScheduleState.loading()),
          () => listener(any(), const ScheduleState.error('Server Error')),
        ]);

        container.dispose();
      });
    });
  });

  group('JobDetailController', () {
    late MockGetJobDetailUseCase mockGetJobDetailUseCase;
    late MockGetJobByCompanyUseCase mockGetJobByCompanyUseCase;

    setUp(() {
      mockGetJobDetailUseCase = MockGetJobDetailUseCase();
      mockGetJobByCompanyUseCase = MockGetJobByCompanyUseCase();
    });

    group('getJobDetail', () {
      testWidgets('should emit loading then error when use case fails', (
        final tester,
      ) async {
        when(() => mockGetJobDetailUseCase(any())).thenAnswer(
          (_) async => const Left(
            tServerFailure,
          ),
        );

        final container = ProviderContainer(
          overrides: [
            getJobDetailUseCaseProvider.overrideWithValue(
              mockGetJobDetailUseCase,
            ),
            getJobByCompanyUseCaseProvider.overrideWithValue(
              mockGetJobByCompanyUseCase,
            ),
          ],
        );

        final controller = container.read(jobDetailControllerProvider.notifier);
        final listener = MockListener<JobDetailState>();

        container.listen(
          jobDetailControllerProvider,
          listener.call,
          fireImmediately: true,
        );

        await controller.getJobDetail(jobId: 1);

        verifyInOrder([
          () => listener(null, const JobDetailState.initial()),
          () => listener(any(), const JobDetailState.loading()),
          () => listener(any(), const JobDetailState.error('Server Error')),
        ]);

        container.dispose();
      });
    });
  });

  group('ApplyJobController', () {
    late MockGetAppliedJobsUseCase mockGetAppliedJobsUseCase;
    late MockApplyJobUseCase mockApplyJobUseCase;

    setUp(() {
      mockGetAppliedJobsUseCase = MockGetAppliedJobsUseCase();
      mockApplyJobUseCase = MockApplyJobUseCase();
    });

    group('getJobApplied', () {
      testWidgets('should emit loading then loaded when successful', (
        final tester,
      ) async {
        when(() => mockGetAppliedJobsUseCase(any())).thenAnswer(
          (_) async => Right(tJobList),
        );

        final container = ProviderContainer(
          overrides: [
            getAppliedJobsUseCaseProvider.overrideWithValue(
              mockGetAppliedJobsUseCase,
            ),
          ],
        );

        final controller = container.read(applyJobControllerProvider.notifier);
        final listener = MockListener<ApplyJobState>();

        container.listen(
          applyJobControllerProvider,
          listener.call,
          fireImmediately: true,
        );

        await controller.getJobApplied(page: 0);

        verifyInOrder([
          () => listener(null, const ApplyJobState.initial()),
          () => listener(any(), const ApplyJobState.loading()),
          () => listener(
            any(),
            ApplyJobState.loaded(
              jobs: tJobList,
              finished: false,
            ),
          ),
        ]);

        verify(
          () => mockGetAppliedJobsUseCase(
            const AppliedJobParams(page: 0, limit: 10),
          ),
        ).called(1);

        container.dispose();
      });

      testWidgets('should not fetch when finished is true', (
        final tester,
      ) async {
        final container = ProviderContainer(
          overrides: [
            getAppliedJobsUseCaseProvider.overrideWithValue(
              mockGetAppliedJobsUseCase,
            ),
          ],
        );

        final controller = container.read(applyJobControllerProvider.notifier)
          ..state = const ApplyJobState.loaded(
            jobs: [],
            finished: true,
          );

        await controller.getJobApplied(page: 0);

        verifyNever(() => mockGetAppliedJobsUseCase(any()));

        container.dispose();
      });

      testWidgets('should emit loading then error when use case fails', (
        final tester,
      ) async {
        when(() => mockGetAppliedJobsUseCase(any())).thenAnswer(
          (_) async => const Left(tServerFailure),
        );

        final container = ProviderContainer(
          overrides: [
            getAppliedJobsUseCaseProvider.overrideWithValue(
              mockGetAppliedJobsUseCase,
            ),
          ],
        );

        final controller = container.read(applyJobControllerProvider.notifier);
        final listener = MockListener<ApplyJobState>();

        container.listen(
          applyJobControllerProvider,
          listener.call,
          fireImmediately: true,
        );

        await controller.getJobApplied(page: 0);

        verifyInOrder([
          () => listener(null, const ApplyJobState.initial()),
          () => listener(any(), const ApplyJobState.loading()),
          () => listener(any(), const ApplyJobState.error('Server Error')),
        ]);

        container.dispose();
      });
    });

    group('applyJob', () {
      testWidgets('should emit loading then loaded when successful', (
        final tester,
      ) async {
        when(() => mockApplyJobUseCase(any())).thenAnswer(
          (_) async => Right(tJob),
        );

        final container = ProviderContainer(
          overrides: [
            applyJobUseCaseProvider.overrideWithValue(mockApplyJobUseCase),
          ],
        );

        final controller = container.read(applyJobControllerProvider.notifier);
        final listener = MockListener<ApplyJobState>();

        container.listen(
          applyJobControllerProvider,
          listener.call,
          fireImmediately: true,
        );

        final cvFile = FileSelectorResult(
          name: 'test.pdf',
          path: 'test/path/test.pdf',
          data: Uint8List(0),
        );

        await controller.applyJob(
          jobId: 1,
          referenceLetter: 'Test letter',
          cv: cvFile,
        );

        verifyInOrder([
          () => listener(null, const ApplyJobState.initial()),
          () => listener(any(), const ApplyJobState.loading()),
          () => listener(
            any(),
            ApplyJobState.loaded(
              jobs: [tJob],
              finished: false,
            ),
          ),
        ]);

        verify(
          () => mockApplyJobUseCase(
            ApplyJobParams(
              jobId: 1,
              referenceLetter: 'Test letter',
              cv: FileRequest(name: 'test.pdf', data: Uint8List(0)),
            ),
          ),
        ).called(1);

        container.dispose();
      });

      testWidgets('should emit loading then error when use case fails', (
        final tester,
      ) async {
        when(() => mockApplyJobUseCase(any())).thenAnswer(
          (_) async => const Left(
            tServerFailure,
          ),
        );

        final container = ProviderContainer(
          overrides: [
            applyJobUseCaseProvider.overrideWithValue(mockApplyJobUseCase),
          ],
        );

        final controller = container.read(applyJobControllerProvider.notifier);
        final listener = MockListener<ApplyJobState>();

        container.listen(
          applyJobControllerProvider,
          listener.call,
          fireImmediately: true,
        );

        final cvFile = FileSelectorResult(
          name: 'test.pdf',
          path: 'test/path/test.pdf',
          data: Uint8List(0),
        );

        await controller.applyJob(
          jobId: 1,
          referenceLetter: 'Test letter',
          cv: cvFile,
        );

        verifyInOrder([
          () => listener(null, const ApplyJobState.initial()),
          () => listener(any(), const ApplyJobState.loading()),
          () => listener(any(), const ApplyJobState.error('Server Error')),
        ]);

        container.dispose();
      });
    });
  });
}
