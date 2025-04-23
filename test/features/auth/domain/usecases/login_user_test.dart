import 'package:dart_either/dart_either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobsit/core/error/failures.dart';
import 'package:jobsit/features/auth/domain/entities/user.dart';
import 'package:jobsit/features/auth/domain/repositories/auth_repository.dart';
import 'package:jobsit/features/auth/domain/usecases/login_user.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../core/error/failure.dart';
import 'login_user_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  group('Login User Test', () {
    late LoginUser loginUseCase;
    late MockAuthRepository mockAuthRepository;
    setUp(() {
      mockAuthRepository = MockAuthRepository();
      loginUseCase = LoginUser(mockAuthRepository);
    });
    setUpAll(() {
      provideDummy<Either<Failure, User>>(const Left(DummyFailure()));
    });
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    const tUser = User(
      idUser: 1,
      email: tEmail,
      role: 'ROLE_CANDIDATE',
      avatar: 'None',
    );
    const tLoginParams = LoginUserParams(email: tEmail, password: tPassword);
    test(
      'should get user from the repository when login is successful',
      () async {
        when(
          mockAuthRepository.loginUser(email: tEmail, password: tPassword),
        ).thenAnswer((_) async => const Right(tUser));
        final result = await loginUseCase(tLoginParams);
        expect(result, equals(const Right(tUser)));
        verify(
          await mockAuthRepository.loginUser(
            email: tEmail,
            password: tPassword,
          ),
        );
        verifyNoMoreInteractions(mockAuthRepository);
      },
    );
    test('should return a Failure when login fails', () async {
      const tFailure = ServerFailure('Server error');
      when(
        mockAuthRepository.loginUser(email: tEmail, password: tPassword),
      ).thenAnswer((_) async => const Left(tFailure));
      final result = await loginUseCase(tLoginParams);
      expect(result, equals(const Left(tFailure)));
      verify(
        await mockAuthRepository.loginUser(email: tEmail, password: tPassword),
      );
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
