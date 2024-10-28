import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/widgets/movies_slider.dart';
import 'package:dima_project/models/movie.dart';
import 'package:mockito/mockito.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {}
}

void main() {
  group('MoviesSlider Widget Tests', () {
    late List<Movie> testMovies;
    late MockNavigatorObserver mockObserver;

    setUp(() {
      mockObserver = MockNavigatorObserver();
      testMovies = [
        Movie(
          id: 1,
          title: 'Test Movie 1',
          overview: 'Overview 1',
          posterPath: '/test_path_1.jpg',
          voteAverage: 7.5,
          genres: ['Action'],
        ),
        Movie(
          id: 2,
          title: 'Test Movie 2',
          overview: 'Overview 2',
          posterPath: '/test_path_2.jpg',
          voteAverage: 8.0,
          genres: ['Drama'],
        ),
      ];
    });

    testWidgets('renders correctly with movies list',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [mockObserver],
          home: Scaffold(
            body: MoviesSlider(movies: testMovies),
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsNWidgets(testMovies.length));
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('handles null posterPath gracefully',
        (WidgetTester tester) async {
      final movieWithNullPoster = Movie(
        id: 3,
        title: 'No Poster Movie',
        overview: 'Overview 3',
        posterPath: null,
        voteAverage: 6.5,
        genres: ['Comedy'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoviesSlider(movies: [movieWithNullPoster]),
          ),
        ),
      );

      await tester.pump();

      expect(find.byIcon(Icons.movie), findsOneWidget);
    });

    testWidgets('applies correct scroll physics', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoviesSlider(movies: testMovies),
          ),
        ),
      );

      final ListView listView = tester.widget(find.byType(ListView));
      expect(listView.physics, isA<BouncingScrollPhysics>());
    });

    testWidgets('allows horizontal scrolling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoviesSlider(movies: testMovies),
          ),
        ),
      );

      final initialPosition = tester.getTopLeft(find.byType(ListView));
      await tester.drag(find.byType(ListView), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();

      final finalPosition = tester.getTopLeft(find.byType(ListView));
      expect(finalPosition, equals(initialPosition));
    });

    testWidgets('handles shuffle correctly', (WidgetTester tester) async {
      final movieList = List.generate(
        5,
        (index) => Movie(
          id: index,
          title: 'Movie $index',
          overview: 'Overview $index',
          posterPath: null, // Use null to avoid image loading issues
          voteAverage: 7.0,
          genres: ['Action'],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoviesSlider(movies: movieList, shuffle: true),
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('renders with correct dimensions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoviesSlider(movies: testMovies),
          ),
        ),
      );

      final SizedBox parentSizedBox =
          tester.widget(find.byType(SizedBox).first);
      expect(parentSizedBox.height, 185);
      expect(parentSizedBox.width, double.infinity);

      final moviePosters = find.descendant(
        of: find.byType(ClipRRect),
        matching: find.byType(SizedBox),
      );

      final SizedBox posterSizedBox = tester.widget(moviePosters.first);
      expect(posterSizedBox.height, 185);
      expect(posterSizedBox.width, 115);
    });

    testWidgets('handles empty movie list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoviesSlider(movies: const []),
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(GestureDetector), findsNothing);
    });

    test('creates logger instance', () {
      final moviesSlider = MoviesSlider(movies: testMovies);
      expect(moviesSlider.logger, isNotNull);
    });

    testWidgets('handles basic placeholder for failed images',
        (WidgetTester tester) async {
      final movie = Movie(
        id: 1,
        title: 'Test Movie',
        overview: 'Overview',
        posterPath: null,
        voteAverage: 7.5,
        genres: ['Action'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoviesSlider(movies: [movie]),
          ),
        ),
      );

      expect(find.byIcon(Icons.movie), findsOneWidget);
    });
  });
}
