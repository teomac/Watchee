import 'package:dima_project/models/movie_review.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/account/edit_reviews_page.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import '../../../mocks/w_edit_reviews_page_test.mocks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@GenerateMocks([UserService])
void main() {
  late MockUserService mockUserService;
  late MyUser testUser;
  late List<MovieReview> testReviews;

  setUp(() {
    mockUserService = MockUserService();

    testUser = MyUser(
      id: '1',
      username: 'testuser',
      name: 'Test User',
      email: 'test@test.com',
      favoriteGenres: [],
      following: [],
      followers: [],
      likedMovies: [],
      seenMovies: [],
      followedWatchlists: {},
    );

    testReviews = [
      MovieReview(
          userId: '1',
          id: '1',
          movieId: 1,
          rating: 4,
          text: 'Great movie!',
          title: 'Movie 1',
          username: 'testuser',
          timestamp: Timestamp.fromDate(
              DateTime(2024, 1, 15, 14, 30)) // January 15, 2024 at 14:30
          ),
      MovieReview(
          userId: '1',
          id: '2',
          movieId: 2,
          rating: 3,
          text: 'Good movie',
          title: 'Movie 2',
          username: 'testuser',
          timestamp: Timestamp.fromDate(
              DateTime(2024, 1, 15, 14, 30))) // January 15, 2024 at 14:30
    ];

    // Setup mock behavior
    when(mockUserService.getCurrentUser()).thenAnswer((_) async => testUser);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
      home: MultiProvider(
        providers: [
          Provider<UserService>(
            create: (_) => mockUserService,
          ),
        ],
        child: Scaffold(
          body: EditReviewsPage(
            user: testUser,
            userReviews: testReviews,
          ),
        ),
      ),
    );
  }

  testWidgets('EditReviewsPage displays reviews correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    // Wait for async operation to complete
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    // Verify app bar title
    expect(find.text('Edit Reviews'), findsOneWidget);

    // Verify reviews are displayed
    expect(find.text('Movie 1'), findsOneWidget);
    expect(find.text('Great movie!'), findsOneWidget);
    expect(find.text('4/5'), findsOneWidget);

    expect(find.text('Movie 2'), findsOneWidget);
    expect(find.text('Good movie'), findsOneWidget);
    expect(find.text('3/5'), findsOneWidget);

    // Verify checkboxes exist
    expect(find.byType(Checkbox), findsNWidgets(2));
  });

  testWidgets('Selecting reviews updates UI', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Initially no reviews selected
    final firstCheckbox = find.byType(Checkbox).first;
    expect(tester.widget<Checkbox>(firstCheckbox).value, false);

    // Select first review
    await tester.tap(firstCheckbox);
    await tester.pumpAndSettle();

    // Verify checkbox is checked
    expect(tester.widget<Checkbox>(firstCheckbox).value, true);
  });

  testWidgets('Delete confirmation dialog appears and works',
      (WidgetTester tester) async {
    when(mockUserService.deleteReviews(any, any)).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    // Select first review
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    // Tap delete button
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    // Verify dialog appears
    expect(find.text('Confirm deletion'), findsOneWidget);
    expect(
        find.text(
            'Are you sure you want to delete 1 review(s)?\nThis action cannot be undone.'),
        findsOneWidget);

    // Tap delete in dialog
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // Verify delete was called
    verify(mockUserService.deleteReviews(testUser.id, any)).called(1);
  });

  testWidgets('Cancel delete keeps reviews', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Select first review
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    // Tap delete button
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    // Tap cancel in dialog
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Verify reviews still exist
    expect(find.text('Movie 1'), findsOneWidget);
    expect(find.text('Movie 2'), findsOneWidget);
  });

  testWidgets('Delete error shows snackbar', (WidgetTester tester) async {
    // Setup mock to throw error
    when(mockUserService.deleteReviews(any, any))
        .thenThrow(Exception('Delete failed'));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Select and delete review
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // Verify error snackbar
    expect(
        find.text(
            'Failed to delete selected reviews: Exception: Delete failed'),
        findsOneWidget);
  });
}
