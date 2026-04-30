import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:url_shortener/l10n/app_localizations.dart';
import 'core/theme.dart';
import 'core/services/iap_service.dart';
import 'core/services/ad_service.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/providers/theme_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'presentation/providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge-to-edge display
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // ── Initialize services ──────────────────────────────────────────────────
  await IapService().init();   // restores purchases + listens to stream
  await AdService().init();    // inits AppLovin MAX (skipped if premium)

  runApp(const ProviderScope(child: ShortlyApp()));
}

class ShortlyApp extends ConsumerWidget {
  const ShortlyApp({super.key});

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
      supportedLocales: const [Locale('en'), Locale('es')],
      home: const MainScreen(),
    );
  }
}
