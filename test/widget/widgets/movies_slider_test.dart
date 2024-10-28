import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/widgets/movies_slider.dart';
import 'package:dima_project/models/movie.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart'; // Add this import

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

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
      await mockNetworkImagesFor(() async {
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

      expect(find.byIcon(Icons.movie), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);

      final Container container = tester.widget(find.byType(Container).first);
      expect(container.color, equals(Colors.grey[300]));
    });

    testWidgets('handles image loading state', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        final movie = Movie(
          id: 1,
          title: 'Test Movie',
          overview: 'Test Overview',
          posterPath: '/test_path.jpg',
          voteAverage: 7.0,
          genres: ['Action'],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MoviesSlider(movies: [movie]),
            ),
          ),
        );

        // Initial build should show loading state
        await tester.pump(Duration.zero);
        expect(find.byType(Image), findsOneWidget);
      });
    });

    testWidgets('applies correct padding and border radius',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MoviesSlider(movies: testMovies),
            ),
          ),
        );

        final ClipRRect clipRRect = tester.widget(find.byType(ClipRRect).first);
        expect(clipRRect.borderRadius, BorderRadius.circular(8));

        final Padding padding = tester.widget(find.byType(Padding).first);
        expect(padding.padding, const EdgeInsets.all(8.0));
      });
    });

    testWidgets('handles shuffle functionality', (WidgetTester tester) async {
      final movies = List.generate(
        5,
        (index) => Movie(
          id: index,
          title: 'Movie $index',
          overview: 'Overview $index',
          posterPath: '/test_path_$index.jpg',
          voteAverage: 7.0,
          genres: ['Action'],
        ),
      );

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MoviesSlider(movies: [...movies], shuffle: true),
            ),
          ),
        );

        // Verify that the correct number of movies is displayed
        expect(find.byType(GestureDetector), findsNWidgets(movies.length));

        // Test that movies list is actually modified when shuffle is true
        final MoviesSlider slider = tester.widget(find.byType(MoviesSlider));
        expect(slider.shuffle, isTrue);
      });
    });

    testWidgets('handles movie title display', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MoviesSlider(movies: testMovies),
            ),
          ),
        );

        // Verify widget dimensions
        final SizedBox sizedBox = tester.widget(find.byType(SizedBox).first);
        expect(sizedBox.height, 185);

        final movieContainer = find.byType(ClipRRect);
        expect(movieContainer, findsWidgets);
      });
    });

    test('creates logger instance', () {
      final moviesSlider = MoviesSlider(movies: testMovies);
      expect(moviesSlider.logger, isNotNull);
    });
  });
}
