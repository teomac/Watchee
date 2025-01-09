// ignore_for_file: deprecated_member_use

import 'package:dima_project/pages/force_update_screen.dart';
import 'package:dima_project/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import '../../mocks/w_force_update_screen_test.mocks.dart';

@GenerateMocks([ThemeProvider])
void main() {
  late MockThemeProvider mockThemeProvider;

  setUp(() {
    mockThemeProvider = MockThemeProvider();
    when(mockThemeProvider.themeMode).thenReturn(ThemeMode.light);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ChangeNotifierProvider<ThemeProvider>(
        create: (_) => mockThemeProvider,
        child: ForceUpdateScreen(
          currentVersion: '1.0.0',
          requiredVersion: '2.0.0',
          updateMessage: 'Please update to continue using the app.',
          themeProvider: mockThemeProvider,
        ),
      ),
    );
  }

  testWidgets('ForceUpdateScreen displays correct information',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify title and main message
    expect(find.text('Update Required'), findsOneWidget);
    expect(
        find.text('Please update to continue using the app.'), findsOneWidget);

    // Verify version information
    expect(find.text('Current version: 1.0.0\nRequired version: 2.0.0'),
        findsOneWidget);

    // Verify update button exists
    expect(find.text('Update Now'), findsOneWidget);
    expect(find.byIcon(Icons.download), findsOneWidget);

    // Verify system update icon
    expect(find.byIcon(Icons.system_update), findsOneWidget);
  });

  testWidgets('Text styles are applied correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Check 'Update Required' text style
    final titleFinder = find.text('Update Required');
    final Text titleWidget = tester.widget<Text>(titleFinder);
    expect(titleWidget.style?.fontWeight,
        FontWeight.w400); // Default from headlineSmall
    expect(titleWidget.textAlign, TextAlign.center);

    // Check update message text style
    final messageFinder = find.text('Please update to continue using the app.');
    final Text messageWidget = tester.widget<Text>(messageFinder);
    expect(messageWidget.style?.fontWeight,
        FontWeight.w400); // Default from bodyLarge
    expect(messageWidget.textAlign, TextAlign.center);

    // Check version text style
    final versionFinder =
        find.text('Current version: 1.0.0\nRequired version: 2.0.0');
    final Text versionWidget = tester.widget<Text>(versionFinder);
    expect(versionWidget.style?.fontWeight, FontWeight.w400);
    expect(versionWidget.textAlign, TextAlign.center);
  });

  testWidgets('Layout is responsive', (WidgetTester tester) async {
    // Set up a small screen size
    tester.binding.window.physicalSizeTestValue = const Size(320, 480);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify all content is visible on small screen
    expect(find.text('Update Required'), findsOneWidget);
    expect(find.text('Update Now'), findsOneWidget);

    // Set up a large screen size
    tester.binding.window.physicalSizeTestValue = const Size(1024, 1366);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify all content is visible on large screen
    expect(find.text('Update Required'), findsOneWidget);
    expect(find.text('Update Now'), findsOneWidget);

    // Reset the test screen size
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
  });
}
