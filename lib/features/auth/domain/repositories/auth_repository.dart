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

  Future<Either<Failure, User>> loginUser({
    required String email,
    required String password,
  });
}
