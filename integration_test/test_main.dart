// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_shortener/l10n/app_localizations.dart';
import 'package:url_shortener/core/theme.dart';
import 'package:url_shortener/presentation/screens/main_screen.dart';
import 'package:url_shortener/presentation/screens/onboarding_screen.dart';
import 'package:url_shortener/presentation/providers/theme_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:url_shortener/presentation/providers/locale_provider.dart';

/// Test-safe entry point for integration tests.
///
/// Mirrors [main.dart] but intentionally skips platform-specific services
/// (AppLovin MAX, IAP, update checks) that cannot initialise on Firebase
/// Test Lab emulators without real credentials.
void testMain() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // ⚠️ AdService / IapService / UpdateService intentionally NOT initialised
  // during integration tests to keep them fast and hermetic.

  runApp(const ProviderScope(child: _TestShortlyApp()));
}

class _TestShortlyApp extends ConsumerWidget {
  const _TestShortlyApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Shortly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('fr'),
        Locale('de'),
        Locale('pt'),
        Locale('it'),
        Locale('hi'),
        Locale('zh'),
        Locale('ar'),
      ],
      home: FutureBuilder<bool>(
        future: OnboardingScreen.hasSeenOnboarding(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            );
          }
          return snapshot.data! ? const MainScreen() : const OnboardingScreen();
        },
      ),
    );
  }
}
