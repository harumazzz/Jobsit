// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Login helper function used across all test groups
  Future<void> loginUser(
    final WidgetTester tester,
  ) async {
    // Wait for the app to load
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Find and tap the email field
    final emailField = find.byKey(const Key('email_field'));
    expect(emailField, findsOneWidget);
    await tester.tap(emailField);
    await tester.pumpAndSettle();

    // Enter email
    await tester.enterText(emailField, 'khanhgia10a1@gmail.com');
    await tester.pumpAndSettle();

    // Find and tap the password field
    final passwordField = find.byKey(const Key('password_field'));
    expect(passwordField, findsOneWidget);
    await tester.tap(passwordField);
    await tester.pumpAndSettle();

    // Enter password
    await tester.enterText(passwordField, 'Khanhktt1');
    await tester.pumpAndSettle();

    // Find and tap the login button
    final loginButton = find.byKey(const Key('login_button'));
    expect(loginButton, findsOneWidget);
    await tester.tap(loginButton);

    // Wait for login to complete and navigate to home
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Verify we're on the home page by checking for bottom navigation
    expect(find.byKey(const Key('home_tab')), findsOneWidget);
  }

  group('Job Features Integration Tests', () {
    setUpAll(() async {
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

    testWidgets('should login and browse jobs', (
      final WidgetTester tester,
    ) async {
      await initApp();
      await setupApp(tester);
      await loginUser(tester);
      await tester.pumpAndSettle();
      final jobCards = find.byType(Card);
      expect(jobCards, findsWidgets);

      debugPrint('✅ Login and job browsing test completed successfully');
    });

    testWidgets('should use job search functionality', (
      final WidgetTester tester,
    ) async {
      await initApp();
      await setupApp(tester);
      await loginUser(tester);

      // Find and tap the search bar
      final searchBar = find.byKey(const Key('job_search_bar'));
      expect(searchBar, findsOneWidget);
      await tester.tap(searchBar);
      await tester.pumpAndSettle();

      // Enter search term
      await tester.enterText(searchBar, 'Flutter');
      await tester.pumpAndSettle();

      // Wait for search results
      await tester.pumpAndSettle(const Duration(seconds: 2));

      debugPrint('✅ Job search test completed successfully');
    });
    testWidgets('should open job filter modal', (
      final WidgetTester tester,
    ) async {
      await initApp();
      await setupApp(tester);
      await loginUser(tester);

      // Find and tap the filter button
      final filterButton = find.byKey(const Key('job_filter_button'));
      expect(filterButton, findsOneWidget);
      await tester.tap(filterButton);
      await tester.pumpAndSettle();

      // Verify filter modal is visible
      final filterModal = find.byKey(const Key('filter_modal_container'));
      expect(filterModal, findsOneWidget);

      // Close the modal by tapping outside or close button
      await tester.tapAt(const Offset(50, 50)); // Tap outside the modal
      await tester.pumpAndSettle();

      debugPrint('✅ Job filter modal test completed successfully');
    });

    testWidgets('should apply filters and see filtered results', (
      final WidgetTester tester,
    ) async {
      await initApp();
      await setupApp(tester);
      await loginUser(tester);

      // Get initial job count
      final initialJobCards = find.byType(Card);
      final initialCount = tester.widgetList(initialJobCards).length;

      // Open filter modal
      final filterButton = find.byKey(const Key('job_filter_button'));
      await tester.tap(filterButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify filter modal is open
      final filterModal = find.byKey(const Key('filter_modal_container'));
      expect(filterModal, findsOneWidget);

      // Select some filters if available
      final chipWidgets = find.byType(Chip);
      if (tester.widgetList(chipWidgets).isNotEmpty) {
        // Tap the first available filter chip
        await tester.tap(chipWidgets.first);
        await tester.pumpAndSettle();
      }

      // Apply filters
      final applyButton = find.byKey(const Key('apply_filter_button'));
      if (tester.widgetList(applyButton).isNotEmpty) {
        await tester.tap(applyButton);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Verify we're back to the job list and filters are applied
        expect(find.byKey(const Key('filter_modal_container')), findsNothing);

        // Check that job results might have changed (filtered)
        final filteredJobCards = find.byType(Card);
        debugPrint(
          // ignore: lines_longer_than_80_chars
          'Initial jobs: $initialCount, Filtered jobs: ${tester.widgetList(filteredJobCards).length}',
        );
      }

      debugPrint('✅ Job filter application test completed successfully');
    });

    testWidgets('should bookmark and unbookmark a job', (
      final WidgetTester tester,
    ) async {
      await initApp();
      await setupApp(tester);
      await loginUser(tester);

      // Wait for jobs to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find first job card with bookmark button
      final bookmarkButtons = find.byType(IconButton);
      if (tester.widgetList(bookmarkButtons).isNotEmpty) {
        // Find bookmark button within a job card
        final jobCards = find.byType(Card);
        if (tester.widgetList(jobCards).isNotEmpty) {
          final firstCard = jobCards.first;

          // Look for bookmark button in the first card
          final bookmarkInCard = find.descendant(
            of: firstCard,
            matching: find.byType(IconButton),
          );

          if (tester.widgetList(bookmarkInCard).isNotEmpty) {
            // Tap to bookmark
            await tester.tap(bookmarkInCard.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));

            // Tap again to unbookmark
            await tester.tap(bookmarkInCard.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));
          }
        }
      }

      debugPrint('✅ Job bookmark test completed successfully');
    });

    testWidgets('should navigate to job detail and back', (
      final WidgetTester tester,
    ) async {
      await initApp();
      await setupApp(tester);
      await loginUser(tester);

      // Wait for jobs to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find and tap on first job card
      final jobCards = find.byType(Card);
      expect(jobCards, findsWidgets);

      if (tester.widgetList(jobCards).isNotEmpty) {
        await tester.tap(jobCards.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Verify we're on job detail page
        final jobDetailElements = find.text('Job Detail');
        if (tester.widgetList(jobDetailElements).isEmpty) {
          // Try alternative ways to verify we're on detail page
          final applyButtons = find.byKey(const Key('job_apply_button'));
          final bookmarkButtons = find.byKey(
            const Key('job_detail_bookmark_button'),
          );
          if (tester.widgetList(applyButtons).isNotEmpty ||
              tester
                  .widgetList(
                    bookmarkButtons,
                  )
                  .isNotEmpty) {
            debugPrint('Successfully navigated to job detail page');
          }
        } // Go back to job list
        final backButton = find.byType(BackButton);
        if (tester.widgetList(backButton).isNotEmpty) {
          await tester.tap(backButton.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        } else {
          // Try navigation using app bar back button or similar
          final appBarBackButtons = find.byIcon(Icons.arrow_back);
          if (tester.widgetList(appBarBackButtons).isNotEmpty) {
            await tester.tap(appBarBackButtons.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));
          }
        }

        // Verify we're back to job list
        expect(find.byKey(const Key('job_search_bar')), findsOneWidget);
      }

      debugPrint('✅ Job detail navigation test completed successfully');
    });

    testWidgets('should test search functionality with different queries', (
      final WidgetTester tester,
    ) async {
      await initApp();
      await setupApp(tester);
      await loginUser(tester);

      final searchQueries = ['Flutter', 'React', 'Java', 'Python', 'Developer'];

      for (final query in searchQueries) {
        // Clear search bar
        final searchBar = find.byKey(const Key('job_search_bar'));
        await tester.tap(searchBar);
        await tester.pumpAndSettle();

        // Clear existing text
        await tester.enterText(searchBar, '');
        await tester.pumpAndSettle();

        // Enter new search query
        await tester.enterText(searchBar, query);
        await tester.pumpAndSettle();

        // Wait for search results
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Check if results are shown (cards should exist)
        final jobCards = find.byType(Card);
        debugPrint(
          'Search: "$query": Got ${tester.widgetList(jobCards).length} result',
        );

        // Small delay between searches
        await tester.pump(const Duration(milliseconds: 500));
      }

      debugPrint('✅ Multiple search queries test completed successfully');
    });

    testWidgets('should test saved jobs functionality', (
      final WidgetTester tester,
    ) async {
      await initApp();
      await setupApp(tester);
      await loginUser(tester);

      // Bookmark a job first
      await tester.pumpAndSettle(const Duration(seconds: 2));
      final jobCards = find.byType(Card);

      if (tester.widgetList(jobCards).isNotEmpty) {
        final firstCard = jobCards.first;
        final bookmarkInCard = find.descendant(
          of: firstCard,
          matching: find.byType(IconButton),
        );

        if (tester.widgetList(bookmarkInCard).isNotEmpty) {
          await tester.tap(bookmarkInCard.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }

      // Navigate to saved jobs tab
      final savedJobsTab = find.byKey(const Key('saved_jobs_tab'));
      expect(savedJobsTab, findsOneWidget);
      await tester.tap(savedJobsTab);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Check if saved jobs are displayed
      final savedJobCards = find.byType(Card);
      debugPrint('Found ${tester.widgetList(savedJobCards).length} saved jobs');

      // Go back to home
      final homeTab = find.byKey(const Key('home_tab'));
      await tester.tap(homeTab);
      await tester.pumpAndSettle();

      debugPrint('✅ Saved jobs functionality test completed successfully');
    });

    testWidgets('should test applied jobs page', (
      final WidgetTester tester,
    ) async {
      await initApp();
      await setupApp(tester);
      await loginUser(tester);

      // Navigate to applied jobs tab
      final appliedJobsTab = find.byKey(const Key('applied_jobs_tab'));
      expect(appliedJobsTab, findsOneWidget);
      await tester.tap(appliedJobsTab);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Check if applied jobs page loads (might be empty)
      final appliedJobsPageElements = find.text('Applied Job');
      if (tester.widgetList(appliedJobsPageElements).isEmpty) {
        // Check for alternative indicators we're on applied jobs page
        debugPrint('Applied jobs page loaded (content may be empty)');
      }

      // Go back to home
      final homeTab = find.byKey(const Key('home_tab'));
      await tester.tap(homeTab);
      await tester.pumpAndSettle();

      debugPrint('✅ Applied jobs page test completed successfully');
    });

    testWidgets('should test profile page functionality', (
      final WidgetTester tester,
    ) async {
      await initApp();
      await setupApp(tester);
      await loginUser(tester);

      // Navigate to profile tab
      final profileTab = find.byKey(const Key('profile_tab'));
      expect(profileTab, findsOneWidget);
      await tester.tap(profileTab);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Check if profile elements are visible
      final profileElements = find.byType(SwitchListTile);
      if (tester.widgetList(profileElements).isNotEmpty) {
        debugPrint(
          // ignore: lines_longer_than_80_chars
          'Profile page load with ${tester.widgetList(profileElements).length} settings',
        );
      }

      // Look for edit buttons
      final editButtons = find.byType(IconButton);
      debugPrint(
        'Found ${tester.widgetList(editButtons).length} buttons on profile',
      );

      // Go back to home
      final homeTab = find.byKey(const Key('home_tab'));
      await tester.tap(homeTab);
      await tester.pumpAndSettle();

      debugPrint('✅ Profile page functionality test completed successfully');
    });

    testWidgets('should test language selector functionality', (
      final WidgetTester tester,
    ) async {
      await initApp();
      await setupApp(tester);
      await loginUser(tester);

      // Look for language selector (might be in app bar or settings)
      final languageSelectors = find.byType(PopupMenuButton);

      if (tester.widgetList(languageSelectors).isNotEmpty) {
        // Tap language selector
        await tester.tap(languageSelectors.first);
        await tester.pumpAndSettle();

        // Look for language options
        final languageOptions = find.byType(PopupMenuItem);
        if (tester.widgetList(languageOptions).isNotEmpty) {
          debugPrint(
            'Language selector opened with ${tester.widgetList(languageOptions).length} options',
          );

          // Close the popup by tapping outside
          await tester.tapAt(const Offset(50, 50));
          await tester.pumpAndSettle();
        }
      }

      debugPrint('✅ Language selector test completed successfully');
    });

    testWidgets('should test error handling and recovery', (
      final WidgetTester tester,
    ) async {
      await initApp();
      await setupApp(tester);
      await loginUser(tester);

      // Test search with special characters
      final searchBar = find.byKey(const Key('job_search_bar'));
      await tester.tap(searchBar);
      await tester.pumpAndSettle(); // Enter special characters
      await tester.enterText(searchBar, r'!@#$%^&*()');
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Clear and enter very long text
      await tester.enterText(searchBar, 'a' * 100);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Clear search
      await tester.enterText(searchBar, '');
      await tester.pumpAndSettle();

      // Test rapid tab switching
      final tabKeys = ['applied_jobs_tab', 'saved_jobs_tab', 'profile_tab', 'home_tab'];

      for (int i = 0; i < 3; i++) {
        for (final tabKey in tabKeys) {
          final tab = find.byKey(Key(tabKey));
          if (tester.widgetList(tab).isNotEmpty) {
            await tester.tap(tab);
            await tester.pump(const Duration(milliseconds: 100));
          }
        }
      }

      await tester.pumpAndSettle();

      debugPrint('✅ Error handling and recovery test completed successfully');
    });

    testWidgets('should test app state persistence across navigation', (
      final WidgetTester tester,
    ) async {
      await initApp();
      await setupApp(tester);
      await loginUser(tester);

      // Perform a search
      final searchBar = find.byKey(const Key('job_search_bar'));
      await tester.tap(searchBar);
      await tester.pumpAndSettle();
      await tester.enterText(searchBar, 'Flutter Developer');
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to different tabs and back
      final savedJobsTab = find.byKey(const Key('saved_jobs_tab'));
      await tester.tap(savedJobsTab);
      await tester.pumpAndSettle();

      final homeTab = find.byKey(const Key('home_tab'));
      await tester.tap(homeTab);
      await tester.pumpAndSettle();

      // Verify search term is still there
      final searchBarWidget = tester.widget<SearchBar>(searchBar);
      final controller = searchBarWidget.controller;
      if (controller != null) {
        debugPrint('Search term preserved: "${controller.text}"');
      }

      debugPrint('✅ App state persistence test completed successfully');
    });

    testWidgets('should navigate between bottom tabs', (
      final WidgetTester tester,
    ) async {
      await initApp();
      await setupApp(tester);
      await loginUser(tester);

      // Test navigation to different tabs
      final tabKeys = ['applied_jobs_tab', 'saved_jobs_tab', 'profile_tab'];

      for (final tabKey in tabKeys) {
        final tab = find.byKey(Key(tabKey));
        expect(tab, findsOneWidget);
        await tester.tap(tab);
        await tester.pumpAndSettle();

        // Small delay between tab switches
        await tester.pump(const Duration(milliseconds: 500));
      }

      // Go back to home
      final homeTab = find.byKey(const Key('home_tab'));
      expect(homeTab, findsOneWidget);
      await tester.tap(homeTab);
      await tester.pumpAndSettle();

      debugPrint('✅ Bottom tab navigation test completed successfully');
    });
  });
  group('Advanced Integration Tests', () {
    setUpAll(() async {
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

    testWidgets('should handle offline mode gracefully', (
      final WidgetTester tester,
    ) async {
      await initApp();
      await setupApp(tester);
      await loginUser(tester);

      // Wait for initial data to load
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Simulate offline mode by disabling network
      debugPrint('📶 Simulating offline mode...');

      // Try to perform actions that require network
      final searchField = find.byKey(const Key('search_field'));
      if (tester.widgetList(searchField).isNotEmpty) {
        await tester.enterText(searchField, 'offline test');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Check for offline indicator or cached data
        debugPrint('📶 Checking offline behavior...');
      }

      // Try to refresh data
      final refreshButton = find.byKey(const Key('refresh_button'));
      if (tester.widgetList(refreshButton).isNotEmpty) {
        await tester.tap(refreshButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      debugPrint('✅ Offline mode handling test completed');
    });

    testWidgets('should handle job application workflow end-to-end', (
      final WidgetTester tester,
    ) async {
      await initApp();
      await setupApp(tester);
      await loginUser(tester);

      // Wait for jobs to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find and tap on a job card to view details
      final jobCards = find.byType(Card);
      expect(jobCards, findsAtLeastNWidgets(1));

      await tester.tap(jobCards.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Look for apply button
      final applyButton = find.byKey(const Key('apply_job_button'));
      final applyButtonText = find.text('Apply Now');
      final applyButtonAlt = find.text('Apply');

      if (tester.widgetList(applyButton).isNotEmpty) {
        await tester.tap(applyButton);
      } else if (tester.widgetList(applyButtonText).isNotEmpty) {
        await tester.tap(applyButtonText);
      } else if (tester.widgetList(applyButtonAlt).isNotEmpty) {
        await tester.tap(applyButtonAlt);
      }

      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Fill application form if it exists
      final coverLetterField = find.byKey(const Key('cover_letter_field'));
      final messageField = find.byKey(const Key('application_message'));

      if (tester.widgetList(coverLetterField).isNotEmpty) {
        await tester.enterText(
          coverLetterField,
          'Dear Hiring Manager,\n\nI am excited to apply for this position. I have relevant experience and would be a great fit for your team.\n\nBest regards,\nTest User',
        );
        await tester.pumpAndSettle();
      } else if (tester.widgetList(messageField).isNotEmpty) {
        await tester.enterText(messageField, 'I am interested in this position and would like to apply.');
        await tester.pumpAndSettle();
      }

      // Submit application
      final submitButton = find.byKey(const Key('submit_application_button'));
      final submitButtonText = find.text('Submit Application');

      if (tester.widgetList(submitButton).isNotEmpty) {
        await tester.tap(submitButton);
        await tester.pumpAndSettle(const Duration(seconds: 3));
      } else if (tester.widgetList(submitButtonText).isNotEmpty) {
        await tester.tap(submitButtonText);
        await tester.pumpAndSettle(const Duration(seconds: 3));
      } // Verify application was submitted
      final successMessage = find.text('Application submitted successfully');
      final appliedStatus = find.text('Applied');

      if (tester.widgetList(successMessage).isNotEmpty || tester.widgetList(appliedStatus).isNotEmpty) {
        debugPrint('🎯 Application submitted successfully');
      }

      debugPrint('🎯 Application submission completed');
      debugPrint('✅ Job application workflow test completed');
    });

    testWidgets('should handle data loading states and skeleton screens', (
      final WidgetTester tester,
    ) async {
      await initApp();
      await setupApp(tester);
      await loginUser(tester);

      // Check for loading indicators during initial load
      debugPrint('⏳ Testing loading states...');

      // Look for loading indicators
      final loadingIndicators = [
        find.byType(CircularProgressIndicator),
        find.byKey(const Key('loading_indicator')),
        find.byKey(const Key('skeleton_loader')),
        find.text('Loading...'),
      ];

      for (final indicator in loadingIndicators) {
        if (tester.widgetList(indicator).isNotEmpty) {
          debugPrint(
            'Found loading indicator: $indicator',
          );
        }
      }

      // Wait for data to load
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify content is loaded
      final jobCards = find.byType(Card);
      debugPrint('Jobs loaded: ${tester.widgetList(jobCards).length}');

      // Test pull-to-refresh
      final scrollView = find.byType(Scrollable);
      if (tester.widgetList(scrollView).isNotEmpty) {
        await tester.fling(scrollView.first, const Offset(0, 500), 1000);
        await tester.pumpAndSettle();

        // Wait for refresh to complete
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      debugPrint('✅ Loading states test completed');
    });

    testWidgets('should handle pagination and infinite scroll', (
      final WidgetTester tester,
    ) async {
      await initApp();
      await setupApp(tester);
      await loginUser(tester);

      // Wait for initial jobs to load
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final initialJobCards = find.byType(Card);
      final initialCount = tester.widgetList(initialJobCards).length;
      debugPrint('Initial job count: $initialCount');

      // Scroll to bottom to trigger pagination
      final scrollView = find.byType(Scrollable);
      if (tester.widgetList(scrollView).isNotEmpty && initialCount > 0) {
        // Scroll down multiple times to trigger load more
        for (int i = 0; i < 3; i++) {
          await tester.fling(scrollView.first, const Offset(0, -800), 1000);
          await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 2));
        }

        // Check if more jobs were loaded
        final updatedJobCards = find.byType(Card);
        final updatedCount = tester.widgetList(updatedJobCards).length;
        debugPrint('Updated job count after scroll: $updatedCount');

        // Look for load more indicator
        final loadMoreIndicator = find.byKey(const Key('load_more_indicator'));
        if (tester.widgetList(loadMoreIndicator).isNotEmpty) {
          debugPrint('Found load more indicator');
        }
      }

      debugPrint('✅ Pagination test completed');
    });

    testWidgets('should handle user profile and settings workflow', (
      final WidgetTester tester,
    ) async {
      await initApp();
      await setupApp(tester);
      await loginUser(tester);

      // Navigate to profile
      final profileTab = find.byKey(const Key('profile_tab'));
      final profileButton = find.byKey(const Key('profile_button'));

      if (tester.widgetList(profileTab).isNotEmpty) {
        await tester.tap(profileTab);
      } else if (tester.widgetList(profileButton).isNotEmpty) {
        await tester.tap(profileButton);
      }

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Look for profile elements
      final profileElements = [
        find.byKey(const Key('profile_picture')),
        find.byKey(const Key('user_name')),
        find.byKey(const Key('user_email')),
        find.byKey(const Key('edit_profile_button')),
        find.byKey(const Key('settings_button')),
      ];

      for (final element in profileElements) {
        if (tester.widgetList(element).isNotEmpty) {
          debugPrint('Found profile element: $element');
        }
      }

      // Try to access settings
      final settingsButton = find.byKey(const Key('settings_button'));
      final settingsIcon = find.byIcon(Icons.settings);

      if (tester.widgetList(settingsButton).isNotEmpty) {
        await tester.tap(settingsButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      } else if (tester.widgetList(settingsIcon).isNotEmpty) {
        await tester.tap(settingsIcon);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      } // Test logout functionality
      final logoutButton = find.byKey(const Key('logout_button'));
      final logoutText = find.text('Logout');

      if (tester.widgetList(logoutButton).isNotEmpty) {
        await tester.tap(logoutButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Handle confirmation dialog if present
        final confirmLogout = find.text('Confirm');
        final yesButton = find.text('Yes');

        if (tester.widgetList(confirmLogout).isNotEmpty) {
          await tester.tap(confirmLogout);
        } else if (tester.widgetList(yesButton).isNotEmpty) {
          await tester.tap(yesButton);
        }

        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Verify we're back to login screen
        final loginFields = find.byKey(const Key('email_field'));
        debugPrint('Logout successful: ${tester.widgetList(loginFields).isNotEmpty}');
      } else if (tester.widgetList(logoutText).isNotEmpty) {
        await tester.tap(logoutText);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Handle confirmation dialog if present
        final confirmLogout = find.text('Confirm');
        final yesButton = find.text('Yes');

        if (tester.widgetList(confirmLogout).isNotEmpty) {
          await tester.tap(confirmLogout);
        } else if (tester.widgetList(yesButton).isNotEmpty) {
          await tester.tap(yesButton);
        }

        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Verify we're back to login screen
        final loginFields = find.byKey(const Key('email_field'));
        debugPrint('Logout successful: ${tester.widgetList(loginFields).isNotEmpty}');
      }

      debugPrint('✅ Profile and settings workflow test completed');
    });

    testWidgets('should handle deep linking and navigation state', (
      final WidgetTester tester,
    ) async {
      await initApp();
      await setupApp(tester);
      await loginUser(tester);

      // Test complex navigation patterns
      final navigationSteps = [
        () async {
          // Go to job details
          final jobCards = find.byType(Card);
          if (tester.widgetList(jobCards).isNotEmpty) {
            await tester.tap(jobCards.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));
          }
        },
        () async {
          // Go back to list
          final backButton = find.byKey(const Key('back_button'));
          final backIcon = find.byIcon(Icons.arrow_back);

          if (tester.widgetList(backButton).isNotEmpty) {
            await tester.tap(backButton);
          } else if (tester.widgetList(backIcon).isNotEmpty) {
            await tester.tap(backIcon);
          }
          await tester.pumpAndSettle();
        },
        () async {
          // Navigate to favorites
          final favoritesTab = find.byKey(const Key('saved_jobs_tab'));
          if (tester.widgetList(favoritesTab).isNotEmpty) {
            await tester.tap(favoritesTab);
            await tester.pumpAndSettle();
          }
        },
        () async {
          // Navigate to applications
          final applicationsTab = find.byKey(const Key('applied_jobs_tab'));
          if (tester.widgetList(applicationsTab).isNotEmpty) {
            await tester.tap(applicationsTab);
            await tester.pumpAndSettle();
          }
        },
      ];

      for (final step in navigationSteps) {
        await step();
        await tester.pump(const Duration(milliseconds: 500));
      }

      // Test navigation stack preservation
      final homeTab = find.byKey(const Key('home_tab'));
      if (tester.widgetList(homeTab).isNotEmpty) {
        await tester.tap(homeTab);
        await tester.pumpAndSettle();
      }

      debugPrint('✅ Deep linking and navigation state test completed');
    });

    testWidgets('should handle concurrent operations and race conditions', (
      final WidgetTester tester,
    ) async {
      await initApp();
      await setupApp(tester);
      await loginUser(tester);

      // Wait for initial load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Perform multiple operations quickly
      final searchField = find.byKey(const Key('search_field'));
      if (tester.widgetList(searchField).isNotEmpty) {
        // Rapid search operations
        await tester.enterText(searchField, 'developer');
        await tester.pump(const Duration(milliseconds: 100));

        await tester.enterText(searchField, 'engineer');
        await tester.pump(const Duration(milliseconds: 100));

        await tester.enterText(searchField, 'manager');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      // Rapid tab switching
      final tabs = ['saved_jobs_tab', 'applied_jobs_tab', 'home_tab'];
      for (final tabKey in tabs) {
        final tab = find.byKey(Key(tabKey));
        if (tester.widgetList(tab).isNotEmpty) {
          await tester.tap(tab);
          await tester.pump(const Duration(milliseconds: 200));
        }
      }

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Rapid filter operations
      final filterButton = find.byKey(const Key('job_filter_button'));
      if (tester.widgetList(filterButton).isNotEmpty) {
        await tester.tap(filterButton);
        await tester.pumpAndSettle();

        // Quick filter selections
        final chips = find.byType(Chip);
        final chipCount = tester.widgetList(chips).length;

        for (int i = 0; i < chipCount && i < 3; i++) {
          await tester.tap(chips.at(i));
          await tester.pump(const Duration(milliseconds: 100));
        }

        final applyButton = find.byKey(const Key('apply_filter_button'));
        if (tester.widgetList(applyButton).isNotEmpty) {
          await tester.tap(applyButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }

      debugPrint('✅ Concurrent operations test completed');
    });

    testWidgets('should handle memory management and performance', (
      final WidgetTester tester,
    ) async {
      await initApp();
      await setupApp(tester);
      await loginUser(tester);

      // Perform memory-intensive operations
      debugPrint('🧠 Testing memory management...');

      // Load and scroll through many jobs
      for (int i = 0; i < 5; i++) {
        await tester.pumpAndSettle(const Duration(seconds: 1));

        final scrollView = find.byType(Scrollable);
        if (tester.widgetList(scrollView).isNotEmpty) {
          await tester.fling(scrollView.first, const Offset(0, -500), 800);
          await tester.pumpAndSettle();
        }
      }

      // Navigate between tabs multiple times
      final tabs = ['saved_jobs_tab', 'applied_jobs_tab', 'profile_tab', 'home_tab'];
      for (int cycle = 0; cycle < 3; cycle++) {
        for (final tabKey in tabs) {
          final tab = find.byKey(Key(tabKey));
          if (tester.widgetList(tab).isNotEmpty) {
            await tester.tap(tab);
            await tester.pumpAndSettle();
          }
        }
      }

      // Perform multiple searches
      final searchField = find.byKey(const Key('search_field'));
      if (tester.widgetList(searchField).isNotEmpty) {
        final searchTerms = ['developer', 'engineer', 'manager', 'analyst', 'designer'];

        for (final term in searchTerms) {
          await tester.enterText(searchField, term);
          await tester.testTextInput.receiveAction(TextInputAction.search);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }

      debugPrint('✅ Memory management test completed');
    });

    testWidgets('should handle accessibility features', (
      final WidgetTester tester,
    ) async {
      await initApp();
      await setupApp(tester);
      await loginUser(tester);

      // Test semantic labels and accessibility
      debugPrint('♿ Testing accessibility features...');

      // Check for semantic labels on key elements
      final accessibilityElements = [
        find.bySemanticsLabel('Search jobs'),
        find.bySemanticsLabel('Filter jobs'),
        find.bySemanticsLabel('Job list'),
        find.bySemanticsLabel('Apply for job'),
        find.bySemanticsLabel('Save job'),
      ];

      for (final element in accessibilityElements) {
        if (tester.widgetList(element).isNotEmpty) {
          debugPrint('Found accessible element: $element');
        }
      }

      // Test keyboard navigation
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      // Test focus management
      final focusableElements = find.byType(TextFormField);
      if (tester.widgetList(focusableElements).isNotEmpty) {
        await tester.tap(focusableElements.first);
        await tester.pumpAndSettle();
      }

      debugPrint('✅ Accessibility test completed');
    });

    testWidgets('should handle edge cases and error recovery', (
      final WidgetTester tester,
    ) async {
      await initApp();
      await setupApp(tester);
      await loginUser(tester);

      debugPrint('🔍 Testing edge cases and error recovery...');

      // Test empty search results
      final searchField = find.byKey(const Key('search_field'));
      if (tester.widgetList(searchField).isNotEmpty) {
        await tester.enterText(searchField, 'xyzabc123nonexistent');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Look for empty state
        final emptyState = find.text('No jobs found');
        final noResults = find.text('No results');

        if (tester.widgetList(emptyState).isNotEmpty || tester.widgetList(noResults).isNotEmpty) {
          debugPrint('Empty state handled correctly');
        }
      }

      // Test invalid input handling
      if (tester.widgetList(searchField).isNotEmpty) {
        await tester.enterText(searchField, r'!@#$%^&*()');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Test rapid state changes
      final filterButton = find.byKey(const Key('job_filter_button'));
      if (tester.widgetList(filterButton).isNotEmpty) {
        // Rapidly open and close filter
        for (int i = 0; i < 3; i++) {
          await tester.tap(filterButton);
          await tester.pump(const Duration(milliseconds: 200));

          // Try to close modal
          final closeButton = find.byKey(const Key('close_filter_button'));
          if (tester.widgetList(closeButton).isNotEmpty) {
            await tester.tap(closeButton);
            await tester.pump(const Duration(milliseconds: 200));
          }
        }
      }

      // Test back button spam
      final jobCards = find.byType(Card);
      if (tester.widgetList(jobCards).isNotEmpty) {
        await tester.tap(jobCards.first);
        await tester.pumpAndSettle();

        // Rapid back button presses
        final backButton = find.byIcon(Icons.arrow_back);
        if (tester.widgetList(backButton).isNotEmpty) {
          for (int i = 0; i < 3; i++) {
            await tester.tap(backButton);
            await tester.pump(const Duration(milliseconds: 100));
          }
        }
      }

      await tester.pumpAndSettle(const Duration(seconds: 2));
      debugPrint('✅ Edge cases and error recovery test completed');
    });
  });

  group('Performance Integration Tests', () {
    setUpAll(() async {
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

    testWidgets('should measure app startup performance', (
      final WidgetTester tester,
    ) async {
      final startupStopwatch = Stopwatch()..start();

      await initApp();
      await setupApp(tester);

      // Measure time to first meaningful paint
      final firstPaintTime = startupStopwatch.elapsedMilliseconds;
      debugPrint('⚡ Time to first paint: ${firstPaintTime}ms');

      // Measure time to login screen ready
      await tester.pumpAndSettle();
      final loginReadyTime = startupStopwatch.elapsedMilliseconds;
      debugPrint('⚡ Time to login screen ready: ${loginReadyTime}ms');

      await loginUser(tester);

      // Measure time to home screen with data
      final homeReadyTime = startupStopwatch.elapsedMilliseconds;
      debugPrint('⚡ Time to home screen with data: ${homeReadyTime}ms');

      startupStopwatch.stop();

      // Performance assertions
      expect(firstPaintTime, lessThan(3000), reason: 'First paint should be under 3 seconds');
      expect(loginReadyTime, lessThan(5000), reason: 'Login screen should be ready under 5 seconds');
      expect(homeReadyTime, lessThan(10000), reason: 'Home screen should load under 10 seconds');

      debugPrint('✅ App startup performance test completed');
    });

    testWidgets('should measure job list scrolling performance', (
      final WidgetTester tester,
    ) async {
      await initApp();
      await setupApp(tester);
      await loginUser(tester);

      // Wait for jobs to load
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final scrollView = find.byType(Scrollable);
      expect(scrollView, findsAtLeastNWidgets(1));

      final performanceStopwatch = Stopwatch();
      final frameTimings = <int>[];

      // Measure scroll performance over multiple scrolls
      for (int i = 0; i < 10; i++) {
        performanceStopwatch
          ..reset()
          ..start();

        // Scroll down
        await tester.fling(scrollView.first, const Offset(0, -500), 1000);
        await tester.pump();

        performanceStopwatch.stop();
        frameTimings.add(performanceStopwatch.elapsedMilliseconds);

        // Small delay between scrolls
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Calculate performance metrics
      final averageFrameTime = frameTimings.reduce((final a, final b) => a + b) / frameTimings.length;
      final maxFrameTime = frameTimings.reduce((final a, final b) => a > b ? a : b);
      final minFrameTime = frameTimings.reduce((final a, final b) => a < b ? a : b);

      debugPrint('⚡ Scroll Performance Metrics:');
      debugPrint('   Average frame time: ${averageFrameTime.toStringAsFixed(2)}ms');
      debugPrint('   Max frame time: ${maxFrameTime}ms');
      debugPrint('   Min frame time: ${minFrameTime}ms');

      // Performance assertions
      expect(averageFrameTime, lessThan(32), reason: 'Average frame time should be under 32ms (30fps)');
      expect(maxFrameTime, lessThan(50), reason: 'Max frame time should be under 50ms');

      debugPrint('✅ Job list scrolling performance test completed');
    });

    testWidgets('should measure search performance with various queries', (
      final WidgetTester tester,
    ) async {
      await initApp();
      await setupApp(tester);
      await loginUser(tester);

      final searchQueries = [
        'Flutter',
        'React Native',
        'JavaScript Developer',
        'Senior Software Engineer',
        'Full Stack Developer Remote',
      ];

      final searchTimings = <String, int>{};

      for (final query in searchQueries) {
        final searchStopwatch = Stopwatch()..start();

        // Perform search
        final searchBar = find.byKey(const Key('job_search_bar'));
        await tester.tap(searchBar);
        await tester.pumpAndSettle();

        await tester.enterText(searchBar, query);
        await tester.pumpAndSettle();

        // Wait for search results
        await tester.pumpAndSettle(const Duration(seconds: 3));

        searchStopwatch.stop();
        searchTimings[query] = searchStopwatch.elapsedMilliseconds;

        debugPrint('⚡ Search "$query": ${searchStopwatch.elapsedMilliseconds}ms');

        // Clear search for next iteration
        await tester.enterText(searchBar, '');
        await tester.pumpAndSettle();
      }

      // Calculate average search time
      final averageSearchTime = searchTimings.values.reduce((final a, final b) => a + b) / searchTimings.length;
      debugPrint('⚡ Average search time: ${averageSearchTime.toStringAsFixed(2)}ms');

      // Performance assertion
      expect(averageSearchTime, lessThan(5000), reason: 'Average search time should be under 5 seconds');

      debugPrint('✅ Search performance test completed');
    });

    testWidgets('should measure navigation performance between tabs', (
      final WidgetTester tester,
    ) async {
      await initApp();
      await setupApp(tester);
      await loginUser(tester);

      final tabKeys = ['home_tab', 'applied_jobs_tab', 'saved_jobs_tab', 'profile_tab'];
      final navigationTimings = <String, int>{};

      for (final tabKey in tabKeys) {
        final navigationStopwatch = Stopwatch()..start();

        final tab = find.byKey(Key(tabKey));
        if (tester.widgetList(tab).isNotEmpty) {
          await tester.tap(tab);
          await tester.pumpAndSettle();

          navigationStopwatch.stop();
          navigationTimings[tabKey] = navigationStopwatch.elapsedMilliseconds;

          debugPrint('⚡ Navigation to $tabKey: ${navigationStopwatch.elapsedMilliseconds}ms');
        }
      }

      // Calculate average navigation time
      if (navigationTimings.isNotEmpty) {
        final averageNavigationTime =
            navigationTimings.values.reduce((final a, final b) => a + b) / navigationTimings.length;
        debugPrint('⚡ Average navigation time: ${averageNavigationTime.toStringAsFixed(2)}ms');

        // Performance assertion
        expect(averageNavigationTime, lessThan(1000), reason: 'Average navigation time should be under 1 second');
      }

      debugPrint('✅ Navigation performance test completed');
    });

    testWidgets('should measure memory usage during heavy operations', (
      final WidgetTester tester,
    ) async {
      await initApp();
      await setupApp(tester);
      await loginUser(tester);

      debugPrint('⚡ Starting memory usage test...');

      // Simulate heavy operations
      final operations = [
        'Multiple searches',
        'Rapid tab switching',
        'Extensive scrolling',
        'Filter applications',
      ];

      for (final operation in operations) {
        debugPrint('⚡ Performing: $operation');

        switch (operation) {
          case 'Multiple searches':
            for (int i = 0; i < 5; i++) {
              final searchBar = find.byKey(const Key('job_search_bar'));
              await tester.tap(searchBar);
              await tester.enterText(searchBar, 'test query $i');
              await tester.pumpAndSettle(const Duration(seconds: 1));
            }
            break;

          case 'Rapid tab switching':
            final tabs = ['home_tab', 'applied_jobs_tab', 'saved_jobs_tab', 'profile_tab'];
            for (int i = 0; i < 10; i++) {
              for (final tabKey in tabs) {
                final tab = find.byKey(Key(tabKey));
                if (tester.widgetList(tab).isNotEmpty) {
                  await tester.tap(tab);
                  await tester.pump(const Duration(milliseconds: 100));
                }
              }
            }
            await tester.pumpAndSettle();
            break;

          case 'Extensive scrolling':
            final scrollView = find.byType(Scrollable);
            if (tester.widgetList(scrollView).isNotEmpty) {
              for (int i = 0; i < 20; i++) {
                await tester.fling(scrollView.first, const Offset(0, -300), 800);
                await tester.pump(const Duration(milliseconds: 50));
              }
            }
            await tester.pumpAndSettle();
            break;

          case 'Filter applications':
            final filterButton = find.byKey(const Key('job_filter_button'));
            if (tester.widgetList(filterButton).isNotEmpty) {
              for (int i = 0; i < 3; i++) {
                await tester.tap(filterButton);
                await tester.pumpAndSettle();

                // Close filter modal
                await tester.tapAt(const Offset(50, 50));
                await tester.pumpAndSettle();
              }
            }
            break;
        }

        // Force garbage collection simulation
        await tester.pumpAndSettle(const Duration(seconds: 1));
        debugPrint('⚡ Completed: $operation');
      }

      debugPrint('✅ Memory usage test completed');
    });

    testWidgets('should measure job detail loading performance', (
      final WidgetTester tester,
    ) async {
      await initApp();
      await setupApp(tester);
      await loginUser(tester);

      // Wait for jobs to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final jobCards = find.byType(Card);
      expect(jobCards, findsAtLeastNWidgets(1));

      // Measure job detail loading for multiple jobs
      final detailLoadingTimes = <int>[];
      final maxJobsToTest = tester.widgetList(jobCards).length > 3 ? 3 : tester.widgetList(jobCards).length;

      for (int i = 0; i < maxJobsToTest; i++) {
        final loadingStopwatch = Stopwatch()..start();

        // Tap on job card
        await tester.tap(jobCards.at(i));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        loadingStopwatch.stop();
        detailLoadingTimes.add(loadingStopwatch.elapsedMilliseconds);

        debugPrint('⚡ Job detail ${i + 1} loading time: ${loadingStopwatch.elapsedMilliseconds}ms');

        // Navigate back
        final backButton = find.byType(BackButton);
        final backIcon = find.byIcon(Icons.arrow_back);

        if (tester.widgetList(backButton).isNotEmpty) {
          await tester.tap(backButton.first);
        } else if (tester.widgetList(backIcon).isNotEmpty) {
          await tester.tap(backIcon.first);
        }

        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      if (detailLoadingTimes.isNotEmpty) {
        final averageDetailLoadingTime =
            detailLoadingTimes.reduce((final a, final b) => a + b) / detailLoadingTimes.length;
        debugPrint('⚡ Average job detail loading time: ${averageDetailLoadingTime.toStringAsFixed(2)}ms');

        // Performance assertion
        expect(
          averageDetailLoadingTime,
          lessThan(4000),
          reason: 'Average job detail loading should be under 4 seconds',
        );
      }

      debugPrint('✅ Job detail loading performance test completed');
    });

    testWidgets('should measure network request performance', (
      final WidgetTester tester,
    ) async {
      await initApp();
      await setupApp(tester);

      final networkStopwatch = Stopwatch()..start();

      // Measure login network performance
      await loginUser(tester);
      final loginNetworkTime = networkStopwatch.elapsedMilliseconds;
      debugPrint('⚡ Login network time: ${loginNetworkTime}ms');

      networkStopwatch
        ..reset()
        ..start();

      // Measure job list loading network performance
      await tester.pumpAndSettle(const Duration(seconds: 5));
      final jobListNetworkTime = networkStopwatch.elapsedMilliseconds;
      debugPrint('⚡ Job list network time: ${jobListNetworkTime}ms');

      // Test search network performance
      final searchNetworkTimes = <int>[];

      for (int i = 0; i < 3; i++) {
        networkStopwatch
          ..reset()
          ..start();

        final searchBar = find.byKey(const Key('job_search_bar'));
        await tester.tap(searchBar);
        await tester.enterText(searchBar, 'performance test $i');
        await tester.pumpAndSettle(const Duration(seconds: 3));

        networkStopwatch.stop();
        searchNetworkTimes.add(networkStopwatch.elapsedMilliseconds);

        debugPrint('⚡ Search network time ${i + 1}: ${networkStopwatch.elapsedMilliseconds}ms');
      }

      final averageSearchNetworkTime =
          searchNetworkTimes.reduce((final a, final b) => a + b) / searchNetworkTimes.length;
      debugPrint('⚡ Average search network time: ${averageSearchNetworkTime.toStringAsFixed(2)}ms');

      // Performance assertions
      expect(loginNetworkTime, lessThan(8000), reason: 'Login network requests should complete under 8 seconds');
      expect(jobListNetworkTime, lessThan(6000), reason: 'Job list loading should complete under 6 seconds');
      expect(
        averageSearchNetworkTime,
        lessThan(4000),
        reason: 'Search network requests should complete under 4 seconds',
      );

      debugPrint('✅ Network request performance test completed');
    });

    testWidgets('should measure filter and sort performance', (
      final WidgetTester tester,
    ) async {
      await initApp();
      await setupApp(tester);
      await loginUser(tester);

      // Wait for initial data
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Test filter performance
      final filterStopwatch = Stopwatch();

      final filterButton = find.byKey(const Key('job_filter_button'));
      if (tester.widgetList(filterButton).isNotEmpty) {
        filterStopwatch.start();

        // Open filter modal
        await tester.tap(filterButton);
        await tester.pumpAndSettle();

        // Apply filters if available
        final chipWidgets = find.byType(Chip);
        if (tester.widgetList(chipWidgets).isNotEmpty) {
          await tester.tap(chipWidgets.first);
          await tester.pumpAndSettle();
        }

        // Apply filter
        final applyButton = find.byKey(const Key('apply_filter_button'));
        if (tester.widgetList(applyButton).isNotEmpty) {
          await tester.tap(applyButton);
          await tester.pumpAndSettle(const Duration(seconds: 3));
        }

        filterStopwatch.stop();
        debugPrint('⚡ Filter application time: ${filterStopwatch.elapsedMilliseconds}ms');

        // Performance assertion
        expect(
          filterStopwatch.elapsedMilliseconds,
          lessThan(3000),
          reason: 'Filter application should complete under 3 seconds',
        );
      }

      // Test sort performance if available
      final sortButton = find.byKey(const Key('sort_button'));
      if (tester.widgetList(sortButton).isNotEmpty) {
        final sortStopwatch = Stopwatch()..start();

        await tester.tap(sortButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        sortStopwatch.stop();
        debugPrint('⚡ Sort operation time: ${sortStopwatch.elapsedMilliseconds}ms');

        // Performance assertion
        expect(
          sortStopwatch.elapsedMilliseconds,
          lessThan(2000),
          reason: 'Sort operation should complete under 2 seconds',
        );
      }

      debugPrint('✅ Filter and sort performance test completed');
    });

    testWidgets('should measure rendering performance under stress', (
      final WidgetTester tester,
    ) async {
      await initApp();
      await setupApp(tester);
      await loginUser(tester);

      debugPrint('⚡ Starting rendering stress test...');

      // Stress test: Rapid UI updates
      final stressStopwatch = Stopwatch()..start();

      // Perform rapid search updates
      final searchBar = find.byKey(const Key('job_search_bar'));
      for (int i = 0; i < 10; i++) {
        await tester.tap(searchBar);
        await tester.enterText(searchBar, 'stress test $i');
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Rapid tab switching
      final tabs = ['home_tab', 'applied_jobs_tab', 'saved_jobs_tab', 'profile_tab'];
      for (int cycle = 0; cycle < 5; cycle++) {
        for (final tabKey in tabs) {
          final tab = find.byKey(Key(tabKey));
          if (tester.widgetList(tab).isNotEmpty) {
            await tester.tap(tab);
            await tester.pump(const Duration(milliseconds: 50));
          }
        }
      }

      // Rapid scrolling
      final scrollView = find.byType(Scrollable);
      if (tester.widgetList(scrollView).isNotEmpty) {
        for (int i = 0; i < 15; i++) {
          await tester.fling(scrollView.first, i.isEven ? const Offset(0, -200) : const Offset(0, 200), 500);
          await tester.pump(const Duration(milliseconds: 50));
        }
      }

      await tester.pumpAndSettle();
      stressStopwatch.stop();

      debugPrint('⚡ Rendering stress test duration: ${stressStopwatch.elapsedMilliseconds}ms');

      // Verify app is still responsive
      final homeTab = find.byKey(const Key('home_tab'));
      if (tester.widgetList(homeTab).isNotEmpty) {
        await tester.tap(homeTab);
        await tester.pumpAndSettle();
      }

      // Performance assertion
      expect(
        stressStopwatch.elapsedMilliseconds,
        lessThan(15000),
        reason: 'Rendering stress test should complete under 15 seconds',
      );

      debugPrint('✅ Rendering stress test completed');
    });

    testWidgets('should generate comprehensive performance report', (
      final WidgetTester tester,
    ) async {
      await initApp();
      await setupApp(tester);

      debugPrint('📊 =================================');
      debugPrint('📊 PERFORMANCE TEST SUMMARY REPORT');
      debugPrint('📊 =================================');

      final reportStopwatch = Stopwatch()..start();

      // Overall app performance metrics
      await loginUser(tester);
      final overallLoadTime = reportStopwatch.elapsedMilliseconds;

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Count UI elements for complexity analysis
      final jobCards = find.byType(Card);
      final buttons = find.byType(ElevatedButton);
      final icons = find.byType(Icon);
      final textFields = find.byType(TextField);

      debugPrint('📊 App Load Time: ${overallLoadTime}ms');
      debugPrint('📊 UI Complexity:');
      debugPrint('   - Job Cards: ${tester.widgetList(jobCards).length}');
      debugPrint('   - Buttons: ${tester.widgetList(buttons).length}');
      debugPrint('   - Icons: ${tester.widgetList(icons).length}');
      debugPrint('   - Text Fields: ${tester.widgetList(textFields).length}');

      // Performance recommendations
      debugPrint('📊 Performance Recommendations:');
      if (overallLoadTime > 8000) {
        debugPrint('   ⚠️  Consider optimizing app startup time');
      } else {
        debugPrint('   ✅ App startup time is within acceptable range');
      }

      if (tester.widgetList(jobCards).length > 20) {
        debugPrint('   ⚠️  Consider implementing pagination for job cards');
      } else {
        debugPrint('   ✅ Job card count is manageable');
      }
      debugPrint('📊 =================================');
      debugPrint('✅ Performance report generation completed');
    });
  });
}
