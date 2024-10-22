import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/pages/login_and_register/genre_selection_page.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Mock classes
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockDocumentReference extends Mock implements DocumentReference {}

class MockCollectionReference extends Mock implements CollectionReference {}

// Mock User class
class MockUser extends Mock implements User {
  @override
  final String uid;

  MockUser({required this.uid});
}

void main() {
  group('GenreSelectionPage Widget Tests', () {
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      // Set up basic mocks
      when(mockAuth.currentUser).thenReturn(MockUser(uid: 'test-uid'));
    });

    testWidgets('renders initial state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GenreSelectionPage()));

      // Verify title and instructions are present
      expect(find.text('Select Your Favorite Genres'), findsOneWidget);
      expect(find.text('Choose at least 3 genres you like'), findsOneWidget);

      // Verify continue button exists and is disabled
      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);
      expect(tester.widget<ElevatedButton>(button).enabled, isFalse);
    });

    testWidgets('enables submit button when 3 or more genres selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GenreSelectionPage()));

      // Select 3 genres
      await tester.tap(find.text('Action'));
      await tester.tap(find.text('Comedy'));
      await tester.tap(find.text('Drama'));
      await tester.pump();

      // Verify button is enabled
      final button = find.byType(ElevatedButton);
      expect(tester.widget<ElevatedButton>(button).enabled, isTrue);
    });

    testWidgets('disables submit button when less than 3 genres selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GenreSelectionPage()));

      // Select only 2 genres
      await tester.tap(find.text('Action'));
      await tester.tap(find.text('Comedy'));
      await tester.pump();

      // Verify button is disabled
      final button = find.byType(ElevatedButton);
      expect(tester.widget<ElevatedButton>(button).enabled, isFalse);
    });

    testWidgets('allows deselection of genres', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GenreSelectionPage()));

      // Select 3 genres
      await tester.tap(find.text('Action'));
      await tester.tap(find.text('Comedy'));
      await tester.tap(find.text('Drama'));
      await tester.pump();

      // Deselect one genre
      await tester.tap(find.text('Action'));
      await tester.pump();

      // Verify button is disabled after deselection
      final button = find.byType(ElevatedButton);
      expect(tester.widget<ElevatedButton>(button).enabled, isFalse);
    });

    testWidgets('shows selected state for genres', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GenreSelectionPage()));

      // Select a genre
      await tester.tap(find.text('Action'));
      await tester.pump();

      // Verify the genre chip shows selected state
      final filterChip = tester.widget<FilterChip>(
        find.ancestor(
          of: find.text('Action'),
          matching: find.byType(FilterChip),
        ),
      );
      expect(filterChip.selected, isTrue);
    });

    testWidgets('maintains selection state during rebuild',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GenreSelectionPage()));

      // Select genres
      await tester.tap(find.text('Action'));
      await tester.tap(find.text('Comedy'));
      await tester.pump();

      // Trigger a rebuild
      await tester.pumpWidget(const MaterialApp(home: GenreSelectionPage()));

      // Verify selections are maintained
      final actionChip = tester.widget<FilterChip>(
        find.ancestor(
          of: find.text('Action'),
          matching: find.byType(FilterChip),
        ),
      );
      final comedyChip = tester.widget<FilterChip>(
        find.ancestor(
          of: find.text('Comedy'),
          matching: find.byType(FilterChip),
        ),
      );

      expect(actionChip.selected, isTrue);
      expect(comedyChip.selected, isTrue);
    });
  });
}
