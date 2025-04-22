import 'package:equatable/equatable.dart';

class ApiConstant extends Equatable {
  const ApiConstant._();

  @override
  List<Object?> get props => [];

  static const String baseUrl = 'http://192.168.31.122:8085/api/';

  static const String loginEndpoint = '/login';

  static const String registerEndpoint = '/candidate';

  static const String sendOtpEndpoint = '/mail/active-user';

  static const String verifyOtpEndpoint = '/active';
}
