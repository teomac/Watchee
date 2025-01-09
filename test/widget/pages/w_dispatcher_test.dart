// ignore_for_file: deprecated_member_use

import 'package:dima_project/pages/dispatcher.dart';
import 'package:dima_project/pages/follow/follow_page.dart';
import 'package:dima_project/pages/movies/home_movies.dart';
import 'package:dima_project/pages/watchlists/my_lists.dart';
import 'package:dima_project/services/notifications_service.dart';
import 'package:dima_project/services/tmdb_api_service.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:dima_project/services/watchlist_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../mocks/w_dispatcher_test.mocks.dart';
import 'package:dima_project/services/custom_auth.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseAuth>(),
  MockSpec<FirebaseFirestore>(),
  MockSpec<UserService>(),
  MockSpec<WatchlistService>(),
  MockSpec<TmdbApiService>(),
  MockSpec<GoogleSignIn>(),
  MockSpec<CustomAuth>(),
  MockSpec<NotificationsService>()
])
void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseFirestore mockFirebaseFirestore;
  late MockUserService mockUserService;
  late MockWatchlistService mockWatchlistService;
  late MockTmdbApiService mockTmdbApiService;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockCustomAuth mockCustomAuth;
  late MockNotificationsService mockNotificationsService;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirebaseFirestore = MockFirebaseFirestore();
    mockUserService = MockUserService();
    mockWatchlistService = MockWatchlistService();
    mockTmdbApiService = MockTmdbApiService();
    mockGoogleSignIn = MockGoogleSignIn();
    mockCustomAuth = MockCustomAuth();
    mockNotificationsService = MockNotificationsService();
  });

  Widget createDispatcherWithProviders() {
    return MultiProvider(
      providers: [
        Provider<FirebaseAuth>(create: (_) => mockFirebaseAuth),
        Provider<FirebaseFirestore>(create: (_) => mockFirebaseFirestore),
        Provider<UserService>(create: (_) => mockUserService),
        Provider<WatchlistService>(create: (_) => mockWatchlistService),
        Provider<TmdbApiService>(create: (_) => mockTmdbApiService),
        Provider<GoogleSignIn>(create: (_) => mockGoogleSignIn),
        Provider<CustomAuth>(create: (_) => mockCustomAuth),
        Provider<NotificationsService>(create: (_) => mockNotificationsService),
      ],
      child: const MaterialApp(
        home: Dispatcher(),
      ),
    );
  }

  testWidgets('Dispatcher initializes with HomeMovies screen',
      (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    await tester.pumpWidget(createDispatcherWithProviders());

    expect(find.byType(HomeMovies), findsOneWidget);
    expect(find.byType(MyLists), findsNothing);
    expect(find.byType(FollowView), findsNothing);
  });

  testWidgets('Navigation bar shows all three destinations',
      (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    await tester.pumpWidget(createDispatcherWithProviders());

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('My lists'), findsOneWidget);
    expect(find.text('People'), findsOneWidget);
  });

  testWidgets('Tapping MyLists navigation item shows MyLists screen',
      (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    await tester.pumpWidget(createDispatcherWithProviders());

    await tester.tap(find.text('My lists'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeMovies), findsNothing);
    expect(find.byType(MyLists), findsOneWidget);
    expect(find.byType(FollowView), findsNothing);
  });

  testWidgets('Tapping People navigation item shows FollowView screen',
      (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    await tester.pumpWidget(createDispatcherWithProviders());

    await tester.tap(find.text('People'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeMovies), findsNothing);
    expect(find.byType(MyLists), findsNothing);
    expect(find.byType(FollowView), findsOneWidget);
  });

  testWidgets('Navigation maintains state when switching between tabs',
      (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    await tester.pumpWidget(createDispatcherWithProviders());

    // Initial state
    expect(find.byType(HomeMovies), findsOneWidget);

    // Navigate to MyLists
    await tester.tap(find.text('My lists'));
    await tester.pump();
    expect(find.byType(MyLists), findsOneWidget);

    // Navigate to FollowView
    await tester.tap(find.text('People'));
    await tester.pump();
    expect(find.byType(FollowView), findsOneWidget);

    // Navigate back to Home
    await tester.tap(find.text('Home'));
    await tester.pump();
    expect(find.byType(HomeMovies), findsOneWidget);
  });

  testWidgets('Dispatcher shows correct bottom navigation bar in phone mode',
      (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(400, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(createDispatcherWithProviders());
    await tester.pump();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);

    // Reset the window size
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
  });

  testWidgets('Navigation bar icons change when selected',
      (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    await tester.pumpWidget(createDispatcherWithProviders());
    await tester.pump();

    // Check initial state
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.home_outlined), findsNothing);

    // Navigate to My lists
    await tester.tap(find.text('My lists'));
    await tester.pump();
    expect(find.byIcon(Icons.subscriptions), findsOneWidget);
    expect(find.byIcon(Icons.subscriptions_outlined), findsNothing);

    // Navigate to People
    await tester.tap(find.text('People'));
    await tester.pump();
    expect(find.byIcon(Icons.people), findsOneWidget);
    expect(find.byIcon(Icons.people_outlined), findsNothing);
  });

  testWidgets('Navigation maintains child widget states',
      (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1280, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    await tester.pumpWidget(createDispatcherWithProviders());
    await tester.pump();

    // Navigate through all tabs multiple times to ensure state preservation
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('My lists'));
      await tester.pump();
      expect(find.byType(MyLists), findsOneWidget);

      await tester.tap(find.text('People'));
      await tester.pump();
      expect(find.byType(FollowView), findsOneWidget);

      await tester.tap(find.text('Home'));
      await tester.pump();
      expect(find.byType(HomeMovies), findsOneWidget);
    }
  });
}
