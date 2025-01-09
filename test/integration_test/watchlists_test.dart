import 'package:dima_project/services/fcm_service.dart';
import 'package:dima_project/services/notifications_service.dart';
import 'package:dima_project/services/tmdb_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dima_project/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'test_helper.dart';
import 'package:provider/provider.dart';
import 'package:dima_project/theme/theme_provider.dart';
import 'package:dima_project/widgets/movie_search_bar_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:dima_project/services/watchlist_service.dart';
import 'package:dima_project/services/custom_auth.dart';
import 'package:dima_project/services/custom_google_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Test account credentials
  const String testEmail = 'fritziano@gmail.com';
  const String testPassword = 'Ciao123\$';
  const String testWatchlistName = 'My Test Watchlist';
  const String testMovieTitle = 'Coco';

  setUpAll(() async {
    await TestHelper.setupFirebaseForTesting();
  });

  setUp(() async {
    await FirebaseAuth.instance.signOut();
  });

  Widget createTestableApp() {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final googleSignIn = GoogleSignIn();
    final userService = UserService(auth: auth, firestore: firestore);
    final messaging = FirebaseMessaging.instance;
    final watchlistService = WatchlistService(
      firestore: firestore,
      userService: userService,
    );
    final customAuth =
        CustomAuth(firebaseAuth: auth, googleSignIn: googleSignIn);
    final customGoogleAuth = CustomGoogleAuth(
      auth: auth,
      firestore: firestore,
      googleSignIn: googleSignIn,
      userService: userService,
    );
    final fcm =
        FCMService(messaging: messaging, auth: auth, firestore: firestore);
    final notificationsService = NotificationsService();
    final tmdbApiService = TmdbApiService();

    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ThemeProvider()..loadThemeMode(),
          ),
          Provider<FirebaseAuth>.value(value: auth),
          Provider<FirebaseFirestore>.value(value: firestore),
          Provider<GoogleSignIn>.value(value: googleSignIn),
          Provider<FirebaseMessaging>.value(value: messaging),
          Provider<UserService>.value(value: userService),
          Provider<CustomAuth>.value(value: customAuth),
          Provider<CustomGoogleAuth>.value(value: customGoogleAuth),
          Provider<WatchlistService>.value(value: watchlistService),
          Provider<FCMService>.value(value: fcm),
          Provider<NotificationsService>.value(value: notificationsService),
          Provider<TmdbApiService>.value(value: tmdbApiService),
        ],
        child: const MyApp(initialUri: null),
      ),
    );
  }

  group('Watchlist Tests', () {
    testWidgets('Complete watchlist flow test', (WidgetTester tester) async {
      // Build and render the app
      await tester.pumpWidget(createTestableApp());
      await tester.pumpAndSettle();

      //Login
      final emailField = find.widgetWithText(TextField, 'Email');
      final passwordField = find.widgetWithText(TextField, 'Password');
      await tester.enterText(emailField, testEmail);
      await tester.enterText(passwordField, testPassword);
      final loginButton = find.text('Sign In');
      await tester.tap(loginButton);
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      /////////////////////////////////////////////

      // Navigate to My lists page
      // First, ensure we're on the home screen
      expect(find.byIcon(Icons.subscriptions_outlined), findsOneWidget,
          reason: 'Navigation bar not found');
      // Tap the My Lists tab and wait for navigation
      await tester.tap(find.byIcon(Icons.subscriptions_outlined));
      await Future.delayed(const Duration(seconds: 3));
      await tester.pump();

      // Wait for Firestore operations
      expect(find.text('My Lists'), findsOneWidget,
          reason: 'Failed to find My Lists title');

      expect(
        find.text('Press the + button to create your first watchlist'),
        findsOneWidget,
        reason: 'Empty state message not found',
      );

      //Create new watchlist using FAB

      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget, reason: 'FAB not found');

      final fabWidget = tester.widget<FloatingActionButton>(fab);
      expect(fabWidget.onPressed, isNotNull, reason: 'FAB is not tappable');

      await tester.tap(fab);
      await tester.pump();

      // Fill watchlist name in dialog
      final nameField = find.widgetWithText(TextFormField, 'Watchlist Name');
      await tester.enterText(nameField, testWatchlistName);
      await tester.pump();

      // Tap create button in dialog
      final createButton = find.widgetWithText(ElevatedButton, 'Create');
      await tester.tap(createButton);
      await Future.delayed(const Duration(seconds: 3));

      await tester.pump();

      // Verify watchlist is created by finding the ListTile with the watchlist name
      expect(find.text(testWatchlistName), findsOneWidget);

      // Open watchlist
      await tester.tap(find.text(testWatchlistName));
      await Future.delayed(const Duration(seconds: 2));

      await tester.pump();

      // Find and tap the "Add a movie" button using button with icon
      final addMovieButton = find.byKey(const Key('add_movie_button'));

      expect(addMovieButton, findsOneWidget,
          reason: 'Add a movie button not found');
      await tester.tap(addMovieButton);
      await Future.delayed(const Duration(seconds: 2));
      await tester.pump();

      // Search for movie using MovieSearchBarWidget
      final searchField = find.byType(MovieSearchBarWidget);
      expect(searchField, findsOneWidget);
      await tester.enterText(
          find.descendant(
            of: searchField,
            matching: find.byType(TextField),
          ),
          testMovieTitle);
      await Future.delayed(
          const Duration(seconds: 2)); // Wait for search results
      await tester.pumpAndSettle();

      // Tap add button on the movie result
      final movieAddButton = find.byIcon(Icons.add);
      await tester.tap(movieAddButton.first);
      await tester.pumpAndSettle();

      // Verify success snackbar appears
      expect(find.text('Successfully added to watchlist'), findsOneWidget);

      // Go back to watchlist
      final backButton = find.byIcon(Icons.arrow_back);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Verify movie is added to the watchlist
      expect(find.text(testMovieTitle), findsOneWidget);

      await Future.delayed(const Duration(seconds: 5));

      // Remove movie through long press
      await tester.longPress(find.text(testMovieTitle));
      await Future.delayed(const Duration(seconds: 2));
      await tester.pump();

      final removeOption = find.text('Remove from $testWatchlistName');
      await tester.tap(removeOption);
      await tester.pump();

      // Verify removal snackbar appears
      expect(find.textContaining('removed from watchlist'), findsOneWidget);

      // Go back to My Lists page
      await tester.tap(backButton);

      await tester.pump(const Duration(seconds: 2));

      // Delete watchlist
      // Long press on the watchlist to delete it
      await tester.longPress(find.text(testWatchlistName));
      await tester.pump(const Duration(seconds: 2));

      final deleteOption = find.text('Delete');
      await tester.tap(deleteOption);
      await tester.pump(const Duration(seconds: 2));

      // Confirm deletion
      final confirmDelete = find.text('Delete');
      await tester.tap(confirmDelete);
      await tester.pump(const Duration(seconds: 2));

      // Verify watchlist is deleted
      expect(find.text('Press the + button to create your first watchlist'),
          findsOneWidget);
    });
  });
}
