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
      // Should not throw any errors
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
  });
}
