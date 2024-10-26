import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/widgets/double_row_slider.dart';
import 'package:dima_project/models/movie.dart';
import 'package:mockito/mockito.dart';
import 'package:logger/logger.dart';

class MockLogger extends Mock implements Logger {}

void main() {
  group('DoubleRowSlider Widget Tests', () {
    late List<Movie> testMovies;

    setUp(() {
      testMovies = [
        Movie(
          id: 1,
          title: 'Test Movie 1',
          overview: 'Overview 1',
          posterPath: '/test_poster1.jpg',
          voteAverage: 7.5,
          genres: ['Action'],
        ),
        Movie(
          id: 2,
          title: 'Test Movie 2',
          overview: 'Overview 2',
          posterPath: '/test_poster2.jpg',
          voteAverage: 8.0,
          genres: ['Drama'],
        ),
        Movie(
          id: 3,
          title: 'Test Movie 3',
          overview: 'Overview 3',
          posterPath: null, // Test case for missing poster
          voteAverage: 6.5,
          genres: ['Comedy'],
        ),
      ];
    });

    testWidgets('renders correct number of movies',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DoubleRowSlider(movies: testMovies),
          ),
        ),
      );

      // Verify that all movies are rendered
      expect(find.byType(GestureDetector), findsNWidgets(testMovies.length));
    });

    testWidgets('displays placeholder for missing poster',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DoubleRowSlider(movies: testMovies),
          ),
        ),
      );

      // Verify that a placeholder is shown for the movie without a poster
      expect(find.byIcon(Icons.movie), findsOneWidget);
    });

    testWidgets('applies correct dimensions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DoubleRowSlider(movies: testMovies),
          ),
        ),
      );

      // Verify the overall height of the slider
      final sliderBox =
          tester.element(find.byType(SizedBox).first).renderObject as RenderBox;
      expect(sliderBox.size.height, 390.0); // As specified in the widget

      // Verify GridView properties
      final gridView = find.byType(GridView);
      expect(gridView, findsOneWidget);
    });

    testWidgets('handles empty movie list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DoubleRowSlider(movies: const []),
          ),
        ),
      );

      // Verify that the widget still renders without errors
      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(GestureDetector), findsNothing);
    });

    testWidgets('applies shuffle when specified', (WidgetTester tester) async {
      // Create a copy of test movies to compare against
      final originalOrder = List<Movie>.from(testMovies);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DoubleRowSlider(
              movies: testMovies,
              shuffle: true,
            ),
          ),
        ),
      );

      // Note: We can't directly test the randomization, but we can verify
      // that all movies are still present
      expect(find.byType(GestureDetector), findsNWidgets(originalOrder.length));
    });

    testWidgets('handles image loading errors gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DoubleRowSlider(movies: [
              Movie(
                id: 1,
                title: 'Test Movie',
                overview: 'Overview',
                posterPath: '/invalid_path.jpg',
                voteAverage: 7.5,
                genres: ['Action'],
              ),
            ]),
          ),
        ),
      );

      // Let the image loading error occur
      await tester.pumpAndSettle();

      // Verify that a placeholder is shown when image loading fails
      expect(find.byIcon(Icons.movie), findsOneWidget);
    });
  });
}
