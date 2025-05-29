import 'dart:typed_data';

import 'package:dart_either/dart_either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobsit/core/error/failures.dart';
import 'package:jobsit/core/services/file_service.dart';
import 'package:jobsit/features/jobs/domain/entities/job.dart';
import 'package:jobsit/features/jobs/domain/repositories/job_repository.dart';
import 'package:jobsit/features/jobs/domain/usecases/get_applied_jobs.dart';
import 'package:mocktail/mocktail.dart';

class MockJobRepository extends Mock implements JobRepository {}

void main() {
  late JobRepository mockJobRepository;
  setUp(() {
    mockJobRepository = MockJobRepository();
  });
  group('Get Applied Jobs Use Case', () {
    const tPage = 1;
    const tLimit = 10;
    const tParams = AppliedJobParams(
      page: tPage,
      limit: tLimit,
    );
    test('should return a list of applied jobs', () async {
      // Arrange
      final useCase = GetAppliedJobsUseCase(mockJobRepository);

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
            name: 'Applied',
          ),
        ),
      ];

      when(
        () => mockJobRepository.getAppliedJob(),
      ).thenAnswer((_) async => Right(expectedJobs));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, Right(expectedJobs));
      verify(
        () => mockJobRepository.getAppliedJob(),
      ).called(1);
      verifyNoMoreInteractions(mockJobRepository);
    });
    test('should return a failure when repository fails', () async {
      // Arrange
      const tError = 'Failed to fetch applied jobs';
      final useCase = GetAppliedJobsUseCase(mockJobRepository);
      const expectedFailure = ServerFailure(tError);

      when(
        () => mockJobRepository.getAppliedJob(),
      ).thenAnswer((_) async => const Left(expectedFailure));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, const Left(expectedFailure));
      verify(
        () => mockJobRepository.getAppliedJob(),
      ).called(1);
      verifyNoMoreInteractions(mockJobRepository);
    });
  });
  group('Apply Job Use Case', () {
    test('should return a success when applying for a job', () async {
      // Arrange
      final useCase = ApplyJobUseCase(mockJobRepository);
      const tJobId = 1;
      const tCoverLetter = 'This is a cover letter';
      final tCv = FileRequest(
        name: 'cv.pdf',
        data: Uint8List.fromList([0x00]),
      );
      final job = Job(
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
          name: 'Applied',
        ),
      );

      when(
        () => mockJobRepository.applyJob(
          jobId: tJobId,
          coverLetter: tCoverLetter,
          cv: tCv,
        ),
      ).thenAnswer((_) async => Right(job));

      // Act
      final result = await useCase(
        ApplyJobParams(
          jobId: tJobId,
          referenceLetter: tCoverLetter,
          cv: tCv,
        ),
      );

      // Assert
      expect(result, Right(job));
      verify(
        () => mockJobRepository.applyJob(
          jobId: tJobId,
          coverLetter: tCoverLetter,
          cv: tCv,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockJobRepository);
    });
    test('should return a error when ffailed to apply for a job', () async {
      // Arrange
      final useCase = ApplyJobUseCase(mockJobRepository);
      const tJobId = 1;
      const tCoverLetter = 'This is a cover letter';
      final tCv = FileRequest(
        name: 'cv.pdf',
        data: Uint8List.fromList([0x00]),
      );
      const tError = 'Failed to apply for job';
      when(
        () => mockJobRepository.applyJob(
          jobId: tJobId,
          coverLetter: tCoverLetter,
          cv: tCv,
        ),
      ).thenAnswer((_) async => const Left(ServerFailure(tError)));

      // Act
      final result = await useCase(
        ApplyJobParams(
          jobId: tJobId,
          referenceLetter: tCoverLetter,
          cv: tCv,
        ),
      );

      // Assert
      expect(result, const Left(ServerFailure(tError)));
      verify(
        () => mockJobRepository.applyJob(
          jobId: tJobId,
          coverLetter: tCoverLetter,
          cv: tCv,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockJobRepository);
    });
  });
}
