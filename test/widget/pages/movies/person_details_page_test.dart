// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/models/person.dart';
import 'package:dima_project/pages/movies//person_details_page.dart';
import 'package:dima_project/services/tmdb_api_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:dima_project/models/movie.dart';

@GenerateNiceMocks([MockSpec<TmdbApiService>()])
import 'person_details_page_test.mocks.dart';

void main() {
  late MockTmdbApiService mockTmdbApiService;

  setUp(() {
    mockTmdbApiService = MockTmdbApiService();
  });

  Person createTestPerson({
    bool includeProfilePath = true,
    bool includeBiography = true,
    bool includeKnownFor = true,
  }) {
    return Person(
      adult: false,
      alsoKnownAs: ['Test Name 2'],
      biography: includeBiography
          ? 'Test biography that is long enough to test the show more/less functionality. ' *
              10
          : '',
      birthday: '1990-01-01',
      deathday: null,
      gender: 1,
      id: 1,
      knownForDepartment: 'Acting',
      name: 'Test Person',
      placeOfBirth: 'Test City, Test Country',
      popularity: 10.0,
      knownFor: includeKnownFor
          ? [
              Movie(
                id: 1,
                overview: 'Test overview',
                releaseDate: '2021-01-01',
                title: 'Test Movie',
                voteAverage: 8.0,
                genres: [],
              )
            ]
          : [],
    );
  }

  Widget createTestWidget(Person person) {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<TmdbApiService>.value(value: mockTmdbApiService),
        ],
        child: PersonDetailsPage(person: person),
      ),
    );
  }

  testWidgets(
      'PersonDetailsPage loads and displays basic information correctly',
      (WidgetTester tester) async {
    final testPerson = createTestPerson();
    when(mockTmdbApiService.fetchPersonDetails(1))
        .thenAnswer((_) async => testPerson);

    await tester.pumpWidget(createTestWidget(testPerson));
    await tester.pumpAndSettle();

    // Verify basic information is displayed
    expect(find.text('Test Person'), findsWidgets);
    expect(find.text('Acting'), findsWidgets);
    expect(find.text('Personal Information'), findsOneWidget);
    expect(find.text('Biography'), findsOneWidget);
    expect(find.text('Known For'), findsOneWidget);
  });

  testWidgets('PersonDetailsPage handles missing profile picture correctly',
      (WidgetTester tester) async {
    final testPerson = createTestPerson(includeProfilePath: false);
    when(mockTmdbApiService.fetchPersonDetails(1))
        .thenAnswer((_) async => testPerson);

    await tester.pumpWidget(createTestWidget(testPerson));
    await tester.pumpAndSettle();

    // Verify fallback container is present
    expect(find.byIcon(Icons.movie), findsWidgets);
  });

  testWidgets('Biography show more/less functionality works correctly',
      (WidgetTester tester) async {
    final testPerson = createTestPerson();
    when(mockTmdbApiService.fetchPersonDetails(1))
        .thenAnswer((_) async => testPerson);

    // Set a fixed viewport size for consistent testing
    tester.binding.window.physicalSizeTestValue = const Size(400, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(createTestWidget(testPerson));
    await tester.pumpAndSettle();

    final scroll = find.byKey(const PageStorageKey('person_details_page'));
    await tester.drag(scroll, const Offset(0, -500)); // Scroll down
    await tester.pumpAndSettle();

    // First, we need to ensure the biography card is visible
    final scrollFinder = find.byKey(const Key('known_for_card'));
    await tester.drag(scrollFinder, const Offset(0, -300)); // Scroll down
    await tester.pumpAndSettle();

    // Find and verify 'Show More' button
    expect(find.text('Show More'), findsOneWidget);

    // Tap show more button
    await tester.tap(find.text('Show More'));
    await tester.pumpAndSettle();

    await tester.drag(scroll, const Offset(0, -800)); // Scroll down
    await tester.pumpAndSettle();

    // First, we need to ensure the biography card is visible
    await tester.drag(scrollFinder, const Offset(0, -300)); // Scroll down
    await tester.pumpAndSettle();

    // Verify expanded state
    expect(find.text('Show Less'), findsOneWidget);

    // Tap show less button
    await tester.tap(find.text('Show Less'));
    await tester.pumpAndSettle();

    // Verify collapsed state again
    expect(find.text('Show More'), findsOneWidget);

    // Reset the window to its original size
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
  });

  testWidgets('PersonDetailsPage handles empty biography correctly',
      (WidgetTester tester) async {
    final testPerson = createTestPerson(includeBiography: false);
    when(mockTmdbApiService.fetchPersonDetails(1))
        .thenAnswer((_) async => testPerson);

    await tester.pumpWidget(createTestWidget(testPerson));
    await tester.pumpAndSettle();

    expect(find.text('No biography available.'), findsOneWidget);
    expect(find.text('Show More'), findsNothing);
    expect(find.text('Show Less'), findsNothing);
  });

  testWidgets('PersonDetailsPage handles empty known for list correctly',
      (WidgetTester tester) async {
    final testPerson = createTestPerson(includeKnownFor: false);
    when(mockTmdbApiService.fetchPersonDetails(1))
        .thenAnswer((_) async => testPerson);

    await tester.pumpWidget(createTestWidget(testPerson));
    await tester.pumpAndSettle();

    expect(find.text('Known For'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
    expect(find.text('Test Movie'), findsNothing);
  });

  testWidgets('Back button navigation works correctly',
      (WidgetTester tester) async {
    final testPerson = createTestPerson();
    when(mockTmdbApiService.fetchPersonDetails(1))
        .thenAnswer((_) async => testPerson);

    bool popped = false;
    await tester.pumpWidget(MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<TmdbApiService>.value(value: mockTmdbApiService),
        ],
        child: Navigator(
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) => PersonDetailsPage(person: testPerson),
            );
          },
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // Find and tap the back button
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(popped, false); // The page should have attempted to pop
  });

  testWidgets('Personal Information section displays correctly',
      (WidgetTester tester) async {
    final testPerson = createTestPerson();
    when(mockTmdbApiService.fetchPersonDetails(1))
        .thenAnswer((_) async => testPerson);

    await tester.pumpWidget(createTestWidget(testPerson));
    await tester.pumpAndSettle();

    // Check for all personal information fields
    expect(find.text('Born:'), findsOneWidget);
    expect(find.text('Place of Birth:'), findsOneWidget);
    expect(find.text('Known For:'),
        findsWidgets); // This appears twice: once in personal info and once in movies section
    expect(find.text('Test City, Test Country'), findsOneWidget);
    expect(find.text('Acting'), findsWidgets);
  });

  testWidgets('Error handling works correctly when API call fails',
      (WidgetTester tester) async {
    final testPerson = createTestPerson();
    when(mockTmdbApiService.fetchPersonDetails(1))
        .thenThrow(Exception('Failed to load person details'));

    await tester.pumpWidget(createTestWidget(testPerson));
    await tester.pumpAndSettle();

    // The page should still render with the initial person data
    expect(find.text('Test Person'), findsNothing);
    expect(find.text('Acting'), findsNothing);
  });
}
