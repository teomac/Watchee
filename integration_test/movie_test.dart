import 'package:dima_project/services/fcm_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dima_project/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './test_helper.dart';
import 'package:provider/provider.dart';
import 'package:dima_project/theme/theme_provider.dart';
import 'package:dima_project/widgets/home_carousel.dart';
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
        ],
        child: const MyApp(initialUri: null),
      ),
    );
  }

  group('Movie Flow Tests', () {
    testWidgets('Complete movie interaction flow test',
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

      // Step 2: Verify we're on HomePage and find first movie
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Trending movies'), findsOneWidget);

      // Wait for movies to load
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Find movie in trending section
      final trendingSection = find.byType(HomeCarousel);
      expect(trendingSection, findsOneWidget);

      // Find clickable movie items within the trending section
      final movieItems = find.descendant(
        of: trendingSection,
        matching: find.byType(GestureDetector),
      );
      expect(movieItems, findsWidgets);

      // Tap the first movie in the trending section
      await tester.tap(movieItems.first);
      await Future.delayed(const Duration(seconds: 2));
      await tester.pump();

      // Step 4: Verify MoviePage elements
      // Check essential movie details are present
      expect(find.byType(SliverAppBar), findsOneWidget);
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Cast'), findsOneWidget);
      expect(find.text('Available On'), findsOneWidget);
      expect(find.text('Add your review'), findsOneWidget);
      expect(find.text('You may also like'), findsOneWidget);

      // Step 5: Add movie to liked movies
      final addButton = find.byIcon(Icons.add);
      await tester.tap(addButton);
      await tester.pump(const Duration(seconds: 2));

      // Find and tap the liked movies option
      final likedMoviesOption = find.text('Liked movies');
      expect(likedMoviesOption, findsOneWidget);

      await tester.ensureVisible(find.byKey(const Key('like_button')));
      await tester.pumpAndSettle();

      final likeButton = find.byKey(const Key('like_button'));
      await tester.tap(likeButton);
      await tester.pumpAndSettle();

      // Wait for the snackbar confirmation and modal to close
      await Future.delayed(const Duration(seconds: 1));
      await tester.tapAt(const Offset(20, 20)); // Tap outside to dismiss modal
      await tester.pumpAndSettle();

      // Step 6: Find and open first cast member profile
      // Scroll back to top to find cast section
      await tester.dragUntilVisible(
        find.text('Cast'),
        find.byType(CustomScrollView),
        const Offset(0, 500),
      );
      await tester.pumpAndSettle();

      final castMembers = find.descendant(
        of: find.byType(ListView),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(castMembers.first);
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Step 8: Navigate back to HomePage
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Step 9: Navigate to My Lists page
      await tester.tap(find.byIcon(Icons.subscriptions_outlined));
      await Future.delayed(const Duration(seconds: 3));
      await tester.pump();

      // Step 10: Open Liked Movies section
      final likedMoviesSection = find.text('Liked Movies');
      expect(likedMoviesSection, findsOneWidget);
      await tester.tap(likedMoviesSection);
      await tester.pump(const Duration(seconds: 1));

      // Step 11: Verify the movie is present in liked movies
      expect(find.byType(ListTile), findsWidgets);
      final likedMovie = find.byType(ListTile).first;

      await tester.longPress(likedMovie);
      await Future.delayed(const Duration(seconds: 2));
      await tester.pump();

      final removeOption = find.textContaining('Remove from');
      await tester.tap(removeOption);
      await tester.pump();

      // Verify removal snackbar appears
      expect(find.textContaining('removed from watchlist'), findsOneWidget);
    });
  });
}
