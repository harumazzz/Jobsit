import 'package:flutter_test/flutter_test.dart';
import 'package:jobsit/features/auth/domain/entities/user.dart';

void main() {
  group('Status Entity', () {
    test('should create Status instance with required fields', () {
      // Arrange
      const id = 1;
      const name = 'Active';

      // Act
      const status = Status(
        id: id,
        name: name,
      );

      // Assert
      expect(status.id, equals(id));
      expect(status.name, equals(name));
    });

    test('should support equality comparison', () {
      // Arrange
      const status1 = Status(id: 1, name: 'Active');
      const status2 = Status(id: 1, name: 'Active');
      const status3 = Status(id: 2, name: 'Inactive');

      // Assert
      expect(status1, equals(status2));
      expect(status1, isNot(equals(status3)));
    });

    test('should have proper toString representation', () {
      // Arrange
      const status = Status(id: 1, name: 'Active');

      // Act
      final result = status.toString();

      // Assert
      expect(result, contains('Status'));
      expect(result, contains('id: 1'));
      expect(result, contains('name: Active'));
    });
  });

  group('Role Entity', () {
    test('should create Role instance with required fields', () {
      // Arrange
      const id = 1;
      const name = 'Candidate';

      // Act
      const role = Role(
        id: id,
        name: name,
      );

      // Assert
      expect(role.id, equals(id));
      expect(role.name, equals(name));
    });

    test('should support equality comparison', () {
      // Arrange
      const role1 = Role(id: 1, name: 'Candidate');
      const role2 = Role(id: 1, name: 'Candidate');
      const role3 = Role(id: 2, name: 'Employer');

      // Assert
      expect(role1, equals(role2));
      expect(role1, isNot(equals(role3)));
    });
  });

  group('University Entity', () {
    test('should create University instance with required fields', () {
      // Arrange
      const id = 1;
      const name = 'MIT';

      // Act
      const university = University(
        id: id,
        name: name,
      );

      // Assert
      expect(university.id, equals(id));
      expect(university.name, equals(name));
    });

    test('should support equality comparison', () {
      // Arrange
      const university1 = University(id: 1, name: 'MIT');
      const university2 = University(id: 1, name: 'MIT');
      const university3 = University(id: 2, name: 'Stanford');

      // Assert
      expect(university1, equals(university2));
      expect(university1, isNot(equals(university3)));
    });
  });

  group('RegisteredUser Entity', () {
    test('should create RegisteredUser instance with all required fields', () {
      // Arrange
      const id = 1;
      const email = 'test@example.com';
      const firstName = 'John';
      const lastName = 'Doe';
      const phone = '1234567890';
      const status = Status(id: 1, name: 'Active');
      const role = Role(id: 1, name: 'Candidate');

      // Act
      const registeredUser = RegisteredUser(
        id: id,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        status: status,
        role: role,
      );

      // Assert
      expect(registeredUser.id, equals(id));
      expect(registeredUser.email, equals(email));
      expect(registeredUser.firstName, equals(firstName));
      expect(registeredUser.lastName, equals(lastName));
      expect(registeredUser.phone, equals(phone));
      expect(registeredUser.status, equals(status));
      expect(registeredUser.role, equals(role));
    });

    test('should support equality comparison', () {
      // Arrange
      const status = Status(id: 1, name: 'Active');
      const role = Role(id: 1, name: 'Candidate');

      const user1 = RegisteredUser(
        id: 1,
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        phone: '1234567890',
        status: status,
        role: role,
      );

      const user2 = RegisteredUser(
        id: 1,
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        phone: '1234567890',
        status: status,
        role: role,
      );

      const user3 = RegisteredUser(
        id: 2,
        email: 'test2@example.com',
        firstName: 'Jane',
        lastName: 'Smith',
        phone: '0987654321',
        status: status,
        role: role,
      );

      // Assert
      expect(user1, equals(user2));
      expect(user1, isNot(equals(user3)));
    });
  });

  group('UserInformation Entity', () {
    test('should create UserInformation instance with required fields', () {
      // Arrange
      const email = 'test@example.com';
      const firstName = 'John';
      const lastName = 'Doe';
      const phone = '1234567890';
      const gender = true;
      const mailReceive = true;

      // Act
      const userInfo = UserInformation(
        email: email,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        gender: gender,
        mailReceive: mailReceive,
      );

      // Assert
      expect(userInfo.email, equals(email));
      expect(userInfo.firstName, equals(firstName));
      expect(userInfo.lastName, equals(lastName));
      expect(userInfo.phone, equals(phone));
      expect(userInfo.gender, equals(gender));
      expect(userInfo.mailReceive, equals(mailReceive));
      expect(userInfo.city, isNull);
      expect(userInfo.district, isNull);
      expect(userInfo.birthDate, isNull);
      expect(userInfo.address, isNull);
      expect(userInfo.avatar, isNull);
    });

    test('should create UserInformation instance with optional fields', () {
      // Arrange
      const city = 'New York';
      const district = 'Manhattan';
      const birthDate = '1990-01-01';
      const address = '123 Main St';
      const avatar = 'avatar.jpg';

      // Act
      const userInfo = UserInformation(
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        phone: '1234567890',
        gender: true,
        mailReceive: true,
        city: city,
        district: district,
        birthDate: birthDate,
        address: address,
        avatar: avatar,
      );

      // Assert
      expect(userInfo.city, equals(city));
      expect(userInfo.district, equals(district));
      expect(userInfo.birthDate, equals(birthDate));
      expect(userInfo.address, equals(address));
      expect(userInfo.avatar, equals(avatar));
    });

    test('should support equality comparison', () {
      // Arrange
      const userInfo1 = UserInformation(
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        phone: '1234567890',
        gender: true,
        mailReceive: true,
      );

      const userInfo2 = UserInformation(
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        phone: '1234567890',
        gender: true,
        mailReceive: true,
      );

      const userInfo3 = UserInformation(
        email: 'different@example.com',
        firstName: 'Jane',
        lastName: 'Smith',
        phone: '0987654321',
        gender: false,
        mailReceive: false,
      );

      // Assert
      expect(userInfo1, equals(userInfo2));
      expect(userInfo1, isNot(equals(userInfo3)));
    });
  });

  group('Major Entity', () {
    test('should create Major instance with required fields', () {
      // Arrange
      const id = 1;
      const name = 'Computer Science';

      // Act
      const major = Major(
        id: id,
        name: name,
      );

      // Assert
      expect(major.id, equals(id));
      expect(major.name, equals(name));
    });

    test('should support equality comparison', () {
      // Arrange
      const major1 = Major(id: 1, name: 'Computer Science');
      const major2 = Major(id: 1, name: 'Computer Science');
      const major3 = Major(id: 2, name: 'Mathematics');

      // Assert
      expect(major1, equals(major2));
      expect(major1, isNot(equals(major3)));
    });
  });

  group('Position Entity', () {
    test('should create Position instance with required fields', () {
      // Arrange
      const id = 1;
      const name = 'Software Engineer';

      // Act
      const position = Position(
        id: id,
        name: name,
      );

      // Assert
      expect(position.id, equals(id));
      expect(position.name, equals(name));
    });

    test('should support equality comparison', () {
      // Arrange
      const position1 = Position(id: 1, name: 'Software Engineer');
      const position2 = Position(id: 1, name: 'Software Engineer');
      const position3 = Position(id: 2, name: 'Product Manager');

      // Assert
      expect(position1, equals(position2));
      expect(position1, isNot(equals(position3)));
    });
  });

  group('Schedule Entity', () {
    test('should create Schedule instance with required fields', () {
      // Arrange
      const id = 1;
      const name = 'Full-time';

      // Act
      const schedule = Schedule(
        id: id,
        name: name,
      );

      // Assert
      expect(schedule.id, equals(id));
      expect(schedule.name, equals(name));
    });

    test('should support equality comparison', () {
      // Arrange
      const schedule1 = Schedule(id: 1, name: 'Full-time');
      const schedule2 = Schedule(id: 1, name: 'Full-time');
      const schedule3 = Schedule(id: 2, name: 'Part-time');

      // Assert
      expect(schedule1, equals(schedule2));
      expect(schedule1, isNot(equals(schedule3)));
    });
  });

  group('JobInformation Entity', () {
    late List<Position> testPositions;
    late List<Major> testMajors;
    late List<Schedule> testSchedules;

    setUp(() {
      testPositions = [
        const Position(id: 1, name: 'Software Engineer'),
        const Position(id: 2, name: 'Data Scientist'),
      ];
      testMajors = [
        const Major(id: 1, name: 'Computer Science'),
        const Major(id: 2, name: 'Mathematics'),
      ];
      testSchedules = [
        const Schedule(id: 1, name: 'Full-time'),
        const Schedule(id: 2, name: 'Part-time'),
      ];
    });

    test('should create JobInformation instance with required fields', () {
      // Arrange
      const searchable = true;

      // Act
      final jobInfo = JobInformation(
        positions: testPositions,
        majors: testMajors,
        schedules: testSchedules,
        searchable: searchable,
      );

      // Assert
      expect(jobInfo.positions, equals(testPositions));
      expect(jobInfo.majors, equals(testMajors));
      expect(jobInfo.schedules, equals(testSchedules));
      expect(jobInfo.searchable, equals(searchable));
      expect(jobInfo.university, isNull);
      expect(jobInfo.referenceLetter, isNull);
      expect(jobInfo.desiredJob, isNull);
      expect(jobInfo.desiredWorkingProvince, isNull);
      expect(jobInfo.cv, isNull);
    });

    test('should create JobInformation instance with optional fields', () {
      // Arrange
      const university = University(id: 1, name: 'MIT');
      const referenceLetter = 'reference.pdf';
      const desiredJob = 'Senior Developer';
      const desiredWorkingProvince = 'California';
      const cv = 'cv.pdf';

      // Act
      final jobInfo = JobInformation(
        university: university,
        referenceLetter: referenceLetter,
        positions: testPositions,
        majors: testMajors,
        schedules: testSchedules,
        searchable: true,
        desiredJob: desiredJob,
        desiredWorkingProvince: desiredWorkingProvince,
        cv: cv,
      );

      // Assert
      expect(jobInfo.university, equals(university));
      expect(jobInfo.referenceLetter, equals(referenceLetter));
      expect(jobInfo.desiredJob, equals(desiredJob));
      expect(jobInfo.desiredWorkingProvince, equals(desiredWorkingProvince));
      expect(jobInfo.cv, equals(cv));
    });

    test('should support equality comparison', () {
      // Arrange
      final jobInfo1 = JobInformation(
        positions: testPositions,
        majors: testMajors,
        schedules: testSchedules,
        searchable: true,
      );

      final jobInfo2 = JobInformation(
        positions: testPositions,
        majors: testMajors,
        schedules: testSchedules,
        searchable: true,
      );

      const jobInfo3 = JobInformation(
        positions: [Position(id: 3, name: 'Designer')],
        majors: [Major(id: 3, name: 'Art')],
        schedules: [Schedule(id: 3, name: 'Contract')],
        searchable: false,
      );

      // Assert
      expect(jobInfo1, equals(jobInfo2));
      expect(jobInfo1, isNot(equals(jobInfo3)));
    });

    test('should handle empty lists', () {
      // Act
      const jobInfo = JobInformation(
        positions: [],
        majors: [],
        schedules: [],
        searchable: false,
      );

      // Assert
      expect(jobInfo.positions, isEmpty);
      expect(jobInfo.majors, isEmpty);
      expect(jobInfo.schedules, isEmpty);
      expect(jobInfo.searchable, isFalse);
    });
  });

  group('User Entity', () {
    late UserInformation testUserInfo;
    late JobInformation testJobInfo;

    setUp(() {
      testUserInfo = const UserInformation(
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        phone: '1234567890',
        gender: true,
        mailReceive: true,
      );

      testJobInfo = const JobInformation(
        positions: [],
        majors: [],
        schedules: [],
        searchable: true,
      );
    });

    test('should create User instance with all required fields', () {
      // Arrange
      const userId = 1;
      const role = 'CANDIDATE';

      // Act
      final user = User(
        userId: userId,
        role: role,
        userInfo: testUserInfo,
        jobInfo: testJobInfo,
      );

      // Assert
      expect(user.userId, equals(userId));
      expect(user.role, equals(role));
      expect(user.userInfo, equals(testUserInfo));
      expect(user.jobInfo, equals(testJobInfo));
    });

    test('should support equality comparison', () {
      // Arrange
      final user1 = User(
        userId: 1,
        role: 'CANDIDATE',
        userInfo: testUserInfo,
        jobInfo: testJobInfo,
      );

      final user2 = User(
        userId: 1,
        role: 'CANDIDATE',
        userInfo: testUserInfo,
        jobInfo: testJobInfo,
      );

      const user3 = User(
        userId: 2,
        role: 'EMPLOYER',
        userInfo: UserInformation(
          email: 'different@example.com',
          firstName: 'Jane',
          lastName: 'Smith',
          phone: '0987654321',
          gender: false,
          mailReceive: false,
        ),
        jobInfo: JobInformation(
          positions: [],
          majors: [],
          schedules: [],
          searchable: false,
        ),
      );

      // Assert
      expect(user1, equals(user2));
      expect(user1, isNot(equals(user3)));
    });

    test('should work with different role types', () {
      // Arrange & Act
      final candidateUser = User(
        userId: 1,
        role: 'CANDIDATE',
        userInfo: testUserInfo,
        jobInfo: testJobInfo,
      );

      final employerUser = User(
        userId: 2,
        role: 'EMPLOYER',
        userInfo: testUserInfo,
        jobInfo: testJobInfo,
      );

      // Assert
      expect(candidateUser.role, equals('CANDIDATE'));
      expect(employerUser.role, equals('EMPLOYER'));
      expect(candidateUser, isNot(equals(employerUser)));
    });

    test('should have proper toString representation', () {
      // Arrange
      final user = User(
        userId: 1,
        role: 'CANDIDATE',
        userInfo: testUserInfo,
        jobInfo: testJobInfo,
      );

      // Act
      final result = user.toString();

      // Assert
      expect(result, contains('User'));
      expect(result, contains('userId: 1'));
      expect(result, contains('role: CANDIDATE'));
    });
  });

  group('Entity Integration Tests', () {
    test('should create complete user profile with all nested entities', () {
      // Arrange
      const status = Status(id: 1, name: 'Active');
      const role = Role(id: 1, name: 'Candidate');
      const university = University(id: 1, name: 'MIT');
      const major = Major(id: 1, name: 'Computer Science');
      const position = Position(id: 1, name: 'Software Engineer');
      const schedule = Schedule(id: 1, name: 'Full-time');

      const registeredUser = RegisteredUser(
        id: 1,
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        phone: '1234567890',
        status: status,
        role: role,
      );

      const userInfo = UserInformation(
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        phone: '1234567890',
        gender: true,
        mailReceive: true,
        city: 'New York',
        district: 'Manhattan',
        birthDate: '1990-01-01',
        address: '123 Main St',
        avatar: 'avatar.jpg',
      );

      const jobInfo = JobInformation(
        university: university,
        referenceLetter: 'reference.pdf',
        positions: [position],
        majors: [major],
        schedules: [schedule],
        searchable: true,
        desiredJob: 'Senior Developer',
        desiredWorkingProvince: 'California',
        cv: 'cv.pdf',
      );

      // Act
      const user = User(
        userId: 1,
        role: 'CANDIDATE',
        userInfo: userInfo,
        jobInfo: jobInfo,
      );

      // Assert
      expect(user.userId, equals(1));
      expect(user.role, equals('CANDIDATE'));
      expect(user.userInfo.email, equals(registeredUser.email));
      expect(user.userInfo.firstName, equals(registeredUser.firstName));
      expect(user.jobInfo.university?.name, equals('MIT'));
      expect(user.jobInfo.positions.first.name, equals('Software Engineer'));
      expect(user.jobInfo.majors.first.name, equals('Computer Science'));
      expect(user.jobInfo.schedules.first.name, equals('Full-time'));
    });

    test('should handle nullable fields correctly', () {
      // Arrange
      const userInfo = UserInformation(
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        phone: '1234567890',
        gender: true,
        mailReceive: true,
        // All optional fields are null
      );

      const jobInfo = JobInformation(
        positions: [],
        majors: [],
        schedules: [],
        searchable: false,
        // All optional fields are null
      );

      // Act
      const user = User(
        userId: 1,
        role: 'CANDIDATE',
        userInfo: userInfo,
        jobInfo: jobInfo,
      );

      // Assert
      expect(user.userInfo.city, isNull);
      expect(user.userInfo.district, isNull);
      expect(user.userInfo.birthDate, isNull);
      expect(user.userInfo.address, isNull);
      expect(user.userInfo.avatar, isNull);
      expect(user.jobInfo.university, isNull);
      expect(user.jobInfo.referenceLetter, isNull);
      expect(user.jobInfo.desiredJob, isNull);
      expect(user.jobInfo.desiredWorkingProvince, isNull);
      expect(user.jobInfo.cv, isNull);
    });
  });
}
