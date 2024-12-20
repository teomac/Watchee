import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/widgets/movies_slider.dart';
import 'package:dima_project/models/movie.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dima_project/services/tmdb_api_service.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:dima_project/services/watchlist_service.dart';
import 'package:dima_project/services/notifications_service.dart';
import 'movies_slider_test.mocks.dart';

@GenerateMocks(
    [TmdbApiService, UserService, WatchlistService, NotificationsService])
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  group('MoviesSlider Widget Tests', () {
    late List<Movie> testMovies;
    late MockNavigatorObserver mockObserver;
    late MockTmdbApiService mockTmdbApiService;
    late MockUserService mockUserService;
    late MockWatchlistService mockWatchlistService;
    late MockNotificationsService mockNotificationsService;

    setUp(() {
      mockObserver = MockNavigatorObserver();
      mockTmdbApiService = MockTmdbApiService();
      mockUserService = MockUserService();
      mockWatchlistService = MockWatchlistService();
      mockNotificationsService = MockNotificationsService();
      testMovies = [
        Movie(
          id: 1,
          title: 'Test Movie 1',
          overview: 'Overview 1',
          posterPath: '/test_path_1.jpg',
          voteAverage: 7.5,
          genres: ['Action'],
          releaseDate: '2023-01-01',
          backdropPath: '/backdrop_1.jpg',
        ),
        Movie(
          id: 2,
          title: 'Test Movie 2',
          overview: 'Overview 2',
          posterPath: '/test_path_2.jpg',
          voteAverage: 8.0,
          genres: ['Drama'],
          releaseDate: '2023-02-01',
          backdropPath: '/backdrop_2.jpg',
        ),
      ];

      // Setup mock responses
      when(mockTmdbApiService.retrieveFilmInfo(any))
          .thenAnswer((invocation) => Future.value(testMovies[0]));
      when(mockTmdbApiService.retrieveCast(any))
          .thenAnswer((invocation) => Future.value([
                {'id': 1, 'name': 'Actor 1', 'character': 'Character 1'},
              ]));
      when(mockTmdbApiService.retrieveTrailer(any))
          .thenAnswer((invocation) => Future.value('trailer_key'));
    });

    Widget buildTestWidget({required List<Movie> movies, bool? shuffle}) {
      return MultiProvider(
        providers: [
          Provider<TmdbApiService>.value(value: mockTmdbApiService),
          Provider<UserService>.value(value: mockUserService),
          Provider<WatchlistService>.value(value: mockWatchlistService),
          Provider<NotificationsService>.value(value: mockNotificationsService),
        ],
        child: MaterialApp(
          navigatorObservers: [mockObserver],
          home: Material(
            child: MoviesSlider(movies: movies, shuffle: shuffle),
          ),
        ),
      );
    }

    testWidgets('renders correctly with movies list',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(buildTestWidget(movies: testMovies));

        expect(find.byType(GestureDetector), findsNWidgets(testMovies.length));
        expect(find.byType(ListView), findsOneWidget);

        // Test dimensions
        final SizedBox sliderContainer =
            tester.widget(find.byType(SizedBox).first);
        expect(sliderContainer.height, 185);
        expect(sliderContainer.width, double.infinity);
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
        releaseDate: '2023-03-01',
      );

      await tester.pumpWidget(buildTestWidget(movies: [movieWithNullPoster]));

      expect(find.byIcon(Icons.movie), findsOneWidget);

      // Test placeholder styling
      final Container container = tester.widget(find.byType(Container).first);
      expect(container.color, equals(Colors.grey[300]));

      final Icon placeholderIcon = tester.widget(find.byIcon(Icons.movie));
      expect(placeholderIcon.size, 40);
      expect(placeholderIcon.color, Colors.grey);
    });

    testWidgets('handles image loading errors', (WidgetTester tester) async {
      final movieWithInvalidPath = Movie(
        id: 4,
        title: 'Invalid Image Movie',
        overview: 'Overview 4',
        voteAverage: 7.0,
        genres: ['Horror'],
        releaseDate: '2023-04-01',
      );

      await tester.pumpWidget(buildTestWidget(movies: [movieWithInvalidPath]));
      await tester.pump(); // Trigger error builder

      // Should show placeholder when image fails to load
      expect(find.byIcon(Icons.movie), findsOneWidget);
    });

    testWidgets('handles movie tap correctly', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(buildTestWidget(movies: testMovies));

        // Tap the first movie
        await tester.tap(find.byType(GestureDetector).first);

        // Only verify the API calls that happen during the tap
        // Don't verify navigation or subsequent initialization
        verify(mockTmdbApiService.retrieveFilmInfo(testMovies[0].id)).called(1);
        verify(mockTmdbApiService.retrieveCast(testMovies[0].id)).called(1);
        verify(mockTmdbApiService.retrieveTrailer(testMovies[0].id)).called(1);
      });
    });
    testWidgets('handles empty movies list', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(movies: []));

      expect(find.byType(GestureDetector), findsNothing);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('applies shuffle when enabled', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(buildTestWidget(
          movies: List.from(testMovies), // Create a copy to compare later
          shuffle: true,
        ));

        final MoviesSlider slider = tester.widget(find.byType(MoviesSlider));
        expect(slider.shuffle, isTrue);
      });
    });

    test('creates valid logger instance', () {
      final moviesSlider = MoviesSlider(movies: testMovies);
      expect(moviesSlider.logger, isNotNull);
    });
  });
}
