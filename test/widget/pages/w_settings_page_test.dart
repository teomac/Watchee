import 'package:dima_project/pages/settings_page.dart';
import 'package:dima_project/services/fcm_settings_service.dart';
import 'package:dima_project/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import '../../mocks/w_settings_page_test.mocks.dart';

@GenerateMocks([ThemeProvider, FCMSettingsService])
void main() {
  late MockThemeProvider mockThemeProvider;
  late MockFCMSettingsService mockFCMSettingsService;

  setUp(() {
    mockThemeProvider = MockThemeProvider();
    mockFCMSettingsService = MockFCMSettingsService();

    // Setup default mock behaviors
    when(mockThemeProvider.themeMode).thenReturn(ThemeMode.system);
    when(mockFCMSettingsService.isPushNotificationsEnabled())
        .thenAnswer((_) async => true);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>.value(
            value: mockThemeProvider,
          ),
          Provider<FCMSettingsService>(create: (_) => mockFCMSettingsService)
        ],
        child: const SettingsPage(),
      ),
    );
  }

  testWidgets('SettingsPage displays correct sections',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // Verify sections are present
    expect(find.text('General'), findsOneWidget);
    expect(find.text('Notification Preferences'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
  });

  testWidgets('Theme selector works correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // Verify initial theme mode
    expect(find.text('System default'), findsOneWidget);

    // Open theme dropdown
    await tester.tap(find.text('System default'));
    await tester.pump();

    // Verify theme options
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);

    // Select Light theme
    await tester.tap(find.text('Light'));
    await tester.pump();

    // Verify theme provider was called with Light theme
    verify(mockThemeProvider.setThemeMode(ThemeMode.light)).called(1);
  });

  testWidgets('Version information is displayed', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // Verify version is displayed
    expect(find.text('1.0.0'), findsOneWidget);
    expect(find.text('Version'), findsOneWidget);
  });

  testWidgets('Push Notifications toggle works', (WidgetTester tester) async {
    // Mock FCM Settings Service with predefined return values
    when(mockFCMSettingsService.isPushNotificationsEnabled())
        .thenAnswer((_) async => false);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();
    await tester.pump(); // Extra pump to handle async loading

    // Find the Switch ListTile for Push Notifications
    final switchFinder = find.byType(SwitchListTile);
    expect(switchFinder, findsOneWidget);

    // Tap to enable push notifications
    await tester.tap(switchFinder);
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('Navigation to Terms of Service works',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // Find and tap Terms of Service
    await tester.tap(find.text('Terms of Service'));
    await tester.pump();

    expect(find.text('Terms of Service'), findsOneWidget);
  });

  testWidgets('Navigation to Privacy Policy works',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // Find and tap Privacy Policy
    await tester.tap(find.text('Privacy Policy'));
    await tester.pump();

    expect(find.text('Privacy Policy'), findsOneWidget);
  });
}
