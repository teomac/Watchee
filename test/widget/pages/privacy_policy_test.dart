import 'package:dima_project/pages/privacy_policy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: PrivacyPolicyPage(),
    );
  }

  testWidgets('PrivacyPolicyPage displays correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Find Markdown widget
    final markdownFinder = find.byType(Markdown);
    expect(markdownFinder, findsOneWidget);

    // Get the Markdown widget
    final markdownWidget = tester.widget<Markdown>(markdownFinder);

    // Verify app bar exists with correct title
    // Verify AppBar title
    expect(find.byType(AppBar), findsOneWidget);

    final appBar = tester.widget<AppBar>(find.byType(AppBar));

    final titleText = appBar.title as Text;
    expect(titleText.data?.contains('Privacy Policy'), isTrue);

    // Verify key sections are present
    expect(markdownWidget.data.contains('Privacy Policy'), isTrue);
    expect(markdownWidget.data.contains('1. Introduction'), isTrue);
    expect(markdownWidget.data.contains('2. Information We Collect'), isTrue);
    expect(
        markdownWidget.data.contains('3. How We Use Your Information'), isTrue);
    expect(
        markdownWidget.data.contains('4. Data Storage and Security'), isTrue);
    expect(
        markdownWidget.data.contains('5. Data Sharing and Disclosure'), isTrue);
    expect(markdownWidget.data.contains('6. Your Rights Under GDPR'), isTrue);

    // Verify contact information is present
    expect(markdownWidget.data.contains('Contact Information'), isTrue);
    expect(
        markdownWidget.data.contains(
            'matteo.laini@mail.polimi.it or matteo.macaluso@mail.polimi.it'),
        isTrue);
  });

  testWidgets('PrivacyPolicyPage styling is applied correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Find Markdown widget and verify its styling
    final markdownWidget = tester.widget<Markdown>(find.byType(Markdown));

    // Verify stylesheet exists
    expect(markdownWidget.styleSheet, isNotNull);

    // Verify padding
    expect(markdownWidget.padding, const EdgeInsets.all(16.0));
  });

  testWidgets('PrivacyPolicyPage scrolling works', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Initial position - "Privacy Policy" should be visible
    expect(find.text('Privacy Policy'), findsWidgets);

    // Scroll down
    await tester.dragFrom(const Offset(0, 300), const Offset(0, -300));
    await tester.pumpAndSettle();

    // Find Markdown widget
    final markdownFinder = find.byType(Markdown);
    expect(markdownFinder, findsOneWidget);

    // Get the Markdown widget
    final markdownWidget = tester.widget<Markdown>(markdownFinder);

    // Verify that content has scrolled
    expect(markdownWidget.data.contains('14. Supervisory Authority'), isTrue);
  });

  testWidgets('PrivacyPolicyPage SafeArea is applied',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify SafeArea widget is present
    expect(find.byType(SafeArea), findsWidgets);
  });

  testWidgets('PrivacyPolicyPage handles theme changes',
      (WidgetTester tester) async {
    // Test with light theme
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData.light(),
      home: const PrivacyPolicyPage(),
    ));
    await tester.pumpAndSettle();

    // Test with dark theme
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData.dark(),
      home: const PrivacyPolicyPage(),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(Markdown), findsOneWidget);
  });

  testWidgets('PrivacyPolicyPage link handling', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final markdown = tester.widget<Markdown>(find.byType(Markdown));
    expect(markdown.onTapLink, isNotNull);
  });
}
