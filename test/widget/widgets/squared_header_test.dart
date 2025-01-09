import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/widgets/squared_header.dart';

void main() {
  group('ProfileHeaderWidget', () {
    testWidgets('renders correctly with minimal props',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileHeaderWidget(
              imagePath: null,
            ),
          ),
        ),
      );

      expect(find.byType(ProfileHeaderWidget), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('displays all text elements when provided',
        (WidgetTester tester) async {
      const testTitle = 'Test Title';
      const testSubtitle = 'Test Subtitle';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileHeaderWidget(
              imagePath: null,
              title: testTitle,
              subtitle: testSubtitle,
            ),
          ),
        ),
      );

      expect(find.text(testTitle), findsOneWidget);
      expect(find.text(testSubtitle), findsOneWidget);
    });

    testWidgets('displays network image when imagePath is provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileHeaderWidget(
              imagePath: 'https://example.com/image.jpg',
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('shows placeholder when image fails to load',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileHeaderWidget(
              imagePath: 'invalid_url',
            ),
          ),
        ),
      );

      await tester.pump(); // Wait for error to be caught
      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('handles tap callback', (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeaderWidget(
              imagePath: null,
              onTap: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      expect(wasTapped, isTrue);
    });

    testWidgets('displays action button when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeaderWidget(
              imagePath: null,
              actionButton: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('uses correct size', (WidgetTester tester) async {
      const testSize = 300.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileHeaderWidget(
              imagePath: null,
              size: testSize,
            ),
          ),
        ),
      );

      final containerSize = tester.getSize(find.byType(Container).first);
      expect(containerSize.height, testSize);
    });

    testWidgets('adjusts width when useBackdropImage is true',
        (WidgetTester tester) async {
      const testSize = 300.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileHeaderWidget(
              imagePath: null,
              size: testSize,
              useBackdropImage: true,
            ),
          ),
        ),
      );

      final containerSize = tester.getSize(find.byType(Container).first);
      expect(containerSize.width, testSize * 1.26);
    });

    testWidgets('displays additional info widgets when provided',
        (WidgetTester tester) async {
      final additionalInfo = [
        const Text('Info 1'),
        const Text('Info 2'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeaderWidget(
              imagePath: null,
              additionalInfo: additionalInfo,
            ),
          ),
        ),
      );

      expect(find.text('Info 1'), findsOneWidget);
      expect(find.text('Info 2'), findsOneWidget);
    });

    testWidgets('applies correct border radius to card',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileHeaderWidget(
              imagePath: null,
            ),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      final shape = card.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(12));
    });

    testWidgets('handles null values gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileHeaderWidget(
              imagePath: null,
              title: null,
              subtitle: null,
              additionalInfo: null,
              onTap: null,
              actionButton: null,
            ),
          ),
        ),
      );

      expect(find.byType(ProfileHeaderWidget), findsOneWidget);
    });

    testWidgets('uses correct image fit for backdrop vs regular image',
        (WidgetTester tester) async {
      // Test with backdrop image
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileHeaderWidget(
              imagePath: 'https://example.com/image.jpg',
              useBackdropImage: true,
            ),
          ),
        ),
      );

      Image backdropImage = tester.widget<Image>(find.byType(Image));
      expect(backdropImage.fit, BoxFit.cover);

      // Test with regular image
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileHeaderWidget(
              imagePath: 'https://example.com/image.jpg',
              useBackdropImage: false,
            ),
          ),
        ),
      );

      Image regularImage = tester.widget<Image>(find.byType(Image));
      expect(regularImage.fit, BoxFit.contain);
    });

    // New tests to achieve 100% coverage

    testWidgets('handles image loading state', (WidgetTester tester) async {
      late BuildContext testContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              testContext = context;
              return const Scaffold(
                body: ProfileHeaderWidget(
                  imagePath: 'https://example.com/image.jpg',
                ),
              );
            },
          ),
        ),
      );

      // Find the Image widget and get its loadingBuilder
      final Image image = tester.widget<Image>(find.byType(Image));
      final loadingBuilder = image.loadingBuilder!;

      // Test loading state
      final loadingWidget = loadingBuilder(
        testContext,
        Container(),
        const ImageChunkEvent(
          expectedTotalBytes: 100,
          cumulativeBytesLoaded: 50,
        ),
      );

      // Pump the loading widget so we can find its children
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: loadingWidget,
          ),
        ),
      );

      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
        'builds placeholder with correct icon based on useBackdropImage',
        (WidgetTester tester) async {
      // Test with useBackdropImage = true
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileHeaderWidget(
              imagePath: null,
              useBackdropImage: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.movie), findsOneWidget);

      // Test with useBackdropImage = false
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileHeaderWidget(
              imagePath: null,
              useBackdropImage: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('applies gradient overlay correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileHeaderWidget(
              imagePath: 'https://example.com/image.jpg',
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ProfileHeaderWidget),
          matching: find.byType(Container).at(1),
        ),
      );

      final BoxDecoration decoration = container.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;

      expect(gradient.begin, equals(Alignment.topCenter));
      expect(gradient.end, equals(Alignment.bottomCenter));
      expect(gradient.colors.length, equals(2));
      expect(gradient.stops, equals([0.6, 1.0]));
    });
  });
}
