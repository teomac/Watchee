import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:dima_project/widgets/universal_search_bar_widget.dart';
import 'package:dima_project/models/movie.dart';
import 'package:dima_project/models/person.dart';
import 'package:dima_project/services/tmdb_api_service.dart';
import 'universal_search_bar_widget_test.mocks.dart';

@GenerateNiceMocks([MockSpec<TmdbApiService>()])
void main() {
  late ThemeData mockTheme;
  late MockTmdbApiService mockTmdbApiService;

  setUp(() {
    mockTheme = ThemeData.light();
    mockTmdbApiService = MockTmdbApiService();
  });

  Widget createWidgetUnderTest({
    required bool isDarkMode,
    required Function(bool) onExpandChanged,
    required Function(List<Movie>, List<Person>) onSearchResults,
  }) {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<TmdbApiService>(
            create: (_) => mockTmdbApiService,
          ),
        ],
        child: Scaffold(
          body: UniversalSearchBarWidget(
            theme: mockTheme,
            isDarkMode: isDarkMode,
            onExpandChanged: onExpandChanged,
            onSearchResults: onSearchResults,
          ),
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
      // Setup mock responses
      when(mockTmdbApiService.searchMovie(any))
          .thenAnswer((_) async => <Movie>[]);
      when(mockTmdbApiService.searchPeople(any))
          .thenAnswer((_) async => <Person>[]);

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
      // Setup mock responses
      when(mockTmdbApiService.searchMovie(any))
          .thenAnswer((_) async => <Movie>[]);
      when(mockTmdbApiService.searchPeople(any))
          .thenAnswer((_) async => <Person>[]);

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

    testWidgets('should perform search when text is entered',
        (WidgetTester tester) async {
      final movies = [
        Movie(
            id: 1,
            title: 'Test Movie',
            overview: '',
            voteAverage: 1.0,
            genres: [])
      ];
      final people = [
        Person(
            id: 1,
            name: 'Test Person',
            adult: false,
            knownFor: [],
            gender: 0,
            popularity: 0.0,
            alsoKnownAs: [],
            knownForDepartment: 'Acting')
      ];

      // Setup mock responses
      when(mockTmdbApiService.searchMovie('test'))
          .thenAnswer((_) async => movies);
      when(mockTmdbApiService.searchPeople('test'))
          .thenAnswer((_) async => people);

      List<Movie> resultMovies = [];
      List<Person> resultPeople = [];

      await tester.pumpWidget(createWidgetUnderTest(
        isDarkMode: false,
        onExpandChanged: (_) {},
        onSearchResults: (m, p) {
          resultMovies = m;
          resultPeople = p;
        },
      ));

      // Enter search text
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300)); // Wait for debounce

      // Verify search was performed
      verify(mockTmdbApiService.searchMovie('test')).called(1);
      verify(mockTmdbApiService.searchPeople('test')).called(1);

      // Wait for the futures to complete
      await tester.pumpAndSettle();

      expect(resultMovies, equals(movies));
      expect(resultPeople, equals(people));
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
