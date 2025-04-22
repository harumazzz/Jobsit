import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

final class InvalidEmailFailure extends Failure {
  const InvalidEmailFailure(super.message);
}

final class ShortPasswordFailure extends Failure {
  const ShortPasswordFailure(super.message);
}

final class Success extends Equatable {
  const Success();

  @override
  List<Object?> get props => [];
}
