import 'package:dart_either/dart_either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobsit/core/error/failures.dart';
import 'package:jobsit/features/jobs/domain/entities/job.dart';
import 'package:jobsit/features/jobs/domain/repositories/job_repository.dart';
import 'package:jobsit/features/jobs/domain/usecases/get_saved_jobs.dart';
import 'package:mocktail/mocktail.dart';

class MockJobRepository extends Mock implements JobRepository {}

void main() {
  late JobRepository mockJobRepository;
  setUp(() {
    mockJobRepository = MockJobRepository();
  });
  group('Get Saved Jobs Use Case', () {
    const tPage = 1;
    const tLimit = 10;
    const tParams = SavedJobParams(
      page: tPage,
      limit: tLimit,
    );

    test('should return a list of saved jobs', () async {
      // Arrange
      final useCase = GetSavedJobsUseCase(mockJobRepository);

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
            name: 'Saved',
          ),
        ),
      ];

      when(() => mockJobRepository.getSavedJobs()).thenAnswer(
        (_) async => Right(expectedJobs),
      );

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, Right(expectedJobs));
      verify(() => mockJobRepository.getSavedJobs()).called(1);
      verifyNoMoreInteractions(mockJobRepository);
    });
    test('should return a failure when repository fails', () async {
      // Arrange
      final useCase = GetSavedJobsUseCase(mockJobRepository);
      const tError = 'Failed to fetch saved jobs';
      const expectedFailure = ServerFailure(tError);

      when(() => mockJobRepository.getSavedJobs()).thenAnswer(
        (_) async => const Left(expectedFailure),
      );

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, const Left(expectedFailure));
      verify(() => mockJobRepository.getSavedJobs()).called(1);
      verifyNoMoreInteractions(mockJobRepository);
    });
  });
  group('Add Saved Jobs Use Case', () {
    const tJobId = 1;
    const tParams = AddSavedJobParams(jobId: tJobId);

    test('should return success when job is saved', () async {
      // Arrange
      final useCase = AddSavedJobUseCase(mockJobRepository);
      const expectedSuccess = Success();

      when(() => mockJobRepository.addSavedJob(jobId: tJobId)).thenAnswer(
        (_) async => const Right(expectedSuccess),
      );

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, const Right(expectedSuccess));
      verify(() => mockJobRepository.addSavedJob(jobId: tJobId)).called(1);
      verifyNoMoreInteractions(mockJobRepository);
    });
    test('should return a failure when repository fails', () async {
      // Arrange
      final useCase = AddSavedJobUseCase(mockJobRepository);
      const tError = 'Failed to save job';
      const expectedFailure = ServerFailure(tError);

      when(() => mockJobRepository.addSavedJob(jobId: tJobId)).thenAnswer(
        (_) async => const Left(expectedFailure),
      );

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, const Left(expectedFailure));
      verify(() => mockJobRepository.addSavedJob(jobId: tJobId)).called(1);
      verifyNoMoreInteractions(mockJobRepository);
    });
  });
  group('Delete Saved Jobs Use Case', () {
    const tJobId = 1;
    const tParams = DeleteSavedJobParams(jobId: tJobId);

    test('should return success when job is deleted from saved list', () async {
      // Arrange
      final useCase = DeleteSavedJobUseCase(mockJobRepository);
      const expectedSuccess = Success();

      when(() => mockJobRepository.deleteSavedJob(jobId: tJobId)).thenAnswer(
        (_) async => const Right(expectedSuccess),
      );

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, const Right(expectedSuccess));
      verify(() => mockJobRepository.deleteSavedJob(jobId: tJobId)).called(1);
      verifyNoMoreInteractions(mockJobRepository);
    });
    test('should return a failure when repository fails', () async {
      // Arrange
      final useCase = DeleteSavedJobUseCase(mockJobRepository);
      const tError = 'Failed to delete saved job';
      const expectedFailure = ServerFailure(tError);

      when(() => mockJobRepository.deleteSavedJob(jobId: tJobId)).thenAnswer(
        (_) async => const Left(expectedFailure),
      );

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, const Left(expectedFailure));
      verify(() => mockJobRepository.deleteSavedJob(jobId: tJobId)).called(1);
      verifyNoMoreInteractions(mockJobRepository);
    });
  });
  return;
}
