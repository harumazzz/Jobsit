import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'i18n/strings.g.dart';
import 'injection_container.dart';
import 'shared/routes/app_router.dart';
import 'shared/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  AppTheme.applyOverlay();
  await LocaleSettings.setLocale(AppLocale.vi);
  InjectionContainer.injectDependencies();
  runApp(TranslationProvider(child: const ProviderScope(child: MainApp())));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Jobsit IT',
      theme: AppTheme.theme,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        multitouchDragStrategy: MultitouchDragStrategy.sumAllPointers,
        scrollbars: false,
      ),
      routerConfig: AppRouter.router,
    );
  }
}
