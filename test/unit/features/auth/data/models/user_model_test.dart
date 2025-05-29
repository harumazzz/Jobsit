import 'package:flutter_test/flutter_test.dart';
import 'package:jobsit/features/auth/data/models/user_model.dart';
import 'package:jobsit/features/auth/domain/entities/user.dart';

void main() {
  group('HttpResponse Model', () {
    const tHttpResponse = HttpResponse(
      httpCode: 200,
      message: 'Success',
      path: '/api/users',
    );

    const tHttpResponseJson = {
      'httpCode': 200,
      'message': 'Success',
      'path': '/api/users',
    };

    test('should create HttpResponse instance with all fields', () {
      // Assert
      expect(tHttpResponse.httpCode, equals(200));
      expect(tHttpResponse.message, equals('Success'));
      expect(tHttpResponse.path, equals('/api/users'));
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

  group('ChangePasswordRequest Model', () {
    const tChangePasswordRequest = ChangePasswordRequest(
      oldPassword: 'oldPassword123',
      newPassword: 'newPassword123',
      confirmPassword: 'newPassword123',
    );

    const tChangePasswordRequestJson = {
      'oldPassword': 'oldPassword123',
      'newPassword': 'newPassword123',
      'confirmPassword': 'newPassword123',
    };

    test('should create ChangePasswordRequest instance with all fields', () {
      // Assert
      expect(tChangePasswordRequest.oldPassword, equals('oldPassword123'));
      expect(tChangePasswordRequest.newPassword, equals('newPassword123'));
      expect(tChangePasswordRequest.confirmPassword, equals('newPassword123'));
    });

    test('should convert from JSON correctly', () {
      // Act
      final result = ChangePasswordRequest.fromJson(tChangePasswordRequestJson);

      // Assert
      expect(result, equals(tChangePasswordRequest));
    });

    test('should convert to JSON correctly', () {
      // Act
      final result = tChangePasswordRequest.toJson();

      // Assert
      expect(result, equals(tChangePasswordRequestJson));
    });
  });

  group('UserCreationRequest Model', () {
    const tUserCreationRequest = UserCreationRequest(
      email: 'test@example.com',
      password: 'password123',
      firstName: 'John',
      lastName: 'Doe',
      phone: '1234567890',
    );

    const tUserCreationRequestJson = {
      'email': 'test@example.com',
      'password': 'password123',
      'firstName': 'John',
      'lastName': 'Doe',
      'phone': '1234567890',
    };

    test('should create UserCreationRequest instance with all fields', () {
      // Assert
      expect(tUserCreationRequest.email, equals('test@example.com'));
      expect(tUserCreationRequest.password, equals('password123'));
      expect(tUserCreationRequest.firstName, equals('John'));
      expect(tUserCreationRequest.lastName, equals('Doe'));
      expect(tUserCreationRequest.phone, equals('1234567890'));
    });

    test('should convert from JSON correctly', () {
      // Act
      final result = UserCreationRequest.fromJson(tUserCreationRequestJson);

      // Assert
      expect(result, equals(tUserCreationRequest));
    });

    test('should convert to JSON correctly', () {
      // Act
      final result = tUserCreationRequest.toJson();

      // Assert
      expect(result, equals(tUserCreationRequestJson));
    });
  });

  group('RegisterUserRequest Model', () {
    const tUserCreationRequest = UserCreationRequest(
      email: 'test@example.com',
      password: 'password123',
      firstName: 'John',
      lastName: 'Doe',
      phone: '1234567890',
    );

    const tRegisterUserRequest = RegisterUserRequest(
      user: tUserCreationRequest,
    );

    const tRegisterUserRequestJson = {
      'userCreationDTO': {
        'email': 'test@example.com',
        'password': 'password123',
        'firstName': 'John',
        'lastName': 'Doe',
        'phone': '1234567890',
      },
    };

    test('should create RegisterUserRequest instance with user field', () {
      // Assert
      expect(tRegisterUserRequest.user, equals(tUserCreationRequest));
    });

    test('should convert from JSON correctly', () {
      // Act
      final result = RegisterUserRequest.fromJson(tRegisterUserRequestJson);

      // Assert
      expect(result, equals(tRegisterUserRequest));
    });
  });

  group('RoleResponse Model', () {
    const tRoleResponse = RoleResponse(
      id: 1,
      name: 'CANDIDATE',
    );

    const tRoleResponseJson = {
      'id': 1,
      'name': 'CANDIDATE',
    };

    test('should create RoleResponse instance with all fields', () {
      // Assert
      expect(tRoleResponse.id, equals(1));
      expect(tRoleResponse.name, equals('CANDIDATE'));
    });

    test('should convert from JSON correctly', () {
      // Act
      final result = RoleResponse.fromJson(tRoleResponseJson);

      // Assert
      expect(result, equals(tRoleResponse));
    });

    test('should convert to JSON correctly', () {
      // Act
      final result = tRoleResponse.toJson();

      // Assert
      expect(result, equals(tRoleResponseJson));
    });

    test('should convert to entity correctly', () {
      // Act
      final result = tRoleResponse.toEntity();

      // Assert
      expect(result, isA<Role>());
      expect(result.id, equals(1));
      expect(result.name, equals('CANDIDATE'));
    });
  });

  group('StatusResponse Model', () {
    const tStatusResponse = StatusResponse(
      id: 1,
      name: 'ACTIVE',
    );

    const tStatusResponseJson = {
      'id': 1,
      'name': 'ACTIVE',
    };

    test('should create StatusResponse instance with all fields', () {
      // Assert
      expect(tStatusResponse.id, equals(1));
      expect(tStatusResponse.name, equals('ACTIVE'));
    });

    test('should convert from JSON correctly', () {
      // Act
      final result = StatusResponse.fromJson(tStatusResponseJson);

      // Assert
      expect(result, equals(tStatusResponse));
    });

    test('should convert to JSON correctly', () {
      // Act
      final result = tStatusResponse.toJson();

      // Assert
      expect(result, equals(tStatusResponseJson));
    });

    test('should convert to entity correctly', () {
      // Act
      final result = tStatusResponse.toEntity();

      // Assert
      expect(result, isA<Status>());
      expect(result.id, equals(1));
      expect(result.name, equals('ACTIVE'));
    });
  });

  group('UniversityResponse Model', () {
    const tUniversityResponse = UniversityResponse(
      id: 1,
      name: 'MIT',
    );

    const tUniversityResponseJson = {
      'id': 1,
      'name': 'MIT',
    };

    test('should create UniversityResponse instance with all fields', () {
      // Assert
      expect(tUniversityResponse.id, equals(1));
      expect(tUniversityResponse.name, equals('MIT'));
    });

    test('should convert from JSON correctly', () {
      // Act
      final result = UniversityResponse.fromJson(tUniversityResponseJson);

      // Assert
      expect(result, equals(tUniversityResponse));
    });

    test('should convert to JSON correctly', () {
      // Act
      final result = tUniversityResponse.toJson();

      // Assert
      expect(result, equals(tUniversityResponseJson));
    });

    test('should convert to entity correctly', () {
      // Act
      final result = tUniversityResponse.toEntity();

      // Assert
      expect(result, isA<University>());
      expect(result.id, equals(1));
      expect(result.name, equals('MIT'));
    });
  });

  group('UserCreationResponse Model', () {
    const tRoleResponse = RoleResponse(id: 1, name: 'CANDIDATE');
    const tStatusResponse = StatusResponse(id: 1, name: 'ACTIVE');

    const tUserCreationResponse = UserCreationResponse(
      id: 1,
      email: 'test@example.com',
      firstName: 'John',
      lastName: 'Doe',
      phone: '1234567890',
      gender: true,
      birthDate: '1990-01-01',
      avatar: 'avatar.jpg',
      address: '123 Main St',
      city: 'New York',
      district: 'Manhattan',
      mailReceive: true,
      role: tRoleResponse,
      status: tStatusResponse,
    );

    const tUserCreationResponseJson = {
      'id': 1,
      'email': 'test@example.com',
      'firstName': 'John',
      'lastName': 'Doe',
      'phone': '1234567890',
      'gender': true,
      'birthDay': '1990-01-01',
      'avatar': 'avatar.jpg',
      'location': '123 Main St',
      'city': 'New York',
      'district': 'Manhattan',
      'mailReceive': true,
      'roleDTO': {
        'id': 1,
        'name': 'CANDIDATE',
      },
      'statusDTO': {
        'id': 1,
        'name': 'ACTIVE',
      },
    };

    test('should create UserCreationResponse instance with all fields', () {
      // Assert
      expect(tUserCreationResponse.id, equals(1));
      expect(tUserCreationResponse.email, equals('test@example.com'));
      expect(tUserCreationResponse.firstName, equals('John'));
      expect(tUserCreationResponse.lastName, equals('Doe'));
      expect(tUserCreationResponse.phone, equals('1234567890'));
      expect(tUserCreationResponse.gender, equals(true));
      expect(tUserCreationResponse.birthDate, equals('1990-01-01'));
      expect(tUserCreationResponse.avatar, equals('avatar.jpg'));
      expect(tUserCreationResponse.address, equals('123 Main St'));
      expect(tUserCreationResponse.city, equals('New York'));
      expect(tUserCreationResponse.district, equals('Manhattan'));
      expect(tUserCreationResponse.mailReceive, equals(true));
      expect(tUserCreationResponse.role, equals(tRoleResponse));
      expect(tUserCreationResponse.status, equals(tStatusResponse));
    });

    test('should convert from JSON correctly', () {
      // Act
      final result = UserCreationResponse.fromJson(tUserCreationResponseJson);

      // Assert
      expect(result, equals(tUserCreationResponse));
    });

    test('should convert to entity correctly', () {
      // Act
      final result = tUserCreationResponse.toEntity();

      // Assert
      expect(result, isA<RegisteredUser>());
      expect(result.id, equals(1));
      expect(result.email, equals('test@example.com'));
      expect(result.firstName, equals('John'));
      expect(result.lastName, equals('Doe'));
      expect(result.phone, equals('1234567890'));
      expect(result.status.id, equals(1));
      expect(result.role.id, equals(1));
    });

    test('should handle null optional fields', () {
      // Arrange
      const userCreationResponseWithNulls = UserCreationResponse(
        id: 1,
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        phone: '1234567890',
        mailReceive: true,
        role: tRoleResponse,
        status: tStatusResponse,
      );

      // Assert
      expect(userCreationResponseWithNulls.gender, isNull);
      expect(userCreationResponseWithNulls.birthDate, isNull);
      expect(userCreationResponseWithNulls.avatar, isNull);
      expect(userCreationResponseWithNulls.address, isNull);
      expect(userCreationResponseWithNulls.city, isNull);
      expect(userCreationResponseWithNulls.district, isNull);
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

    test('should convert to entity correctly', () {
      // Act
      final result = tMajorResponse.toEntity();

      // Assert
      expect(result, isA<Major>());
      expect(result.id, equals(1));
      expect(result.name, equals('Computer Science'));
    });

    test('should handle null name field', () {
      // Arrange
      const majorResponseWithNullName = MajorResponse(id: 1, name: null);

      // Act
      final result = majorResponseWithNullName.toEntity();

      // Assert
      expect(result.name, equals(''));
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

    test('should convert to entity correctly', () {
      // Act
      final result = tPositionResponse.toEntity();

      // Assert
      expect(result, isA<Position>());
      expect(result.id, equals(1));
      expect(result.name, equals('Software Engineer'));
    });

    test('should handle null name field', () {
      // Arrange
      const positionResponseWithNullName = PositionResponse(id: 1, name: null);

      // Act
      final result = positionResponseWithNullName.toEntity();

      // Assert
      expect(result.name, equals(''));
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

    test('should convert to entity correctly', () {
      // Act
      final result = tScheduleResponse.toEntity();

      // Assert
      expect(result, isA<Schedule>());
      expect(result.id, equals(1));
      expect(result.name, equals('Full-time'));
    });

    test('should handle null name field', () {
      // Arrange
      const scheduleResponseWithNullName = ScheduleResponse(id: 1, name: null);

      // Act
      final result = scheduleResponseWithNullName.toEntity();

      // Assert
      expect(result.name, equals(''));
    });
  });

  group('JobInformationResponse Model', () {
    const tUniversityResponse = UniversityResponse(id: 1, name: 'MIT');
    const tPositionResponse = PositionResponse(
      id: 1,
      name: 'Software Engineer',
    );
    const tMajorResponse = MajorResponse(id: 1, name: 'Computer Science');
    const tScheduleResponse = ScheduleResponse(id: 1, name: 'Full-time');

    const tJobInformationResponse = JobInformationResponse(
      university: tUniversityResponse,
      referenceLetter: 'reference.pdf',
      positions: [tPositionResponse],
      majors: [tMajorResponse],
      schedules: [tScheduleResponse],
      desiredJob: 'Senior Developer',
      desiredWorkingProvince: 'California',
      searchable: true,
      cv: 'cv.pdf',
    );

    const tJobInformationResponseJson = {
      'universityDTO': {
        'id': 1,
        'name': 'MIT',
      },
      'referenceLetter': 'reference.pdf',
      'positionDTOs': [
        {
          'id': 1,
          'name': 'Software Engineer',
        },
      ],
      'majorDTOs': [
        {
          'id': 1,
          'name': 'Computer Science',
        },
      ],
      'scheduleDTOs': [
        {
          'id': 1,
          'name': 'Full-time',
        },
      ],
      'desiredJob': 'Senior Developer',
      'desiredWorkingProvince': 'California',
      'searchable': true,
      'cv': 'cv.pdf',
    };

    test('should create JobInformationResponse instance with all fields', () {
      // Assert
      expect(tJobInformationResponse.university, equals(tUniversityResponse));
      expect(tJobInformationResponse.referenceLetter, equals('reference.pdf'));
      expect(tJobInformationResponse.positions, contains(tPositionResponse));
      expect(tJobInformationResponse.majors, contains(tMajorResponse));
      expect(tJobInformationResponse.schedules, contains(tScheduleResponse));
      expect(tJobInformationResponse.desiredJob, equals('Senior Developer'));
      expect(
        tJobInformationResponse.desiredWorkingProvince,
        equals('California'),
      );
      expect(tJobInformationResponse.searchable, equals(true));
      expect(tJobInformationResponse.cv, equals('cv.pdf'));
    });

    test('should convert from JSON correctly', () {
      // Act
      final result = JobInformationResponse.fromJson(
        tJobInformationResponseJson,
      );

      // Assert
      expect(result, equals(tJobInformationResponse));
    });

    test('should handle empty lists and null optional fields', () {
      // Arrange
      const jobInfoWithMinimalData = JobInformationResponse(
        positions: [],
        majors: [],
        schedules: [],
        searchable: false,
      );

      // Assert
      expect(jobInfoWithMinimalData.university, isNull);
      expect(jobInfoWithMinimalData.referenceLetter, isNull);
      expect(jobInfoWithMinimalData.positions, isEmpty);
      expect(jobInfoWithMinimalData.majors, isEmpty);
      expect(jobInfoWithMinimalData.schedules, isEmpty);
      expect(jobInfoWithMinimalData.desiredJob, isNull);
      expect(jobInfoWithMinimalData.desiredWorkingProvince, isNull);
      expect(jobInfoWithMinimalData.searchable, equals(false));
      expect(jobInfoWithMinimalData.cv, isNull);
    });
  });

  group('RegisteredUserResponse Model', () {
    const tRoleResponse = RoleResponse(id: 1, name: 'CANDIDATE');
    const tStatusResponse = StatusResponse(id: 1, name: 'ACTIVE');
    const tUserCreationResponse = UserCreationResponse(
      id: 1,
      email: 'test@example.com',
      firstName: 'John',
      lastName: 'Doe',
      phone: '1234567890',
      mailReceive: true,
      role: tRoleResponse,
      status: tStatusResponse,
    );
    const tJobInformationResponse = JobInformationResponse(
      positions: [],
      majors: [],
      schedules: [],
      searchable: true,
    );

    const tRegisteredUserResponse = RegisteredUserResponse(
      id: 1,
      user: tUserCreationResponse,
      jobInfo: tJobInformationResponse,
    );

    const tRegisteredUserResponseJson = {
      'id': 1,
      'userDTO': {
        'id': 1,
        'email': 'test@example.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'phone': '1234567890',
        'mailReceive': true,
        'roleDTO': {
          'id': 1,
          'name': 'CANDIDATE',
        },
        'statusDTO': {
          'id': 1,
          'name': 'ACTIVE',
        },
      },
      'candidateOtherInfoDTO': {
        'positionDTOs': [],
        'majorDTOs': [],
        'scheduleDTOs': [],
        'searchable': true,
      },
    };

    test('should create RegisteredUserResponse instance with all fields', () {
      // Assert
      expect(tRegisteredUserResponse.id, equals(1));
      expect(tRegisteredUserResponse.user, equals(tUserCreationResponse));
      expect(tRegisteredUserResponse.jobInfo, equals(tJobInformationResponse));
    });

    test('should convert from JSON correctly', () {
      // Act
      final result = RegisteredUserResponse.fromJson(
        tRegisteredUserResponseJson,
      );

      // Assert
      expect(result, equals(tRegisteredUserResponse));
    });
  });

  group('LogInResponse Model', () {
    const tLogInResponse = LogInResponse(
      token: 'jwt_token_here',
      type: 'Bearer',
      email: 'test@example.com',
      role: 'CANDIDATE',
      avatar: 'avatar.jpg',
      userId: 1,
    );

    const tLogInResponseJson = {
      'token': 'jwt_token_here',
      'type': 'Bearer',
      'email': 'test@example.com',
      'role': 'CANDIDATE',
      'avatar': 'avatar.jpg',
      'idUser': 1,
    };

    test('should create LogInResponse instance with all fields', () {
      // Assert
      expect(tLogInResponse.token, equals('jwt_token_here'));
      expect(tLogInResponse.type, equals('Bearer'));
      expect(tLogInResponse.email, equals('test@example.com'));
      expect(tLogInResponse.role, equals('CANDIDATE'));
      expect(tLogInResponse.avatar, equals('avatar.jpg'));
      expect(tLogInResponse.userId, equals(1));
    });

    test('should convert from JSON correctly', () {
      // Act
      final result = LogInResponse.fromJson(tLogInResponseJson);

      // Assert
      expect(result, equals(tLogInResponse));
    });

    test('should convert to JSON correctly', () {
      // Act
      final result = tLogInResponse.toJson();

      // Assert
      expect(result, equals(tLogInResponseJson));
    });

    test('should handle null avatar field', () {
      // Arrange
      const logInResponseWithoutAvatar = LogInResponse(
        token: 'jwt_token_here',
        type: 'Bearer',
        email: 'test@example.com',
        role: 'CANDIDATE',
        userId: 1,
      );

      // Assert
      expect(logInResponseWithoutAvatar.avatar, isNull);
    });
  });

  group('LogInRequest Model', () {
    const tLogInRequest = LogInRequest(
      email: 'test@example.com',
      password: 'password123',
    );

    const tLogInRequestJson = {
      'email': 'test@example.com',
      'password': 'password123',
    };

    test('should create LogInRequest instance with all fields', () {
      // Assert
      expect(tLogInRequest.email, equals('test@example.com'));
      expect(tLogInRequest.password, equals('password123'));
    });

    test('should convert from JSON correctly', () {
      // Act
      final result = LogInRequest.fromJson(tLogInRequestJson);

      // Assert
      expect(result, equals(tLogInRequest));
    });

    test('should convert to JSON correctly', () {
      // Act
      final result = tLogInRequest.toJson();

      // Assert
      expect(result, equals(tLogInRequestJson));
    });
  });

  group('ResetPasswordRequest Model', () {
    const tResetPasswordRequest = ResetPasswordRequest(
      resetToken: 'reset_token_123',
      password: 'newPassword123',
      confirmPassword: 'newPassword123',
    );

    const tResetPasswordRequestJson = {
      'resetToken': 'reset_token_123',
      'password': 'newPassword123',
      'confirmPassword': 'newPassword123',
    };

    test('should create ResetPasswordRequest instance with all fields', () {
      // Assert
      expect(tResetPasswordRequest.resetToken, equals('reset_token_123'));
      expect(tResetPasswordRequest.password, equals('newPassword123'));
      expect(tResetPasswordRequest.confirmPassword, equals('newPassword123'));
    });

    test('should convert from JSON correctly', () {
      // Act
      final result = ResetPasswordRequest.fromJson(tResetPasswordRequestJson);

      // Assert
      expect(result, equals(tResetPasswordRequest));
    });

    test('should convert to JSON correctly', () {
      // Act
      final result = tResetPasswordRequest.toJson();

      // Assert
      expect(result, equals(tResetPasswordRequestJson));
    });
  });

  group('GetUserResponse Model', () {
    const tRoleResponse = RoleResponse(id: 1, name: 'CANDIDATE');
    const tStatusResponse = StatusResponse(id: 1, name: 'ACTIVE');
    const tUniversityResponse = UniversityResponse(id: 1, name: 'MIT');
    const tPositionResponse = PositionResponse(
      id: 1,
      name: 'Software Engineer',
    );
    const tMajorResponse = MajorResponse(id: 1, name: 'Computer Science');
    const tScheduleResponse = ScheduleResponse(id: 1, name: 'Full-time');

    const tUserCreationResponse = UserCreationResponse(
      id: 1,
      email: 'test@example.com',
      firstName: 'John',
      lastName: 'Doe',
      phone: '1234567890',
      gender: true,
      birthDate: '1990-01-01',
      avatar: 'avatar.jpg',
      address: '123 Main St',
      city: 'New York',
      district: 'Manhattan',
      mailReceive: true,
      role: tRoleResponse,
      status: tStatusResponse,
    );

    const tJobInformationResponse = JobInformationResponse(
      university: tUniversityResponse,
      referenceLetter: 'reference.pdf',
      positions: [tPositionResponse],
      majors: [tMajorResponse],
      schedules: [tScheduleResponse],
      desiredJob: 'Senior Developer',
      desiredWorkingProvince: 'California',
      searchable: true,
      cv: 'cv.pdf',
    );

    const tGetUserResponse = GetUserResponse(
      id: 1,
      user: tUserCreationResponse,
      jobInfo: tJobInformationResponse,
    );

    test('should convert to User entity correctly', () {
      // Act
      final result = tGetUserResponse.toEntity();

      // Assert
      expect(result, isA<User>());
      expect(result.userId, equals(1));
      expect(result.role, equals('CANDIDATE'));
      expect(result.userInfo.email, equals('test@example.com'));
      expect(result.userInfo.firstName, equals('John'));
      expect(result.userInfo.lastName, equals('Doe'));
      expect(result.userInfo.phone, equals('1234567890'));
      expect(result.userInfo.gender, equals(true));
      expect(result.userInfo.birthDate, equals('1990-01-01'));
      expect(result.userInfo.avatar, equals('avatar.jpg'));
      expect(result.userInfo.address, equals('123 Main St'));
      expect(result.userInfo.city, equals('New York'));
      expect(result.userInfo.district, equals('Manhattan'));
      expect(result.userInfo.mailReceive, equals(true));
      expect(result.jobInfo.university?.name, equals('MIT'));
      expect(result.jobInfo.referenceLetter, equals('reference.pdf'));
      expect(result.jobInfo.positions.first.name, equals('Software Engineer'));
      expect(result.jobInfo.majors.first.name, equals('Computer Science'));
      expect(result.jobInfo.schedules.first.name, equals('Full-time'));
      expect(result.jobInfo.desiredJob, equals('Senior Developer'));
      expect(result.jobInfo.desiredWorkingProvince, equals('California'));
      expect(result.jobInfo.searchable, equals(true));
      expect(result.jobInfo.cv, equals('cv.pdf'));
    });

    test('should handle null fields when converting to entity', () {
      // Arrange
      const userWithNulls = UserCreationResponse(
        id: 1,
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        phone: '1234567890',
        mailReceive: true,
        role: tRoleResponse,
        status: tStatusResponse,
      );

      const jobInfoWithNulls = JobInformationResponse(
        positions: [],
        majors: [],
        schedules: [],
        searchable: false,
      );

      const getUserResponseWithNulls = GetUserResponse(
        id: 1,
        user: userWithNulls,
        jobInfo: jobInfoWithNulls,
      );

      // Act
      final result = getUserResponseWithNulls.toEntity();

      // Assert
      expect(result.userInfo.gender, equals(false)); // Default value when null
      expect(result.userInfo.birthDate, isNull);
      expect(result.userInfo.avatar, isNull);
      expect(result.userInfo.address, isNull);
      expect(result.userInfo.city, isNull);
      expect(result.userInfo.district, isNull);
      expect(result.jobInfo.university, isNull);
      expect(result.jobInfo.referenceLetter, isNull);
      expect(result.jobInfo.positions, isEmpty);
      expect(result.jobInfo.majors, isEmpty);
      expect(result.jobInfo.schedules, isEmpty);
      expect(result.jobInfo.desiredJob, isNull);
      expect(result.jobInfo.desiredWorkingProvince, isNull);
      expect(result.jobInfo.cv, isNull);
    });
  });

  group('Request Models', () {
    group('UniversityRequest', () {
      const tUniversityRequest = UniversityRequest(id: 1);
      const tUniversityRequestJson = {'id': 1};

      test('should create UniversityRequest instance', () {
        expect(tUniversityRequest.id, equals(1));
      });

      test('should convert from/to JSON correctly', () {
        final fromJson = UniversityRequest.fromJson(tUniversityRequestJson);
        final toJson = tUniversityRequest.toJson();

        expect(fromJson, equals(tUniversityRequest));
        expect(toJson, equals(tUniversityRequestJson));
      });
    });

    group('PositionRequest', () {
      const tPositionRequest = PositionRequest(id: 1);
      const tPositionRequestJson = {'id': 1};

      test('should create PositionRequest instance', () {
        expect(tPositionRequest.id, equals(1));
      });

      test('should convert from/to JSON correctly', () {
        final fromJson = PositionRequest.fromJson(tPositionRequestJson);
        final toJson = tPositionRequest.toJson();

        expect(fromJson, equals(tPositionRequest));
        expect(toJson, equals(tPositionRequestJson));
      });
    });

    group('MajorRequest', () {
      const tMajorRequest = MajorRequest(id: 1);
      const tMajorRequestJson = {'id': 1};

      test('should create MajorRequest instance', () {
        expect(tMajorRequest.id, equals(1));
      });

      test('should convert from/to JSON correctly', () {
        final fromJson = MajorRequest.fromJson(tMajorRequestJson);
        final toJson = tMajorRequest.toJson();

        expect(fromJson, equals(tMajorRequest));
        expect(toJson, equals(tMajorRequestJson));
      });
    });

    group('ScheduleRequest', () {
      const tScheduleRequest = ScheduleRequest(id: 1);
      const tScheduleRequestJson = {'id': 1};

      test('should create ScheduleRequest instance', () {
        expect(tScheduleRequest.id, equals(1));
      });

      test('should convert from/to JSON correctly', () {
        final fromJson = ScheduleRequest.fromJson(tScheduleRequestJson);
        final toJson = tScheduleRequest.toJson();

        expect(fromJson, equals(tScheduleRequest));
        expect(toJson, equals(tScheduleRequestJson));
      });
    });

    group('OtherInfoRequest', () {
      const tPositionRequest = PositionRequest(id: 1);
      const tMajorRequest = MajorRequest(id: 1);
      const tScheduleRequest = ScheduleRequest(id: 1);

      const tOtherInfoRequest = OtherInfoRequest(
        desiredJob: 'Senior Developer',
        desiredWorkingProvince: 'California',
        referenceLetter: 'reference.pdf',
        positionDTOs: [tPositionRequest],
        majorDTOs: [tMajorRequest],
        scheduleDTOs: [tScheduleRequest],
      );

      test('should create OtherInfoRequest instance with all fields', () {
        expect(tOtherInfoRequest.desiredJob, equals('Senior Developer'));
        expect(tOtherInfoRequest.desiredWorkingProvince, equals('California'));
        expect(tOtherInfoRequest.referenceLetter, equals('reference.pdf'));
        expect(tOtherInfoRequest.positionDTOs, contains(tPositionRequest));
        expect(tOtherInfoRequest.majorDTOs, contains(tMajorRequest));
        expect(tOtherInfoRequest.scheduleDTOs, contains(tScheduleRequest));
      });
    });
  });

  group('Response Models', () {
    const tMessageResponseJson = {'message': 'Operation successful'};

    group('SendMailResponse', () {
      const tSendMailResponse = SendMailResponse(
        message: 'Operation successful',
      );

      test('should create SendMailResponse instance', () {
        expect(tSendMailResponse.message, equals('Operation successful'));
      });

      test('should convert from/to JSON correctly', () {
        final fromJson = SendMailResponse.fromJson(tMessageResponseJson);
        final toJson = tSendMailResponse.toJson();

        expect(fromJson, equals(tSendMailResponse));
        expect(toJson, equals(tMessageResponseJson));
      });
    });

    group('VerifyMailResponse', () {
      const tVerifyMailResponse = VerifyMailResponse(
        message: 'Operation successful',
      );

      test('should create VerifyMailResponse instance', () {
        expect(tVerifyMailResponse.message, equals('Operation successful'));
      });

      test('should convert from/to JSON correctly', () {
        final fromJson = VerifyMailResponse.fromJson(tMessageResponseJson);
        final toJson = tVerifyMailResponse.toJson();

        expect(fromJson, equals(tVerifyMailResponse));
        expect(toJson, equals(tMessageResponseJson));
      });
    });

    group('CheckMailResponse', () {
      const tCheckMailResponse = CheckMailResponse(
        message: 'Operation successful',
      );

      test('should create CheckMailResponse instance', () {
        expect(tCheckMailResponse.message, equals('Operation successful'));
      });

      test('should convert from/to JSON correctly', () {
        final fromJson = CheckMailResponse.fromJson(tMessageResponseJson);
        final toJson = tCheckMailResponse.toJson();

        expect(fromJson, equals(tCheckMailResponse));
        expect(toJson, equals(tMessageResponseJson));
      });
    });

    group('ForgotPasswordResponse', () {
      const tForgotPasswordResponse = ForgotPasswordResponse(
        message: 'Operation successful',
      );

      test('should create ForgotPasswordResponse instance', () {
        expect(tForgotPasswordResponse.message, equals('Operation successful'));
      });

      test('should convert from/to JSON correctly', () {
        final fromJson = ForgotPasswordResponse.fromJson(tMessageResponseJson);
        final toJson = tForgotPasswordResponse.toJson();

        expect(fromJson, equals(tForgotPasswordResponse));
        expect(toJson, equals(tMessageResponseJson));
      });
    });

    group('ResetPasswordResponse', () {
      const tResetPasswordResponse = ResetPasswordResponse(
        message: 'Operation successful',
      );

      test('should create ResetPasswordResponse instance', () {
        expect(tResetPasswordResponse.message, equals('Operation successful'));
      });

      test('should convert from/to JSON correctly', () {
        final fromJson = ResetPasswordResponse.fromJson(tMessageResponseJson);
        final toJson = tResetPasswordResponse.toJson();

        expect(fromJson, equals(tResetPasswordResponse));
        expect(toJson, equals(tMessageResponseJson));
      });
    });

    group('VerifyOtpResponse', () {
      const tVerifyOtpResponse = VerifyOtpResponse(
        message: 'Operation successful',
      );

      test('should create VerifyOtpResponse instance', () {
        expect(tVerifyOtpResponse.message, equals('Operation successful'));
      });

      test('should convert from/to JSON correctly', () {
        final fromJson = VerifyOtpResponse.fromJson(tMessageResponseJson);
        final toJson = tVerifyOtpResponse.toJson();

        expect(fromJson, equals(tVerifyOtpResponse));
        expect(toJson, equals(tMessageResponseJson));
      });
    });
  });

  group('JSON Serialization Edge Cases', () {
    test('should handle deeply nested JSON structures', () {
      // Arrange
      const complexJson = {
        'id': 1,
        'userDTO': {
          'id': 1,
          'email': 'test@example.com',
          'firstName': 'John',
          'lastName': 'Doe',
          'phone': '1234567890',
          'mailReceive': true,
          'roleDTO': {'id': 1, 'name': 'CANDIDATE'},
          'statusDTO': {'id': 1, 'name': 'ACTIVE'},
        },
        'candidateOtherInfoDTO': {
          'universityDTO': {'id': 1, 'name': 'MIT'},
          'positionDTOs': [
            {'id': 1, 'name': 'Software Engineer'},
          ],
          'majorDTOs': [
            {'id': 1, 'name': 'Computer Science'},
          ],
          'scheduleDTOs': [
            {'id': 1, 'name': 'Full-time'},
          ],
          'searchable': true,
        },
      };

      // Act & Assert - Should not throw exceptions
      expect(
        () => RegisteredUserResponse.fromJson(complexJson),
        returnsNormally,
      );
    });

    test('should handle JSON with missing optional fields', () {
      // Arrange
      const minimalJson = {
        'positionDTOs': [],
        'majorDTOs': [],
        'scheduleDTOs': [],
        'searchable': false,
      };

      // Act & Assert - Should not throw exceptions
      expect(
        () => JobInformationResponse.fromJson(minimalJson),
        returnsNormally,
      );
    });
  });
}
