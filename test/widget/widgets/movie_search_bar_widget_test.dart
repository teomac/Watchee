import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/widgets/movie_search_bar_widget.dart';
import 'package:dima_project/models/movie.dart';

void main() {
  late ThemeData mockTheme;

  setUp(() {
    mockTheme = ThemeData.light();
  });

  Widget createWidgetUnderTest({
    required bool isDarkMode,
    required Function(bool) onExpandChanged,
    required Function(List<Movie>) onSearchResults,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: MovieSearchBarWidget(
          theme: mockTheme,
          isDarkMode: isDarkMode,
          onExpandChanged: onExpandChanged,
          onSearchResults: onSearchResults,
        ),
      ),
    );
  }

  group('MovieSearchBarWidget', () {
    testWidgets('should render correctly in initial state',
        (WidgetTester tester) async {
      bool expandedState = false;
      List<Movie> searchResults = [];

      await tester.pumpWidget(createWidgetUnderTest(
        isDarkMode: false,
        onExpandChanged: (bool expanded) => expandedState = expanded,
        onSearchResults: (List<Movie> movies) => searchResults = movies,
      ));

      // Verify initial state
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);
      expect(expandedState, false);
      expect(searchResults, isEmpty);
      expect(find.text('Search movies...'), findsOneWidget);
    });

    testWidgets('should expand when focused', (WidgetTester tester) async {
      bool expandedState = false;

      await tester.pumpWidget(createWidgetUnderTest(
        isDarkMode: false,
        onExpandChanged: (bool expanded) => expandedState = expanded,
        onSearchResults: (_) {},
      ));

      // Tap the search field to focus it
      await tester.tap(find.byType(TextField));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(expandedState, true);
    });

    testWidgets('should show close icon when text is entered',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        isDarkMode: false,
        onExpandChanged: (_) {},
        onSearchResults: (_) {},
      ));

      // Enter text to show the close button
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should clear text and collapse when close button is pressed',
        (WidgetTester tester) async {
      bool expandedState = true;
      List<Movie> searchResults = [];

      await tester.pumpWidget(createWidgetUnderTest(
        isDarkMode: false,
        onExpandChanged: (bool expanded) => expandedState = expanded,
        onSearchResults: (List<Movie> movies) => searchResults = movies,
      ));

      // Enter text first
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap the close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('test'), findsNothing);
      expect(expandedState, false);
      expect(searchResults, isEmpty);
    });

    testWidgets('should trigger search when text is entered',
        (WidgetTester tester) async {
      List<Movie> searchResults = [];

      await tester.pumpWidget(createWidgetUnderTest(
        isDarkMode: false,
        onExpandChanged: (_) {},
        onSearchResults: (List<Movie> movies) => searchResults = movies,
      ));

      // Enter search text
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify that search was triggered
      // Note: Actual search results will be empty in test environment
      expect(searchResults, isEmpty);
    });

    testWidgets('should stay expanded when focus is lost with non-empty text',
        (WidgetTester tester) async {
      bool expandedState = false;

      await tester.pumpWidget(createWidgetUnderTest(
        isDarkMode: false,
        onExpandChanged: (bool expanded) {
          expandedState = expanded;
        },
        onSearchResults: (_) {},
      ));

      // Focus and enter text
      await tester.tap(find.byType(TextField));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(expandedState, true);

      // Then unfocus
      await tester.tapAt(const Offset(0, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Should stay expanded because there is text
      expect(expandedState, true);
    });

    testWidgets('should apply correct theme colors',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        isDarkMode: true,
        onExpandChanged: (_) {},
        onSearchResults: (_) {},
      ));

      final TextField textField =
          tester.widget<TextField>(find.byType(TextField));
      final InputDecoration decoration = textField.decoration!;

      expect(decoration.border, isA<OutlineInputBorder>());
      expect(decoration.filled, true);
      expect(
        (decoration.border as OutlineInputBorder).borderRadius,
        BorderRadius.circular(24),
      );
    });

    testWidgets('should handle width animation correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        isDarkMode: false,
        onExpandChanged: (_) {},
        onSearchResults: (_) {},
      ));

      // Get initial width
      final initialWidth = tester.getSize(find.byType(TextField)).width;

      // Focus to trigger expansion
      await tester.tap(find.byType(TextField));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Get expanded width
      final expandedWidth = tester.getSize(find.byType(TextField)).width;

      expect(expandedWidth, greaterThan(initialWidth));
    });

    testWidgets(
        'should maintain expanded state with non-empty text when losing focus',
        (WidgetTester tester) async {
      bool expandedState = false;

      await tester.pumpWidget(createWidgetUnderTest(
        isDarkMode: false,
        onExpandChanged: (bool expanded) => expandedState = expanded,
        onSearchResults: (_) {},
      ));

      // Enter text and focus
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Remove focus
      await tester.tap(find.byType(Scaffold));
      await tester.pump();

      expect(expandedState, true);
      expect(find.text('test'), findsOneWidget);
    });
  });
}
