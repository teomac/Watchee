import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:dima_project/pages/tos.dart';

void main() {
  group('TermsOfServicePage Tests', () {
    Widget createWidgetUnderTest() {
      return const MaterialApp(
        home: TermsOfServicePage(),
      );
    }

    testWidgets('Page renders with correct title', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify AppBar title
      expect(find.byType(AppBar), findsOneWidget);

      final appBar = tester.widget<AppBar>(find.byType(AppBar));

      final titleText = appBar.title as Text;
      expect(titleText.data?.contains('Terms of Service'), isTrue);
    });

    testWidgets('Page contains Markdown content', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify Markdown widget exists
      expect(find.byType(Markdown), findsOneWidget);
    });

    testWidgets('Markdown styling is applied', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find Markdown widget
      final markdownFinder = find.byType(Markdown);
      expect(markdownFinder, findsOneWidget);

      // Verify Markdown widget has correct padding
      final markdownWidget = tester.widget<Markdown>(markdownFinder);
      expect(markdownWidget.padding, const EdgeInsets.all(16.0));
    });

    testWidgets('Last updated date is correct', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Last Updated: October 28, 2024'), findsOneWidget);
    });

    testWidgets('Markdown links can be tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find Markdown widget
      final markdownFinder = find.byType(Markdown);
      expect(markdownFinder, findsOneWidget);

      // Verify onTapLink callback is set
      final markdownWidget = tester.widget<Markdown>(markdownFinder);
      expect(markdownWidget.onTapLink, isNotNull);
    });

    testWidgets('Contact emails are present as links',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find Markdown widget
      final markdownFinder = find.byType(Markdown);
      expect(markdownFinder, findsOneWidget);

      // Get the Markdown widget
      final markdownWidget = tester.widget<Markdown>(markdownFinder);

      // Check that the Markdown text contains the emails
      expect(
          markdownWidget.data.contains('matteo.laini@mail.polimi.it'), isTrue);
      expect(markdownWidget.data.contains('matteo.macaluso@mail.polimi.it'),
          isTrue);
    });
  });
}
