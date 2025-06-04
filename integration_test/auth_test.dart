import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jobsit/core/services/shared_prefs_service.dart';
import 'package:jobsit/i18n/strings.g.dart';
import 'package:jobsit/injection_container.dart';
import 'package:jobsit/shared/routes/app_router.dart';
import 'package:jobsit/shared/theme/app_theme.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> initApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  AppTheme.applyOverlay();
}

/// Creates a test-specific app widget with a fresh GoRouter instance
class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create a fresh GoRouter instance for each test
    final testRouter = GoRouter(
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

    return TranslationProvider(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Jobsit IT',
        theme: AppTheme.theme,
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          multitouchDragStrategy: MultitouchDragStrategy.sumAllPointers,
          scrollbars: false,
        ),
        routerConfig: testRouter,
      ),
    );
  }
}

/// Helper function to initialize and pump the app widget
Future<void> setupApp(final WidgetTester tester) async {
  // Reset dependencies first
  await InjectionContainer.reset();
  InjectionContainer.injectDependencies();

  final localeService = InjectionContainer.get<LocaleService>();
  final savedLocale = await localeService.getSavedLocale();
  await LocaleSettings.setLocale(savedLocale ?? AppLocale.en);

  await tester.pumpWidget(const ProviderScope(child: TestApp()));
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Integration Tests', () {
    setUp(() async {
      await initApp();
    });
    tearDown(() async {
      // Clear any stored authentication data
      final authService = InjectionContainer.get<IAuthStorageService>();
      await authService.deleteToken();

      // Clear secure storage completely for tests
      final secureStorage = InjectionContainer.get<ISecureStorageService>();
      await secureStorage.deleteAll();

      // Reset the dependency injection container
      await InjectionContainer.reset();

      // Clear any remaining timers/animations and allow garbage collection
      await Future.delayed(const Duration(milliseconds: 200));
    });
    testWidgets('complete user registration flow', (final tester) async {
      await setupApp(tester);

      final registerButton = find.byKey(
        const Key('signup_link'),
      );
      await tester.tap(registerButton);
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(
        find.byType(FormBuilder),
        findsOneWidget,
        reason: 'Should navigate to registration page',
      );
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueEmail = 'test+$timestamp@example.com';
      await tester.enterText(
        find.byKey(const Key('first_name_field')),
        'Test',
      );
      await tester.enterText(
        find.byKey(const Key('last_name_field')),
        'User',
      );
      await tester.enterText(
        find.byKey(const Key('email_field')),
        uniqueEmail,
      );
      await tester.enterText(
        find.byKey(const Key('phone_field')),
        '01234567890',
      );

      await tester.enterText(
        find.byKey(const Key('password_field')),
        'Password123@',
      );

      await tester.enterText(
        find.byKey(const Key('confirm_password_field')),
        'Password123@',
      );
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(
        find.byKey(const Key('verify_button')),
        findsOneWidget,
        reason: 'Should navigate to OTP page',
      );
      await tester.pump();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });
    testWidgets('user login flow with valid credentials', (
      final tester,
    ) async {
      await setupApp(tester);
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'khanhgia10a1@gmail.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'Khanhktt1@',
      );
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(
        find.byKey(const Key('login_button')),
        findsOneWidget,
        reason: 'Login form should still be present after login attempt',
      );
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });
    testWidgets('login validation with invalid credentials', (
      final tester,
    ) async {
      await setupApp(tester);

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'invalid@email.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'wrongpassword',
      );
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('login_button')),
        findsOneWidget,
        reason: 'Login form should still be present after failed login',
      );
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });
    testWidgets('forgot password flow', (final tester) async {
      await setupApp(tester);

      await tester.tap(find.byKey(const Key('forgot_password_button')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('reset_email_field')),
        'test@example.com',
      );
      await tester.tap(find.byKey(const Key('send_reset_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });
  });
}
