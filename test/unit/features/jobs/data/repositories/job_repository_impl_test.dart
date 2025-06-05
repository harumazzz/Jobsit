import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobsit/core/error/failures.dart';
import 'package:jobsit/core/services/file_service.dart';
import 'package:jobsit/core/services/location_service.dart';
import 'package:jobsit/features/auth/data/models/user_model.dart' as auth_models;
import 'package:jobsit/features/jobs/data/datasources/job_remote_data_source.dart';
import 'package:jobsit/features/jobs/data/models/job_model.dart';
import 'package:jobsit/features/jobs/data/repositories/job_repository_impl.dart';
import 'package:jobsit/features/jobs/domain/entities/job.dart';
import 'package:mocktail/mocktail.dart';

class MockJobRemoteDataSource extends Mock implements JobRemoteDataSource {}

void main() {
  late JobRepositoryImpl repository;
  late MockJobRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockJobRemoteDataSource();
    repository = JobRepositoryImpl(mockRemoteDataSource);
  });
  setUpAll(() {
    registerFallbackValue(FormData());
  });

  group('JobRepositoryImpl', () {
    const tJobId = 1;
    const tPage = 1;
    const tLimit = 10;

    const tJobStatusResponse = JobStatusResponse(
      id: 1,
      name: 'Active',
    );

    const tCompanyResponse = CompanyResponse(
      id: 1,
      logo: 'test_logo.png',
      name: 'Test Company',
      status: tJobStatusResponse,
    );

    const tPositionResponse = PositionResponse(
      id: 1,
      name: 'Developer',
    );

    const tMajorResponse = MajorResponse(
      id: 1,
      name: 'Computer Science',
    );

    const tScheduleResponse = ScheduleResponse(
      id: 1,
      name: 'Full-time',
    );

    final tJobResponse = JobResponse(
      id: tJobId,
      title: 'Test Job',
      positions: [tPositionResponse],
      majors: [tMajorResponse],
      schedules: [tScheduleResponse],
      amount: 1,
      postingDate: DateTime(2024),
      applicationDeadline: DateTime(2024, 12, 31),
      minAllowance: 1000,
      maxAllowance: 2000,
      description: 'Test description',
      requirements: 'Test requirements',
      benefits: 'Test benefits',
      country: 'Vietnam',
      city: 'Ho Chi Minh City',
      district: 'District 1',
      address: 'Test Address',
      noAllowance: false,
      company: tCompanyResponse,
      status: tJobStatusResponse,
    );

    final tJobListResponse = JobListResponse(
      contents: [tJobResponse],
      totalPages: 1,
      totalItems: 1,
      limit: tLimit,
      no: tPage - 1,
      last: true,
      first: true,
    );

    final tSavedJobResponse = SavedJobResponse(
      id: 1,
      job: tJobResponse,
    );

    final tSavedJobListResponse = SavedJobListResponse(
      contents: [tSavedJobResponse],
      totalPages: 1,
      totalItems: 1,
      limit: tLimit,
      no: tPage - 1,
      last: true,
      first: true,
    );
    const tUserResponse = auth_models.GetUserResponse(
      id: 1,
      user: auth_models.UserCreationResponse(
        id: 1,
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        phone: '123456789',
        role: auth_models.RoleResponse(id: 1, name: 'USER'),
        mailReceive: true,
        status: auth_models.StatusResponse(id: 1, name: 'Active'),
      ),
      jobInfo: auth_models.JobInformationResponse(
        positions: [],
        majors: [],
        schedules: [],
        searchable: false,
      ),
    );

    final tAppliedJobResponse = AppliedJobResponse(
      id: 1,
      job: tJobResponse,
      candidate: tUserResponse,
      appliedDate: '2024-01-01',
      referenceLetter: 'Reference letter',
      email: 'test@example.com',
      fullName: 'Test User',
      phone: '123456789',
      cv: 'cv_path.pdf',
    );
    const tCity = City(
      code: 79,
      name: 'Thành phố Ho Chi Minh City',
      codename: 'ho_chi_minh',
      divisionType: 'thanh-pho',
      phoneCode: 28,
      districts: [],
    );

    final tFileRequest = FileRequest(
      name: 'test_cv.pdf',
      data: Uint8List.fromList([1, 2, 3, 4, 5]),
    );

    const tHttpResponse = HttpResponse(
      httpCode: 200,
      message: 'Success',
      path: '/api/test',
    );

    group('getJobs', () {
      test('should return a list of jobs when success', () async {
        // arrange
        when(() => mockRemoteDataSource.getJobs(page: tPage)).thenAnswer(
          (_) async => tJobListResponse,
        );

        // act
        final result = await repository.getJobs();

        // assert
        expect(result.isRight, true);
        result.fold(
          ifLeft: (final failure) => fail('Expected Right, got Left: $failure'),
          ifRight: (final jobs) {
            expect(jobs, hasLength(1));
            expect(jobs.first.id, tJobId);
          },
        );
        verify(() => mockRemoteDataSource.getJobs(page: tPage)).called(1);
      });
      test('should return ServerFailure when exception', () async {
        // arrange
        when(() => mockRemoteDataSource.getJobs(page: tPage)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/test'),
            message: 'Network error',
          ),
        );

        // act
        final result = await repository.getJobs();

        // assert
        expect(result.isLeft, true);
        result.fold(
          ifLeft: (final failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Network error');
          },
          ifRight: (final jobs) => fail('Expected Left, got Right: $jobs'),
        );
      });

      test('should return ServerFailure when exception', () async {
        // arrange
        when(() => mockRemoteDataSource.getJobs(page: tPage)).thenThrow(
          Exception('Generic error'),
        );

        // act
        final result = await repository.getJobs();

        // assert
        expect(result.isLeft, true);
        result.fold(
          ifLeft: (final failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Exception: Generic error');
          },
          ifRight: (final jobs) => fail('Expected Left, got Right: $jobs'),
        );
      });
    });

    group('getJobById', () {
      test('should return a job when data source returns success', () async {
        // arrange
        when(() => mockRemoteDataSource.getJobById(tJobId)).thenAnswer(
          (_) async => tJobResponse,
        );

        // act
        final result = await repository.getJobById(tJobId);

        // assert
        expect(result.isRight, true);
        result.fold(
          ifLeft: (final failure) => fail('Expected Right, got Left: $failure'),
          ifRight: (final job) {
            expect(job.id, tJobId);
            expect(job.title, 'Test Job');
          },
        );
        verify(() => mockRemoteDataSource.getJobById(tJobId)).called(1);
      });
      test('should return ServerFailure when job not found', () async {
        // arrange
        when(() => mockRemoteDataSource.getJobById(tJobId)).thenAnswer(
          (_) async => null,
        );

        // act
        final result = await repository.getJobById(tJobId);

        // assert
        expect(result.isLeft, true);
        result.fold(
          ifLeft: (final failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Job not found');
          },
          ifRight: (final job) => fail('Expected Left, got Right: $job'),
        );
        verify(() => mockRemoteDataSource.getJobById(tJobId)).called(1);
      });
      test('should return ServerFailure when failed', () async {
        // arrange
        when(() => mockRemoteDataSource.getJobById(tJobId)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/test'),
            message: 'Network error',
          ),
        );

        // act
        final result = await repository.getJobById(tJobId);

        // assert
        expect(result.isLeft, true);
        result.fold(
          ifLeft: (final failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Network error');
          },
          ifRight: (final job) => fail('Expected Left, got Right: $job'),
        );
        verify(() => mockRemoteDataSource.getJobById(tJobId)).called(1);
      });

      test('should return ServerFailure when fail', () async {
        // arrange
        when(() => mockRemoteDataSource.getJobById(tJobId)).thenThrow(
          Exception('Generic error'),
        );

        // act
        final result = await repository.getJobById(tJobId);

        // assert
        expect(result.isLeft, true);
        result.fold(
          ifLeft: (final failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Exception: Generic error');
          },
          ifRight: (final job) => fail('Expected Left, got Right: $job'),
        );
        verify(() => mockRemoteDataSource.getJobById(tJobId)).called(1);
      });
    });

    group('getMajors', () {
      test('should return a list of majors when success', () async {
        // arrange
        when(() => mockRemoteDataSource.getMajors()).thenAnswer(
          (_) async => [tMajorResponse],
        );

        // act
        final result = await repository.getMajors();

        // assert
        expect(result.isRight, true);
        result.fold(
          ifLeft: (final failure) => fail('Expected Right, got Left: $failure'),
          ifRight: (final majors) {
            expect(majors, hasLength(1));
            expect(majors.first.id, 1);
          },
        );
        verify(() => mockRemoteDataSource.getMajors()).called(1);
      });

      test('should return ServerFailure when failed', () async {
        // arrange
        when(() => mockRemoteDataSource.getMajors()).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/test'),
            message: 'Network error',
          ),
        );

        // act
        final result = await repository.getMajors();

        // assert
        expect(result.isLeft, true);
        result.fold(
          ifLeft: (final failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Network error');
          },
          ifRight: (final majors) => fail('Expected Left, got Right: $majors'),
        );
      });
    });

    group('getPositions', () {
      test('should return a list of positions when success', () async {
        // arrange
        when(() => mockRemoteDataSource.getPositions()).thenAnswer(
          (_) async => [tPositionResponse],
        );

        // act
        final result = await repository.getPositions();

        // assert
        expect(result.isRight, true);
        result.fold(
          ifLeft: (final failure) => fail('Expected Right, got Left: $failure'),
          ifRight: (final positions) {
            expect(positions, hasLength(1));
            expect(positions.first.id, 1);
          },
        );
        verify(() => mockRemoteDataSource.getPositions()).called(1);
      });

      test('should return ServerFailure when failed', () async {
        // arrange
        when(() => mockRemoteDataSource.getPositions()).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/test'),
            message: 'Network error',
          ),
        );

        // act
        final result = await repository.getPositions();

        // assert
        expect(result.isLeft, true);
        result.fold(
          ifLeft: (final failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Network error');
          },
          ifRight: (final positions) => fail(
            'Expected Left, got Right: $positions',
          ),
        );
      });
    });

    group('getSchedules', () {
      test('should return a list of schedules when  success', () async {
        // arrange
        when(() => mockRemoteDataSource.getSchedules()).thenAnswer(
          (_) async => [tScheduleResponse],
        );

        // act
        final result = await repository.getSchedules();

        // assert
        expect(result.isRight, true);
        result.fold(
          ifLeft: (final failure) => fail('Expected Right, got Left: $failure'),
          ifRight: (final schedules) {
            expect(schedules, hasLength(1));
            expect(schedules.first.id, 1);
          },
        );
        verify(() => mockRemoteDataSource.getSchedules()).called(1);
      });

      test('should return ServerFailure when failed', () async {
        // arrange
        when(() => mockRemoteDataSource.getSchedules()).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/test'),
            message: 'Network error',
          ),
        );

        // act
        final result = await repository.getSchedules();

        // assert
        expect(result.isLeft, true);
        result.fold(
          ifLeft: (final failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Network error');
          },
          ifRight: (final schedules) => fail(
            'Expected Left, got Right: $schedules',
          ),
        );
      });
    });

    group('getFilteredJobs', () {
      test('should return filtered jobs when success', () async {
        // arrange
        when(
          () => mockRemoteDataSource.getFilteredJobs(
            formData: any(named: 'formData'),
          ),
        ).thenAnswer((_) async => tJobListResponse);

        // act
        final result = await repository.getFilteredJobs(
          positions: [const Position(id: 1, name: 'Developer')],
          schedules: [const Schedule(id: 1, name: 'Full-time')],
          city: tCity,
          majors: [const Major(id: 1, name: 'Computer Science')],
          title: 'Test',
        );

        // assert
        expect(result.isRight, true);
        result.fold(
          ifLeft: (final failure) => fail('Expected Right, got Left: $failure'),
          ifRight: (final jobs) {
            expect(jobs, hasLength(1));
            expect(jobs.first.id, tJobId);
          },
        );
        verify(
          () => mockRemoteDataSource.getFilteredJobs(
            formData: any(named: 'formData'),
          ),
        ).called(1);
      });

      test('should return ServerFailure when failed', () async {
        // arrange
        when(
          () => mockRemoteDataSource.getFilteredJobs(
            formData: any(named: 'formData'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/test'),
            message: 'Network error',
          ),
        );

        // act
        final result = await repository.getFilteredJobs();

        // assert
        expect(result.isLeft, true);
        result.fold(
          ifLeft: (final failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Network error');
          },
          ifRight: (final jobs) => fail('Expected Left, got Right: $jobs'),
        );
      });
    });

    group('getJobsByCompany', () {
      const tCompany = Company(
        id: 1,
        name: 'Test Company',
        logo: 'test_logo.png',
        status: JobStatus(id: 1, name: 'Active'),
      );

      test('should return jobs by company when success', () async {
        // arrange
        when(
          () => mockRemoteDataSource.getJobsByCompany(
            companyId: tCompany.id,
            page: tPage,
          ),
        ).thenAnswer((_) async => tJobListResponse);

        // act
        final result = await repository.getJobsByCompany(
          company: tCompany,
        );

        // assert
        expect(result.isRight, true);
        result.fold(
          ifLeft: (final failure) => fail('Expected Right, got Left: $failure'),
          ifRight: (final jobs) {
            expect(jobs, hasLength(1));
            expect(jobs.first.id, tJobId);
          },
        );
        verify(
          () => mockRemoteDataSource.getJobsByCompany(
            companyId: tCompany.id,
            page: tPage,
          ),
        ).called(1);
      });

      test('should return ServerFailure when failed', () async {
        // arrange
        when(
          () => mockRemoteDataSource.getJobsByCompany(
            companyId: tCompany.id,
            page: tPage,
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/test'),
            message: 'Network error',
          ),
        );

        // act
        final result = await repository.getJobsByCompany(
          company: tCompany,
        );

        // assert
        expect(result.isLeft, true);
        result.fold(
          ifLeft: (final failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Network error');
          },
          ifRight: (final jobs) => fail('Expected Left, got Right: $jobs'),
        );
      });
    });

    group('getSavedJobs', () {
      test('should return saved jobs when success', () async {
        // arrange
        when(
          () => mockRemoteDataSource.getSavedJobs(page: tPage),
        ).thenAnswer((_) async => tSavedJobListResponse);

        // act
        final result = await repository.getSavedJobs();

        // assert
        expect(result.isRight, true);
        result.fold(
          ifLeft: (final failure) => fail('Expected Right, got Left: $failure'),
          ifRight: (final jobs) {
            expect(jobs, hasLength(1));
            expect(jobs.first.id, tJobId);
          },
        );
        verify(() => mockRemoteDataSource.getSavedJobs(page: tPage)).called(1);
      });

      test('should return ServerFailure when failed', () async {
        // arrange
        when(() => mockRemoteDataSource.getSavedJobs(page: tPage)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/test'),
            message: 'Network error',
          ),
        );

        // act
        final result = await repository.getSavedJobs();

        // assert
        expect(result.isLeft, true);
        result.fold(
          ifLeft: (final failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Network error');
          },
          ifRight: (final jobs) => fail('Expected Left, got Right: $jobs'),
        );
      });
    });

    group('addSavedJob', () {
      test('should return Success when job is saved successfully', () async {
        // arrange
        when(() => mockRemoteDataSource.addSavedJob(jobId: tJobId)).thenAnswer(
          (_) async => tHttpResponse,
        );

        // act
        final result = await repository.addSavedJob(jobId: tJobId);

        // assert
        expect(result.isRight, true);
        result.fold(
          ifLeft: (final failure) => fail('Expected Right, got Left: $failure'),
          ifRight: (final success) {
            expect(success, isA<Success>());
          },
        );
        verify(() => mockRemoteDataSource.addSavedJob(jobId: tJobId)).called(1);
      });

      test('should return ServerFailure when failed', () async {
        // arrange
        when(() => mockRemoteDataSource.addSavedJob(jobId: tJobId)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/test'),
            message: 'Network error',
          ),
        );

        // act
        final result = await repository.addSavedJob(jobId: tJobId);

        // assert
        expect(result.isLeft, true);
        result.fold(
          ifLeft: (final failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Network error');
          },
          ifRight: (final success) => fail(
            'Expected Left, got Right: $success',
          ),
        );
      });

      test('should return ServerFailure when failed', () async {
        // arrange
        when(() => mockRemoteDataSource.addSavedJob(jobId: tJobId)).thenThrow(
          Exception('Generic error'),
        );

        // act
        final result = await repository.addSavedJob(jobId: tJobId);

        // assert
        expect(result.isLeft, true);
        result.fold(
          ifLeft: (final failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Exception: Generic error');
          },
          ifRight: (final success) => fail(
            'Expected Left, got Right: $success',
          ),
        );
      });
    });

    group('deleteSavedJob', () {
      test('should return Success when job is deleted successfully', () async {
        // arrange
        when(
          () => mockRemoteDataSource.deleteSavedJob(jobId: tJobId),
        ).thenAnswer((_) async => tHttpResponse);

        // act
        final result = await repository.deleteSavedJob(jobId: tJobId);

        // assert
        expect(result.isRight, true);
        result.fold(
          ifLeft: (final failure) => fail('Expected Right, got Left: $failure'),
          ifRight: (final success) {
            expect(success, isA<Success>());
          },
        );
        verify(
          () => mockRemoteDataSource.deleteSavedJob(jobId: tJobId),
        ).called(1);
      });

      test('should return ServerFailure when failed', () async {
        // arrange
        when(
          () => mockRemoteDataSource.deleteSavedJob(jobId: tJobId),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/test'),
            message: 'Network error',
          ),
        );

        // act
        final result = await repository.deleteSavedJob(jobId: tJobId);

        // assert
        expect(result.isLeft, true);
        result.fold(
          ifLeft: (final failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Network error');
          },
          ifRight: (final success) => fail(
            'Expected Left, got Right: $success',
          ),
        );
      });
    });

    group('getAppliedJob', () {
      test('should return applied jobs when success', () async {
        // arrange
        when(
          () => mockRemoteDataSource.getAppliedJob(page: tPage),
        ).thenAnswer((_) async => tSavedJobListResponse);

        // act
        final result = await repository.getAppliedJob();

        // assert
        expect(result.isRight, true);
        result.fold(
          ifLeft: (final failure) => fail('Expected Right, got Left: $failure'),
          ifRight: (final jobs) {
            expect(jobs, hasLength(1));
            expect(jobs.first.id, tJobId);
          },
        );
        verify(() => mockRemoteDataSource.getAppliedJob(page: tPage)).called(1);
      });

      test('should return ServerFailure when failed', () async {
        // arrange
        when(() => mockRemoteDataSource.getAppliedJob(page: tPage)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/test'),
            message: 'Network error',
          ),
        );

        // act
        final result = await repository.getAppliedJob();

        // assert
        expect(result.isLeft, true);
        result.fold(
          ifLeft: (final failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Network error');
          },
          ifRight: (final jobs) => fail('Expected Left, got Right: $jobs'),
        );
      });
    });

    group('applyJob', () {
      test('should return job when application is successful', () async {
        // arrange
        when(
          () => mockRemoteDataSource.applyJob(formData: any(named: 'formData')),
        ).thenAnswer((_) async => tAppliedJobResponse);

        // act
        final result = await repository.applyJob(
          jobId: tJobId,
          coverLetter: 'Test cover letter',
          cv: tFileRequest,
        );

        // assert
        expect(result.isRight, true);
        result.fold(
          ifLeft: (final failure) => fail('Expected Right, got Left: $failure'),
          ifRight: (final job) {
            expect(job.id, tJobId);
            expect(job.title, 'Test Job');
          },
        );
        verify(
          () => mockRemoteDataSource.applyJob(formData: any(named: 'formData')),
        ).called(1);
      });

      test('should return ServerFailure when failed', () async {
        // arrange
        when(
          () => mockRemoteDataSource.applyJob(
            formData: any(named: 'formData'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/test'),
            message: 'Network error',
          ),
        );

        // act
        final result = await repository.applyJob(
          jobId: tJobId,
          coverLetter: 'Test cover letter',
          cv: tFileRequest,
        );

        // assert
        expect(result.isLeft, true);
        result.fold(
          ifLeft: (final failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Network error');
          },
          ifRight: (final job) => fail('Expected Left, got Right: $job'),
        );
      });

      test('should return ServerFailure when failed', () async {
        // arrange
        when(
          () => mockRemoteDataSource.applyJob(formData: any(named: 'formData')),
        ).thenThrow(Exception('Generic error'));

        // act
        final result = await repository.applyJob(
          jobId: tJobId,
          coverLetter: 'Test cover letter',
          cv: tFileRequest,
        );

        // assert
        expect(result.isLeft, true);
        result.fold(
          ifLeft: (final failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Exception: Generic error');
          },
          ifRight: (final job) => fail('Expected Left, got Right: $job'),
        );
      });
    });
  });
}
