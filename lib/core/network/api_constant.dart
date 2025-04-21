import 'package:equatable/equatable.dart';

class ApiConstant extends Equatable {
  const ApiConstant._();

  @override
  List<Object?> get props => [];

  static const String baseUrl = 'http://localhost:8085/api/';

  static const String loginEndpoint = '/login';

  static const String registerEndpoint = '/candidate';
}
