import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/widgets/home_carousel.dart';
import 'package:dima_project/models/movie.dart';

void main() {
  group('HomeCarousel Widget Tests', () {
    testWidgets('HomeCarousel displays correctly with movies',
        (WidgetTester tester) async {
      final movies = [
        Movie(
          id: 1,
          title: 'Test Movie 1',
          overview: 'Overview 1',
          backdropPath: '/test_backdrop1.jpg',
          voteAverage: 7.5,
          releaseDate: '2024-01-01',
          genres: ['Action'],
        ),
        Movie(
          id: 2,
          title: 'Test Movie 2',
          overview: 'Overview 2',
          backdropPath: '/test_backdrop2.jpg',
          voteAverage: 8.0,
          releaseDate: '2024-01-02',
          genres: ['Drama'],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeCarousel(
              movies: movies,
              isTablet: false,
            ),
          ),
        ),
      );

      // Verify that the carousel is rendered
      expect(find.byType(CustomSlider), findsOneWidget);

      // Verify that movie titles are displayed
      expect(find.text('Test Movie 1'), findsOneWidget);

      // Verify that release dates are displayed
      expect(find.text('2024-01-01'), findsOneWidget);
    });

    testWidgets('HomeCarousel handles empty movie list',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeCarousel(
              movies: [],
              isTablet: false,
            ),
          ),
        ),
      );

      // Verify that empty state is handled
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('SliderCard displays movie information correctly',
        (WidgetTester tester) async {
      final movie = Movie(
        id: 1,
        title: 'Test Movie',
        overview: 'Test Overview',
        backdropPath: '/test_backdrop.jpg',
        voteAverage: 7.5,
        releaseDate: '2024-01-01',
        genres: ['Action'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SliderCard(
              movie: movie,
              itemIndex: 0,
            ),
          ),
        ),
      );

      // Verify movie title is displayed
      expect(find.text('Test Movie'), findsOneWidget);

      // Verify release date is displayed
      expect(find.text('2024-01-01'), findsOneWidget);
    });

    testWidgets('SliderCard handles null release date',
        (WidgetTester tester) async {
      final movie = Movie(
        id: 1,
        title: 'Test Movie',
        overview: 'Test Overview',
        backdropPath: '/test_backdrop.jpg',
        voteAverage: 7.5,
        releaseDate: null,
        genres: ['Action'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SliderCard(
              movie: movie,
              itemIndex: 0,
            ),
          ),
        ),
      );

      // Verify fallback text is displayed
      expect(find.text('Unknown release date'), findsOneWidget);
    });

    testWidgets('CustomSlider handles error in image loading',
        (WidgetTester tester) async {
      final movies = [
        Movie(
          id: 1,
          title: 'Test Movie',
          overview: 'Overview',
          backdropPath: 'invalid_path.jpg', // Invalid path to trigger error
          voteAverage: 7.5,
          releaseDate: '2024-01-01',
          genres: ['Action'],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeCarousel(
              movies: movies,
              isTablet: false,
            ),
          ),
        ),
      );

      // Allow error widget to build
      await tester.pump();

      // Verify error icon is displayed
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('CustomSlider adapts to tablet mode',
        (WidgetTester tester) async {
      final movies = [
        Movie(
          id: 1,
          title: 'Test Movie',
          overview: 'Overview',
          backdropPath: '/test_backdrop.jpg',
          voteAverage: 7.5,
          releaseDate: '2024-01-01',
          genres: ['Action'],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeCarousel(
              movies: movies,
              isTablet: true,
            ),
          ),
        ),
      );

      final CustomSlider slider =
          tester.widget<CustomSlider>(find.byType(CustomSlider));
      expect(slider.isTablet, true);
    });
  });
}
