import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jobsit/injection_container.dart';
import 'package:jobsit/main.dart' as app;
import 'package:timezone/data/latest.dart' as tz;

void initApp() {
  tz.initializeTimeZones();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app loads and displays correctly', (final tester) async {
    initApp();

    // Initialize dependency injection
    InjectionContainer.injectDependencies();

    // Pump the app widget with providers
    await tester.pumpWidget(
      const ProviderScope(
        child: app.Main(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify app loads successfully
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
