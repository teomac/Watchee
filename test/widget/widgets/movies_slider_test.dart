import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/widgets/movies_slider.dart';
import 'package:dima_project/models/movie.dart';
import 'package:mockito/mockito.dart';

// Mock class for navigation observer
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  group('MoviesSlider Widget Tests', () {
    late List<Movie> testMovies;

    setUp(() {
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
          home: Scaffold(
            body: MoviesSlider(movies: testMovies),
          ),
        ),
      );

      // Verify the widget creates the correct number of movie cards
      expect(find.byType(GestureDetector), findsNWidgets(testMovies.length));

      // Verify the SizedBox dimensions
      final SizedBox sizedBox = tester.widget(find.byType(SizedBox).first);
      expect(sizedBox.height, 185);
      expect(sizedBox.width, double.infinity);
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

      // Verify placeholder is shown when posterPath is null
      expect(find.byIcon(Icons.movie), findsOneWidget);
    });

    testWidgets('handles empty movies list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoviesSlider(movies: []),
          ),
        ),
      );

      // Verify the widget still renders without crashing
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(GestureDetector), findsNothing);
    });

    testWidgets('renders with correct dimensions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoviesSlider(movies: testMovies),
          ),
        ),
      );

      // Verify the movie poster dimensions
      final sizedBox = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(ClipRRect),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(sizedBox.height, 185);
      expect(sizedBox.width, 115);
    });

    testWidgets('shuffles movies when shuffle is true',
        (WidgetTester tester) async {
      final List<Movie> originalOrder = List.from(testMovies);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoviesSlider(movies: testMovies, shuffle: true),
          ),
        ),
      );

      // Note: Since shuffling is random, we can't test the exact order
      // We can only verify that the same movies are still present
      originalOrder.map((m) => m.title).toList();
      final Iterable<Widget> movieWidgets =
          tester.widgetList(find.byType(GestureDetector));

      expect(movieWidgets.length, originalOrder.length);
    });

    testWidgets('applies correct border radius', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoviesSlider(movies: testMovies),
          ),
        ),
      );

      final ClipRRect clipRRect = tester.widget(find.byType(ClipRRect).first);
      expect(clipRRect.borderRadius, BorderRadius.circular(8));
    });

    testWidgets('applies correct padding', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoviesSlider(movies: testMovies),
          ),
        ),
      );

      final Padding padding = tester.widget(find.byType(Padding).first);
      expect(padding.padding, const EdgeInsets.all(8.0));
    });
  });
}
