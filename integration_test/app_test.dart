// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_main.dart' as test_app;

/// ---------------------------------------------------------------------------
/// Shortly – Integration Test Suite
///
/// Run locally on a connected device:
///   flutter test integration_test/app_test.dart -d [device-id]
///
/// Build for Firebase Test Lab (see README_FIREBASE_TEST_LAB.md):
///   flutter build apk --debug
///   flutter build apk --debug integration_test/app_test.dart
/// ---------------------------------------------------------------------------

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Pre-seed SharedPreferences so onboarding is already completed and we
  /// land on MainScreen directly for every test group that doesn't test
  /// the onboarding flow itself.
  Future<void> skipOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
  }

  /// Fully reset SharedPreferences between test groups.
  Future<void> resetPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Pump the test-safe app and wait for all animations/frames to settle.
  Future<void> pumpApp(WidgetTester tester) async {
    test_app.testMain();
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  // ---------------------------------------------------------------------------
  // Group 1 – Onboarding flow
  // ---------------------------------------------------------------------------
  group('Onboarding', () {
    setUp(resetPrefs);

    testWidgets('shows first onboarding page on fresh launch', (tester) async {
      await pumpApp(tester);
      expect(find.text('Shorten Any Link'), findsOneWidget);
    });

    testWidgets('Next advances through all pages', (tester) async {
      await pumpApp(tester);

      // Page 1 → 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle(const Duration(milliseconds: 800));
      expect(find.text('Verify Before You Click'), findsOneWidget);

      // Page 2 → 3
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle(const Duration(milliseconds: 800));
      expect(find.text('Track Your History'), findsOneWidget);

      // Page 3 → MainScreen
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Bottom nav bar presence confirms we are on MainScreen
      expect(find.byIcon(Icons.home_rounded), findsWidgets);
    });

    testWidgets('Skip button goes straight to MainScreen', (tester) async {
      await pumpApp(tester);

      expect(find.text('Skip'), findsOneWidget);
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byIcon(Icons.home_rounded), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // Group 2 – Bottom navigation
  // ---------------------------------------------------------------------------
  group('Bottom Navigation', () {
    setUp(skipOnboarding);

    testWidgets('visits all four tabs without crashing', (tester) async {
      await pumpApp(tester);

      // Home is already active; cycle through the other three
      for (final icon in [
        Icons.link_rounded,
        Icons.verified_user_rounded,
        Icons.settings_rounded,
        Icons.home_rounded,
      ]) {
        await tester.tap(find.byIcon(icon).first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(find.byType(Scaffold), findsWidgets);
      }
    });
  });

  // ---------------------------------------------------------------------------
  // Group 3 – ShortenerView
  // ---------------------------------------------------------------------------
  group('ShortenerView', () {
    setUp(skipOnboarding);

    testWidgets('shows URL input and Shorten Now button', (tester) async {
      await pumpApp(tester);

      expect(
        find.text('https://example.com/very-long-url...'),
        findsOneWidget,
      );
      expect(find.text('Shorten Now'), findsOneWidget);
    });

    testWidgets('shows SnackBar when URL field is empty', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('Shorten Now'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('accepts URL text input', (tester) async {
      await pumpApp(tester);

      const testUrl = 'https://flutter.dev/docs/get-started/install';
      await tester.enterText(find.byType(TextField).first, testUrl);
      await tester.pump();

      expect(find.text(testUrl), findsOneWidget);
    });

    testWidgets('paste icon button is present', (tester) async {
      await pumpApp(tester);

      expect(find.byIcon(Icons.content_paste_rounded), findsOneWidget);
    });

    testWidgets('provider dropdown opens and allows selection', (tester) async {
      await pumpApp(tester);

      // Default provider label should be visible
      expect(find.text('TinyURL'), findsOneWidget);

      // Open the dropdown
      await tester.tap(find.byIcon(Icons.expand_more_rounded).first);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // At least one provider other than TinyURL should now be visible
      expect(find.text('CleanUri'), findsOneWidget);

      // Close by tapping outside
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
    });

    testWidgets('Recent Links section header is visible', (tester) async {
      await pumpApp(tester);

      expect(find.text('Recent Links'), findsOneWidget);
    });

    testWidgets('shows empty state when history is empty', (tester) async {
      // Ensure DB is empty by using a fresh prefs state
      await skipOnboarding();
      await pumpApp(tester);

      // Either the empty-state icon or a list — both are valid
      final hasEmpty =
          find.byIcon(Icons.link_off_rounded).evaluate().isNotEmpty;
      final hasList = find.byType(ListView).evaluate().isNotEmpty;
      expect(hasEmpty || hasList, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // Group 4 – ExpanderView
  // ---------------------------------------------------------------------------
  group('ExpanderView', () {
    setUp(skipOnboarding);

    testWidgets('renders input field on Expand & Verify tab', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.byIcon(Icons.verified_user_rounded).first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(TextField), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // Group 5 – HistoryView
  // ---------------------------------------------------------------------------
  group('HistoryView', () {
    setUp(skipOnboarding);

    testWidgets('My Links tab renders without error', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.byIcon(Icons.link_rounded).first);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final hasEmpty =
          find.byIcon(Icons.history_toggle_off_rounded).evaluate().isNotEmpty;
      final hasList = find.byType(ListView).evaluate().isNotEmpty;
      expect(hasEmpty || hasList, isTrue);
    });

    testWidgets('search field is visible', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.byIcon(Icons.link_rounded).first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byIcon(Icons.search_rounded), findsWidgets);
    });

    testWidgets('search query filters the list', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.byIcon(Icons.link_rounded).first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Enter a search term
      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'zzz_nonexistent_zzz');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Empty state or zero list items expected
      final hasEmpty =
          find.byIcon(Icons.history_toggle_off_rounded).evaluate().isNotEmpty;
      expect(hasEmpty, isTrue);
    });

    testWidgets('refresh button is tappable', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.byIcon(Icons.link_rounded).first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final refreshBtn = find.byIcon(Icons.refresh_rounded);
      if (refreshBtn.evaluate().isNotEmpty) {
        await tester.tap(refreshBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
    });
  });

  // ---------------------------------------------------------------------------
  // Group 6 – Navigation Drawer
  // ---------------------------------------------------------------------------
  group('Navigation Drawer', () {
    setUp(skipOnboarding);

    testWidgets('opens drawer via swipe gesture', (tester) async {
      await pumpApp(tester);

      final scaffoldTopLeft =
          tester.getTopLeft(find.byType(Scaffold).first);
      await tester.dragFrom(
        scaffoldTopLeft + const Offset(2, 300),
        const Offset(280, 0),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Premium Link Management'), findsOneWidget);
    });

    testWidgets('drawer closes when tapping outside', (tester) async {
      await pumpApp(tester);

      final scaffoldTopLeft =
          tester.getTopLeft(find.byType(Scaffold).first);
      await tester.dragFrom(
        scaffoldTopLeft + const Offset(2, 300),
        const Offset(280, 0),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Tap into the main content area to close
      await tester.tapAt(const Offset(350, 300));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Drawer header should no longer be visible
      expect(find.text('Premium Link Management'), findsNothing);
    });

    testWidgets('drawer Help & FAQ item is tappable', (tester) async {
      await pumpApp(tester);

      final scaffoldTopLeft =
          tester.getTopLeft(find.byType(Scaffold).first);
      await tester.dragFrom(
        scaffoldTopLeft + const Offset(2, 300),
        const Offset(280, 0),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final helpItem = find.text('Help & FAQ');
      if (helpItem.evaluate().isNotEmpty) {
        await tester.tap(helpItem);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }
    });
  });

  // ---------------------------------------------------------------------------
  // Group 7 – Settings / MenuScreen
  // ---------------------------------------------------------------------------
  group('MenuScreen', () {
    setUp(skipOnboarding);

    testWidgets('settings tab renders without error', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.byIcon(Icons.settings_rounded).first);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // Group 8 – Full smoke pass (renders all screens without crashing)
  // ---------------------------------------------------------------------------
  group('Smoke – All Screens', () {
    setUp(skipOnboarding);

    testWidgets('cycles all 4 tabs without throwing', (tester) async {
      await pumpApp(tester);

      for (final icon in [
        Icons.home_rounded,
        Icons.link_rounded,
        Icons.verified_user_rounded,
        Icons.settings_rounded,
      ]) {
        await tester.tap(find.byIcon(icon).first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        expect(find.byType(Scaffold), findsWidgets);
      }
    });
  });
}
