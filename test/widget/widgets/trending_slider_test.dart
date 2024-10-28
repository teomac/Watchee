import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dima_project/widgets/trending_slider.dart';
import 'package:dima_project/models/movie.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {}
}

void main() {
  group('TrendingSlider Widget Tests', () {
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

    testWidgets('renders correctly with trending movies list',
        (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            navigatorObservers: [mockObserver],
            home: Scaffold(
              body: TrendingSlider(trendingMovies: testMovies),
            ),
          ),
        );

        // Verify the basic structure
        expect(find.byType(CarouselSlider), findsOneWidget);
        expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
        expect(find.byType(ClipRRect), findsWidgets);
        expect(find.byType(Image), findsWidgets);

        // Verify that we can find both movie titles (to ensure both movies are rendered)
        final movie1 = testMovies[0];
        final movie2 = testMovies[1];

        // Verify images are being loaded with correct URLs
        final images = tester.widgetList<Image>(find.byType(Image));
        expect(
          images
              .any((img) => img.image.toString().contains(movie1.posterPath!)),
          isTrue,
          reason: 'Should find image for first movie',
        );
        expect(
          images
              .any((img) => img.image.toString().contains(movie2.posterPath!)),
          isTrue,
          reason: 'Should find image for second movie',
        );
      });
    });

    testWidgets('handles empty movie list', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TrendingSlider(trendingMovies: []),
            ),
          ),
        );

        expect(find.byType(SizedBox), findsOneWidget);
        expect(find.byType(CarouselSlider), findsNothing);
      });
    });

    testWidgets('CarouselSlider has correct properties when movies exist',
        (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TrendingSlider(trendingMovies: testMovies),
            ),
          ),
        );

        final CarouselSlider carouselSlider =
            tester.widget(find.byType(CarouselSlider));

        expect(carouselSlider.options.height, 185);
        expect(carouselSlider.options.autoPlay, true);
        expect(carouselSlider.options.viewportFraction, 0.33);
        expect(carouselSlider.options.enlargeCenterPage, true);
        expect(carouselSlider.options.pageSnapping, true);
        expect(carouselSlider.options.autoPlayCurve, Curves.fastOutSlowIn);
        expect(carouselSlider.options.autoPlayAnimationDuration,
            const Duration(seconds: 1));
      });
    });

    testWidgets('renders with correct movie poster dimensions',
        (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TrendingSlider(trendingMovies: testMovies),
            ),
          ),
        );

        final moviePosters = find.descendant(
          of: find.byType(ClipRRect),
          matching: find.byType(SizedBox),
        );

        final SizedBox posterSizedBox = tester.widget(moviePosters.first);
        expect(posterSizedBox.height, 185);
        expect(posterSizedBox.width, 115);
      });
    });

    testWidgets('handles image loading error gracefully',
        (WidgetTester tester) async {
      final movieWithInvalidPath = Movie(
        id: 3,
        title: 'Invalid Image Movie',
        overview: 'Overview 3',
        posterPath: '/invalid_path.jpg',
        voteAverage: 6.5,
        genres: ['Comedy'],
      );

      mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TrendingSlider(trendingMovies: [movieWithInvalidPath]),
            ),
          ),
        );

        // Trigger the error callback for the image
        final Image image = tester.widget(find.byType(Image).first);
        final ImageProvider provider = image.image;
        const ImageConfiguration configuration = ImageConfiguration();
        final ImageStream completer = provider.resolve(configuration);
        completer.addListener(
          ImageStreamListener(
            (_, __) {},
            onError: (dynamic exception, StackTrace? stackTrace) {
              // Error callback triggered
            },
          ),
        );

        await tester.pump();
        expect(find.byType(Center), findsWidgets);
      });
    });

    testWidgets('wraps content in SizedBox with infinite width',
        (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TrendingSlider(trendingMovies: testMovies),
            ),
          ),
        );

        final SizedBox sizedBox = tester.widget(find.byType(SizedBox).first);
        expect(sizedBox.width, double.infinity);
      });
    });

    testWidgets('applies correct border radius to movie posters',
        (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TrendingSlider(trendingMovies: testMovies),
            ),
          ),
        );

        final ClipRRect clipRRect = tester.widget(find.byType(ClipRRect).first);
        expect(clipRRect.borderRadius, BorderRadius.circular(6));
      });
    });

    testWidgets('movie posters have high filter quality',
        (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TrendingSlider(trendingMovies: testMovies),
            ),
          ),
        );

        final Image image = tester.widget(find.byType(Image).first);
        expect(image.filterQuality, FilterQuality.high);
        expect(image.fit, BoxFit.cover);
      });
    });

    testWidgets('has correct viewport fraction for movie display',
        (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TrendingSlider(trendingMovies: testMovies),
            ),
          ),
        );

        final CarouselSlider carousel =
            tester.widget(find.byType(CarouselSlider));
        expect(carousel.options.viewportFraction, 0.33);
      });
    });

    testWidgets('auto-plays carousel animation', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TrendingSlider(trendingMovies: testMovies),
            ),
          ),
        );

        final CarouselSlider carousel =
            tester.widget(find.byType(CarouselSlider));
        expect(carousel.options.autoPlay, true);
        expect(carousel.options.autoPlayAnimationDuration.inSeconds, equals(1));
      });
    });
  });
}
