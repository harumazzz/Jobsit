// ignore_for_file: lines_longer_than_80_chars

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
import '../../features/profile/presentation/pages/change_password_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../injection_container.dart';

part 'app_router.g.dart';

/// Defines the application's routes and navigation logic using GoRouter.
///
/// This class holds constants for route names and paths, and provides
/// access to the configured [GoRouter] instance.
class AppRouter extends Equatable {
  const AppRouter._();

  /// Name for the home route.
  static const String homeName = 'home';

  /// Name for the applied jobs route.
  static const String appliedName = 'applied';

  /// Name for the saved jobs route.
  static const String savedName = 'saved';

  /// Name for the profile route.
  static const String profileName = 'profile';

  /// Name for the login route.
  static const String loginName = 'login';

  /// Name for the register route.
  static const String registerName = 'register';

  /// Name for the forgot password route.
  static const String forgotPasswordName = 'forgot_password';

  /// Name for the reset password route.
  static const String resetPasswordName = 'reset_password';

  /// Name for the OTP verification route.
  static const String otpVerificationName = 'otp_verification';

  /// Name for the OTP verified route.
  static const String otpVerifiedName = 'otp_verified';

  /// Name for the job detail route.
  static const String jobDetailName = 'job_detail';

  /// Name for the change password route.
  static const String changePasswordName = 'change_password';

  /// Name for the edit profile route.
  static const String editProfileName = 'edit_profile';

  /// Name for the edit job information route.
  static const String editJobName = 'edit_job';

  /// Name for the forgot password OTP verification route.
  static const String forgotPasswordOtpName = 'forgot_password_otp';

  /// Path for the home route.
  static const String homeRoute = '/';

  /// Path for the login route.
  static const String loginRoute = '/$loginName';

  /// Path for the register route.
  static const String registerRoute = '/$registerName';

  /// Path for the forgot password route.
  static const String forgotPasswordRoute = '/$forgotPasswordName';

  /// Path for the reset password route.
  static const String resetPasswordRoute = '/$resetPasswordName';

  /// Path for the OTP verification route.
  static const String otpVerificationRoute = '/$otpVerificationName';

  /// Path for the OTP verified route.
  static const String otpVerifiedRoute = '/$otpVerifiedName';

  /// Path for the applied jobs route.
  static const String appliedRoute = '/$appliedName';

  /// Path for the saved jobs route.
  static const String savedRoute = '/$savedName';

  /// Path for the profile route.
  static const String profileRoute = '/$profileName';

  /// Path for the job detail route. Expects an 'id' parameter.
  static const String jobDetailRoute = '/$jobDetailName/:id';

  /// Path for the change password route.
  static const String changePasswordRoute = '/$changePasswordName';

  /// Path for the edit profile route.
  static const String editProfileRoute = '/$editProfileName';

  /// Path for the edit job information route.
  static const String editJobRoute = '/$editJobName';

  /// Path for the forgot password OTP verification route.
  static const String forgotPasswordOtpRoute = '/$forgotPasswordOtpName';

  /// The configured [GoRouter] instance for the application.
  static GoRouter get router => _router;

  @override
  List<Object?> get props => [];
}

/// Route data for the login page.
@TypedGoRoute<LoginRoute>(path: AppRouter.loginRoute, name: AppRouter.loginName)
final class LoginRoute extends GoRouteData with _$LoginRoute {
  /// Creates a [LoginRoute].
  const LoginRoute();

  @override
  Widget build(final BuildContext context, final GoRouterState state) => const LoginPage();
}

/// Route data for the registration page.
@TypedGoRoute<RegisterRoute>(path: AppRouter.registerRoute, name: AppRouter.registerName)
final class RegisterRoute extends GoRouteData with _$RegisterRoute {
  /// Creates a [RegisterRoute].
  const RegisterRoute();

  @override
  Widget build(final BuildContext context, final GoRouterState state) => const RegisterPage();
}

/// Route data for the forgot password page.
@TypedGoRoute<ForgotPasswordRoute>(path: AppRouter.forgotPasswordRoute, name: AppRouter.forgotPasswordName)
final class ForgotPasswordRoute extends GoRouteData with _$ForgotPasswordRoute {
  /// Creates a [ForgotPasswordRoute].
  const ForgotPasswordRoute();

  @override
  Widget build(final BuildContext context, final GoRouterState state) => const ForgotPasswordPage();
}

/// Route data for the reset password page.
@TypedGoRoute<ResetPasswordRoute>(path: AppRouter.resetPasswordRoute, name: AppRouter.resetPasswordName)
final class ResetPasswordRoute extends GoRouteData with _$ResetPasswordRoute {
  /// Creates a [ResetPasswordRoute].
  /// Requires a [resetToken] for password reset.
  const ResetPasswordRoute({required this.resetToken});

  /// The token required to reset the password.
  final String resetToken;

  @override
  Widget build(final BuildContext context, final GoRouterState state) => ResetPasswordPage(resetToken: resetToken);

  /// Creates a [ResetPasswordRoute] from an extra parameter.
  static ResetPasswordRoute fromExtra(final String extra) => ResetPasswordRoute(resetToken: extra);
}

/// Route data for the OTP verification page.
@TypedGoRoute<OtpVerificationRoute>(path: AppRouter.otpVerificationRoute, name: AppRouter.otpVerificationName)
final class OtpVerificationRoute extends GoRouteData with _$OtpVerificationRoute {
  /// Creates an [OtpVerificationRoute].
  /// Requires the [email] for which OTP is being verified.
  const OtpVerificationRoute({required this.email});

  /// The email address associated with the OTP verification.
  final String email;

  @override
  Widget build(final BuildContext context, final GoRouterState state) => OtpVerificationPage(email: email);

  /// Creates an [OtpVerificationRoute] from an extra parameter.
  static OtpVerificationRoute fromExtra(final String extra) => OtpVerificationRoute(email: extra);
}

/// Route data for the page shown after successful OTP verification.
@TypedGoRoute<OtpVerifiedRoute>(path: AppRouter.otpVerifiedRoute, name: AppRouter.otpVerifiedName)
final class OtpVerifiedRoute extends GoRouteData with _$OtpVerifiedRoute {
  /// Creates an [OtpVerifiedRoute].
  const OtpVerifiedRoute();

  @override
  Widget build(final BuildContext context, final GoRouterState state) => const OtpVerifiedPage();
}

/// Route data for the home page.
@TypedGoRoute<HomeRoute>(path: AppRouter.homeRoute, name: AppRouter.homeName)
final class HomeRoute extends GoRouteData with _$HomeRoute {
  /// Creates a [HomeRoute].
  const HomeRoute();

  @override
  Widget build(final BuildContext context, final GoRouterState state) => const HomePage();
}

/// Route data for the job detail page.
@TypedGoRoute<JobDetailRoute>(path: AppRouter.jobDetailRoute, name: AppRouter.jobDetailName)
final class JobDetailRoute extends GoRouteData with _$JobDetailRoute {
  /// Creates a [JobDetailRoute].
  /// Requires the [id] of the job to display.
  const JobDetailRoute({required this.id});

  /// The ID of the job.
  final int id;

  @override
  Widget build(final BuildContext context, final GoRouterState state) => JobDetailPage(jobId: id);
}

/// Route data for the change password page.
@TypedGoRoute<ChangePasswordRoute>(path: AppRouter.changePasswordRoute, name: AppRouter.changePasswordName)
final class ChangePasswordRoute extends GoRouteData with _$ChangePasswordRoute {
  /// Creates a [ChangePasswordRoute].
  const ChangePasswordRoute();

  @override
  Widget build(final BuildContext context, final GoRouterState state) => const ChangePasswordPage();
}

/// Route data for the edit personal information page.
@TypedGoRoute<EditProfileRoute>(path: AppRouter.editProfileRoute, name: AppRouter.editProfileName)
final class EditProfileRoute extends GoRouteData with _$EditProfileRoute {
  /// Creates an [EditProfileRoute].
  const EditProfileRoute();

  @override
  Widget build(final BuildContext context, final GoRouterState state) => const PersonalInfoEditPage();
}

/// Route data for the edit job information page.
@TypedGoRoute<EditJobRoute>(path: AppRouter.editJobRoute, name: AppRouter.editJobName)
final class EditJobRoute extends GoRouteData with _$EditJobRoute {
  /// Creates an [EditJobRoute].
  const EditJobRoute();

  @override
  Widget build(final BuildContext context, final GoRouterState state) => const JobInfoEditPage();
}

/// Route data for the forgot password OTP verification page.
@TypedGoRoute<VerifyForgotPasswordOTPRoute>(
  path: AppRouter.forgotPasswordOtpRoute,
  name: AppRouter.forgotPasswordOtpName,
)
final class VerifyForgotPasswordOTPRoute extends GoRouteData with _$VerifyForgotPasswordOTPRoute {
  /// Creates a [VerifyForgotPasswordOTPRoute].
  /// Requires the [email] for which the OTP is being verified.
  const VerifyForgotPasswordOTPRoute({required this.email});

  /// The email address associated with the forgot password OTP verification.
  final String email;

  @override
  Widget build(final BuildContext context, final GoRouterState state) => ForgotPasswordOTP(email: email);
}

final _router = GoRouter(
  routes: $appRoutes,
  initialLocation: AppRouter.loginRoute,
  debugLogDiagnostics: kDebugMode,
  redirect: (final context, final state) async {
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
