import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobsit/core/services/file_service.dart';
import 'package:jobsit/features/auth/data/models/user_model.dart' as auth_models;
import 'package:jobsit/features/jobs/data/models/job_model.dart';
import 'package:jobsit/features/jobs/domain/entities/job.dart';

void main() {
  group('HttpResponse Model', () {
    const tHttpResponse = HttpResponse(
      httpCode: 200,
      message: 'Success',
      path: '/api/jobs',
    );

    const tHttpResponseJson = {
      'httpCode': 200,
      'message': 'Success',
      'path': '/api/jobs',
    };

    test('should create HttpResponse instance with all fields', () {
      // Assert
      expect(tHttpResponse.httpCode, equals(200));
      expect(tHttpResponse.message, equals('Success'));
      expect(tHttpResponse.path, equals('/api/jobs'));
    });

    test('should convert from JSON correctly', () {
      // Act
      final result = HttpResponse.fromJson(tHttpResponseJson);

      // Assert
      expect(result, equals(tHttpResponse));
    });

    test('should convert to JSON correctly', () {
      // Act
      final result = tHttpResponse.toJson();

      // Assert
      expect(result, equals(tHttpResponseJson));
    });
  });

  group('JobStatusResponse Model', () {
    const tJobStatusResponse = JobStatusResponse(
      id: 1,
      name: 'Active',
    );

    const tJobStatusResponseJson = {
      'id': 1,
      'name': 'Active',
    };

    test('should create JobStatusResponse instance with all fields', () {
      // Assert
      expect(tJobStatusResponse.id, equals(1));
      expect(tJobStatusResponse.name, equals('Active'));
    });

    test('should convert from JSON correctly', () {
      // Act
      final result = JobStatusResponse.fromJson(tJobStatusResponseJson);

      // Assert
      expect(result, equals(tJobStatusResponse));
    });

    test('should convert to JSON correctly', () {
      // Act
      final result = tJobStatusResponse.toJson();

      // Assert
      expect(result, equals(tJobStatusResponseJson));
    });

    test('should convert to domain entity correctly', () {
      // Act
      final result = tJobStatusResponse.toEntity();

      // Assert
      expect(result, isA<JobStatus>());
      expect(result.id, equals(1));
      expect(result.name, equals('Active'));
    });
  });

  group('PositionResponse Model', () {
    const tPositionResponse = PositionResponse(
      id: 1,
      name: 'Software Engineer',
    );

    const tPositionResponseJson = {
      'id': 1,
      'name': 'Software Engineer',
    };

    test('should create PositionResponse instance with all fields', () {
      // Assert
      expect(tPositionResponse.id, equals(1));
      expect(tPositionResponse.name, equals('Software Engineer'));
    });

    test('should convert from JSON correctly', () {
      // Act
      final result = PositionResponse.fromJson(tPositionResponseJson);

      // Assert
      expect(result, equals(tPositionResponse));
    });

    test('should convert to JSON correctly', () {
      // Act
      final result = tPositionResponse.toJson();

      // Assert
      expect(result, equals(tPositionResponseJson));
    });

    test('should convert to domain entity correctly', () {
      // Act
      final result = tPositionResponse.toEntity();

      // Assert
      expect(result, isA<Position>());
      expect(result.id, equals(1));
      expect(result.name, equals('Software Engineer'));
    });
  });

  group('MajorResponse Model', () {
    const tMajorResponse = MajorResponse(
      id: 1,
      name: 'Computer Science',
    );

    const tMajorResponseJson = {
      'id': 1,
      'name': 'Computer Science',
    };

    test('should create MajorResponse instance with all fields', () {
      // Assert
      expect(tMajorResponse.id, equals(1));
      expect(tMajorResponse.name, equals('Computer Science'));
    });

    test('should convert from JSON correctly', () {
      // Act
      final result = MajorResponse.fromJson(tMajorResponseJson);

      // Assert
      expect(result, equals(tMajorResponse));
    });

    test('should convert to JSON correctly', () {
      // Act
      final result = tMajorResponse.toJson();

      // Assert
      expect(result, equals(tMajorResponseJson));
    });

    test('should convert to domain entity correctly', () {
      // Act
      final result = tMajorResponse.toEntity();

      // Assert
      expect(result, isA<Major>());
      expect(result.id, equals(1));
      expect(result.name, equals('Computer Science'));
    });
  });

  group('ScheduleResponse Model', () {
    const tScheduleResponse = ScheduleResponse(
      id: 1,
      name: 'Full-time',
    );

    const tScheduleResponseJson = {
      'id': 1,
      'name': 'Full-time',
    };

    test('should create ScheduleResponse instance with all fields', () {
      // Assert
      expect(tScheduleResponse.id, equals(1));
      expect(tScheduleResponse.name, equals('Full-time'));
    });

    test('should convert from JSON correctly', () {
      // Act
      final result = ScheduleResponse.fromJson(tScheduleResponseJson);

      // Assert
      expect(result, equals(tScheduleResponse));
    });

    test('should convert to JSON correctly', () {
      // Act
      final result = tScheduleResponse.toJson();

      // Assert
      expect(result, equals(tScheduleResponseJson));
    });

    test('should convert to domain entity correctly', () {
      // Act
      final result = tScheduleResponse.toEntity();

      // Assert
      expect(result, isA<Schedule>());
      expect(result.id, equals(1));
      expect(result.name, equals('Full-time'));
    });
  });

  group('CompanyResponse Model', () {
    const tJobStatusResponse = JobStatusResponse(id: 1, name: 'Active');

    const tCompanyResponse = CompanyResponse(
      id: 1,
      logo: 'logo.png',
      name: 'Tech Corp',
      tax: '123456789',
      email: 'contact@techcorp.com',
      phone: '+1234567890',
      personnelSize: '100-500',
      website: 'https://techcorp.com',
      country: 'USA',
      province: 'California',
      district: 'San Francisco',
      createdDate: '2023-01-01',
      location: '123 Tech Street, San Francisco, CA',
      status: tJobStatusResponse,
      description: 'Leading technology company',
    );

    const tCompanyResponseJson = {
      'id': 1,
      'logo': 'logo.png',
      'name': 'Tech Corp',
      'tax': '123456789',
      'email': 'contact@techcorp.com',
      'phone': '+1234567890',
      'personnelSize': '100-500',
      'website': 'https://techcorp.com',
      'country': 'USA',
      'province': 'California',
      'district': 'San Francisco',
      'createdDate': '2023-01-01',
      'location': '123 Tech Street, San Francisco, CA',
      'statusDTO': {
        'id': 1,
        'name': 'Active',
      },
      'description': 'Leading technology company',
    };

    test('should create CompanyResponse instance with all fields', () {
      // Assert
      expect(tCompanyResponse.id, equals(1));
      expect(tCompanyResponse.name, equals('Tech Corp'));
      expect(tCompanyResponse.email, equals('contact@techcorp.com'));
      expect(tCompanyResponse.status, equals(tJobStatusResponse));
    });

    test('should convert from JSON correctly', () {
      // Act
      final result = CompanyResponse.fromJson(tCompanyResponseJson);

      // Assert
      expect(result, equals(tCompanyResponse));
    });

    test('should convert to domain entity correctly', () {
      // Act
      final result = tCompanyResponse.toEntity();

      // Assert
      expect(result, isA<Company>());
      expect(result.id, equals(1));
      expect(result.name, equals('Tech Corp'));
      expect(result.email, equals('contact@techcorp.com'));
      expect(result.status.id, equals(1));
      expect(result.status.name, equals('Active'));
    });

    test('should handle nullable fields correctly', () {
      // Arrange
      const minimalCompany = CompanyResponse(
        id: 1,
        status: tJobStatusResponse,
      );

      // Assert
      expect(minimalCompany.id, equals(1));
      expect(minimalCompany.logo, isNull);
      expect(minimalCompany.name, isNull);
      expect(minimalCompany.status, equals(tJobStatusResponse));
    });
  });

  group('JobResponse Model', () {
    final tPostingDate = DateTime(2023);
    final tApplicationDeadline = DateTime(2023, 2);

    const tJobStatusResponse = JobStatusResponse(id: 1, name: 'Active');
    const tCompanyResponse = CompanyResponse(
      id: 1,
      name: 'Tech Corp',
      status: tJobStatusResponse,
    );
    const tPositionResponse = PositionResponse(
      id: 1,
      name: 'Software Engineer',
    );
    const tMajorResponse = MajorResponse(id: 1, name: 'Computer Science');
    const tScheduleResponse = ScheduleResponse(id: 1, name: 'Full-time');

    final tJobResponse = JobResponse(
      id: 1,
      title: 'Senior Software Engineer',
      positions: const [tPositionResponse],
      majors: const [tMajorResponse],
      schedules: const [tScheduleResponse],
      amount: 5,
      postingDate: tPostingDate,
      applicationDeadline: tApplicationDeadline,
      minAllowance: 50000,
      maxAllowance: 80000,
      description: 'Great opportunity for a software engineer',
      requirements: 'Bachelor degree in Computer Science',
      benefits: 'Health insurance, 401k',
      country: 'USA',
      city: 'San Francisco',
      district: 'Downtown',
      address: '123 Tech Street',
      noAllowance: false,
      company: tCompanyResponse,
      status: tJobStatusResponse,
    );

    final tJobResponseJson = {
      'id': 1,
      'title': 'Senior Software Engineer',
      'positionDTOS': [
        {'id': 1, 'name': 'Software Engineer'},
      ],
      'majorDTOS': [
        {'id': 1, 'name': 'Computer Science'},
      ],
      'scheduleDTOS': [
        {'id': 1, 'name': 'Full-time'},
      ],
      'amount': 5,
      'postingDate': '2023-01-01T00:00:00.000',
      'applicationDeadline': '2023-02-01T00:00:00.000',
      'minAllowance': 50000.0,
      'maxAllowance': 80000.0,
      'description': 'Great opportunity for a software engineer',
      'requirements': 'Bachelor degree in Computer Science',
      'benefits': 'Health insurance, 401k',
      'country': 'USA',
      'city': 'San Francisco',
      'district': 'Downtown',
      'address': '123 Tech Street',
      'noAllowance': false,
      'companyDTO': {
        'id': 1,
        'name': 'Tech Corp',
        'statusDTO': {'id': 1, 'name': 'Active'},
      },
      'statusDTO': {'id': 1, 'name': 'Active'},
    };

    test('should create JobResponse instance with all fields', () {
      // Assert
      expect(tJobResponse.id, equals(1));
      expect(tJobResponse.title, equals('Senior Software Engineer'));
      expect(tJobResponse.positions.length, equals(1));
      expect(tJobResponse.majors.length, equals(1));
      expect(tJobResponse.schedules.length, equals(1));
      expect(tJobResponse.amount, equals(5));
      expect(tJobResponse.postingDate, equals(tPostingDate));
      expect(tJobResponse.applicationDeadline, equals(tApplicationDeadline));
      expect(tJobResponse.minAllowance, equals(50000.0));
      expect(tJobResponse.maxAllowance, equals(80000.0));
      expect(tJobResponse.noAllowance, equals(false));
    });

    test('should convert from JSON correctly', () {
      // Act
      final result = JobResponse.fromJson(tJobResponseJson);

      // Assert
      expect(result, equals(tJobResponse));
    });

    test('should convert to domain entity correctly', () {
      // Act
      final result = tJobResponse.toEntity();

      // Assert
      expect(result, isA<Job>());
      expect(result.id, equals(1));
      expect(result.title, equals('Senior Software Engineer'));
      expect(result.positions.length, equals(1));
      expect(result.positions.first.id, equals(1));
      expect(result.majors.length, equals(1));
      expect(result.majors.first.id, equals(1));
      expect(result.schedules.length, equals(1));
      expect(result.schedules.first.id, equals(1));
      expect(result.company.id, equals(1));
      expect(result.status.id, equals(1));
    });
  });

  group('SavedJobResponse Model', () {
    final tPostingDate = DateTime(2023);
    final tApplicationDeadline = DateTime(2023, 2);

    const tJobStatusResponse = JobStatusResponse(id: 1, name: 'Active');
    const tCompanyResponse = CompanyResponse(
      id: 1,
      name: 'Tech Corp',
      status: tJobStatusResponse,
    );
    const tPositionResponse = PositionResponse(
      id: 1,
      name: 'Software Engineer',
    );
    const tMajorResponse = MajorResponse(id: 1, name: 'Computer Science');
    const tScheduleResponse = ScheduleResponse(id: 1, name: 'Full-time');

    final tJobResponse = JobResponse(
      id: 1,
      title: 'Senior Software Engineer',
      positions: const [tPositionResponse],
      majors: const [tMajorResponse],
      schedules: const [tScheduleResponse],
      amount: 5,
      postingDate: tPostingDate,
      applicationDeadline: tApplicationDeadline,
      minAllowance: 50000,
      maxAllowance: 80000,
      description: 'Great opportunity',
      requirements: 'Bachelor degree',
      benefits: 'Health insurance',
      country: 'USA',
      city: 'San Francisco',
      district: 'Downtown',
      address: '123 Tech Street',
      noAllowance: false,
      company: tCompanyResponse,
      status: tJobStatusResponse,
    );

    final tSavedJobResponse = SavedJobResponse(
      id: 100,
      job: tJobResponse,
    );

    final tSavedJobResponseJson = {
      'id': 100,
      'jobDTO': {
        'id': 1,
        'title': 'Senior Software Engineer',
        'positionDTOS': [
          {'id': 1, 'name': 'Software Engineer'},
        ],
        'majorDTOS': [
          {'id': 1, 'name': 'Computer Science'},
        ],
        'scheduleDTOS': [
          {'id': 1, 'name': 'Full-time'},
        ],
        'amount': 5,
        'postingDate': '2023-01-01T00:00:00.000',
        'applicationDeadline': '2023-02-01T00:00:00.000',
        'minAllowance': 50000.0,
        'maxAllowance': 80000.0,
        'description': 'Great opportunity',
        'requirements': 'Bachelor degree',
        'benefits': 'Health insurance',
        'country': 'USA',
        'city': 'San Francisco',
        'district': 'Downtown',
        'address': '123 Tech Street',
        'noAllowance': false,
        'companyDTO': {
          'id': 1,
          'name': 'Tech Corp',
          'statusDTO': {'id': 1, 'name': 'Active'},
        },
        'statusDTO': {'id': 1, 'name': 'Active'},
      },
    };

    test('should create SavedJobResponse instance with all fields', () {
      // Assert
      expect(tSavedJobResponse.id, equals(100));
      expect(tSavedJobResponse.job, equals(tJobResponse));
    });

    test('should convert from JSON correctly', () {
      // Act
      final result = SavedJobResponse.fromJson(tSavedJobResponseJson);

      // Assert
      expect(result, equals(tSavedJobResponse));
    });

    test('should convert to domain entity correctly', () {
      // Act
      final result = tSavedJobResponse.toEntity();

      // Assert
      expect(result, isA<Job>());
      expect(result.id, equals(1));
      expect(result.title, equals('Senior Software Engineer'));
    });
  });

  group('JobListResponse Model', () {
    final tPostingDate = DateTime(2023);
    final tApplicationDeadline = DateTime(2023, 2);

    const tJobStatusResponse = JobStatusResponse(id: 1, name: 'Active');
    const tCompanyResponse = CompanyResponse(
      id: 1,
      name: 'Tech Corp',
      status: tJobStatusResponse,
    );
    const tPositionResponse = PositionResponse(
      id: 1,
      name: 'Software Engineer',
    );
    const tMajorResponse = MajorResponse(id: 1, name: 'Computer Science');
    const tScheduleResponse = ScheduleResponse(id: 1, name: 'Full-time');

    final tJobResponse = JobResponse(
      id: 1,
      title: 'Senior Software Engineer',
      positions: const [tPositionResponse],
      majors: const [tMajorResponse],
      schedules: const [tScheduleResponse],
      amount: 5,
      postingDate: tPostingDate,
      applicationDeadline: tApplicationDeadline,
      minAllowance: 50000,
      maxAllowance: 80000,
      description: 'Great opportunity',
      requirements: 'Bachelor degree',
      benefits: 'Health insurance',
      country: 'USA',
      city: 'San Francisco',
      district: 'Downtown',
      address: '123 Tech Street',
      noAllowance: false,
      company: tCompanyResponse,
      status: tJobStatusResponse,
    );

    final tJobListResponse = JobListResponse(
      contents: [tJobResponse],
      totalPages: 10,
      totalItems: 100,
      limit: 10,
      no: 0,
      last: false,
      first: true,
    );

    final tJobListResponseJson = {
      'contents': [
        {
          'id': 1,
          'title': 'Senior Software Engineer',
          'positionDTOS': [
            {'id': 1, 'name': 'Software Engineer'},
          ],
          'majorDTOS': [
            {'id': 1, 'name': 'Computer Science'},
          ],
          'scheduleDTOS': [
            {'id': 1, 'name': 'Full-time'},
          ],
          'amount': 5,
          'postingDate': '2023-01-01T00:00:00.000',
          'applicationDeadline': '2023-02-01T00:00:00.000',
          'minAllowance': 50000.0,
          'maxAllowance': 80000.0,
          'description': 'Great opportunity',
          'requirements': 'Bachelor degree',
          'benefits': 'Health insurance',
          'country': 'USA',
          'city': 'San Francisco',
          'district': 'Downtown',
          'address': '123 Tech Street',
          'noAllowance': false,
          'companyDTO': {
            'id': 1,
            'name': 'Tech Corp',
            'statusDTO': {'id': 1, 'name': 'Active'},
          },
          'statusDTO': {'id': 1, 'name': 'Active'},
        },
      ],
      'totalPages': 10,
      'totalItems': 100,
      'limit': 10,
      'no': 0,
      'last': false,
      'first': true,
    };

    test('should create JobListResponse instance with all fields', () {
      // Assert
      expect(tJobListResponse.contents.length, equals(1));
      expect(tJobListResponse.totalPages, equals(10));
      expect(tJobListResponse.totalItems, equals(100));
      expect(tJobListResponse.limit, equals(10));
      expect(tJobListResponse.no, equals(0));
      expect(tJobListResponse.last, equals(false));
      expect(tJobListResponse.first, equals(true));
    });

    test('should convert from JSON correctly', () {
      // Act
      final result = JobListResponse.fromJson(tJobListResponseJson);

      // Assert
      expect(result, equals(tJobListResponse));
    });
  });

  group('SavedJobListResponse Model', () {
    final tPostingDate = DateTime(2023);
    final tApplicationDeadline = DateTime(2023, 2);

    const tJobStatusResponse = JobStatusResponse(id: 1, name: 'Active');
    const tCompanyResponse = CompanyResponse(
      id: 1,
      name: 'Tech Corp',
      status: tJobStatusResponse,
    );
    const tPositionResponse = PositionResponse(
      id: 1,
      name: 'Software Engineer',
    );
    const tMajorResponse = MajorResponse(id: 1, name: 'Computer Science');
    const tScheduleResponse = ScheduleResponse(id: 1, name: 'Full-time');

    final tJobResponse = JobResponse(
      id: 1,
      title: 'Senior Software Engineer',
      positions: const [tPositionResponse],
      majors: const [tMajorResponse],
      schedules: const [tScheduleResponse],
      amount: 5,
      postingDate: tPostingDate,
      applicationDeadline: tApplicationDeadline,
      minAllowance: 50000,
      maxAllowance: 80000,
      description: 'Great opportunity',
      requirements: 'Bachelor degree',
      benefits: 'Health insurance',
      country: 'USA',
      city: 'San Francisco',
      district: 'Downtown',
      address: '123 Tech Street',
      noAllowance: false,
      company: tCompanyResponse,
      status: tJobStatusResponse,
    );

    final tSavedJobResponse = SavedJobResponse(
      id: 100,
      job: tJobResponse,
    );

    final tSavedJobListResponse = SavedJobListResponse(
      contents: [tSavedJobResponse],
      totalPages: 5,
      totalItems: 50,
      limit: 10,
      no: 0,
      last: false,
      first: true,
    );

    final tSavedJobListResponseJson = {
      'contents': [
        {
          'id': 100,
          'jobDTO': {
            'id': 1,
            'title': 'Senior Software Engineer',
            'positionDTOS': [
              {'id': 1, 'name': 'Software Engineer'},
            ],
            'majorDTOS': [
              {'id': 1, 'name': 'Computer Science'},
            ],
            'scheduleDTOS': [
              {'id': 1, 'name': 'Full-time'},
            ],
            'amount': 5,
            'postingDate': '2023-01-01T00:00:00.000',
            'applicationDeadline': '2023-02-01T00:00:00.000',
            'minAllowance': 50000.0,
            'maxAllowance': 80000.0,
            'description': 'Great opportunity',
            'requirements': 'Bachelor degree',
            'benefits': 'Health insurance',
            'country': 'USA',
            'city': 'San Francisco',
            'district': 'Downtown',
            'address': '123 Tech Street',
            'noAllowance': false,
            'companyDTO': {
              'id': 1,
              'name': 'Tech Corp',
              'statusDTO': {'id': 1, 'name': 'Active'},
            },
            'statusDTO': {'id': 1, 'name': 'Active'},
          },
        },
      ],
      'totalPages': 5,
      'totalItems': 50,
      'limit': 10,
      'no': 0,
      'last': false,
      'first': true,
    };

    test('should create SavedJobListResponse instance with all fields', () {
      // Assert
      expect(tSavedJobListResponse.contents.length, equals(1));
      expect(tSavedJobListResponse.totalPages, equals(5));
      expect(tSavedJobListResponse.totalItems, equals(50));
      expect(tSavedJobListResponse.limit, equals(10));
      expect(tSavedJobListResponse.no, equals(0));
      expect(tSavedJobListResponse.last, equals(false));
      expect(tSavedJobListResponse.first, equals(true));
    });

    test('should convert from JSON correctly', () {
      // Act
      final result = SavedJobListResponse.fromJson(tSavedJobListResponseJson);

      // Assert
      expect(result, equals(tSavedJobListResponse));
    });

    test('should convert to domain entities correctly', () {
      // Act
      final result = tSavedJobListResponse.toEntity();

      // Assert
      expect(result, isA<List<Job>>());
      expect(result.length, equals(1));
      expect(result.first.id, equals(1));
      expect(result.first.title, equals('Senior Software Engineer'));
    });
  });

  group('JobRequest Model', () {
    const tJobRequest = JobRequest(id: 1);

    const tJobRequestJson = {'id': 1};

    test('should create JobRequest instance with all fields', () {
      // Assert
      expect(tJobRequest.id, equals(1));
    });

    test('should convert from JSON correctly', () {
      // Act
      final result = JobRequest.fromJson(tJobRequestJson);

      // Assert
      expect(result, equals(tJobRequest));
    });

    test('should convert to JSON correctly', () {
      // Act
      final result = tJobRequest.toJson();

      // Assert
      expect(result, equals(tJobRequestJson));
    });
  });

  group('CandidateApplicationRequest Model', () {
    const tJobRequest = JobRequest(id: 1);
    final tFileRequest = FileRequest(
      name: 'resume.pdf',
      data: Uint8List.fromList([1, 2, 3]),
    );

    final tCandidateApplicationRequest = CandidateApplicationRequest(
      candidateApplication: tJobRequest,
      fileCV: tFileRequest,
    );

    test('should create CandidateApplicationRequest', () {
      // Assert
      expect(
        tCandidateApplicationRequest.candidateApplication,
        equals(tJobRequest),
      );
      expect(tCandidateApplicationRequest.fileCV, equals(tFileRequest));
    });
  });

  group('AppliedJobResponse Model', () {
    final tPostingDate = DateTime(2023);
    final tApplicationDeadline = DateTime(2023, 2);

    const tJobStatusResponse = JobStatusResponse(id: 1, name: 'Active');
    const tCompanyResponse = CompanyResponse(
      id: 1,
      name: 'Tech Corp',
      status: tJobStatusResponse,
    );
    const tPositionResponse = PositionResponse(
      id: 1,
      name: 'Software Engineer',
    );
    const tMajorResponse = MajorResponse(id: 1, name: 'Computer Science');
    const tScheduleResponse = ScheduleResponse(id: 1, name: 'Full-time');

    final tJobResponse = JobResponse(
      id: 1,
      title: 'Senior Software Engineer',
      positions: const [tPositionResponse],
      majors: const [tMajorResponse],
      schedules: const [tScheduleResponse],
      amount: 5,
      postingDate: tPostingDate,
      applicationDeadline: tApplicationDeadline,
      minAllowance: 50000,
      maxAllowance: 80000,
      description: 'Great opportunity',
      requirements: 'Bachelor degree',
      benefits: 'Health insurance',
      country: 'USA',
      city: 'San Francisco',
      district: 'Downtown',
      address: '123 Tech Street',
      noAllowance: false,
      company: tCompanyResponse,
      status: tJobStatusResponse,
    );
    const tUserCreationResponse = auth_models.UserCreationResponse(
      id: 1,
      email: 'test@example.com',
      firstName: 'John',
      lastName: 'Doe',
      phone: '1234567890',
      mailReceive: true,
      role: auth_models.RoleResponse(id: 1, name: 'USER'),
      status: auth_models.StatusResponse(id: 1, name: 'Active'),
    );

    const tJobInfoResponse = auth_models.JobInformationResponse(
      positions: [],
      majors: [],
      schedules: [],
      searchable: true,
    );

    const tGetUserResponse = auth_models.GetUserResponse(
      id: 1,
      user: tUserCreationResponse,
      jobInfo: tJobInfoResponse,
    );

    final tAppliedJobResponse = AppliedJobResponse(
      id: 200,
      job: tJobResponse,
      candidate: tGetUserResponse,
      appliedDate: '2023-01-15T10:30:00.000',
      referenceLetter: 'I am very interested in this position...',
      email: 'test@example.com',
      fullName: 'John Doe',
      phone: '1234567890',
      cv: '/path/to/cv.pdf',
    );

    final tAppliedJobResponseJson = {
      'id': 200,
      'jobDTO': {
        'id': 1,
        'title': 'Senior Software Engineer',
        'positionDTOS': [
          {'id': 1, 'name': 'Software Engineer'},
        ],
        'majorDTOS': [
          {'id': 1, 'name': 'Computer Science'},
        ],
        'scheduleDTOS': [
          {'id': 1, 'name': 'Full-time'},
        ],
        'amount': 5,
        'postingDate': '2023-01-01T00:00:00.000',
        'applicationDeadline': '2023-02-01T00:00:00.000',
        'minAllowance': 50000.0,
        'maxAllowance': 80000.0,
        'description': 'Great opportunity',
        'requirements': 'Bachelor degree',
        'benefits': 'Health insurance',
        'country': 'USA',
        'city': 'San Francisco',
        'district': 'Downtown',
        'address': '123 Tech Street',
        'noAllowance': false,
        'companyDTO': {
          'id': 1,
          'name': 'Tech Corp',
          'statusDTO': {'id': 1, 'name': 'Active'},
        },
        'statusDTO': {'id': 1, 'name': 'Active'},
      },
      'candidateDTO': {
        'id': 1,
        'userDTO': {
          'id': 1,
          'email': 'test@example.com',
          'firstName': 'John',
          'lastName': 'Doe',
          'phone': '1234567890',
          'mailReceive': true,
          'roleDTO': {'id': 1, 'name': 'USER'},
          'statusDTO': {'id': 1, 'name': 'Active'},
        },
        'candidateOtherInfoDTO': {
          'positionDTOs': [],
          'majorDTOs': [],
          'scheduleDTOs': [],
          'searchable': true,
        },
      },
      'appliedDate': '2023-01-15T10:30:00.000',
      'referenceLetter': 'I am very interested in this position...',
      'email': 'test@example.com',
      'fullName': 'John Doe',
      'phone': '1234567890',
      'cv': '/path/to/cv.pdf',
    };
    test('should create AppliedJobResponse instance with all fields', () {
      // Assert
      expect(tAppliedJobResponse.id, equals(200));
      expect(tAppliedJobResponse.job, equals(tJobResponse));
      expect(tAppliedJobResponse.candidate, equals(tGetUserResponse));
      expect(
        tAppliedJobResponse.appliedDate,
        equals('2023-01-15T10:30:00.000'),
      );
      expect(
        tAppliedJobResponse.referenceLetter,
        equals('I am very interested in this position...'),
      );
      expect(tAppliedJobResponse.email, equals('test@example.com'));
      expect(tAppliedJobResponse.fullName, equals('John Doe'));
      expect(tAppliedJobResponse.phone, equals('1234567890'));
      expect(tAppliedJobResponse.cv, equals('/path/to/cv.pdf'));
    });

    test('should convert from JSON correctly', () {
      // Act
      final result = AppliedJobResponse.fromJson(tAppliedJobResponseJson);

      // Assert
      expect(result, equals(tAppliedJobResponse));
    });
  });
}
