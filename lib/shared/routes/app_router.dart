import 'package:equatable/equatable.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/shared_prefs_service.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/jobs/presentation/pages/home_page.dart';
import '../../injection_container.dart';

class AppRouter extends Equatable {
  const AppRouter._();

  static final GoRouter _router = GoRouter(
    redirect: (context, state) async {
      final token = await InjectionContainer.get<IAuthStorageService>().getToken();
      if (token == null) {
        return '/login';
      }
      final path = state.path;
      switch (path) {
        case '/login':
        case '/register':
        case '/forgot_password':
        case '/reset_password':
        case '/otp_verification':
        case null:
          return '/home';
      }
      return state.path;
    },
    routes: [
      GoRoute(path: '/login', name: 'login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/register', name: 'register', builder: (_, _) => const RegisterPage()),
      GoRoute(path: '/home', name: 'home', builder: (_, _) => const HomePage()),
      GoRoute(path: '/forgot_password', name: 'forgot_password', builder: (_, _) => const ForgotPasswordPage()),
      GoRoute(
        path: '/reset_password',
        name: 'reset_password',
        builder: (_, state) {
          final extra = state.extra as String;
          assert(extra.isNotEmpty, 'Reset Token is required for password reset');
          final resetToken = extra;
          return ResetPasswordPage(resetToken: resetToken);
        },
      ),
      GoRoute(
        path: '/otp_verification',
        name: 'otp_verification',
        builder: (_, state) {
          final extra = state.extra as String;
          assert(extra.isNotEmpty, 'Extra data is required for OTP verification');
          final email = extra;
          return OtpVerificationPage(email: email);
        },
      ),
      GoRoute(path: '/otp_verified', name: 'otp_verified', builder: (_, _) => const OtpVerifiedPage()),
    ],
  );

  static GoRouter get router => _router;

  @override
  List<Object?> get props => [];
}
