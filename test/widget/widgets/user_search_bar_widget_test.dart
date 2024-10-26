import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:dima_project/widgets/user_search_bar_widget.dart';
import 'package:dima_project/pages/follow/follow_page.dart';
import 'dart:async';

class MockFollowBloc extends Mock implements FollowBloc {
  final _stateController = StreamController<FollowState>.broadcast();

  @override
  Stream<FollowState> get stream => _stateController.stream;

  @override
  FollowState get state => FollowInitial();

  @override
  void add(FollowEvent event) {}

  @override
  Future<void> close() async {
    await _stateController.close();
  }
}

void main() {
  late MockFollowBloc mockFollowBloc;
  late ThemeData mockTheme;

  setUp(() {
    mockFollowBloc = MockFollowBloc();
    mockTheme = ThemeData.light();
  });

  Widget createWidgetUnderTest({
    required bool isDarkMode,
    required Function(bool) onExpandChanged,
    required Function(String) onSearchChanged,
  }) {
    return MaterialApp(
      home: BlocProvider<FollowBloc>.value(
        value: mockFollowBloc,
        child: Scaffold(
          body: SearchBarWidget(
            theme: mockTheme,
            isDarkMode: isDarkMode,
            onExpandChanged: onExpandChanged,
            onSearchChanged: onSearchChanged,
          ),
        ),
      ),
    );
  }

  group('SearchBarWidget', () {
    testWidgets('should render correctly in initial state',
        (WidgetTester tester) async {
      bool expandedState = false;
      String searchText = '';

      await tester.pumpWidget(createWidgetUnderTest(
        isDarkMode: false,
        onExpandChanged: (bool expanded) => expandedState = expanded,
        onSearchChanged: (String text) => searchText = text,
      ));

      // Verify initial state
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);
      expect(expandedState, false);
      expect(searchText, '');
    });

    testWidgets('should expand when focused', (WidgetTester tester) async {
      bool expandedState = false;

      await tester.pumpWidget(createWidgetUnderTest(
        isDarkMode: false,
        onExpandChanged: (bool expanded) => expandedState = expanded,
        onSearchChanged: (String text) {},
      ));

      // Tap the search field to focus it
      await tester.tap(find.byType(TextField));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(expandedState, true);
    });

    testWidgets('should show close icon when expanded',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        isDarkMode: false,
        onExpandChanged: (bool expanded) {},
        onSearchChanged: (String text) {},
      ));

      // Enter text to expand the search bar
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should clear text and collapse when close button is pressed',
        (WidgetTester tester) async {
      bool expandedState = true;

      await tester.pumpWidget(createWidgetUnderTest(
        isDarkMode: false,
        onExpandChanged: (bool expanded) => expandedState = expanded,
        onSearchChanged: (String text) {},
      ));

      // Enter text to show the close button
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap the close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify the text is cleared and the search bar is collapsed
      expect(find.text('test'), findsNothing);
      expect(expandedState, false);
    });

    testWidgets('should trigger search event when text changes',
        (WidgetTester tester) async {
      String searchedText = '';

      await tester.pumpWidget(createWidgetUnderTest(
        isDarkMode: false,
        onExpandChanged: (bool expanded) {},
        onSearchChanged: (String text) => searchedText = text,
      ));

      // Enter search text
      const testText = 'test';
      await tester.enterText(find.byType(TextField), testText);
      await tester.pump();

      // Verify that the search event was handled
      expect(searchedText, equals(testText));
    });

    testWidgets('should apply correct theme colors',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        isDarkMode: true,
        onExpandChanged: (bool expanded) {},
        onSearchChanged: (String text) {},
      ));

      final TextField textField =
          tester.widget<TextField>(find.byType(TextField));
      final InputDecoration decoration = textField.decoration!;

      expect(decoration.border, isA<OutlineInputBorder>());
      expect(decoration.filled, true);
      expect(decoration.hintText, 'Search users...');
    });
  });

  tearDown(() {
    mockFollowBloc.close();
  });
}
