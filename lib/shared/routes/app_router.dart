import 'package:equatable/equatable.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/shared_prefs_service.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/jobs/presentation/pages/home_page.dart';
import '../../features/jobs/presentation/pages/job_detail_page.dart';
import '../../injection_container.dart';

class AppRouter extends Equatable {
  const AppRouter._();

  static const String homeName = 'home';

  static const String appliedName = 'applied';

  static const String savedName = 'saved';

  static const String profileName = 'profile';

  static const String loginName = 'login';

  static const String registerName = 'register';

  static const String forgotPasswordName = 'forgot_password';

  static const String resetPasswordName = 'reset_password';

  static const String otpVerificationName = 'otp_verification';

  static const String otpVerifiedName = 'otp_verified';

  static const String jobDetailName = 'job_detail';

  static const String homeRoute = '/';

  static const String loginRoute = '/$loginName';

  static const String registerRoute = '/$registerName';

  static const String forgotPasswordRoute = '/$forgotPasswordName';

  static const String resetPasswordRoute = '/$resetPasswordName';

  static const String otpVerificationRoute = '/$otpVerificationName';

  static const String otpVerifiedRoute = '/$otpVerifiedName';

  static const String appliedRoute = '/$appliedName';

  static const String savedRoute = '/$savedName';

  static const String profileRoute = '/$profileName';

  static const String jobDetailRoute = '/$jobDetailName/:id';

  static final GoRouter _router = GoRouter(
    redirect: (context, state) async {
      final token = await InjectionContainer.get<IAuthStorageService>().getToken();
      if (token == null) {
        return loginRoute;
      }
      final path = state.path;
      switch (path) {
        case loginRoute:
        case registerRoute:
        case forgotPasswordRoute:
        case resetPasswordRoute:
        case otpVerificationRoute:
        case otpVerifiedRoute:
        case null:
          return homeRoute;
      }
      return path;
    },
    routes: [
      GoRoute(path: loginRoute, name: loginName, builder: (_, _) => const LoginPage()),
      GoRoute(path: registerRoute, name: registerName, builder: (_, _) => const RegisterPage()),
      GoRoute(path: forgotPasswordRoute, name: forgotPasswordName, builder: (_, _) => const ForgotPasswordPage()),
      GoRoute(
        path: resetPasswordRoute,
        name: resetPasswordName,
        builder: (_, state) {
          final extra = state.extra as String;
          assert(extra.isNotEmpty, 'Reset Token is required for password reset');
          final resetToken = extra;
          return ResetPasswordPage(resetToken: resetToken);
        },
      ),
      GoRoute(
        path: otpVerificationRoute,
        name: otpVerificationName,
        builder: (_, state) {
          final extra = state.extra as String;
          assert(extra.isNotEmpty, 'Extra data is required for OTP verification');
          final email = extra;
          return OtpVerificationPage(email: email);
        },
      ),
      GoRoute(path: otpVerifiedRoute, name: otpVerifiedName, builder: (_, _) => const OtpVerifiedPage()),
      GoRoute(path: homeRoute, name: homeName, builder: (context, state) => const HomePage()),
      GoRoute(
        path: jobDetailRoute,
        name: homeName,
        builder: (context, state) => JobDetailPage(jobId: state.extra as int),
      ),
    ],
  );

  static GoRouter get router => _router;

  @override
  List<Object?> get props => [];
}
