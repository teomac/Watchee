import 'package:dima_project/services/fcm_service.dart';
import 'package:dima_project/services/notifications_service.dart';
import 'package:dima_project/services/tmdb_api_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dima_project/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './test_helper.dart';
import 'package:provider/provider.dart';
import 'package:dima_project/theme/theme_provider.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/services/watchlist_service.dart';
import 'package:dima_project/services/custom_auth.dart';
import 'package:dima_project/services/custom_google_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Test account credentials
  const String testEmail = 'fritziano@gmail.com';
  const String testPassword = 'Ciao123\$';
  const String searchUsername = 'matlai2300'; // User to search for and follow

  late FirebaseAuth auth;
  late FirebaseFirestore firestore;
  late GoogleSignIn googleSignIn;
  late UserService userService;
  late WatchlistService watchlistService;
  late CustomAuth customAuth;
  late CustomGoogleAuth customGoogleAuth;
  late FirebaseMessaging messaging;
  late FCMService fcmService;
  late NotificationsService notificationsService;
  late TmdbApiService tmdbApiService;

  setUpAll(() async {
    await TestHelper.setupFirebaseForTesting();
  });

  setUp(() async {
    auth = FirebaseAuth.instance;
    firestore = FirebaseFirestore.instance;
    googleSignIn = GoogleSignIn();
    userService = UserService(auth: auth, firestore: firestore);
    messaging = FirebaseMessaging.instance;
    watchlistService =
        WatchlistService(firestore: firestore, userService: userService);
    customAuth = CustomAuth(firebaseAuth: auth, googleSignIn: googleSignIn);
    customGoogleAuth = CustomGoogleAuth(
      auth: auth,
      firestore: firestore,
      googleSignIn: googleSignIn,
      userService: userService,
    );
    fcmService =
        FCMService(auth: auth, messaging: messaging, firestore: firestore);
    notificationsService = NotificationsService();
    tmdbApiService = TmdbApiService();
    await auth.signOut();
  });
  Widget createTestableApp() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => ThemeProvider()..loadThemeMode()),
          Provider<FirebaseAuth>.value(value: auth),
          Provider<FirebaseFirestore>.value(value: firestore),
          Provider<GoogleSignIn>.value(value: googleSignIn),
          Provider<FirebaseMessaging>.value(value: messaging),
          Provider<UserService>.value(value: userService),
          Provider<CustomAuth>.value(value: customAuth),
          Provider<CustomGoogleAuth>.value(value: customGoogleAuth),
          Provider<WatchlistService>.value(value: watchlistService),
          Provider<FCMService>.value(value: fcmService),
          Provider<NotificationsService>.value(value: notificationsService),
          Provider<TmdbApiService>.value(value: tmdbApiService),
        ],
        child: const MyApp(initialUri: null),
      ),
    );
  }

  group('Follow Flow Tests', () {
    testWidgets('Complete follow interaction flow test',
        (WidgetTester tester) async {
      // Build and render the app
      await tester.pumpWidget(createTestableApp());
      await tester.pumpAndSettle();

      // Step 1: Login
      final emailField = find.widgetWithText(TextField, 'Email');
      final passwordField = find.widgetWithText(TextField, 'Password');
      await tester.enterText(emailField, testEmail);
      await tester.enterText(passwordField, testPassword);
      final loginButton = find.text('Sign In');
      await tester.tap(loginButton);
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      //////////////////////////////////////////////////////

      // Step 2: Navigate to People page
      await tester.tap(find.byIcon(Icons.people_outlined));
      await Future.delayed(const Duration(seconds: 2));
      await tester.pump();

      expect(find.text('Following'), findsOneWidget,
          reason: 'Failed to find following tab');
      expect(find.text('Followers'), findsOneWidget,
          reason: 'Failed to find followers tab');

      // Step 3: Search for user
      await tester.tap(find.byType(TextField).first);
      await tester.enterText(find.byType(TextField).first, searchUsername);
      await Future.delayed(
          const Duration(seconds: 2)); // Wait for search results
      await tester.pump(); // First pump for the search event
      await tester.pump(); // Second pump for the UI update
      await tester
          .pumpAndSettle(); // Final pump to ensure all animations complete

      // Debug prints
      debugPrint('Current widget tree after search:');
      debugPrint('Looking for username: $searchUsername');
      find.byType(ListTile).evaluate().forEach((element) {
        final ListTile tile = element.widget as ListTile;
        if (tile.title is Text) {
          debugPrint('Found ListTile with title: ${(tile.title as Text).data}');
        }
      });

      // Try both direct and descendant find methods
      final userTile = find.descendant(
        of: find.byType(ListView),
        matching: find.textContaining(searchUsername, findRichText: true),
      );
      expect(userTile, findsOneWidget,
          reason: 'User $searchUsername not found in search results');
      await tester.tap(userTile);
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 6));

      // Step 5: Follow the user
      final followButton = find.text('Follow');
      expect(followButton, findsOneWidget);
      await tester.tap(followButton);
      await tester.pump();

      // Verify follow button is gone
      expect(find.text('Follow'), findsNothing);
      expect(find.text('Unfollow'), findsOneWidget);

      // Step 6: Verify public watchlists section exists
      expect(find.text('Public Watchlists'), findsOneWidget);

      await tester.pumpAndSettle(); // Ensure profile page is fully loaded
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Step 6: Verify public watchlists section exists
      expect(find.text('Public Watchlists'), findsOneWidget);

      // Wait for the profile page and watchlists to load
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      // Find all list tiles under the Public Watchlists section
      final watchlistsSection = find
          .ancestor(
            of: find.text('Public Watchlists'),
            matching: find.byType(Column),
          )
          .first;

      // Get the first watchlist tile
      final watchlistTile = find
          .descendant(
            of: watchlistsSection,
            matching: find.byType(ListTile),
          )
          .first;

      // Debug logging
      debugPrint('Found watchlist section: ${watchlistsSection.toString()}');
      debugPrint('Found watchlist tile: ${watchlistTile.toString()}');

      // Store the watchlist name
      final watchlistWidget = tester.widget<ListTile>(watchlistTile);
      final watchlistName = (watchlistWidget.title as Text).data!;
      debugPrint('Watchlist name: $watchlistName');

      // Tap the watchlist
      await tester.tap(watchlistTile);
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      final heartIcon = find.byIcon(Icons.favorite_border);
      if (heartIcon.evaluate().isNotEmpty) {
        await tester.tap(heartIcon);
        await Future.delayed(const Duration(seconds: 2));
        await tester.pump();
        expect(find.byIcon(Icons.favorite), findsOneWidget);
      }

      // Navigate back to user profile
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Navigate back to follow page
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.subscriptions_outlined), findsOneWidget,
          reason: 'Navigation bar not found');
      // Tap the My Lists tab and wait for navigation
      await tester.tap(find.byIcon(Icons.subscriptions_outlined));
      await Future.delayed(const Duration(seconds: 3));
      await tester.pump();

      // Wait for Firestore operations
      expect(find.text('My Lists'), findsOneWidget,
          reason: 'Failed to find My Lists title');
      //ensure that the watchlist is in the followed section
      expect(find.text('Followed Watchlists'), findsOneWidget);

      // Verify watchlist is created by finding the ListTile with the watchlist name
      expect(find.text(watchlistName), findsOneWidget);

      // Step 4: Open watchlist
      await tester.tap(find.text(watchlistName));
      await Future.delayed(const Duration(seconds: 2));

      await tester.pumpAndSettle();
      // Step 5: Verify that the watchlist is opened
      expect(find.text(watchlistName), findsWidgets);

      //come back to the user profile
      await tester.tap(find.byIcon(Icons.arrow_back));
      await Future.delayed(const Duration(seconds: 2));
      await tester.pump();

      //Come back to the follow page
      await tester.tap(find.byIcon(Icons.people_outlined));
      await Future.delayed(const Duration(seconds: 2));
      await tester.pump();

      //find the user in the follow tab and tap it
      final userListTile2 = find.widgetWithText(ListTile, searchUsername);
      expect(userListTile2, findsOneWidget);
      await tester.tap(userListTile2);
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 6));

      // Step 8: Unfollow the user
      final unfollowButton = find.text('Unfollow');
      expect(unfollowButton, findsOneWidget);
      await tester.tap(unfollowButton);
      await tester.pumpAndSettle();

      // Verify follow button is back
      expect(find.text('Follow'), findsOneWidget);
    });
  });
}
