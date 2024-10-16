import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/widgets/custom_submit_button.dart';

void main() {
  testWidgets('CustomSubmitButton displays correct text',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomSubmitButton(
            text: 'Test Button',
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('Test Button'), findsOneWidget);
  });

  testWidgets('CustomSubmitButton calls onPressed when tapped',
      (WidgetTester tester) async {
    bool wasTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomSubmitButton(
            text: 'Test Button',
            onPressed: () {
              wasTapped = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    expect(wasTapped, isTrue);
  });

  testWidgets('CustomSubmitButton uses custom colors',
      (WidgetTester tester) async {
    const Color testBackgroundColor = Colors.red;
    const Color testForegroundColor = Colors.white;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomSubmitButton(
            text: 'Test Button',
            onPressed: () {},
            backgroundColor: testBackgroundColor,
            foregroundColor: testForegroundColor,
          ),
        ),
      ),
    );

    final ElevatedButton button =
        tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    final ButtonStyle? style = button.style;

    expect(style?.backgroundColor?.resolve({}), equals(testBackgroundColor));
    expect(style?.foregroundColor?.resolve({}), equals(testForegroundColor));
  });

  testWidgets('CustomSubmitButton uses custom dimensions',
      (WidgetTester tester) async {
    const double testWidth = 200;
    const double testHeight = 50;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomSubmitButton(
            text: 'Test Button',
            onPressed: () {},
            width: testWidth,
            height: testHeight,
          ),
        ),
      ),
    );

    final Size buttonSize = tester.getSize(find.byType(ElevatedButton));
    expect(buttonSize.width, equals(testWidth));
    expect(buttonSize.height, equals(testHeight));
  });
}
