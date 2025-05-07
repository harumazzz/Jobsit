import 'package:dart_either/dart_either.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, RegisteredUser>> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  });

  Future<Either<Failure, User>> loginUser({required String email, required String password});

  Future<Either<Failure, Success>> sendMail({required String email});

  Future<Either<Failure, Success>> verifyEmail({required String otp});

  Future<Either<Failure, String>> checkEmail({required String email});

  Future<Either<Failure, Success>> forgotPassword({required String email});

  Future<Either<Failure, Success>> resetPassword({
    required String resetToken,
    required String password,
    required String confirmPassword,
  });

  Future<Either<Failure, String>> verifyOtp({required String otp});

  Future<Either<Failure, User>> getUser({required int userId});

  Future<Either<Failure, Success>> updateSearchableCandidate();

  Future<Either<Failure, Success>> updateEmailNotification();

  Future<Either<Failure, Success>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  });

  Future<Either<Failure, Success>> logOut();
}
