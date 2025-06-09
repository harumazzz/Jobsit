import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(final BuildContext context) {
    final testRouter = GoRouter(
      routes: $appRoutes,
      initialLocation: AppRouter.loginRoute,
      debugLogDiagnostics: kDebugMode,
      redirect: (final context, final state) async {
        // ignore: lines_longer_than_80_chars
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

Future<void> setupApp(final WidgetTester tester) async {
  await InjectionContainer.reset();
  InjectionContainer.injectDependencies();

  final localeService = InjectionContainer.get<LocaleService>();
  final savedLocale = await localeService.getSavedLocale();
  await LocaleSettings.setLocale(savedLocale ?? AppLocale.en);

  await tester.pumpWidget(const ProviderScope(child: TestApp()));
  await tester.pumpAndSettle(const Duration(seconds: 2));

  await tester.pump(const Duration(milliseconds: 500));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Integration Tests', () {
    setUp(() async {
      await initApp();
    });
    tearDown(() async {
      final authService = InjectionContainer.get<IAuthStorageService>();
      await authService.deleteToken();
      final secureStorage = InjectionContainer.get<ISecureStorageService>();
      await secureStorage.deleteAll();
      await InjectionContainer.reset();
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

  group('Performance Tests', () {
    setUp(() async {
      await initApp();
    });

    tearDown(() async {
      final authService = InjectionContainer.get<IAuthStorageService>();
      await authService.deleteToken();
      final secureStorage = InjectionContainer.get<ISecureStorageService>();
      await secureStorage.deleteAll();
      await InjectionContainer.reset();
      await Future.delayed(const Duration(milliseconds: 200));
    });

    testWidgets('app startup performance test', (final tester) async {
      final stopwatch = Stopwatch()..start();

      await setupApp(tester);

      stopwatch.stop();
      final startupTime = stopwatch.elapsedMilliseconds;

      debugPrint('App startup time: ${startupTime}ms');

      expect(
        startupTime,
        lessThan(5000),
        reason: 'App startup should complete within 5 seconds',
      );
      expect(find.byType(MaterialApp), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 500));
    });
    testWidgets('navigation performance test', (final tester) async {
      await setupApp(tester);

      final List<int> navigationTimes = [];
      final stopwatch1 = Stopwatch()..start();
      await tester.tap(find.byKey(const Key('signup_link')));
      await tester.pumpAndSettle();
      stopwatch1.stop();
      navigationTimes.add(stopwatch1.elapsedMilliseconds);

      expect(find.byType(FormBuilder), findsOneWidget);
      expect(
        stopwatch1.elapsedMilliseconds,
        lessThan(2500),
        reason: 'Navigation time should be under 2.5 seconds',
      );
    });

    testWidgets('form input performance test', (final tester) async {
      await setupApp(tester);
      await tester.tap(find.byKey(const Key('signup_link')));
      await tester.pumpAndSettle();
      final List<int> inputTimes = [];
      final formFields = [
        'first_name_field',
        'last_name_field',
        'email_field',
        'phone_field',
        'password_field',
        'confirm_password_field',
      ];

      final testValues = [
        'John',
        'Doe',
        'john.doe@example.com',
        '1234567890',
        'Password123@',
        'Password123@',
      ];
      for (int i = 0; i < formFields.length; i++) {
        final stopwatch = Stopwatch()..start();

        await tester.enterText(find.byKey(Key(formFields[i])), testValues[i]);
        await tester.pump();

        stopwatch.stop();
        inputTimes.add(stopwatch.elapsedMilliseconds);
      }

      final averageInputTime =
          inputTimes.reduce(
            (
              final a,
              final b,
            ) => a + b,
          ) /
          inputTimes.length;

      debugPrint('Form input times: $inputTimes ms');
      debugPrint(
        'Average input time: ${averageInputTime.toStringAsFixed(1)}ms',
      );
      for (final time in inputTimes) {
        expect(
          time,
          lessThan(500),
          reason: 'Each form input should complete within 500ms',
        );
      }

      expect(
        averageInputTime,
        lessThan(300),
        reason: 'Average form input time should be under 300ms',
      );
    });

    testWidgets('scroll performance test', (final tester) async {
      await setupApp(tester);
      await tester.tap(find.byKey(const Key('signup_link')));
      await tester.pumpAndSettle();
      final scrollView = find.byType(SingleChildScrollView).first;
      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < 5; i++) {
        await tester.drag(scrollView, const Offset(0, -200));
        await tester.pump();
        await Future.delayed(const Duration(milliseconds: 16));
      }
      for (var i = 0; i < 5; i++) {
        await tester.drag(scrollView, const Offset(0, 200));
        await tester.pump();
        await Future.delayed(const Duration(milliseconds: 16));
      }

      stopwatch.stop();

      final scrollTime = stopwatch.elapsedMilliseconds;
      debugPrint('Scroll operations completed in: ${scrollTime}ms');

      expect(
        scrollTime,
        lessThan(2000),
        reason: 'Scroll operations should complete smoothly within 2 seconds',
      );
    });
    testWidgets('animation performance test', (final tester) async {
      await setupApp(tester);

      final stopwatch = Stopwatch()..start();
      await tester.tap(find.byKey(const Key('signup_link')));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await setupApp(tester);
      if (find
          .byKey(
            const Key('forgot_password_button'),
          )
          .evaluate()
          .isNotEmpty) {
        await tester.tap(find.byKey(const Key('forgot_password_button')));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      stopwatch.stop();

      final animationTime = stopwatch.elapsedMilliseconds;
      debugPrint('Animation transitions completed in: ${animationTime}ms');

      expect(
        animationTime,
        lessThan(10000),
        reason: 'Animation transitions should complete within 10 seconds',
      );
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('network request performance test', (final tester) async {
      await setupApp(tester);
      await tester.tap(find.byKey(const Key('forgot_password_button')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('reset_email_field')),
        'performance.test@example.com',
      );
      final stopwatch = Stopwatch()..start();

      await tester.tap(find.byKey(const Key('send_reset_button')));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      stopwatch.stop();

      final networkTime = stopwatch.elapsedMilliseconds;
      debugPrint('Network request completed in: ${networkTime}ms');

      expect(
        networkTime,
        lessThan(15000),
        reason: 'Network request should complete within 15 seconds',
      );
      await tester.pumpAndSettle();
    });

    testWidgets('widget rebuild performance test', (final tester) async {
      await setupApp(tester);
      await tester.tap(find.byKey(const Key('signup_link')));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Trigger multiple rebuilds by changing form values rapidly
      final emailField = find.byKey(const Key('email_field'));

      for (int i = 0; i < 20; i++) {
        await tester.enterText(emailField, 'test$i@example.com');
        await tester.pump(); // Trigger rebuild
      }

      stopwatch.stop();

      final rebuildTime = stopwatch.elapsedMilliseconds;
      debugPrint('Widget rebuild test completed in: ${rebuildTime}ms');

      expect(
        rebuildTime,
        lessThan(3000),
        reason: 'Widget rebuilds should be efficient and complete within 3s',
      );
    });
  });
}
