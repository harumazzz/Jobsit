import 'package:dart_either/dart_either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobsit/core/error/failures.dart';
import 'package:jobsit/core/services/location_service.dart';
import 'package:jobsit/core/usecases/usecase.dart';
import 'package:jobsit/features/jobs/domain/entities/job.dart';
import 'package:jobsit/features/jobs/domain/repositories/job_repository.dart';
import 'package:jobsit/features/jobs/domain/usecases/search_jobs.dart';
import 'package:mocktail/mocktail.dart';

class MockJobRepository extends Mock implements JobRepository {}

void main() {
  late JobRepository mockJobRepository;
  setUp(() {
    mockJobRepository = MockJobRepository();
  });
  group('Search Jobs Use Case', () {
    const tPage = 1;
    const tLimit = 10;
    const tParams = SearchJobsUseCaseParams(
      page: tPage,
      limit: tLimit,
    );
    test('should return a list of jobs', () async {
      // Arrange
      final useCase = SearchJobsUseCase(mockJobRepository);

      final expectedJobs = [
        Job(
          id: 1,
          title: 'Test Job',
          description: 'Test Description',
          address: 'Test Address',
          amount: 1,
          benefits: 'None',
          city: 'Test',
          applicationDeadline: DateTime.now(),
          country: 'Test Country',
          requirements: 'Test Requirements',
          noAllowance: false,
          postingDate: DateTime.now(),
          district: 'Test District',
          maxAllowance: 100,
          minAllowance: 50,
          company: const Company(
            id: 1,
            name: 'Test Company',
            logo: 'test_logo.png',
            status: JobStatus(
              id: 1,
              name: 'Active',
            ),
          ),
          majors: const [],
          schedules: const [],
          positions: const [],
          status: const JobStatus(
            id: 1,
            name: 'Active',
          ),
        ),
      ];

      when(() => mockJobRepository.getJobs()).thenAnswer(
        (_) async => Right(expectedJobs),
      );

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, Right(expectedJobs));
      verify(() => mockJobRepository.getJobs()).called(1);
      verifyNoMoreInteractions(mockJobRepository);
    });
    test('should return a failure when repository fails', () async {
      // Arrange
      const tError = 'Server Error';
      final useCase = SearchJobsUseCase(mockJobRepository);
      const tFailure = ServerFailure(tError);

      when(() => mockJobRepository.getJobs()).thenAnswer(
        (_) async => const Left(tFailure),
      );

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, const Left(tFailure));
      verify(() => mockJobRepository.getJobs()).called(1);
      verifyNoMoreInteractions(mockJobRepository);
    });
  });
  group('Get Position Use Case', () {
    test('should return a list of positions', () async {
      // Arrange
      final useCase = GetPositionUseCase(mockJobRepository);
      const nil = NoParams();
      const expectedPositions = [
        Position(id: 1, name: 'Software Engineer'),
        Position(id: 2, name: 'Data Scientist'),
      ];

      when(() => mockJobRepository.getPositions()).thenAnswer(
        (_) async => const Right(expectedPositions),
      );

      // Act
      final result = await useCase(nil);

      // Assert
      expect(result, const Right(expectedPositions));
      verify(() => mockJobRepository.getPositions()).called(1);
      verifyNoMoreInteractions(mockJobRepository);
    });
    test('should return a failure when repository fails', () async {
      // Arrange
      final useCase = GetPositionUseCase(mockJobRepository);
      const nil = NoParams();
      const tError = 'Failed to fetch positions';
      const expectedFailure = ServerFailure(tError);

      when(() => mockJobRepository.getPositions()).thenAnswer(
        (_) async => const Left(expectedFailure),
      );

      // Act
      final result = await useCase(nil);

      // Assert
      expect(result, const Left(expectedFailure));
      verify(() => mockJobRepository.getPositions()).called(1);
      verifyNoMoreInteractions(mockJobRepository);
    });
  });
  group('Get Major Use Case', () {
    test('should return a list of majors', () async {
      // Arrange
      final useCase = GetMajorUseCase(mockJobRepository);
      const nil = NoParams();
      const expectedMajors = [
        Major(id: 1, name: 'Computer Science'),
        Major(id: 2, name: 'Information Technology'),
      ];

      when(() => mockJobRepository.getMajors()).thenAnswer(
        (_) async => const Right(expectedMajors),
      );

      // Act
      final result = await useCase(nil);

      // Assert
      expect(result, const Right(expectedMajors));
      verify(() => mockJobRepository.getMajors()).called(1);
      verifyNoMoreInteractions(mockJobRepository);
    });
    test('should return a failure when repository fails', () async {
      // Arrange
      final useCase = GetMajorUseCase(mockJobRepository);
      const nil = NoParams();
      const tError = 'Failed to fetch majors';
      const expectedFailure = ServerFailure(tError);

      when(() => mockJobRepository.getMajors()).thenAnswer(
        (_) async => const Left(expectedFailure),
      );

      // Act
      final result = await useCase(nil);

      // Assert
      expect(result, const Left(expectedFailure));
      verify(() => mockJobRepository.getMajors()).called(1);
      verifyNoMoreInteractions(mockJobRepository);
    });
  });
  group('Get Schedule Use Case', () {
    test('should return a list of schedules', () async {
      // Arrange
      final useCase = GetScheduleUseCase(mockJobRepository);
      const nil = NoParams();
      const expectedSchedules = [
        Schedule(id: 1, name: 'Full-time'),
        Schedule(id: 2, name: 'Part-time'),
      ];

      when(() => mockJobRepository.getSchedules()).thenAnswer(
        (_) async => const Right(expectedSchedules),
      );

      // Act
      final result = await useCase(nil);

      // Assert
      expect(result, const Right(expectedSchedules));
      verify(() => mockJobRepository.getSchedules()).called(1);
      verifyNoMoreInteractions(mockJobRepository);
    });
    test('should return a failure when repository fails', () async {
      // Arrange
      final useCase = GetScheduleUseCase(mockJobRepository);
      const nil = NoParams();
      const tError = 'Failed to fetch schedules';
      const expectedFailure = ServerFailure(tError);

      when(() => mockJobRepository.getSchedules()).thenAnswer(
        (_) async => const Left(expectedFailure),
      );

      // Act
      final result = await useCase(nil);

      // Assert
      expect(result, const Left(expectedFailure));
      verify(() => mockJobRepository.getSchedules()).called(1);
      verifyNoMoreInteractions(mockJobRepository);
    });
  });
  group('Get Job Detail Use Case', () {
    const tJobId = 1;
    const tParams = GetJobDetailParams(jobId: tJobId);

    test('should return job details for a valid job ID', () async {
      // Arrange
      final useCase = GetJobDetailUseCase(mockJobRepository);
      final expectedJob = Job(
        id: tJobId,
        title: 'Test Job',
        description: 'Test Description',
        address: 'Test Address',
        amount: 1,
        benefits: 'None',
        city: 'Test',
        applicationDeadline: DateTime.now(),
        country: 'Test Country',
        requirements: 'Test Requirements',
        noAllowance: false,
        postingDate: DateTime.now(),
        district: 'Test District',
        maxAllowance: 100,
        minAllowance: 50,
        company: const Company(
          id: 1,
          name: 'Test Company',
          logo: 'test_logo.png',
          status: JobStatus(
            id: 1,
            name: 'Active',
          ),
        ),
        majors: const [],
        schedules: const [],
        positions: const [],
        status: const JobStatus(
          id: 1,
          name: 'Active',
        ),
      );

      when(() => mockJobRepository.getJobById(tJobId)).thenAnswer(
        (_) async => Right(expectedJob),
      );

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, Right(expectedJob));
      verify(() => mockJobRepository.getJobById(tJobId)).called(1);
      verifyNoMoreInteractions(mockJobRepository);
    });

    test('should return a failure when repository fails', () async {
      // Arrange
      final useCase = GetJobDetailUseCase(mockJobRepository);
      const tError = 'Failed to fetch job details';
      const expectedFailure = ServerFailure(tError);

      when(() => mockJobRepository.getJobById(tJobId)).thenAnswer(
        (_) async => const Left(expectedFailure),
      );

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, const Left(expectedFailure));
      verify(() => mockJobRepository.getJobById(tJobId)).called(1);
      verifyNoMoreInteractions(mockJobRepository);
    });
  });
  group('Filter Job Use Case', () {
    const tPage = 1;
    const tLimit = 10;
    const tMajors = <Major>[Major(id: 1, name: 'Computer Science')];
    const tPositions = <Position>[Position(id: 1, name: 'Software Engineer')];
    const tSchedules = <Schedule>[Schedule(id: 1, name: 'Full-time')];
    const tCity = City(
      name: 'Test City',
      code: 1,
      codename: 'TC',
      divisionType: 'City',
      phoneCode: 123,
      districts: <District>[
        District(
          name: 'Test District',
          code: 1,
          codename: 'TD',
          divisionType: 'District',
          provinceCode: 123,
          wards: <Ward>[
            Ward(
              name: 'Test Ward',
              code: 1,
              codename: 'TW',
              divisionType: 'Ward',
              shortCodename: 'TW',
            ),
          ],
        ),
      ],
    );
    const tTitle = 'Test Job';
    const tParams = FilterJobUseCaseParams(
      page: tPage,
      limit: tLimit,
      majors: tMajors,
      positions: tPositions,
      schedules: tSchedules,
      city: tCity,
      title: tTitle,
    );

    test('should return a list of filtered jobs', () async {
      // Arrange
      final useCase = FilterJobUseCase(mockJobRepository);
      final expectedJobs = [
        Job(
          id: 1,
          title: 'Filtered Job',
          description: 'Filtered Description',
          address: 'Filtered Address',
          amount: 1,
          benefits: 'None',
          city: 'Filtered City',
          applicationDeadline: DateTime.now(),
          country: 'Filtered Country',
          requirements: 'Filtered Requirements',
          noAllowance: false,
          postingDate: DateTime.now(),
          district: 'Filtered District',
          maxAllowance: 100,
          minAllowance: 50,
          company: const Company(
            id: 1,
            name: 'Filtered Company',
            logo: 'filtered_logo.png',
            status: JobStatus(
              id: 1,
              name: 'Active',
            ),
          ),
          majors: const [],
          schedules: const [],
          positions: const [],
          status: const JobStatus(
            id: 1,
            name: 'Active',
          ),
        ),
      ];

      when(
        () => mockJobRepository.getFilteredJobs(
          majors: tMajors,
          positions: tPositions,
          schedules: tSchedules,
          city: tCity,
          title: tTitle,
        ),
      ).thenAnswer(
        (_) async => Right(expectedJobs),
      );

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, Right(expectedJobs));
      verify(
        () => mockJobRepository.getFilteredJobs(
          majors: tMajors,
          positions: tPositions,
          schedules: tSchedules,
          city: tCity,
          title: tTitle,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockJobRepository);
    });

    test('should return a failure when repository fails', () async {
      // Arrange
      final useCase = FilterJobUseCase(mockJobRepository);
      const tError = 'Failed to filter jobs';
      const expectedFailure = ServerFailure(tError);

      when(
        () => mockJobRepository.getFilteredJobs(
          majors: tMajors,
          positions: tPositions,
          schedules: tSchedules,
          city: tCity,
          title: tTitle,
        ),
      ).thenAnswer(
        (_) async => const Left(expectedFailure),
      );

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, const Left(expectedFailure));
      verify(
        () => mockJobRepository.getFilteredJobs(
          majors: tMajors,
          positions: tPositions,
          schedules: tSchedules,
          city: tCity,
          title: tTitle,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockJobRepository);
    });
  });
  group('Get Job By Company Use Case', () {
    const tCompany = Company(
      id: 1,
      name: 'Test Company',
      logo: 'test_logo.png',
      status: JobStatus(
        id: 1,
        name: 'Active',
      ),
    );
    const tPage = 1;
    const tLimit = 10;
    const tParams = GetJobByCompanyParams(
      company: tCompany,
      page: tPage,
      limit: tLimit,
    );

    test('should return a list of jobs for the specified company', () async {
      // Arrange
      final useCase = GetJobByCompanyUseCase(mockJobRepository);
      final expectedJobs = [
        Job(
          id: 1,
          title: 'Company Job',
          description: 'Company Description',
          address: 'Company Address',
          amount: 1,
          benefits: 'None',
          city: 'Company City',
          applicationDeadline: DateTime.now(),
          country: 'Company Country',
          requirements: 'Company Requirements',
          noAllowance: false,
          postingDate: DateTime.now(),
          district: 'Company District',
          maxAllowance: 100,
          minAllowance: 50,
          company: tCompany,
          majors: const [],
          schedules: const [],
          positions: const [],
          status: const JobStatus(
            id: 1,
            name: 'Active',
          ),
        ),
      ];

      when(
        () => mockJobRepository.getJobsByCompany(
          company: tCompany,
          limit: tLimit,
        ),
      ).thenAnswer((_) async => Right(expectedJobs));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, Right(expectedJobs));
      verify(
        () => mockJobRepository.getJobsByCompany(
          company: tCompany,
          limit: tLimit,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockJobRepository);
    });

    test('should return a failure when repository fails', () async {
      // Arrange
      final useCase = GetJobByCompanyUseCase(mockJobRepository);
      const tError = 'Failed to fetch jobs by company';
      const expectedFailure = ServerFailure(tError);

      when(
        () => mockJobRepository.getJobsByCompany(
          company: tCompany,
          limit: tLimit,
        ),
      ).thenAnswer((_) async => const Left(expectedFailure));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, const Left(expectedFailure));
      verify(
        () => mockJobRepository.getJobsByCompany(
          company: tCompany,
          limit: tLimit,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockJobRepository);
    });
  });
}
