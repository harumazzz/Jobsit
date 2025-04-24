import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/shared_prefs_service.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/jobs/presentation/pages/home_page.dart';
import '../../features/jobs/presentation/pages/job_detail_page.dart';
import '../../injection_container.dart';

part 'app_router.g.dart';

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

  static GoRouter get router => _router;

  @override
  List<Object?> get props => [];
}

@TypedGoRoute<LoginRoute>(path: AppRouter.loginRoute, name: AppRouter.loginName)
class LoginRoute extends GoRouteData {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const LoginPage();
}

@TypedGoRoute<RegisterRoute>(path: AppRouter.registerRoute, name: AppRouter.registerName)
class RegisterRoute extends GoRouteData {
  const RegisterRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const RegisterPage();
}

@TypedGoRoute<ForgotPasswordRoute>(path: AppRouter.forgotPasswordRoute, name: AppRouter.forgotPasswordName)
class ForgotPasswordRoute extends GoRouteData {
  const ForgotPasswordRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const ForgotPasswordPage();
}

@TypedGoRoute<ResetPasswordRoute>(path: AppRouter.resetPasswordRoute, name: AppRouter.resetPasswordName)
class ResetPasswordRoute extends GoRouteData {
  const ResetPasswordRoute({required this.resetToken});
  final String resetToken;

  @override
  Widget build(BuildContext context, GoRouterState state) => ResetPasswordPage(resetToken: resetToken);

  static ResetPasswordRoute fromExtra(String extra) => ResetPasswordRoute(resetToken: extra);
}

@TypedGoRoute<OtpVerificationRoute>(path: AppRouter.otpVerificationRoute, name: AppRouter.otpVerificationName)
class OtpVerificationRoute extends GoRouteData {
  const OtpVerificationRoute({required this.email});
  final String email;

  @override
  Widget build(BuildContext context, GoRouterState state) => OtpVerificationPage(email: email);

  static OtpVerificationRoute fromExtra(String extra) => OtpVerificationRoute(email: extra);
}

@TypedGoRoute<OtpVerifiedRoute>(path: AppRouter.otpVerifiedRoute, name: AppRouter.otpVerifiedName)
class OtpVerifiedRoute extends GoRouteData {
  const OtpVerifiedRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const OtpVerifiedPage();
}

@TypedGoRoute<HomeRoute>(path: AppRouter.homeRoute, name: AppRouter.homeName)
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomePage();
}

@TypedGoRoute<JobDetailRoute>(path: AppRouter.jobDetailRoute, name: AppRouter.jobDetailName)
class JobDetailRoute extends GoRouteData {
  const JobDetailRoute({required this.id});
  final int id;

  @override
  Widget build(BuildContext context, GoRouterState state) => JobDetailPage(jobId: id);
}

final _router = GoRouter(
  routes: $appRoutes,
  initialLocation: AppRouter.loginRoute,
  debugLogDiagnostics: kDebugMode,
  redirect: (context, state) async {
    final token = await InjectionContainer.get<IAuthStorageService>().getToken();
    final path = state.uri.toString();
    if (token != null) {
      switch (path) {
        case AppRouter.loginRoute:
        case AppRouter.registerRoute:
        case AppRouter.forgotPasswordRoute:
        case AppRouter.resetPasswordRoute:
        case AppRouter.otpVerificationRoute:
        case AppRouter.otpVerifiedRoute:
          return AppRouter.homeRoute;
      }
      return path;
    }
    return path;
  },
);
