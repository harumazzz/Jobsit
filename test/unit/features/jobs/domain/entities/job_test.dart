import 'package:flutter_test/flutter_test.dart';
import 'package:jobsit/features/auth/domain/entities/user.dart' as user;
import 'package:jobsit/features/jobs/domain/entities/job.dart';

void main() {
  group('JobStatus Entity', () {
    test('should create JobStatus instance with required fields', () {
      // Arrange
      const id = 1;
      const name = 'Active';

      // Act
      const jobStatus = JobStatus(
        id: id,
        name: name,
      );

      // Assert
      expect(jobStatus.id, equals(id));
      expect(jobStatus.name, equals(name));
    });

    test('should support equality comparison', () {
      // Arrange
      const status1 = JobStatus(id: 1, name: 'Active');
      const status2 = JobStatus(id: 1, name: 'Active');
      const status3 = JobStatus(id: 2, name: 'Expired');

      // Assert
      expect(status1, equals(status2));
      expect(status1, isNot(equals(status3)));
    });

    test('should have proper toString representation', () {
      // Arrange
      const status = JobStatus(id: 1, name: 'Active');

      // Act
      final result = status.toString();

      // Assert
      expect(result, contains('JobStatus'));
      expect(result, contains('id: 1'));
      expect(result, contains('name: Active'));
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
      const major3 = Major(id: 2, name: 'Engineering');

      // Assert
      expect(major1, equals(major2));
      expect(major1, isNot(equals(major3)));
    });
  });

  group('Position Entity', () {
    test('should create Position instance with required fields', () {
      // Arrange
      const id = 1;
      const name = 'Software Developer';

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
      const position1 = Position(id: 1, name: 'Software Developer');
      const position2 = Position(id: 1, name: 'Software Developer');
      const position3 = Position(id: 2, name: 'Data Analyst');

      // Assert
      expect(position1, equals(position2));
      expect(position1, isNot(equals(position3)));
    });
  });

  group('Company Entity', () {
    test('should create Company instance with required fields only', () {
      // Arrange
      const id = 1;
      const status = JobStatus(id: 1, name: 'Active');

      // Act
      const company = Company(
        id: id,
        status: status,
      );

      // Assert
      expect(company.id, equals(id));
      expect(company.status, equals(status));
      expect(company.logo, isNull);
      expect(company.name, isNull);
      expect(company.tax, isNull);
      expect(company.email, isNull);
      expect(company.phone, isNull);
      expect(company.personnelSize, isNull);
      expect(company.website, isNull);
      expect(company.country, isNull);
      expect(company.province, isNull);
      expect(company.district, isNull);
      expect(company.createdDate, isNull);
      expect(company.location, isNull);
      expect(company.description, isNull);
    });

    test('should create Company instance with all fields', () {
      // Arrange
      const id = 1;
      const logo = 'logo.png';
      const name = 'Tech Corp';
      const tax = '123456789';
      const email = 'info@techcorp.com';
      const phone = '+1234567890';
      const personnelSize = '100-500 employees';
      const website = 'https://techcorp.com';
      const country = 'USA';
      const province = 'California';
      const district = 'San Francisco';
      const createdDate = '2020-01-01';
      const location = '123 Tech Street, San Francisco, CA';
      const status = JobStatus(id: 1, name: 'Active');
      const description = 'Leading technology company';

      // Act
      const company = Company(
        id: id,
        logo: logo,
        name: name,
        tax: tax,
        email: email,
        phone: phone,
        personnelSize: personnelSize,
        website: website,
        country: country,
        province: province,
        district: district,
        createdDate: createdDate,
        location: location,
        status: status,
        description: description,
      );

      // Assert
      expect(company.id, equals(id));
      expect(company.logo, equals(logo));
      expect(company.name, equals(name));
      expect(company.tax, equals(tax));
      expect(company.email, equals(email));
      expect(company.phone, equals(phone));
      expect(company.personnelSize, equals(personnelSize));
      expect(company.website, equals(website));
      expect(company.country, equals(country));
      expect(company.province, equals(province));
      expect(company.district, equals(district));
      expect(company.createdDate, equals(createdDate));
      expect(company.location, equals(location));
      expect(company.status, equals(status));
      expect(company.description, equals(description));
    });

    test('should support equality comparison', () {
      // Arrange
      const status = JobStatus(id: 1, name: 'Active');

      const company1 = Company(
        id: 1,
        name: 'Tech Corp',
        status: status,
      );

      const company2 = Company(
        id: 1,
        name: 'Tech Corp',
        status: status,
      );

      const company3 = Company(
        id: 2,
        name: 'Other Corp',
        status: status,
      );

      // Assert
      expect(company1, equals(company2));
      expect(company1, isNot(equals(company3)));
    });
  });

  group('Job Entity', () {
    late DateTime postingDate;
    late DateTime applicationDeadline;
    late JobStatus jobStatus;
    late Company company;
    late List<Position> positions;
    late List<Major> majors;
    late List<Schedule> schedules;

    setUp(() {
      postingDate = DateTime(2024);
      applicationDeadline = DateTime(2024, 12, 31);
      jobStatus = const JobStatus(id: 1, name: 'Active');
      company = const Company(
        id: 1,
        name: 'Tech Corp',
        status: JobStatus(id: 1, name: 'Active'),
      );
      positions = const [Position(id: 1, name: 'Software Developer')];
      majors = const [Major(id: 1, name: 'Computer Science')];
      schedules = const [Schedule(id: 1, name: 'Full-time')];
    });

    test('should create Job instance with all required fields', () {
      // Arrange
      const id = 1;
      const title = 'Software Developer Position';
      const amount = 5;
      const minAllowance = 50000.0;
      const maxAllowance = 80000.0;
      const description = 'Great opportunity for developers';
      const requirements = 'Bachelor degree in CS';
      const benefits = 'Health insurance, flexible hours';
      const country = 'USA';
      const city = 'San Francisco';
      const district = 'Downtown';
      const address = '123 Tech Street';
      const noAllowance = false;

      // Act
      final job = Job(
        id: id,
        title: title,
        positions: positions,
        majors: majors,
        schedules: schedules,
        amount: amount,
        postingDate: postingDate,
        applicationDeadline: applicationDeadline,
        minAllowance: minAllowance,
        maxAllowance: maxAllowance,
        description: description,
        requirements: requirements,
        benefits: benefits,
        country: country,
        city: city,
        district: district,
        address: address,
        noAllowance: noAllowance,
        status: jobStatus,
        company: company,
      );

      // Assert
      expect(job.id, equals(id));
      expect(job.title, equals(title));
      expect(job.positions, equals(positions));
      expect(job.majors, equals(majors));
      expect(job.schedules, equals(schedules));
      expect(job.amount, equals(amount));
      expect(job.postingDate, equals(postingDate));
      expect(job.applicationDeadline, equals(applicationDeadline));
      expect(job.minAllowance, equals(minAllowance));
      expect(job.maxAllowance, equals(maxAllowance));
      expect(job.description, equals(description));
      expect(job.requirements, equals(requirements));
      expect(job.benefits, equals(benefits));
      expect(job.country, equals(country));
      expect(job.city, equals(city));
      expect(job.district, equals(district));
      expect(job.address, equals(address));
      expect(job.noAllowance, equals(noAllowance));
      expect(job.status, equals(jobStatus));
      expect(job.company, equals(company));
    });

    test('should support equality comparison', () {
      // Arrange
      final job1 = Job(
        id: 1,
        title: 'Software Developer Position',
        positions: positions,
        majors: majors,
        schedules: schedules,
        amount: 5,
        postingDate: postingDate,
        applicationDeadline: applicationDeadline,
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
        status: jobStatus,
        company: company,
      );

      final job2 = Job(
        id: 1,
        title: 'Software Developer Position',
        positions: positions,
        majors: majors,
        schedules: schedules,
        amount: 5,
        postingDate: postingDate,
        applicationDeadline: applicationDeadline,
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
        status: jobStatus,
        company: company,
      );

      final job3 = Job(
        id: 2,
        title: 'Data Analyst Position',
        positions: positions,
        majors: majors,
        schedules: schedules,
        amount: 3,
        postingDate: postingDate,
        applicationDeadline: applicationDeadline,
        minAllowance: 40000,
        maxAllowance: 60000,
        description: 'Data analysis role',
        requirements: 'Statistics background',
        benefits: 'Remote work',
        country: 'USA',
        city: 'New York',
        district: 'Manhattan',
        address: '456 Data Ave',
        noAllowance: false,
        status: jobStatus,
        company: company,
      );

      // Assert
      expect(job1, equals(job2));
      expect(job1, isNot(equals(job3)));
    });
  });

  group('SavedJob Entity', () {
    late Job job;

    setUp(() {
      final postingDate = DateTime(2024);
      final applicationDeadline = DateTime(2024, 12, 31);
      const jobStatus = JobStatus(id: 1, name: 'Active');
      const company = Company(
        id: 1,
        name: 'Tech Corp',
        status: JobStatus(id: 1, name: 'Active'),
      );
      const positions = [Position(id: 1, name: 'Software Developer')];
      const majors = [Major(id: 1, name: 'Computer Science')];
      const schedules = [Schedule(id: 1, name: 'Full-time')];

      job = Job(
        id: 1,
        title: 'Software Developer Position',
        positions: positions,
        majors: majors,
        schedules: schedules,
        amount: 5,
        postingDate: postingDate,
        applicationDeadline: applicationDeadline,
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
        status: jobStatus,
        company: company,
      );
    });

    test('should create SavedJob instance with required fields', () {
      // Arrange
      const id = 1;

      // Act
      final savedJob = SavedJob(
        id: id,
        job: job,
      );

      // Assert
      expect(savedJob.id, equals(id));
      expect(savedJob.job, equals(job));
    });

    test('should support equality comparison', () {
      // Arrange
      final savedJob1 = SavedJob(id: 1, job: job);
      final savedJob2 = SavedJob(id: 1, job: job);
      final savedJob3 = SavedJob(id: 2, job: job);

      // Assert
      expect(savedJob1, equals(savedJob2));
      expect(savedJob1, isNot(equals(savedJob3)));
    });
  });

  group('Extension Tests', () {
    group('PositionExtension', () {
      test('should convert jobs Position to auth Position', () {
        // Arrange
        const jobsPosition = Position(id: 1, name: 'Software Developer');

        // Act
        final authPosition = jobsPosition.toAuth();

        // Assert
        expect(authPosition, isA<user.Position>());
        expect(authPosition.id, equals(jobsPosition.id));
        expect(authPosition.name, equals(jobsPosition.name));
      });
    });

    group('MajorExtension', () {
      test('should convert jobs Major to auth Major', () {
        // Arrange
        const jobsMajor = Major(id: 1, name: 'Computer Science');

        // Act
        final authMajor = jobsMajor.toAuth();

        // Assert
        expect(authMajor, isA<user.Major>());
        expect(authMajor.id, equals(jobsMajor.id));
        expect(authMajor.name, equals(jobsMajor.name));
      });
    });

    group('ScheduleExtension', () {
      test('should convert jobs Schedule to auth Schedule', () {
        // Arrange
        const jobsSchedule = Schedule(id: 1, name: 'Full-time');

        // Act
        final authSchedule = jobsSchedule.toAuth();

        // Assert
        expect(authSchedule, isA<user.Schedule>());
        expect(authSchedule.id, equals(jobsSchedule.id));
        expect(authSchedule.name, equals(jobsSchedule.name));
      });
    });
  });
}
