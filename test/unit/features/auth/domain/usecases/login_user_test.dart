import 'package:dart_either/dart_either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobsit/core/error/failures.dart';
import 'package:jobsit/core/usecases/usecase.dart';
import 'package:jobsit/features/auth/domain/entities/user.dart';
import 'package:jobsit/features/auth/domain/repositories/auth_repository.dart';
import 'package:jobsit/features/auth/domain/usecases/login_user.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  setUpAll(() {
    mockAuthRepository = MockAuthRepository();
  });
  group('Login User Use Case', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    const tUser = User(
      userId: 1,
      role: 'USER',
      userInfo: UserInformation(
        firstName: 'John',
        lastName: 'Doe',
        email: tEmail,
        phone: '1234567890',
        address: '123 Main St',
        city: 'Anytown',
        gender: true,
        mailReceive: true,
        birthDate: '1/1/2000',
        district: 'Downtown',
      ),
      jobInfo: JobInformation(
        cv: 'cv.pdf',
        searchable: false,
        referenceLetter: 'reference.pdf',
        desiredJob: 'Software Engineer',
        desiredWorkingProvince: 'Province A',
        majors: [Major(id: 1, name: 'Computer Science')],
        positions: [],
        schedules: [],
        university: University(
          id: 1,
          name: 'University A',
        ),
      ),
    );
    const tLoginParams = LoginUserParams(email: tEmail, password: tPassword);
    test('should get user when login is successful', () async {
      when(
        () => mockAuthRepository.loginUser(
          email: tEmail,
          password: tPassword,
        ),
      ).thenAnswer((_) async => const Right(tUser));
      final result = await LoginUser(mockAuthRepository).call(tLoginParams);
      expect(result, const Right(tUser));
      verify(
        () => mockAuthRepository.loginUser(email: tEmail, password: tPassword),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
    test('should return error when login is not successful', () async {
      const tError = 'No Internet';
      when(
        () => mockAuthRepository.loginUser(
          email: tEmail,
          password: tPassword,
        ),
      ).thenAnswer((_) async => const Left(ServerFailure(tError)));
      final result = await LoginUser(mockAuthRepository).call(tLoginParams);
      expect(result, const Left(ServerFailure(tError)));
      verify(
        () => mockAuthRepository.loginUser(email: tEmail, password: tPassword),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
  group('Forgot Password Use Case', () {
    const tEmail = 'abc@gmail.com';
    test('should success if changing password is successful', () async {
      when(
        () => mockAuthRepository.forgotPassword(email: tEmail),
      ).thenAnswer((_) async => const Right(Success()));
      final result = await ForgotPassword(mockAuthRepository).call(tEmail);
      expect(result, const Right(Success()));
      verify(() => mockAuthRepository.forgotPassword(email: tEmail)).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
    test('should failure if changing password is failed', () async {
      const tError = 'No such email';
      when(
        () => mockAuthRepository.forgotPassword(email: tEmail),
      ).thenAnswer((_) async => const Left(ServerFailure(tError)));
      final result = await ForgotPassword(mockAuthRepository).call(tEmail);
      expect(result, const Left(ServerFailure(tError)));
      verify(() => mockAuthRepository.forgotPassword(email: tEmail)).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
  group('Verify OTP Use Case', () {
    const tOtp = '123456';
    test('should success if verify otp is successful', () async {
      const tMessage = 'OTP is verified';
      when(
        () => mockAuthRepository.verifyOtp(otp: tOtp),
      ).thenAnswer((_) async => const Right(tMessage));
      final result = await VerifyOtp(mockAuthRepository).call(tOtp);
      expect(result, const Right(tMessage));
      verify(() => mockAuthRepository.verifyOtp(otp: tOtp)).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
    test('should failure if verify otp is failed', () async {
      const tError = 'Authorization failed';
      when(
        () => mockAuthRepository.verifyOtp(otp: tOtp),
      ).thenAnswer((_) async => const Left(ServerFailure(tError)));
      final result = await VerifyOtp(mockAuthRepository).call(tOtp);
      expect(result, const Left(ServerFailure(tError)));
      verify(() => mockAuthRepository.verifyOtp(otp: tOtp)).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
  group('Reset Password Use Case', () {
    const tPassword = 'abc123';
    const resetToken = 'abc';
    const params = ResetPasswordParams(
      resetToken: resetToken,
      confirmPassword: tPassword,
      password: tPassword,
    );
    test('should success if reset password is successful', () async {
      when(
        () => mockAuthRepository.resetPassword(
          resetToken: resetToken,
          password: tPassword,
          confirmPassword: tPassword,
        ),
      ).thenAnswer((_) async => const Right(Success()));
      final result = await ResetPassword(mockAuthRepository).call(params);
      expect(result, const Right(Success()));
      verify(
        () => mockAuthRepository.resetPassword(
          resetToken: resetToken,
          password: tPassword,
          confirmPassword: tPassword,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
    test('should failure if reset password is failed', () async {
      const tError = 'Authorization failed';
      when(
        () => mockAuthRepository.resetPassword(
          resetToken: resetToken,
          password: tPassword,
          confirmPassword: tPassword,
        ),
      ).thenAnswer((_) async => const Left(ServerFailure(tError)));
      final result = await ResetPassword(mockAuthRepository).call(params);
      expect(result, const Left(ServerFailure(tError)));
      verify(
        () => mockAuthRepository.resetPassword(
          resetToken: resetToken,
          password: tPassword,
          confirmPassword: tPassword,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
  group('Get User Data Use Case', () {
    const tEmail = 'test@example.com';
    const tId = 1;
    const tUser = User(
      userId: tId,
      role: 'USER',
      userInfo: UserInformation(
        firstName: 'John',
        lastName: 'Doe',
        email: tEmail,
        phone: '1234567890',
        address: '123 Main St',
        city: 'Anytown',
        gender: true,
        mailReceive: true,
        birthDate: '1/1/2000',
        district: 'Downtown',
      ),
      jobInfo: JobInformation(
        cv: 'cv.pdf',
        searchable: false,
        referenceLetter: 'reference.pdf',
        desiredJob: 'Software Engineer',
        desiredWorkingProvince: 'Province A',
        majors: [Major(id: 1, name: 'Computer Science')],
        positions: [],
        schedules: [],
        university: University(
          id: 1,
          name: 'University A',
        ),
      ),
    );
    test('should get user when login is successful', () async {
      when(
        () => mockAuthRepository.getUser(userId: tId),
      ).thenAnswer((_) async => const Right(tUser));
      final result = await GetUserData(mockAuthRepository).call(tId);
      expect(result, const Right(tUser));
      verify(
        () => mockAuthRepository.getUser(userId: tId),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
    test('should return error when login is not successful', () async {
      const tError = 'No Internet';
      when(
        () => mockAuthRepository.getUser(userId: tId),
      ).thenAnswer((_) async => const Left(ServerFailure(tError)));
      final result = await GetUserData(mockAuthRepository).call(tId);
      expect(result, const Left(ServerFailure(tError)));
      verify(
        () => mockAuthRepository.getUser(userId: tId),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
  group('Update Searchable Candidate', () {
    const nil = NoParams();
    test('should success if update is successful', () async {
      when(
        () => mockAuthRepository.updateSearchableCandidate(),
      ).thenAnswer((_) async => const Right(Success()));
      final result = await UpdateSearchableCandidateUseCase(
        mockAuthRepository,
      ).call(nil);
      expect(result, const Right(Success()));
      verify(() => mockAuthRepository.updateSearchableCandidate()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
    test('should failure if update is failed', () async {
      const tError = 'Authorization failed';
      when(
        () => mockAuthRepository.updateSearchableCandidate(),
      ).thenAnswer((_) async => const Left(ServerFailure(tError)));
      final result = await UpdateSearchableCandidateUseCase(
        mockAuthRepository,
      ).call(nil);
      expect(result, const Left(ServerFailure(tError)));
      verify(() => mockAuthRepository.updateSearchableCandidate()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
  group('Update Email Notification', () {
    const nil = NoParams();
    test('should success if update is successful', () async {
      when(
        () => mockAuthRepository.updateEmailNotification(),
      ).thenAnswer((_) async => const Right(Success()));
      final result = await UpdateEmailNotificationUseCase(
        mockAuthRepository,
      ).call(nil);
      expect(result, const Right(Success()));
      verify(() => mockAuthRepository.updateEmailNotification()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
    test('should failure if update is failed', () async {
      const tError = 'Authorization failed';
      when(
        () => mockAuthRepository.updateEmailNotification(),
      ).thenAnswer((_) async => const Left(ServerFailure(tError)));
      final result = await UpdateEmailNotificationUseCase(
        mockAuthRepository,
      ).call(nil);
      expect(result, const Left(ServerFailure(tError)));
      verify(() => mockAuthRepository.updateEmailNotification()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
  group('Logout Use Case', () {
    const nil = NoParams();
    test('should success if logout is successful', () async {
      when(
        () => mockAuthRepository.logOut(),
      ).thenAnswer((_) async => const Right(Success()));
      final result = await LogOutUseCase(mockAuthRepository).call(nil);
      expect(result, const Right(Success()));
      verify(() => mockAuthRepository.logOut()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
    test('should failure if logout is failed', () async {
      const tError = 'Cannot logout';
      when(
        () => mockAuthRepository.logOut(),
      ).thenAnswer((_) async => const Left(ServerFailure(tError)));
      final result = await LogOutUseCase(mockAuthRepository).call(nil);
      expect(result, const Left(ServerFailure(tError)));
      verify(() => mockAuthRepository.logOut()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
  group('Change Password Use Case', () {
    const tPassword = 'abc123';
    const tNewPassword = 'abc';
    const params = ChangePasswordParams(
      oldPassword: tPassword,
      newPassword: tNewPassword,
      confirmPassword: tNewPassword,
    );
    test('should success if change password is successful', () async {
      when(
        () => mockAuthRepository.changePassword(
          oldPassword: tPassword,
          newPassword: tNewPassword,
          confirmPassword: tNewPassword,
        ),
      ).thenAnswer((_) async => const Right(Success()));
      final result = await ChangePasswordUseCase(
        mockAuthRepository,
      ).call(params);
      expect(result, const Right(Success()));
      verify(
        () => mockAuthRepository.changePassword(
          oldPassword: tPassword,
          newPassword: tNewPassword,
          confirmPassword: tNewPassword,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
    test('should failure if change password is failed', () async {
      const tError = 'Authorization failed';
      when(
        () => mockAuthRepository.changePassword(
          oldPassword: tPassword,
          newPassword: tNewPassword,
          confirmPassword: tNewPassword,
        ),
      ).thenAnswer((_) async => const Left(ServerFailure(tError)));
      final result = await ChangePasswordUseCase(
        mockAuthRepository,
      ).call(params);
      expect(result, const Left(ServerFailure(tError)));
      verify(
        () => mockAuthRepository.changePassword(
          oldPassword: tPassword,
          newPassword: tNewPassword,
          confirmPassword: tNewPassword,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
  group('Update User Info Use Case', () {
    const tFirstName = 'John';
    const tLastName = 'Doe';
    const tBirthDay = '1990-01-01';
    const tPhone = '1234567890';
    const tGender = 1;
    const tLocation = '123 Main St';
    const tCity = 'Anytown';
    const tDistrict = 'Downtown';
    const tUniversity = University(id: 1, name: 'A');
    const tUpdatedUser = User(
      userId: 1,
      role: 'USER',
      userInfo: UserInformation(
        firstName: tFirstName,
        lastName: tLastName,
        email: 'test@example.com',
        phone: tPhone,
        address: tLocation,
        city: tCity,
        gender: tGender == 1,
        mailReceive: true,
        birthDate: tBirthDay,
        district: tDistrict,
      ),
      jobInfo: JobInformation(
        cv: 'cv.pdf',
        searchable: false,
        referenceLetter: 'reference.pdf',
        desiredJob: 'Software Engineer',
        desiredWorkingProvince: 'Province A',
        majors: [Major(id: 1, name: 'Computer Science')],
        positions: [],
        schedules: [],
        university: tUniversity,
      ),
    );
    const params = UpdateUserInfoParams(
      firstName: tFirstName,
      lastName: tLastName,
      birthDay: tBirthDay,
      phone: tPhone,
      gender: 1,
      location: tLocation,
      city: tCity,
      district: tDistrict,
      university: tUniversity,
    );

    test('should success if update user info is successful', () async {
      when(
        () => mockAuthRepository.updateUserInfo(
          firstName: tFirstName,
          lastName: tLastName,
          birthDay: tBirthDay,
          phone: tPhone,
          gender: tGender,
          location: tLocation,
          city: tCity,
          district: tDistrict,
          university: tUniversity,
        ),
      ).thenAnswer((_) async => const Right(tUpdatedUser));
      final result = await UpdateUserInfoUseCase(
        mockAuthRepository,
      ).call(params);
      expect(result, const Right(tUpdatedUser));
      verify(
        () => mockAuthRepository.updateUserInfo(
          firstName: tFirstName,
          lastName: tLastName,
          birthDay: tBirthDay,
          phone: tPhone,
          gender: tGender,
          location: tLocation,
          city: tCity,
          district: tDistrict,
          university: tUniversity,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should failure if update user info is failed', () async {
      const tError = 'Update failed';
      when(
        () => mockAuthRepository.updateUserInfo(
          firstName: tFirstName,
          lastName: tLastName,
          birthDay: tBirthDay,
          phone: tPhone,
          gender: tGender,
          location: tLocation,
          city: tCity,
          district: tDistrict,
          university: tUniversity,
        ),
      ).thenAnswer((_) async => const Left(ServerFailure(tError)));
      final result = await UpdateUserInfoUseCase(
        mockAuthRepository,
      ).call(params);
      expect(result, const Left(ServerFailure(tError)));
      verify(
        () => mockAuthRepository.updateUserInfo(
          firstName: tFirstName,
          lastName: tLastName,
          birthDay: tBirthDay,
          phone: tPhone,
          gender: tGender,
          location: tLocation,
          city: tCity,
          district: tDistrict,
          university: tUniversity,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
  group('Update Job Info Use Case', () {
    const tDesiredJob = 'Software Engineer';
    const tDesiredWorkingProvince = 'Province A';
    const tReferenceLetter = 'reference.pdf';
    const tPositions = [Position(id: 1, name: 'Developer')];
    const tMajors = [Major(id: 1, name: 'Computer Science')];
    const tSchedules = [Schedule(id: 1, name: 'Full Time')];

    const tUpdatedUser = User(
      userId: 1,
      role: 'USER',
      userInfo: UserInformation(
        firstName: 'John',
        lastName: 'Doe',
        email: 'test@example.com',
        phone: '1234567890',
        address: '123 Main St',
        city: 'Anytown',
        gender: true,
        mailReceive: true,
        birthDate: '1990-01-01',
        district: 'Downtown',
      ),
      jobInfo: JobInformation(
        cv: 'cv.pdf',
        searchable: false,
        referenceLetter: tReferenceLetter,
        desiredJob: tDesiredJob,
        desiredWorkingProvince: tDesiredWorkingProvince,
        majors: tMajors,
        positions: tPositions,
        schedules: tSchedules,
        university: University(
          id: 1,
          name: 'University A',
        ),
      ),
    );
    const params = UpdateJobInfoParams(
      desiredJob: tDesiredJob,
      desiredWorkingProvince: tDesiredWorkingProvince,
      referenceLetter: tReferenceLetter,
      positions: tPositions,
      majors: tMajors,
      schedules: tSchedules,
    );
    test('should success if update job info is successful', () async {
      when(
        () => mockAuthRepository.updateJobInfo(
          desiredJob: tDesiredJob,
          desiredWorkingProvince: tDesiredWorkingProvince,
          referenceLetter: tReferenceLetter,
          positions: tPositions,
          majors: tMajors,
          schedules: tSchedules,
        ),
      ).thenAnswer((_) async => const Right(tUpdatedUser));
      final result = await UpdateJobInfoUseCase(
        mockAuthRepository,
      ).call(params);
      expect(result, const Right(tUpdatedUser));
      verify(
        () => mockAuthRepository.updateJobInfo(
          desiredJob: tDesiredJob,
          desiredWorkingProvince: tDesiredWorkingProvince,
          referenceLetter: tReferenceLetter,
          positions: tPositions,
          majors: tMajors,
          schedules: tSchedules,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
    test('should failure if update job info is failed', () async {
      const tError = 'Update job info failed';
      when(
        () => mockAuthRepository.updateJobInfo(
          desiredJob: tDesiredJob,
          desiredWorkingProvince: tDesiredWorkingProvince,
          referenceLetter: tReferenceLetter,
          positions: tPositions,
          majors: tMajors,
          schedules: tSchedules,
        ),
      ).thenAnswer((_) async => const Left(ServerFailure(tError)));
      final result = await UpdateJobInfoUseCase(
        mockAuthRepository,
      ).call(params);
      expect(result, const Left(ServerFailure(tError)));
      verify(
        () => mockAuthRepository.updateJobInfo(
          desiredJob: tDesiredJob,
          desiredWorkingProvince: tDesiredWorkingProvince,
          referenceLetter: tReferenceLetter,
          positions: tPositions,
          majors: tMajors,
          schedules: tSchedules,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
  group('Get University Usecase', () {
    const nil = NoParams();
    const universities = [
      University(id: 1, name: 'A'),
      University(id: 2, name: 'B'),
    ];
    test('should success if update is successful', () async {
      when(
        () => mockAuthRepository.getUniversities(),
      ).thenAnswer((_) async => const Right(universities));
      final result = await GetUniversityUseCase(
        mockAuthRepository,
      ).call(nil);
      expect(result, const Right(universities));
      verify(() => mockAuthRepository.getUniversities()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
    test('should failure if update is failed', () async {
      const tError = 'Authorization failed';
      when(
        () => mockAuthRepository.getUniversities(),
      ).thenAnswer((_) async => const Left(ServerFailure(tError)));
      final result = await GetUniversityUseCase(
        mockAuthRepository,
      ).call(nil);
      expect(result, const Left(ServerFailure(tError)));
      verify(() => mockAuthRepository.getUniversities()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
