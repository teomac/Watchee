import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/widgets/my_textfield.dart';

void main() {
  group('MyTextField Widget Tests', () {
    testWidgets('MyTextField displays correctly', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MyTextField(
            controller: controller,
            title: 'Test Field',
            obscureText: false,
          ),
        ),
      ));

      expect(find.byType(MyTextField), findsOneWidget);
      expect(find.text('Test Field'), findsOneWidget);
    });

    testWidgets('MyTextField handles text input', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MyTextField(
            controller: controller,
            title: 'Test Field',
            obscureText: false,
          ),
        ),
      ));

      await tester.enterText(find.byType(TextField), 'Hello, World!');
      expect(controller.text, 'Hello, World!');
    });

    testWidgets('MyTextField obscures text when obscureText is true',
        (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MyTextField(
            controller: controller,
            title: 'Password',
            obscureText: true,
          ),
        ),
      ));

      final TextField textField =
          tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, true);
    });

    testWidgets('MyTextField displays suffix icon when provided',
        (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MyTextField(
            controller: controller,
            title: 'Test Field',
            obscureText: false,
            suffixIcon: const Icon(Icons.visibility),
          ),
        ),
      ));

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });
  });
}
