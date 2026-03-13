import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stably_app/app/l10n/app_localizations.dart';
import 'package:stably_app/app/providers/app_state_providers.dart';
import 'package:stably_app/app/router/app_router.dart';
import 'package:stably_app/app/theme/app_theme.dart';

class StablyApp extends ConsumerWidget {
  const StablyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Stably',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
    );
  }
}
