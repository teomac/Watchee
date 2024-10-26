import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/widgets/universal_search_bar_widget.dart';
import 'package:dima_project/models/movie.dart';
import 'package:dima_project/models/person.dart';

void main() {
  late ThemeData mockTheme;

  setUp(() {
    mockTheme = ThemeData.light();
  });

  Widget createWidgetUnderTest({
    required bool isDarkMode,
    required Function(bool) onExpandChanged,
    required Function(List<Movie>, List<Person>) onSearchResults,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: UniversalSearchBarWidget(
          theme: mockTheme,
          isDarkMode: isDarkMode,
          onExpandChanged: onExpandChanged,
          onSearchResults: onSearchResults,
        ),
      ),
    );
  }

  group('UniversalSearchBarWidget', () {
    testWidgets('should render correctly in initial state',
        (WidgetTester tester) async {
      bool expandedState = false;
      List<Movie> movies = [];
      List<Person> people = [];

      await tester.pumpWidget(createWidgetUnderTest(
        isDarkMode: false,
        onExpandChanged: (bool expanded) => expandedState = expanded,
        onSearchResults: (List<Movie> m, List<Person> p) {
          movies = m;
          people = p;
        },
      ));

      // Verify initial state
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsNothing);
      expect(find.byIcon(Icons.close), findsNothing);
      expect(expandedState, false);
      expect(movies, isEmpty);
      expect(people, isEmpty);
    });

    testWidgets('should expand when focused', (WidgetTester tester) async {
      bool expandedState = false;

      await tester.pumpWidget(createWidgetUnderTest(
        isDarkMode: false,
        onExpandChanged: (bool expanded) => expandedState = expanded,
        onSearchResults: (_, __) {},
      ));

      // Tap the search field to focus it
      await tester.tap(find.byType(TextField));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(expandedState, true);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('should show close icon when text is entered',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        isDarkMode: false,
        onExpandChanged: (_) {},
        onSearchResults: (_, __) {},
      ));

      // Enter text to expand the search bar
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should clear text when close button is pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        isDarkMode: false,
        onExpandChanged: (_) {},
        onSearchResults: (_, __) {},
      ));

      // Enter text
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      // Tap the close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      // Verify the text is cleared
      expect(find.text('test'), findsNothing);
    });

    testWidgets('should collapse when back button is pressed',
        (WidgetTester tester) async {
      bool expandedState = true;

      await tester.pumpWidget(createWidgetUnderTest(
        isDarkMode: false,
        onExpandChanged: (bool expanded) => expandedState = expanded,
        onSearchResults: (_, __) {},
      ));

      // First expand the search bar
      await tester.tap(find.byType(TextField));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap the back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(expandedState, false);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('should apply correct theme colors',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        isDarkMode: true,
        onExpandChanged: (_) {},
        onSearchResults: (_, __) {},
      ));

      final TextField textField =
          tester.widget<TextField>(find.byType(TextField));
      final InputDecoration decoration = textField.decoration!;

      expect(decoration.border, isA<OutlineInputBorder>());
      expect(decoration.filled, true);
      expect(decoration.hintText, 'Search movies and people...');
    });

    testWidgets('should have correct border radius',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        isDarkMode: false,
        onExpandChanged: (_) {},
        onSearchResults: (_, __) {},
      ));

      final TextField textField =
          tester.widget<TextField>(find.byType(TextField));
      final InputDecoration decoration = textField.decoration!;
      final OutlineInputBorder border = decoration.border as OutlineInputBorder;

      expect(border.borderRadius, BorderRadius.circular(24));
    });
  });
}
