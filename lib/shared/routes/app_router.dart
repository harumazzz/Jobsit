import 'package:equatable/equatable.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/jobs/presentation/pages/home_page.dart';

class AppRouter extends Equatable {
  const AppRouter._();

  static final GoRouter config = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', name: 'login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/register', name: 'register', builder: (_, _) => const RegisterPage()),
      GoRoute(path: '/home', name: 'home', builder: (_, _) => const HomePage()),
      GoRoute(path: '/forgot_password', name: 'forgot_password', builder: (_, _) => const ForgotPasswordPage()),
      GoRoute(path: '/otp_verification', name: 'otp_verification', builder: (_, _) => const OtpVerificationPage()),
    ],
  );

  @override
  List<Object?> get props => [];
}
