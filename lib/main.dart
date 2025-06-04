import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/services/shared_prefs_service.dart';
import 'i18n/strings.g.dart';
import 'injection_container.dart';
import 'shared/routes/app_router.dart';
import 'shared/theme/app_theme.dart';

/// The main entry point of the application.
///
/// Initializes necessary services, sets up the locale, injects dependencies,
/// and runs the Flutter application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  AppTheme.applyOverlay();
  InjectionContainer.injectDependencies();
  final localeService = InjectionContainer.get<LocaleService>();
  final savedLocale = await localeService.getSavedLocale();
  await LocaleSettings.setLocale(savedLocale ?? AppLocale.en);
  runApp(const ProviderScope(child: Main()));
}

/// The root widget of the application.
///
/// Sets up the [MaterialApp.router] with the application's theme,
/// title, and router configuration.
class Main extends StatelessWidget {
  /// Creates the main application widget.
  const Main({super.key});

  @override
  Widget build(final BuildContext context) => TranslationProvider(
    child: MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Jobsit IT',
      theme: AppTheme.theme,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        multitouchDragStrategy: MultitouchDragStrategy.sumAllPointers,
        scrollbars: false,
      ),
      routerConfig: AppRouter.router,
    ),
  );
}
